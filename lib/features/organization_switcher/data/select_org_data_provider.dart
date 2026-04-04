import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/session/auth_session_storage.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/data/auth_api_provider.dart';
import '../../organization/data/organizations_api.dart';
import '../../organization/data/organizations_api_provider.dart';

/// Organizations index ([`GET /organizations`]) + roles from [`GET /me`].
class SelectOrgRow {
  const SelectOrgRow({required this.org, required this.role});

  final OrganizationEntity org;
  final AppMembershipRole role;
}

final FutureProvider<List<SelectOrgRow>>
selectOrgDataProvider = FutureProvider.autoDispose<List<SelectOrgRow>>((
  Ref ref,
) async {
  final String? token = ref.watch(authSessionProvider).accessToken;
  if (token == null || token.isEmpty) {
    throw StateError('Not signed in');
  }
  final OrganizationsApi orgs = ref.read(organizationsApiProvider);
  final MeResponse me = await ref.read(authApiProvider).fetchMe(token);
  final List<OrganizationEntity> list = await orgs.listOrganizations();
  final Map<String, AppMembershipRole> roles = <String, AppMembershipRole>{};
  for (final Map<String, dynamic> m in me.memberships) {
    final Map<String, dynamic>? o = m['organization'] as Map<String, dynamic>?;
    final String? id = o?['id'] as String?;
    if (id != null) {
      roles[id] = AuthSessionNotifier.parseMembershipRole(m['role'] as String?);
    }
  }
  return list
      .map(
        (OrganizationEntity o) => SelectOrgRow(
          org: o,
          role: roles[o.id] ?? AppMembershipRole.manager,
        ),
      )
      .toList();
});

final FutureProvider<String?> defaultOrganizationIdProvider =
    FutureProvider.autoDispose<String?>((Ref ref) async {
      return ref.read(authSessionStorageProvider).readDefaultOrganizationId();
    });
