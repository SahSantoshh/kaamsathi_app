import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/widgets.dart';

class CommissionSalesListScreen extends StatelessWidget {
  const CommissionSalesListScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.salesList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgSalesList,
      metadata: 'orgId: $orgId, engagementId: $engagementId — …/commission_sales',
    );
  }
}

class CommissionSaleNewScreen extends StatelessWidget {
  const CommissionSaleNewScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.saleNew;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgSaleNew,
      metadata: 'orgId: $orgId, engagementId: $engagementId — POST …/commission_sales',
    );
  }
}

class CommissionSaleDetailScreen extends StatelessWidget {
  const CommissionSaleDetailScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
    required this.saleId,
  });

  final String orgId;
  final String engagementId;
  final String saleId;

  static const String name = RouteNames.saleDetail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgSaleDetail,
      metadata: 'saleId: $saleId — PATCH …/commission_sales/:id',
    );
  }
}
