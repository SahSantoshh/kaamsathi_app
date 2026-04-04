import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs every request/response in debug builds; redacts [Authorization].
final Interceptor dioDebugLogInterceptor = InterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final Map<String, Object?> headers =
          Map<String, Object?>.from(options.headers);
      if (headers.containsKey('Authorization')) {
        headers['Authorization'] = 'Bearer ***';
      }
      debugPrint('[HTTP] → ${options.method} ${options.uri}');
      debugPrint('[HTTP]   headers: $headers');
      debugPrint('[HTTP]   data: ${options.data}');
    }
    handler.next(options);
  },
  onResponse: (Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[HTTP] ← ${response.statusCode} ${response.requestOptions.uri}',
      );
      debugPrint('[HTTP]   data: ${response.data}');
    }
    handler.next(response);
  },
  onError: (DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[HTTP] ✗ ${err.type} ${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      debugPrint('[HTTP]   message: ${err.message}');
      if (err.response != null) {
        debugPrint(
          '[HTTP]   status: ${err.response?.statusCode} data: ${err.response?.data}',
        );
      }
    }
    handler.next(err);
  },
);
