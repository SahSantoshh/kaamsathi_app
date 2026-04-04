import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_membership_role.dart';

/// Persists **JWT** and **`GET /me` `data`** (user profile JSON) in secure storage;
/// org id / counts / role in [SharedPreferences].
/// **Default organization** (`kaam_default_organization_id`) is client-only (§6).
final Provider<AuthSessionStorage> authSessionStorageProvider =
    Provider<AuthSessionStorage>((Ref ref) => AuthSessionStorage());

class AuthSessionStorage {
  AuthSessionStorage({FlutterSecureStorage? secure})
    : _secure = secure ?? const FlutterSecureStorage();

  static const String _kToken = 'kaam_access_token';
  static const String _kMeProfile = 'kaam_me_profile_json';
  static const String _kOrgId = 'kaam_selected_org_id';
  static const String _kDefaultOrgId = 'kaam_default_organization_id';
  static const String _kMembershipCount = 'kaam_membership_count';
  static const String _kRole = 'kaam_role';

  final FlutterSecureStorage _secure;

  Future<String?> readAccessToken() => _secure.read(key: _kToken);

  Future<void> writeAccessToken(String token) async {
    await _secure.write(key: _kToken, value: token);
  }

  /// Last cached user object from `GET /me` → JSON **`data`** (same shape as API).
  Future<Map<String, dynamic>?> readMeProfile() async {
    final String? raw = await _secure.read(key: _kMeProfile);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded.map((Object? k, Object? v) => MapEntry(k.toString(), v)),
        );
      }
    } on Object {
      await _secure.delete(key: _kMeProfile);
    }
    return null;
  }

  Future<void> writeMeProfile(Map<String, dynamic>? profile) async {
    if (profile == null) {
      await _secure.delete(key: _kMeProfile);
      return;
    }
    await _secure.write(key: _kMeProfile, value: jsonEncode(profile));
  }

  Future<String?> readDefaultOrganizationId() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    return p.getString(_kDefaultOrgId);
  }

  Future<void> writeDefaultOrganizationId(String organizationId) async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setString(_kDefaultOrgId, organizationId);
  }

  Future<void> clearDefaultOrganizationId() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.remove(_kDefaultOrgId);
  }

  Future<PersistedSessionFields> readSessionFields() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final String? orgId = p.getString(_kOrgId);
    final int count = p.getInt(_kMembershipCount) ?? 0;
    final String roleRaw = p.getString(_kRole) ?? 'manager';
    final AppMembershipRole role = roleRaw == 'worker'
        ? AppMembershipRole.worker
        : AppMembershipRole.manager;
    return PersistedSessionFields(
      organizationId: orgId,
      membershipCount: count,
      role: role,
    );
  }

  Future<void> writeSessionFields({
    required String? organizationId,
    required int membershipCount,
    required AppMembershipRole role,
  }) async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    if (organizationId != null && organizationId.isNotEmpty) {
      await p.setString(_kOrgId, organizationId);
    } else {
      await p.remove(_kOrgId);
    }
    await p.setInt(_kMembershipCount, membershipCount);
    await p.setString(
      _kRole,
      role == AppMembershipRole.worker ? 'worker' : 'manager',
    );
  }

  Future<void> clearAll() async {
    await _secure.delete(key: _kToken);
    await _secure.delete(key: _kMeProfile);
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.remove(_kOrgId);
    await p.remove(_kDefaultOrgId);
    await p.remove(_kMembershipCount);
    await p.remove(_kRole);
  }
}

class PersistedSessionFields {
  const PersistedSessionFields({
    required this.organizationId,
    required this.membershipCount,
    required this.role,
  });

  final String? organizationId;
  final int membershipCount;
  final AppMembershipRole role;
}
