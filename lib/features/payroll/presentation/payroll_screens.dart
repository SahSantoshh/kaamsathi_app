import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/payroll_mock_data.dart';
import '../domain/payroll_models.dart';

class PayPeriodsListScreen extends ConsumerWidget {
  const PayPeriodsListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.payPeriodsList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;
    final List<PayPeriod> items = PayrollMockData.periodsForOrg(orgId);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar.large(
            title: Text(l10n.pgPayPeriodsList),
          ),
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: KaamEmptyState(
                title: 'No pay periods',
                message: 'Your organization’s payroll history will appear here.',
                icon: Icons.payments_outlined,
                actionLabel: isManager ? 'New Pay Period' : null,
                onAction: isManager
                    ? () => context.push(AppPaths.orgPayPeriodNew(orgId))
                    : null,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final PayPeriod period = items[index];
                    final String dateRange =
                        '${DateFormat.yMMMd().format(period.startDate)} - ${DateFormat.yMMMd().format(period.endDate)}';
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Material(
                        color: scheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: scheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push(
                            AppPaths.orgPayPeriodDetail(orgId, period.id),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: (period.isLocked
                                            ? scheme.secondaryContainer
                                            : scheme.primaryContainer)
                                        .withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    period.isLocked
                                        ? Icons.lock_outline_rounded
                                        : Icons.lock_open_rounded,
                                    color: period.isLocked
                                        ? scheme.onSecondaryContainer
                                        : scheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        dateRange,
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${period.workerCount} workers · Rs. ${period.totalAmount}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: period.isLocked
                                        ? scheme.outlineVariant.withValues(alpha: 0.2)
                                        : scheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    period.status.toUpperCase(),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: period.isLocked
                                          ? scheme.onSurfaceVariant
                                          : scheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppPaths.orgPayPeriodNew(orgId)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Period'),
            )
          : null,
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgPayPeriodNew)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: <Widget>[
            const Text(
              'Select the date range for this pay period. All attendance and engagements within this range will be totaled.',
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(DateFormat.yMMMd().format(DateTime.now())),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: () {},
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(DateFormat.yMMMd().format(DateTime.now().add(const Duration(days: 30)))),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: () {},
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Create Pay Period'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PayPeriodDetailScreen extends ConsumerWidget {
  const PayPeriodDetailScreen({
    super.key,
    required this.orgId,
    required this.periodId,
  });

  final String orgId;
  final String periodId;

  static const String name = RouteNames.payPeriodDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final PayPeriod? period = PayrollMockData.getPeriodById(orgId, periodId);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;

    if (period == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.pgPayPeriodDetail)),
        body: const Center(child: Text('Pay period not found')),
      );
    }

    final String dateRange =
        '${DateFormat.yMMMd().format(period.startDate)} - ${DateFormat.yMMMd().format(period.endDate)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pgPayPeriodDetail),
        actions: <Widget>[
          if (isManager && !period.isLocked)
            TextButton.icon(
              onPressed: () =>
                  context.push(AppPaths.orgPayPeriodLock(orgId, periodId)),
              icon: const Icon(Icons.lock_outline_rounded, size: 18),
              label: const Text('Lock'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: scheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: <Widget>[
                    _SummaryRow(
                      label: 'Period',
                      value: dateRange,
                      icon: Icons.calendar_today_rounded,
                    ),
                    const Divider(height: AppSpacing.lg),
                    _SummaryRow(
                      label: 'Status',
                      value: period.status.toUpperCase(),
                      icon: period.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      valueColor: period.isLocked ? scheme.error : scheme.primary,
                    ),
                    const Divider(height: AppSpacing.lg),
                    _SummaryRow(
                      label: 'Total Payout',
                      value: 'Rs. ${period.totalAmount}',
                      icon: Icons.account_balance_wallet_rounded,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Worker Summaries',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (period.workerCount == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    'No earnings recorded in this period.',
                    style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: period.workerCount,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Worker Name ${index + 1}'),
                    subtitle: const Text('24 days worked'),
                    trailing: Text(
                      'Rs. ${(period.totalAmount / period.workerCount).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgPayPeriodLock)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.lock_outline_rounded, size: 64, color: Colors.amber),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Lock Pay Period?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Locking this period will finalize all earnings and prevent further edits to attendance or wages for these dates.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Confirm & Lock'),
              ),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
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
