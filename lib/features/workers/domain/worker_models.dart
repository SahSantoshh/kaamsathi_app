import 'package:flutter/foundation.dart';

/// Nested `user` on [Worker] (UserBlueprint **worker_embed** view).
@immutable
class WorkerUser {
  const WorkerUser({
    required this.id,
    this.email,
    this.firstName,
    this.middleName,
    this.lastName,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String? email;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? createdAt;

  String get displayLabel {
    final String? f = fullName?.trim();
    if (f != null && f.isNotEmpty) {
      return f;
    }
    final String? e = email?.trim();
    if (e != null && e.isNotEmpty) {
      return e;
    }
    return '—';
  }

  factory WorkerUser.fromJson(Map<String, dynamic> json) {
    return WorkerUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: _trimUrl(json['avatar_url'] as String?),
      createdAt: _parseDate(json['created_at'] as String?),
    );
  }
}

String? _trimUrl(String? u) {
  if (u == null) {
    return null;
  }
  final String t = u.trim();
  return t.isEmpty ? null : t;
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

/// [WorkerBlueprint] payload (org roster).
@immutable
class Worker {
  const Worker({
    required this.id,
    required this.displayName,
    this.skills,
    this.experience,
    this.userId,
    this.createdAt,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankIfsc,
    this.avatarUrl,
    this.user,
  });

  final String id;
  final String displayName;
  final String? skills;
  final String? experience;
  final String? userId;
  final DateTime? createdAt;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankIfsc;
  final String? avatarUrl;
  final WorkerUser? user;

  String get title =>
      displayName.trim().isNotEmpty ? displayName.trim() : (user?.displayLabel ?? '—');

  String? get effectiveAvatarUrl {
    final String? u = user?.avatarUrl;
    if (u != null && u.isNotEmpty) {
      return u;
    }
    return avatarUrl;
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    final Object? userRaw = json['user'];
    return Worker(
      id: json['id'] as String,
      displayName: (json['display_name'] as String?)?.trim() ?? '',
      skills: json['skills'] as String?,
      experience: json['experience'] as String?,
      userId: json['user_id'] as String?,
      createdAt: _parseDate(json['created_at'] as String?),
      bankAccountName: json['bank_account_name'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankIfsc: json['bank_ifsc'] as String?,
      avatarUrl: _trimUrl(json['avatar_url'] as String?),
      user: userRaw is Map<String, dynamic> ? WorkerUser.fromJson(userRaw) : null,
    );
  }
}
