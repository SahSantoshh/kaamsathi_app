import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/workers_mock_data.dart';
import '../domain/worker_models.dart';
import 'worker_ui_helpers.dart';

class WorkerDetailScreen extends ConsumerWidget {
  const WorkerDetailScreen({
    super.key,
    required this.orgId,
    required this.workerId,
  });

  final String orgId;
  final String workerId;

  static const String name = RouteNames.workerDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final WorkerDetail? detail = WorkersMockData.detailById(workerId);
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;

    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.pgWorkerDetail)),
        body: KaamEmptyState(
          title: l10n.workersNotFoundTitle,
          message: l10n.workersNotFoundBody,
          icon: Icons.person_off_outlined,
          actionLabel: l10n.pgWorkersList,
          onAction: () => context.go(AppPaths.orgWorkers(orgId)),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar.large(
            title: Text(detail.displayName),
            actions: <Widget>[
              if (isManager)
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: l10n.pgWorkerEdit,
                  onPressed: () => context.push(
                    AppPaths.orgWorkerEdit(orgId, workerId),
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            scheme.primaryContainer.withValues(alpha: 0.95),
                        child: Text(
                          workerInitials(detail.displayName),
                          style: textTheme.headlineSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            workerStatusChip(context, detail.statusLabel),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              detail.skillsSummary ?? '—',
                              style: textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(title: l10n.workersContactSection),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoTile(
                    icon: Icons.phone_rounded,
                    label: l10n.workersPhone,
                    value: detail.phoneE164,
                  ),
                  if (detail.email != null)
                    _InfoTile(
                      icon: Icons.mail_outline_rounded,
                      label: l10n.workersEmail,
                      value: detail.email!,
                    ),
                  if (detail.joinedOn != null)
                    _InfoTile(
                      icon: Icons.event_rounded,
                      label: l10n.workersJoined,
                      value: MaterialLocalizations.of(context).formatFullDate(
                        detail.joinedOn!.toLocal(),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionTitle(title: l10n.workersPayoutSection),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoTile(
                    icon: Icons.account_balance_rounded,
                    label: l10n.workersBankAccount,
                    value: detail.bankMasked ?? '—',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionTitle(title: l10n.workersNotesSection),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      detail.notes?.isNotEmpty == true ? detail.notes! : '—',
                      style: textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.workersDemoBadge,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
