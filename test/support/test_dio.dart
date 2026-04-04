import 'package:dio/dio.dart';
import 'package:kaamsathi/core/config/app_config.dart';

/// Fails every request immediately so widget tests never hang on real HTTP.
Dio createTestDio() {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiRoot,
      connectTimeout: const Duration(milliseconds: 1),
      receiveTimeout: const Duration(milliseconds: 1),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'test_dio: no network in widget tests',
          ),
        );
      },
    ),
  );
  return dio;
}
