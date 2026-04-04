import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'auth_api.dart';

final Provider<AuthApi> authApiProvider = Provider<AuthApi>((Ref ref) {
  final Dio dio = ref.watch(dioProvider);
  return AuthApi(dio);
});
