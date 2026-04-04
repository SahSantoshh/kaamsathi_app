import 'package:flutter/foundation.dart';

import 'app_membership_role.dart';

@immutable
class AuthState {
  const AuthState({
    this.accessToken,
    this.selectedOrganizationId,
    this.membershipCount = 0,
    this.role = AppMembershipRole.manager,
    this.meProfile,
  });

  /// Raw JWT string without `Bearer ` (null = signed out).
  final String? accessToken;

  /// Active tenant for `X-Organization-Id` (null until chosen).
  final String? selectedOrganizationId;

  /// From `GET /me` memberships length once wired; used for UX hints.
  final int membershipCount;

  final AppMembershipRole role;

  /// Root `data` object from the last `GET /me` (user profile). Extra keys are
  /// preserved for API evolution (phones, address, future fields).
  final Map<String, dynamic>? meProfile;

  bool get isAuthenticated => accessToken != null;
}
