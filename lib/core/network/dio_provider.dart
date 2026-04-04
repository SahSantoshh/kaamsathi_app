import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_org_interceptor.dart';
import 'dio_client.dart';

/// Global API [Dio] with auth + conditional org header ([AuthOrgInterceptor]).
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = createDioClient();
  dio.interceptors.insert(0, AuthOrgInterceptor(ref));
  return dio;
});
