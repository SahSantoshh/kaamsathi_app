import 'package:dio/dio.dart';

/// Maps API problem payloads (§11).
String userMessageFromProblem(Object? body, {required String fallback}) {
  if (body is! Map<String, dynamic>) {
    return fallback;
  }
  final Object? msg = body['message'];
  String base = fallback;
  if (msg is String && msg.trim().isNotEmpty) {
    base = msg.trim();
  } else {
    final Object? err = body['error'];
    if (err is String) {
      base = err;
    }
  }
  final Object? errs = body['errors'];
  if (errs is List<dynamic>) {
    final List<String> lines = <String>[];
    for (final Object? x in errs) {
      if (x is String && x.isNotEmpty) {
        lines.add(x);
      }
    }
    if (lines.isNotEmpty) {
      return '$base\n${lines.join('\n')}';
    }
  }
  return base;
}

/// Product default for `organizations.pay_schedule` (JSONB) until payroll reads it.
abstract final class OrganizationPayScheduleDefaults {
  static const Map<String, dynamic> v1 = <String, dynamic>{
    'frequency': 'monthly',
    'anchor_day': 1,
  };

  static const int v1AnchorDay = 1;
}

class OrganizationsApiException implements Exception {
  OrganizationsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class OrganizationEntity {
  OrganizationEntity({
    required this.id,
    required this.name,
    required this.raw,
    this.organizationType,
    this.addressLine1,
    this.city,
    this.region,
    this.postalCode,
    this.countryCode,
    this.addressSingleLine,
  });

  final String id;
  final String name;
  final String? organizationType;
  final String? addressLine1;
  final String? city;
  final String? region;
  final String? postalCode;
  final String? countryCode;
  final String? addressSingleLine;
  final Map<String, dynamic> raw;

  /// Merged view of [raw]`['pay_schedule']`; falls back to DB/rails default shape.
  Map<String, dynamic> get payScheduleMap {
    final Object? ps = raw['pay_schedule'];
    if (ps is Map<String, dynamic>) {
      return Map<String, dynamic>.from(ps);
    }
    if (ps is Map) {
      return ps.map((Object? k, Object? v) => MapEntry(k.toString(), v));
    }
    return Map<String, dynamic>.from(OrganizationPayScheduleDefaults.v1);
  }

  String payScheduleFrequencyLabel() {
    final Object? f = payScheduleMap['frequency'];
    final String s = f is String ? f : 'monthly';
    return s.isEmpty ? 'monthly' : s;
  }

  int payScheduleAnchorDay() {
    final Object? v = payScheduleMap['anchor_day'];
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.toInt();
    }
    return OrganizationPayScheduleDefaults.v1AnchorDay;
  }

  String? get verificationStatus => raw['verification_status'] as String?;

  DateTime? get createdAt {
    final Object? c = raw['created_at'];
    if (c is String) {
      return DateTime.tryParse(c);
    }
    return null;
  }

  static OrganizationEntity fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? addr;
    final Object? a = json['address'];
    if (a is Map<String, dynamic>) {
      addr = a;
    }
    return OrganizationEntity(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim() ?? '',
      organizationType: json['organization_type'] as String?,
      addressLine1: addr?['line1'] as String?,
      city: addr?['city'] as String?,
      region: addr?['region'] as String?,
      postalCode: addr?['postal_code'] as String?,
      countryCode: addr?['country_code'] as String?,
      addressSingleLine:
          addr?['single_line'] as String? ?? json['address'] as String?,
      raw: json,
    );
  }
}

class OrganizationsApi {
  OrganizationsApi(this._dio);

  final Dio _dio;

