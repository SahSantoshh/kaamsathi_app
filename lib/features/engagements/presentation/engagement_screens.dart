import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/widgets.dart';

class EngagementListScreen extends StatelessWidget {
  const EngagementListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.engagementsList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgEngagementsList,
      metadata: 'orgId: $orgId — GET /engagements?page&items',
    );
  }
}

class EngagementDetailScreen extends StatelessWidget {
  const EngagementDetailScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.engagementDetail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgEngagementDetail,
      metadata: 'orgId: $orgId, engagementId: $engagementId',
    );
  }
}

class EngagementEditScreen extends StatelessWidget {
  const EngagementEditScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.engagementEdit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgEngagementEdit,
      metadata: 'PATCH /engagements/:id',
    );
  }
}

class WageRulesScreen extends StatelessWidget {
  const WageRulesScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.wageRules;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgWageRules,
      metadata: 'orgId: $orgId, engagementId: $engagementId — …/wage_rules',
    );
  }
}

class CommissionRulesScreen extends StatelessWidget {
  const CommissionRulesScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.commissionRules;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgCommissionRules,
      metadata: 'orgId: $orgId, engagementId: $engagementId — …/commission_rules',
    );
  }
}

class WorkAssignmentsScreen extends StatelessWidget {
  const WorkAssignmentsScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.workAssignments;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgWorkAssignments,
      metadata: 'orgId: $orgId, engagementId: $engagementId — …/work_assignments',
    );
  }
}
