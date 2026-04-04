import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'organizations_api.dart';
import 'organizations_api_provider.dart';

final organizationDetailProvider =
    FutureProvider.family<OrganizationEntity, String>(
  (Ref ref, String organizationId) async {
    final OrganizationsApi api = ref.watch(organizationsApiProvider);
    return api.getOrganization(organizationId);
  },
);
