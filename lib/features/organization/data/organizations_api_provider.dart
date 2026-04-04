import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'organizations_api.dart';

final Provider<OrganizationsApi> organizationsApiProvider =
    Provider<OrganizationsApi>((Ref ref) {
  return OrganizationsApi(ref.watch(dioProvider));
});
