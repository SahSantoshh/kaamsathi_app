import 'package:dio/dio.dart';

import '../../../core/data/pagy_meta.dart';
import '../../organization/data/organizations_api.dart';
import '../domain/worker_models.dart';

class WorkersApiException implements Exception {
  WorkersApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class WorkersPage {
  const WorkersPage({required this.data, required this.meta});

  final List<Worker> data;
  final PagyMeta meta;
}

/// One row from `GET /workers/search` after resolving **User** by phone and/or email.
class WorkerSearchMatch {
  const WorkerSearchMatch({
    required this.userId,
    this.email,
    this.worker,
  });

  final String userId;
  final String? email;
  final Worker? worker;

  static WorkerSearchMatch fromJson(Map<String, dynamic> json) {
    final Object? data = json['data'];
    Worker? worker;
    if (data is Map<String, dynamic>) {
      worker = Worker.fromJson(data);
    }
    final String? uid = json['user_id'] as String?;
    return WorkerSearchMatch(
      userId: uid ?? '',
      email: json['email'] as String?,
      worker: worker,
    );
  }
}

class WorkerSearchOutcome {
  const WorkerSearchOutcome({required this.matches});

  final List<WorkerSearchMatch> matches;

  bool get isEmpty => matches.isEmpty;
}

class WorkersApi {
  WorkersApi(this._dio);

  final Dio _dio;

  Future<WorkersPage> listWorkers({
    int page = 1,
    int items = 50,
  }) async {
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.get<Map<String, dynamic>>(
        '/workers',
        queryParameters: <String, dynamic>{'page': page, 'items': items},
      );
      final List<Worker> out = <Worker>[];
      final Object? data = res.data?['data'];
      if (data is List<dynamic>) {
        for (final Object? item in data) {
          if (item is Map<String, dynamic>) {
            out.add(Worker.fromJson(item));
          }
        }
      }
      final Object? metaRaw = res.data?['meta'];
      final PagyMeta meta = metaRaw is Map<String, dynamic>
          ? PagyMeta.fromJson(metaRaw)
          : const PagyMeta(page: 1, items: 0, count: 0, pages: 1);
      return WorkersPage(data: out, meta: meta);
    } on DioException catch (e) {
      throw WorkersApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not load workers',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Worker>> listAllWorkers({int itemsPerPage = 100}) async {
    final int items = itemsPerPage.clamp(1, 100);
    final List<Worker> all = <Worker>[];
    int page = 1;
    int pages = 1;
    do {
      final WorkersPage chunk = await listWorkers(page: page, items: items);
      all.addAll(chunk.data);
      pages = chunk.meta.pages;
      page++;
    } while (page <= pages);
    return all;
  }

  Future<Worker> getWorker(String id) async {
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.get<Map<String, dynamic>>('/workers/$id');
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw WorkersApiException('Invalid worker response');
      }
      return Worker.fromJson(data);
    } on DioException catch (e) {
      throw WorkersApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not load worker',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<WorkerSearchOutcome> searchWorker({
    String? phoneE164,
    String? email,
  }) async {
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.get<Map<String, dynamic>>(
        '/workers/search',
        queryParameters: <String, dynamic>{
          if (phoneE164 != null && phoneE164.isNotEmpty) 'phone_e164': phoneE164,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );
      final Object? rawMatches = res.data?['matches'];
      final List<WorkerSearchMatch> matches = <WorkerSearchMatch>[];
      if (rawMatches is List<dynamic>) {
        for (final Object? item in rawMatches) {
          if (item is Map<String, dynamic>) {
            matches.add(WorkerSearchMatch.fromJson(item));
          }
        }
      }
      if (matches.isEmpty) {
        final Object? legacyData = res.data?['data'];
        final String? legacyUserId = res.data?['user_id'] as String?;
        Worker? legacyWorker;
        if (legacyData is Map<String, dynamic>) {
          legacyWorker = Worker.fromJson(legacyData);
        }
        if (legacyUserId != null || legacyWorker != null) {
          matches.add(
            WorkerSearchMatch(
              userId: legacyUserId ?? '',
              email: null,
              worker: legacyWorker,
            ),
          );
        }
      }
      return WorkerSearchOutcome(matches: matches);
    } on DioException catch (e) {
      throw WorkersApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not search workers',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Links an existing [worker] row to this org (root `worker_id`).
  Future<Worker> linkExistingWorker(
    String workerId, {
    Map<String, dynamic>? engagement,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{'worker_id': workerId};
    if (engagement != null) {
      body['engagement'] = engagement;
    }
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.post<Map<String, dynamic>>('/workers', data: body);
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw WorkersApiException('Invalid link worker response');
      }
      return Worker.fromJson(data);
    } on DioException catch (e) {
      throw WorkersApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not add worker',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Creates a new worker + engagement (`POST /workers` with nested `worker`).
  Future<Worker> createWorker({
    required Map<String, dynamic> worker,
    Map<String, dynamic>? engagement,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{'worker': worker};
    if (engagement != null) {
      body['engagement'] = engagement;
    }
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.post<Map<String, dynamic>>('/workers', data: body);
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw WorkersApiException('Invalid create worker response');
      }
      return Worker.fromJson(data);
    } on DioException catch (e) {
      throw WorkersApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not create worker',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Worker> updateWorker(
    String id, {
    required Map<String, dynamic> workerPatch,
    Map<String, dynamic>? engagementPatch,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{'worker': workerPatch};
    if (engagementPatch != null) {
      body['engagement'] = engagementPatch;
    }
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.patch<Map<String, dynamic>>('/workers/$id', data: body);
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw WorkersApiException('Invalid update worker response');
      }
      return Worker.fromJson(data);
    } on DioException catch (e) {
      throw WorkersApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not update worker',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteWorker(String id) async {
    try {
      await _dio.delete<void>('/workers/$id');
    } on DioException catch (e) {
      throw WorkersApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not remove worker',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
