import 'package:flutter/foundation.dart';

import '../../workers/domain/worker_models.dart';

@immutable
class EngagementOrganization {
  const EngagementOrganization({
    required this.id,
    required this.name,
    this.organizationType,
    this.verificationStatus,
    this.paySchedule,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? organizationType;
  final String? verificationStatus;
  final Map<String, dynamic>? paySchedule;
  final DateTime? createdAt;

  factory EngagementOrganization.fromJson(Map<String, dynamic> json) {
    final Object? ps = json['pay_schedule'];
    Map<String, dynamic>? payMap;
    if (ps is Map<String, dynamic>) {
      payMap = ps;
    }
    return EngagementOrganization(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim() ?? '',
      organizationType: json['organization_type'] as String?,
      verificationStatus: json['verification_status'] as String?,
      paySchedule: payMap,
      createdAt: _parseDate(json['created_at'] as String?),
    );
  }
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

/// [EngagementBlueprint] — one worker ↔ org contract.
@immutable
class OrgEngagement {
  const OrgEngagement({
    required this.id,
    required this.workerId,
    required this.organizationId,
    this.defaultProjectSiteId,
    required this.status,
    this.startsOn,
    this.endsOn,
    this.compensationProfile,
    this.createdAt,
    required this.worker,
    required this.organization,
  });

  final String id;
  final String workerId;
  final String organizationId;
  final String? defaultProjectSiteId;
  final String status;
  final DateTime? startsOn;
  final DateTime? endsOn;
  final String? compensationProfile;
  final DateTime? createdAt;
  final Worker worker;
  final EngagementOrganization organization;

  factory OrgEngagement.fromJson(Map<String, dynamic> json) {
    final Object? w = json['worker'];
    final Object? o = json['organization'];
    return OrgEngagement(
      id: json['id'] as String,
      workerId: json['worker_id'] as String,
      organizationId: json['organization_id'] as String,
      defaultProjectSiteId: json['default_project_site_id'] as String?,
      status: (json['status'] as String?)?.trim() ?? '',
      startsOn: _parseDate(json['starts_on'] as String?),
      endsOn: _parseDate(json['ends_on'] as String?),
      compensationProfile: json['compensation_profile'] as String?,
      createdAt: _parseDate(json['created_at'] as String?),
      worker: w is Map<String, dynamic>
          ? Worker.fromJson(w)
          : throw FormatException('engagement.worker missing'),
      organization: o is Map<String, dynamic>
          ? EngagementOrganization.fromJson(o)
          : throw FormatException('engagement.organization missing'),
    );
  }
}
