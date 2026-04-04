import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/widgets.dart';

class OrgRatingsListScreen extends StatelessWidget {
  const OrgRatingsListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.ratingsList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgRatingsList,
      metadata: 'orgId: $orgId — GET /org_ratings?page&items',
    );
  }
}

class OrgRatingNewScreen extends StatelessWidget {
  const OrgRatingNewScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.ratingNew;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgRatingNew,
      metadata: 'orgId: $orgId — POST /org_ratings',
    );
  }
}

class ReportsAttendanceScreen extends StatelessWidget {
  const ReportsAttendanceScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.reportAttendance;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgReportAttendance,
      metadata: 'orgId: $orgId — GET /reports/attendance',
    );
  }
}

class ReportsExportScreen extends StatelessWidget {
  const ReportsExportScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.reportExport;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgReportExport,
      metadata: 'orgId: $orgId — GET /reports/export',
    );
  }
}
