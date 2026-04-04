import 'package:dio/dio.dart';

/// Thrown when an auth request fails. Prefer showing [message] in UI; use
/// [errorCode] for branching (e.g. `need_email`, `need_phone`).
class AuthApiException implements Exception {
  AuthApiException(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => message;
}

/// Rails API v1 auth + `GET /me` (KaamSathi_web/docs/flutter_app.md §5–6, §11).
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  /// Prefer JSON `access_token`, then `Authorization: Bearer …` header.
  static String? extractAccessToken(Response<dynamic> response) {
    final Map<String, dynamic>? data = _asJsonMap(response.data);
    final Object? raw = data?['access_token'];
    if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    return extractBearerToken(response);
  }

  static Map<String, dynamic>? _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    return null;
  }

  /// Reads JWT from `Authorization: Bearer …` (devise-jwt; web CORS).
  static String? extractBearerToken(Response<dynamic> response) {
    final String? headerRaw =
        response.headers.value('authorization') ??
        response.headers.value('Authorization');
    if (headerRaw == null || headerRaw.isEmpty) {
      return null;
    }
    final String s = headerRaw.trim();
    if (s.length > 7 && s.toLowerCase().startsWith('bearer ')) {
      return s.substring(7).trim();
    }
    return s;
  }

  static String normalizePhoneE164(String raw) {
    final String t = raw.trim().replaceAll(RegExp(r'\s'), '');
    if (t.isEmpty) {
      throw AuthApiException('Phone number is required');
    }
    return t.startsWith('+') ? t : '+$t';
  }

  /// `POST /auth/otp` — send at least one of [phoneE164] or [email].
  /// Code is emailed to the account’s address (§5).
  Future<void> requestOtp({String? phoneE164, String? email}) async {
    if ((phoneE164 == null || phoneE164.isEmpty) &&
        (email == null || email.trim().isEmpty)) {
      throw AuthApiException('Enter a phone number or email');
    }
    final Map<String, dynamic> data = <String, dynamic>{};
    if (phoneE164 != null && phoneE164.isNotEmpty) {
      data['phone_e164'] = phoneE164;
    }
    final String? em = email?.trim();
    if (em != null && em.isNotEmpty) {
      data['email'] = em;
    }
    try {
      await _dio.post<Map<String, dynamic>>('/auth/otp', data: data);
    } on DioException catch (e) {
      throw _authExceptionFromDio(e, fallback: 'Could not send code');
    }
  }

  /// `POST /auth/otp/verify` — [code] plus same identifiers as OTP request.
  Future<String> verifyOtp({
    required String code,
    String? phoneE164,
    String? email,
  }) async {
    if ((phoneE164 == null || phoneE164.isEmpty) &&
        (email == null || email.trim().isEmpty)) {
      throw AuthApiException('Phone or email is required to verify');
    }
    final Map<String, dynamic> data = <String, dynamic>{'code': code.trim()};
    if (phoneE164 != null && phoneE164.isNotEmpty) {
      data['phone_e164'] = phoneE164;
    }
    final String? em = email?.trim();
    if (em != null && em.isNotEmpty) {
      data['email'] = em;
    }
    try {
      final Response<Map<String, dynamic>> res = await _dio
          .post<Map<String, dynamic>>('/auth/otp/verify', data: data);
      final String? token = extractAccessToken(res);
      if (token == null || token.isEmpty) {
        throw AuthApiException(
          'Server did not return an access_token. '
          'If on web, ensure CORS exposes Authorization or the body includes access_token.',
        );
      }
      return token;
    } on DioException catch (e) {
      throw _authExceptionFromDio(e, fallback: 'Verification failed');
    }
  }

  /// `POST /auth/login` — [password] with at least one of [email] or [phoneE164].
  Future<String> loginWithPassword({
    required String password,
    String? email,
    String? phoneE164,
  }) async {
    final bool hasEmail = email != null && email.trim().isNotEmpty;
    final bool hasPhone = phoneE164 != null && phoneE164.isNotEmpty;
    if (!hasEmail && !hasPhone) {
      throw AuthApiException('Enter your email or phone number');
    }
    final Map<String, dynamic> user = <String, dynamic>{'password': password};
    if (hasEmail) {
      user['email'] = email.trim();
    }
    final Map<String, dynamic> data = <String, dynamic>{'user': user};
    if (hasPhone) {
      data['phone_e164'] = phoneE164;
    }
    try {
      final Response<Map<String, dynamic>> res = await _dio
          .post<Map<String, dynamic>>('/auth/login', data: data);
      final String? token = extractAccessToken(res);
      if (token == null || token.isEmpty) {
        throw AuthApiException(
          'Server did not return an access_token. '
          'If on web, ensure CORS exposes Authorization or the body includes access_token.',
        );
      }
      return token;
    } on DioException catch (e) {
      throw _authExceptionFromDio(e, fallback: 'Sign in failed');
    }
  }

  /// `GET /me` → `{ "data": <user>, "memberships": [ … ] }`.
  ///
  /// Call this right after login / OTP / password reset (and on splash with a
  /// stored token) so [MeResponse.meData] and [MeResponse.memberships] stay in sync.
  Future<MeResponse> fetchMe(String accessToken) async {
    try {
      final Response<Map<String, dynamic>> res = await _dio
          .get<Map<String, dynamic>>(
            '/me',
            options: Options(
              headers: <String, dynamic>{
                'Authorization': 'Bearer $accessToken',
              },
            ),
          );
      final Map<String, dynamic>? data = res.data;
      if (data == null) {
        throw AuthApiException('Invalid response from server');
      }
      return MeResponse.fromJson(data);
    } on DioException catch (e) {
      throw _authExceptionFromDio(e, fallback: 'Could not load profile');
    }
  }

  /// `POST /auth/password/forgot` — at least one of phone / email.
  Future<void> requestPasswordForgot({String? phoneE164, String? email}) async {
    if ((phoneE164 == null || phoneE164.isEmpty) &&
        (email == null || email.trim().isEmpty)) {
      throw AuthApiException('Enter a phone number or email');
    }
    final Map<String, dynamic> data = <String, dynamic>{};
    if (phoneE164 != null && phoneE164.isNotEmpty) {
      data['phone_e164'] = phoneE164;
    }
    final String? em = email?.trim();
    if (em != null && em.isNotEmpty) {
      data['email'] = em;
    }
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/password/forgot',
        data: data,
      );
    } on DioException catch (e) {
      throw _authExceptionFromDio(
        e,
        fallback: 'Could not start password reset',
      );
    }
  }

  /// `PATCH /auth/password` — reset password with email code from **forgot** flow only.
  Future<String> resetPasswordWithCode({
    required String code,
    required String password,
    required String passwordConfirmation,
    String? phoneE164,
    String? email,
  }) async {
    if ((phoneE164 == null || phoneE164.isEmpty) &&
        (email == null || email.trim().isEmpty)) {
      throw AuthApiException('Phone or email is required');
    }
    final Map<String, dynamic> data = <String, dynamic>{
      'code': code.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    if (phoneE164 != null && phoneE164.isNotEmpty) {
      data['phone_e164'] = phoneE164;
    }
    final String? em = email?.trim();
    if (em != null && em.isNotEmpty) {
      data['email'] = em;
    }
    try {
      final Response<Map<String, dynamic>> res = await _dio
          .patch<Map<String, dynamic>>('/auth/password', data: data);
      final String? token = extractAccessToken(res);
      if (token == null || token.isEmpty) {
        throw AuthApiException(
          'Password was reset but no access_token was returned.',
        );
      }
      return token;
    } on DioException catch (e) {
      throw _authExceptionFromDio(e, fallback: 'Could not reset password');
    }
  }

  /// `DELETE /auth/logout` — revokes JWT on server.
  Future<void> logout(String accessToken) async {
    try {
      await _dio.delete<void>(
        '/auth/logout',
        options: Options(
          headers: <String, dynamic>{'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException {
      // Still clear local session even if revoke fails (e.g. expired token).
    }
  }

  static AuthApiException _authExceptionFromDio(
    DioException e, {
    required String fallback,
  }) {
    final Object? body = e.response?.data;
    if (body is Map<String, dynamic>) {
      final String message = _userMessageFromProblem(body, fallback: fallback);
      final String? code = body['error'] as String?;
      return AuthApiException(message, errorCode: code);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AuthApiException(
        'Connection timed out. Check API_BASE_URL and your network.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return AuthApiException(
        'Could not reach the server. Is the API running?',
      );
    }
    return AuthApiException(fallback);
  }

  static String _userMessageFromProblem(
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    final Object? msg = body['message'];
    String base = fallback;
    if (msg is String && msg.trim().isNotEmpty) {
      base = msg.trim();
    } else {
      final Object? err = body['error'];
      if (err is String) {
        base = _mapServerError(err) ?? err;
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

  static String? _mapServerError(String key) {
    switch (key) {
      case 'invalid_code':
        return 'That code is incorrect or has expired.';
      case 'invalid_credentials':
        return 'Email/phone or password is incorrect.';
      case 'need_email':
        return 'Please enter the email for this account.';
      case 'need_phone':
        return 'Please enter the phone number for this account.';
      case 'need_email_or_phone':
        return 'Enter an email address or phone number.';
      default:
        return null;
    }
  }
}

class MeResponse {
  MeResponse({required this.memberships, this.meData});

  /// User object from JSON key **`data`** (`id`, `email`, `full_name`,
  /// `user_phone_numbers`, nested `address`, etc.). `null` if the payload omits it.
  final Map<String, dynamic>? meData;

  final List<Map<String, dynamic>> memberships;

  static MeResponse fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? user;
    final Object? rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      user = Map<String, dynamic>.from(rawData);
    } else if (rawData is Map) {
      user = Map<String, dynamic>.from(
        rawData.map((Object? k, Object? v) => MapEntry(k.toString(), v)),
      );
    }

    final Object? raw = json['memberships'];
    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
    if (raw is List<dynamic>) {
      for (final Object? item in raw) {
        if (item is Map<String, dynamic>) {
          list.add(Map<String, dynamic>.from(item));
        } else if (item is Map) {
          list.add(
            Map<String, dynamic>.from(
              item.map((Object? k, Object? v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
    }
    return MeResponse(memberships: list, meData: user);
  }
}
