import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/widgets.dart';

class ProjectSitesListScreen extends StatelessWidget {
  const ProjectSitesListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.sitesList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgSitesList,
      metadata: 'orgId: $orgId — GET /project_sites',
    );
  }
}

class ProjectSiteNewScreen extends StatelessWidget {
  const ProjectSiteNewScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.siteNew;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgSiteNew,
      metadata: 'POST /project_sites',
    );
  }
}

class ProjectSiteDetailScreen extends StatelessWidget {
  const ProjectSiteDetailScreen({
    super.key,
    required this.orgId,
    required this.siteId,
  });

  final String orgId;
  final String siteId;

  static const String name = RouteNames.siteDetail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgSiteDetail,
      metadata: 'siteId: $siteId — GET /project_sites/:id',
    );
  }
}

class ProjectSiteEditScreen extends StatelessWidget {
  const ProjectSiteEditScreen({
    super.key,
    required this.orgId,
    required this.siteId,
  });

  final String orgId;
  final String siteId;

  static const String name = RouteNames.siteEdit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgSiteEdit,
      metadata: 'PATCH /project_sites/:id',
    );
  }
}
