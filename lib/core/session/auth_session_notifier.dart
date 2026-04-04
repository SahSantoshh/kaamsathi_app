import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_api.dart';
import 'app_membership_role.dart';
import 'auth_session_storage.dart';
import 'auth_state.dart';

class AuthSessionNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> _persistSession() async {
    try {
      final AuthState s = state;
      final AuthSessionStorage storage = ref.read(authSessionStorageProvider);
      if (!s.isAuthenticated || s.accessToken == null) {
        await storage.clearAll();
        return;
      }
      await storage.writeAccessToken(s.accessToken!);
      await storage.writeMeProfile(s.meProfile);
      await storage.writeSessionFields(
        organizationId: s.selectedOrganizationId,
        membershipCount: s.membershipCount,
        role: s.role,
      );
    } on Object {
      // Do not crash auth on persistence errors (tests / keychain edge cases).
    }
  }

  /// Load token + prefs into memory (splash). Network refresh is separate.
  Future<void> restorePersistedSession() async {
    try {
      final AuthSessionStorage storage = ref.read(authSessionStorageProvider);
      final String? token = await storage.readAccessToken().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (token == null || token.isEmpty) {
        return;
      }
      final PersistedSessionFields fields = await storage
          .readSessionFields()
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => const PersistedSessionFields(
              organizationId: null,
              membershipCount: 0,
              role: AppMembershipRole.manager,
            ),
          );
      final Map<String, dynamic>? cachedProfile = await storage
          .readMeProfile()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
      state = AuthState(
        accessToken: token,
        selectedOrganizationId: fields.organizationId,
        membershipCount: fields.membershipCount,
        role: fields.role,
        meProfile: _copyProfileMap(cachedProfile),
      );
    } on Object {
      // e.g. MissingPluginException in widget tests without platform channels.
    }
  }

  /// After OTP verify, login, password reset, or splash [`GET /me`] refresh.
  ///
  /// Keeps a persisted org when still in [memberships]; uses **client** default
  /// from prefs when none selected (§6). Single membership always selects that org.
  Future<void> applyAuthenticatedFromApi(
    String accessToken,
    MeResponse me,
  ) async {
    final int count = me.memberships.length;
    String? orgId = state.selectedOrganizationId;
    AppMembershipRole role = state.role;

    if (orgId != null && !_membershipsContainOrg(me, orgId)) {
      orgId = null;
    }

    if (count == 1) {
      final Map<String, dynamic> m = me.memberships.first;
      final Map<String, dynamic>? org =
          m['organization'] as Map<String, dynamic>?;
      orgId = org?['id'] as String?;
      role = parseMembershipRole(m['role'] as String?);
    } else if (orgId != null) {
      role = _roleForOrg(me, orgId) ?? role;
    } else if (count > 0) {
      try {
        final String? def = await ref
            .read(authSessionStorageProvider)
            .readDefaultOrganizationId();
        if (def != null && _membershipsContainOrg(me, def)) {
          orgId = def;
          role = _roleForOrg(me, def) ?? AppMembershipRole.manager;
        } else {
          role = AppMembershipRole.manager;
        }
      } on Object {
        role = AppMembershipRole.manager;
      }
    } else {
      role = AppMembershipRole.manager;
    }

    state = AuthState(
      accessToken: accessToken,
      selectedOrganizationId: orgId,
      membershipCount: count,
      role: role,
      meProfile: _copyProfileMap(me.meData),
    );
    unawaited(_persistSession());
  }

  Future<void> setDefaultOrganization(String organizationId) async {
    try {
      await ref
          .read(authSessionStorageProvider)
          .writeDefaultOrganizationId(organizationId);
    } on Object {
      // Ignore prefs errors.
    }
  }

  /// After `DELETE /organizations/:id` — clears selection/default if needed.
  Future<void> onOrganizationDeleted(String organizationId) async {
    try {
      final String? def = await ref
          .read(authSessionStorageProvider)
          .readDefaultOrganizationId();
      if (def == organizationId) {
        await ref.read(authSessionStorageProvider).clearDefaultOrganizationId();
      }
    } on Object {
      // Ignore prefs errors when clearing default org id.
    }
    final bool wasSelected = state.selectedOrganizationId == organizationId;
    final int nextCount = state.membershipCount > 0
        ? state.membershipCount - 1
        : 0;
    state = AuthState(
      accessToken: state.accessToken,
      selectedOrganizationId: wasSelected ? null : state.selectedOrganizationId,
      membershipCount: nextCount,
      role: state.role,
      meProfile: state.meProfile,
    );
    unawaited(_persistSession());
  }

  static Map<String, dynamic>? _copyProfileMap(Map<String, dynamic>? raw) {
    if (raw == null) {
      return null;
    }
    return Map<String, dynamic>.from(raw);
  }

  static bool _membershipsContainOrg(MeResponse me, String organizationId) {
    for (final Map<String, dynamic> m in me.memberships) {
      final Map<String, dynamic>? org =
          m['organization'] as Map<String, dynamic>?;
      if (org?['id'] == organizationId) {
        return true;
      }
    }
    return false;
  }

  static AppMembershipRole? _roleForOrg(MeResponse me, String organizationId) {
    for (final Map<String, dynamic> m in me.memberships) {
      final Map<String, dynamic>? org =
          m['organization'] as Map<String, dynamic>?;
      if (org?['id'] == organizationId) {
        return parseMembershipRole(m['role'] as String?);
      }
    }
    return null;
  }

  static AppMembershipRole parseMembershipRole(String? raw) {
    if (raw == null) {
      return AppMembershipRole.manager;
    }
    final String s = raw.toLowerCase();
    if (s == 'worker') {
      return AppMembershipRole.worker;
    }
    return AppMembershipRole.manager;
  }

  void selectOrganization(String organizationId, {AppMembershipRole? role}) {
    state = AuthState(
      accessToken: state.accessToken,
      selectedOrganizationId: organizationId,
      membershipCount: state.membershipCount,
      role: role ?? state.role,
      meProfile: state.meProfile,
    );
    unawaited(_persistSession());
  }

  void clearOrganization() {
    state = AuthState(
      accessToken: state.accessToken,
      selectedOrganizationId: null,
      membershipCount: state.membershipCount,
      role: state.role,
      meProfile: state.meProfile,
    );
    unawaited(_persistSession());
  }

  Future<void> signOut() async {
    state = const AuthState();
    try {
      await ref.read(authSessionStorageProvider).clearAll();
    } on Object {
      // Ignore storage failures when clearing session.
    }
  }
}

final NotifierProvider<AuthSessionNotifier, AuthState> authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthState>(AuthSessionNotifier.new);
