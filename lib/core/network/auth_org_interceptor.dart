import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/auth_session_notifier.dart';
import 'tenant_request.dart';

/// Injects `Authorization` and, when required, `X-Organization-Id` (§6).
final class AuthOrgInterceptor extends Interceptor {
  AuthOrgInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final auth = _ref.read(authSessionProvider);
    final String? token = auth.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    String path = options.path;
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    if (!pathOmitsOrganizationHeader(path)) {
      final String? orgId = auth.selectedOrganizationId;
      if (orgId != null && orgId.isNotEmpty) {
        options.headers['X-Organization-Id'] = orgId;
      }
    } else {
      options.headers.remove('X-Organization-Id');
    }
    handler.next(options);
  }
}
