import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/data/pagy_meta.dart';
import '../../organization/data/organizations_api.dart';
import '../domain/project_site_models.dart';

class ProjectSitesApiException implements Exception {
  ProjectSitesApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ProjectSitesPage {
  const ProjectSitesPage({required this.data, required this.meta});

  final List<ProjectSite> data;
  final PagyMeta meta;
}

class ProjectSitesApi {
  ProjectSitesApi(this._dio);

  final Dio _dio;

  /// Fetches one page (`GET /project_sites`).
  Future<ProjectSitesPage> listProjectSites({
    int page = 1,
    int items = 50,
  }) async {
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.get<Map<String, dynamic>>(
        '/project_sites',
        queryParameters: <String, dynamic>{'page': page, 'items': items},
      );
      final List<ProjectSite> out = <ProjectSite>[];
      final Object? data = res.data?['data'];
      if (data is List<dynamic>) {
        for (final Object? item in data) {
          if (item is Map<String, dynamic>) {
            out.add(ProjectSite.fromJson(item));
          }
        }
      }
      final Object? metaRaw = res.data?['meta'];
      final PagyMeta meta = metaRaw is Map<String, dynamic>
          ? PagyMeta.fromJson(metaRaw)
          : const PagyMeta(page: 1, items: 0, count: 0, pages: 1);
      return ProjectSitesPage(data: out, meta: meta);
    } on DioException catch (e) {
      throw ProjectSitesApiException(
        OrganizationsApi.userMessageFromDio(e) ??
            'Could not load project sites',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Loads every page (max [items] per request, cap 100).
  ///
  /// Stops when a page returns fewer than [items] rows or is empty, so a bad
  /// or missing `meta.pages` value cannot truncate the combined list.
  Future<List<ProjectSite>> listAllProjectSites({int itemsPerPage = 100}) async {
    final int items = itemsPerPage.clamp(1, 100);
    final List<ProjectSite> all = <ProjectSite>[];
    int page = 1;
    while (true) {
      final ProjectSitesPage chunk =
          await listProjectSites(page: page, items: items);
      if (chunk.data.isEmpty) {
        break;
      }
      all.addAll(chunk.data);
      if (chunk.data.length < items) {
        break;
      }
      page++;
    }
    return all;
  }

  Future<ProjectSite> getProjectSite(String id) async {
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.get<Map<String, dynamic>>('/project_sites/$id');
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ProjectSitesApiException('Invalid project site response');
      }
      return ProjectSite.fromJson(data);
    } on DioException catch (e) {
      throw ProjectSitesApiException(
        OrganizationsApi.userMessageFromDio(e) ??
            'Could not load project site',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// [forSelf] sets `for_self: true`. Otherwise send [contractee] map (email required when creating new user).
  ///
  /// When [contracteeAvatarBytes] is set, uses `multipart/form-data` so Rails can attach
  /// **`project_site[contractee][avatar]`** (see KaamSathi_web/docs/flutter_app.md §7–8).
  Future<ProjectSite> createProjectSite({
    required String name,
    required bool forSelf,
    Map<String, dynamic>? contractee,
    String? addressString,
    Map<String, dynamic>? payScheduleOverride,
    Uint8List? contracteeAvatarBytes,
  }) async {
    final String? addressTrimmed = addressString?.trim();
    final bool useMultipart = !forSelf &&
        contractee != null &&
        contracteeAvatarBytes != null &&
        contracteeAvatarBytes.isNotEmpty;

    if (useMultipart) {
      return _createProjectSiteMultipart(
        name: name,
        contractee: contractee,
        addressTrimmed: addressTrimmed,
        payScheduleOverride: payScheduleOverride,
        contracteeAvatarBytes: contracteeAvatarBytes,
      );
    }

    final Map<String, dynamic> body = <String, dynamic>{
      'project_site': <String, dynamic>{
        'name': name,
        if (forSelf) 'for_self': true,
        if (!forSelf && contractee != null) 'contractee': contractee,
        if (addressTrimmed != null && addressTrimmed.isNotEmpty)
          'address': addressTrimmed,
        if (payScheduleOverride case final Map<String, dynamic> ps) 'pay_schedule_override': ps,
      },
    };
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.post<Map<String, dynamic>>('/project_sites', data: body);
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ProjectSitesApiException('Invalid create response');
      }
      return ProjectSite.fromJson(data);
    } on DioException catch (e) {
      throw ProjectSitesApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not create site',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ProjectSite> _createProjectSiteMultipart({
    required String name,
    required Map<String, dynamic> contractee,
    String? addressTrimmed,
    Map<String, dynamic>? payScheduleOverride,
    required Uint8List contracteeAvatarBytes,
  }) async {
    if (payScheduleOverride != null) {
      throw ProjectSitesApiException(
        'Creating a site with both pay_schedule_override and a contractee avatar '
        'is not supported in the client yet.',
      );
    }
    final Map<String, dynamic> fields = <String, dynamic>{
      'project_site[name]': name,
      'project_site[contractee][avatar]': MultipartFile.fromBytes(
        contracteeAvatarBytes,
        filename: 'avatar.jpg',
      ),
    };
    if (addressTrimmed != null && addressTrimmed.isNotEmpty) {
      fields['project_site[address]'] = addressTrimmed;
    }
    contractee.forEach((String key, dynamic value) {
      if (value == null) {
        return;
      }
      final String s = value.toString();
      if (s.isEmpty) {
        return;
      }
      fields['project_site[contractee][$key]'] = s;
    });
    try {
      final Response<Map<String, dynamic>> res = await _dio.post<Map<String, dynamic>>(
        '/project_sites',
        data: FormData.fromMap(fields),
      );
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ProjectSitesApiException('Invalid create response');
      }
      return ProjectSite.fromJson(data);
    } on DioException catch (e) {
      throw ProjectSitesApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not create site',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ProjectSite> updateProjectSite(
    String id, {
    String? name,
    String? addressString,
    String? contracteeId,
    Map<String, dynamic>? payScheduleOverride,
  }) async {
    final Map<String, dynamic> site = <String, dynamic>{};
    if (name != null) {
      site['name'] = name;
    }
    if (addressString != null) {
      site['address'] = addressString.trim().isEmpty ? '' : addressString.trim();
    }
    if (contracteeId != null) {
      site['contractee_id'] = contracteeId;
    }
    if (payScheduleOverride != null) {
      site['pay_schedule_override'] = payScheduleOverride;
    }
    final Map<String, dynamic> body = <String, dynamic>{'project_site': site};
    try {
      final Response<Map<String, dynamic>> res = await _dio
          .patch<Map<String, dynamic>>('/project_sites/$id', data: body);
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ProjectSitesApiException('Invalid update response');
      }
      return ProjectSite.fromJson(data);
    } on DioException catch (e) {
      throw ProjectSitesApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not update site',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteProjectSite(String id) async {
    try {
      await _dio.delete<void>('/project_sites/$id');
    } on DioException catch (e) {
      throw ProjectSitesApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not delete site',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
