import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'me_api.dart';

final meApiProvider = Provider<MeApi>((Ref ref) {
  return MeApi(ref.watch(dioProvider));
});