  Future<List<OrganizationEntity>> listOrganizations() async {
    try {
      final Response<Map<String, dynamic>> res = await _dio
          .get<Map<String, dynamic>>('/organizations');
      final List<OrganizationEntity> out = <OrganizationEntity>[];
      final Object? data = res.data?['data'];
      if (data is List<dynamic>) {
        for (final Object? item in data) {
          if (item is Map<String, dynamic>) {
            out.add(OrganizationEntity.fromJson(item));
          }
        }
      }
      return out;
    } on DioException catch (e) {
      throw OrganizationsApiException(
        userMessageFromDio(e) ?? 'Could not load organizations',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<OrganizationEntity> getOrganization(String id) async {
    try {
      final Response<Map<String, dynamic>> res = await _dio
          .get<Map<String, dynamic>>('/organizations/$id');
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw OrganizationsApiException('Invalid organization response');
      }
      return OrganizationEntity.fromJson(data);
    } on DioException catch (e) {
      throw OrganizationsApiException(
        userMessageFromDio(e) ?? 'Could not load organization',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<OrganizationEntity> createOrganization({
    required String name,
    String? organizationType,
    String? addressString,
    Map<String, dynamic>? addressAttributes,
    Map<String, dynamic>? paySchedule,
  }) async {
    final Map<String, dynamic> org = <String, dynamic>{'name': name};
    if (organizationType != null && organizationType.isNotEmpty) {
      org['organization_type'] = organizationType;
    }
    if (paySchedule != null) {
      org['pay_schedule'] = paySchedule;
    }
    if (addressAttributes != null && addressAttributes.isNotEmpty) {
      org['address_attributes'] = addressAttributes;
    } else if (addressString != null && addressString.trim().isNotEmpty) {
      org['address'] = addressString.trim();
    }
    try {
      final Response<Map<String, dynamic>> res = await _dio
          .post<Map<String, dynamic>>(
            '/organizations',
            data: <String, dynamic>{'organization': org},
          );
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw OrganizationsApiException('Invalid create response');
      }
      return OrganizationEntity.fromJson(data);
    } on DioException catch (e) {
      throw OrganizationsApiException(
        userMessageFromDio(e) ?? 'Could not create organization',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<OrganizationEntity> updateOrganization({
    required String id,
    String? name,
    String? organizationType,
    bool patchOrganizationType = false,
    String? addressString,
    Map<String, dynamic>? addressAttributes,
    Map<String, dynamic>? paySchedule,
  }) async {
    final Map<String, dynamic> org = <String, dynamic>{};
    if (name != null) {
      org['name'] = name;
    }
    if (patchOrganizationType) {
      org['organization_type'] = organizationType;
    }
    if (paySchedule != null) {
      org['pay_schedule'] = paySchedule;
    }
    if (addressAttributes != null) {
      org['address_attributes'] = addressAttributes;
    }
    if (addressString != null) {
      org['address'] = addressString;
    }
    try {
      final Response<Map<String, dynamic>> res = await _dio
          .patch<Map<String, dynamic>>(
            '/organizations/$id',
            data: <String, dynamic>{'organization': org},
          );
      final Map<String, dynamic>? data =
          res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw OrganizationsApiException('Invalid update response');
      }
      return OrganizationEntity.fromJson(data);
    } on DioException catch (e) {
      throw OrganizationsApiException(
        userMessageFromDio(e) ?? 'Could not update organization',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Managers only. Responds with **204** and no body.
  Future<void> deleteOrganization(String id) async {
    try {
      await _dio.delete<void>('/organizations/$id');
    } on DioException catch (e) {
      throw OrganizationsApiException(
        userMessageFromDio(e) ?? 'Could not delete organization',
        statusCode: e.response?.statusCode,
      );
    }
  }

  static String? userMessageFromDio(DioException e) {
    final String m = userMessageFromProblem(e.response?.data, fallback: '');
    if (m.isEmpty &&
        (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout)) {
      return 'Connection timed out. Check API_BASE_URL and your network.';
    }
    if (m.isEmpty && e.type == DioExceptionType.connectionError) {
      return 'Could not reach the server. Is the API running?';
    }
    return m.isEmpty ? null : m;
  }
}
