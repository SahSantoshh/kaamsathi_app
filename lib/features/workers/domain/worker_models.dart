import 'package:flutter/foundation.dart';

@immutable
class WorkerSummary {
  const WorkerSummary({
    required this.id,
    required this.displayName,
    required this.phoneE164,
    this.skillsSummary,
    this.statusLabel,
  });

  final String id;
  final String displayName;
  final String phoneE164;
  final String? skillsSummary;
  final String? statusLabel;
}

@immutable
class WorkerDetail extends WorkerSummary {
  const WorkerDetail({
    required super.id,
    required super.displayName,
    required super.phoneE164,
    super.skillsSummary,
    super.statusLabel,
    this.email,
    this.bankMasked,
    this.joinedOn,
    this.notes,
  });

  final String? email;
  final String? bankMasked;
  final DateTime? joinedOn;
  final String? notes;
}
