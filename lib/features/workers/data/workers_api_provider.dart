import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'workers_api.dart';

final Provider<WorkersApi> workersApiProvider = Provider<WorkersApi>((Ref ref) {
  return WorkersApi(ref.watch(dioProvider));
});
