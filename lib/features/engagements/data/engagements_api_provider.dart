import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'engagements_api.dart';

final Provider<EngagementsApi> engagementsApiProvider =
    Provider<EngagementsApi>((Ref ref) {
  return EngagementsApi(ref.watch(dioProvider));
});
