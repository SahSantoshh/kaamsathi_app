import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/widgets.dart';

class PayPeriodsListScreen extends StatelessWidget {
  const PayPeriodsListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.payPeriodsList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgPayPeriodsList,
      metadata: 'orgId: $orgId — GET /pay_periods?page&items',
    );
  }
}

class PayPeriodNewScreen extends StatelessWidget {
  const PayPeriodNewScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.payPeriodNew;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgPayPeriodNew,
      metadata: 'orgId: $orgId — POST /pay_periods',
    );
  }
}

class PayPeriodDetailScreen extends StatelessWidget {
  const PayPeriodDetailScreen({
    super.key,
    required this.orgId,
    required this.periodId,
  });

  final String orgId;
  final String periodId;

  static const String name = RouteNames.payPeriodDetail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgPayPeriodDetail,
      metadata: 'orgId: $orgId, periodId: $periodId — GET /pay_periods/:id',
    );
  }
}

class PayPeriodLockScreen extends StatelessWidget {
  const PayPeriodLockScreen({
    super.key,
    required this.orgId,
    required this.periodId,
  });

  final String orgId;
  final String periodId;

  static const String name = RouteNames.payPeriodLock;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgPayPeriodLock,
      metadata: 'orgId: $orgId, periodId: $periodId — POST /pay_periods/:id/lock',
    );
  }
}

class PaymentRecordsListScreen extends StatelessWidget {
  const PaymentRecordsListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.paymentsList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgPaymentsList,
      metadata: 'orgId: $orgId — GET /payment_records?page&items',
    );
  }
}

class PaymentRecordNewScreen extends StatelessWidget {
  const PaymentRecordNewScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.paymentNew;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgPaymentNew,
      metadata: 'orgId: $orgId — POST /payment_records',
    );
  }
}
