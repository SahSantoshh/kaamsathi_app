import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/widgets.dart';

class AttendanceListScreen extends StatelessWidget {
  const AttendanceListScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.attendanceList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgAttendanceList,
      metadata: 'orgId: $orgId, engagementId: $engagementId — …/attendance_days',
    );
  }
}

class AttendanceDayNewScreen extends StatelessWidget {
  const AttendanceDayNewScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.attendanceNew;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgAttendanceNew,
      metadata: 'orgId: $orgId, engagementId: $engagementId — POST …/attendance_days',
    );
  }
}

class AttendanceDayScreen extends StatelessWidget {
  const AttendanceDayScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
    required this.dayId,
  });

  final String orgId;
  final String engagementId;
  final String dayId;

  static const String name = RouteNames.attendanceDay;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgAttendanceDay,
      metadata: 'dayId: $dayId — PATCH …/attendance_days/:id',
    );
  }
}

class TimePunchScreen extends StatelessWidget {
  const TimePunchScreen({super.key, required this.orgId, required this.dayId});

  final String orgId;
  final String dayId;

  static const String name = RouteNames.timePunch;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgTimePunch,
      metadata: 'orgId: $orgId, dayId: $dayId — POST /attendance_days/:id/time_punches',
    );
  }
}
