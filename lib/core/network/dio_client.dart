import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'dio_debug_interceptor.dart';

/// Base HTTP client; add [AuthInterceptor] and error mapping in `core/network/`.
Dio createDioClient() {
  if (kDebugMode) {
    debugPrint('[HTTP] API base URL: ${AppConfig.apiRoot}');
  }
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiRoot,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: <String, dynamic>{
        Headers.contentTypeHeader: Headers.jsonContentType,
        Headers.acceptHeader: Headers.jsonContentType,
      },
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(dioDebugLogInterceptor);
  }
  return dio;
}
