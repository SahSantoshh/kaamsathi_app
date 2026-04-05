import 'package:dio/dio.dart';

import '../../../core/data/pagy_meta.dart';
import '../../organization/data/organizations_api.dart';
import '../domain/engagement_models.dart';

class EngagementsApiException implements Exception {
  EngagementsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class EngagementsPage {
  const EngagementsPage({required this.data, required this.meta});

  final List<OrgEngagement> data;
  final PagyMeta meta;
}

class EngagementsApi {
  EngagementsApi(this._dio);

  final Dio _dio;

  Future<EngagementsPage> listEngagements({
    int page = 1,
    int items = 50,
    String? status,
  }) async {
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.get<Map<String, dynamic>>(
        '/engagements',
        queryParameters: <String, dynamic>{
          'page': page,
          'items': items,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      final List<OrgEngagement> out = <OrgEngagement>[];
      final Object? data = res.data?['data'];
      if (data is List<dynamic>) {
        for (final Object? item in data) {
          if (item is Map<String, dynamic>) {
            out.add(OrgEngagement.fromJson(item));
          }
        }
      }
      final Object? metaRaw = res.data?['meta'];
      final PagyMeta meta = metaRaw is Map<String, dynamic>
          ? PagyMeta.fromJson(metaRaw)
          : const PagyMeta(page: 1, items: 0, count: 0, pages: 1);
      return EngagementsPage(data: out, meta: meta);
    } on DioException catch (e) {
      throw EngagementsApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not load engagements',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<OrgEngagement>> listAllEngagements({
    int itemsPerPage = 100,
    String? status,
  }) async {
    final int items = itemsPerPage.clamp(1, 100);
    final List<OrgEngagement> all = <OrgEngagement>[];
    int page = 1;
    int pages = 1;
    do {
      final EngagementsPage chunk =
          await listEngagements(page: page, items: items, status: status);
      all.addAll(chunk.data);
      pages = chunk.meta.pages;
      page++;
    } while (page <= pages);
    return all;
  }

  Future<OrgEngagement> getEngagement(String id) async {
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.get<Map<String, dynamic>>('/engagements/$id');
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw EngagementsApiException('Invalid engagement response');
      }
      return OrgEngagement.fromJson(data);
    } on DioException catch (e) {
      throw EngagementsApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not load engagement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<OrgEngagement> updateEngagement(
    String id,
    Map<String, dynamic> engagement,
  ) async {
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.patch<Map<String, dynamic>>(
        '/engagements/$id',
        data: <String, dynamic>{'engagement': engagement},
      );
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw EngagementsApiException('Invalid engagement update response');
      }
      return OrgEngagement.fromJson(data);
    } on DioException catch (e) {
      throw EngagementsApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not update engagement',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
