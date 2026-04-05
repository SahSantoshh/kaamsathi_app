import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../project_sites/data/project_site_repository.dart';
import '../../project_sites/domain/project_site_models.dart';
import '../../workers/presentation/worker_ui_helpers.dart';
import '../data/engagements_repository.dart';
import '../domain/engagement_models.dart';

class EngagementListScreen extends ConsumerWidget {
  const EngagementListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.engagementsList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<List<OrgEngagement>> async =
        ref.watch(engagementsListProvider(orgId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(engagementsListProvider(orgId));
          await ref.read(engagementsListProvider(orgId).future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar.large(
              title: Text(l10n.pgEngagementsList),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.engagementsListSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            async.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object e, StackTrace _) => SliverFillRemaining(
                child: KaamErrorBanner(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(engagementsListProvider(orgId)),
                  retryLabel: l10n.retry,
                ),
              ),
              data: (List<OrgEngagement> items) {
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: KaamEmptyState(
                      title: l10n.engagementsEmptyTitle,
                      message: l10n.engagementsEmptyBody,
                      icon: Icons.handshake_outlined,
                    ),
                  );
                }
                return SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final OrgEngagement e = items[index];
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Material(
                            color: scheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: scheme.outlineVariant
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push(
                                AppPaths.orgEngagementDetail(orgId, e.id),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: <Widget>[
                                    workerListAvatar(context, e.worker,
                                        radius: 26),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            e.worker.title,
                                            style: textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (e.compensationProfile != null &&
                                              e.compensationProfile!
                                                  .isNotEmpty)
                                            Text(
                                              e.compensationProfile!,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                color: scheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    workerStatusChip(context, e.status),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: scheme.primary
                                          .withValues(alpha: 0.45),
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
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class EngagementDetailScreen extends ConsumerWidget {
  const EngagementDetailScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.engagementDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;
    final AsyncValue<OrgEngagement> async = ref.watch(
      engagementDetailProvider((
        orgId: orgId,
        engagementId: engagementId,
      )),
    );

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.pgEngagementDetail)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object e, StackTrace _) => Scaffold(
        appBar: AppBar(title: Text(l10n.pgEngagementDetail)),
        body: KaamErrorBanner(
          message: e.toString(),
          onRetry: () => ref.invalidate(
            engagementDetailProvider((
              orgId: orgId,
              engagementId: engagementId,
            )),
          ),
          retryLabel: l10n.retry,
        ),
      ),
      data: (OrgEngagement e) {
        final String? siteId = e.defaultProjectSiteId;
        final DateFormat fmt = DateFormat.yMMMd();
        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(e.worker.title),
                actions: <Widget>[
                  if (isManager)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      tooltip: l10n.pgEngagementEdit,
                      onPressed: () => context.push(
                        AppPaths.orgEngagementEdit(orgId, engagementId),
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
                      Text(
                        l10n.engagementDetailSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      workerStatusChip(context, e.status),
                      const SizedBox(height: AppSpacing.lg),
                      if (e.compensationProfile != null &&
                          e.compensationProfile!.isNotEmpty)
                        _EngMetaRow(
                          icon: Icons.payments_outlined,
                          label: l10n.engagementCompensationLabel,
                          value: e.compensationProfile!,
                        ),
                      if (e.startsOn != null)
                        _EngMetaRow(
                          icon: Icons.play_circle_outline_rounded,
                          label: l10n.engagementStartsLabel,
                          value: fmt.format(e.startsOn!.toLocal()),
                        ),
                      if (e.endsOn != null)
                        _EngMetaRow(
                          icon: Icons.stop_circle_outlined,
                          label: l10n.engagementEndsLabel,
                          value: fmt.format(e.endsOn!.toLocal()),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.engagementHomeSiteLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (siteId == null)
                        Text('—', style: textTheme.bodyLarge)
                      else
                        _EngagementHomeSite(orgId: orgId, siteId: siteId),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.engagementShortcutsTitle,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _HubButton(
                        icon: Icons.schedule_rounded,
                        label: l10n.pgWorkAssignments,
                        onTap: () => context.push(
                          AppPaths.orgWorkAssignments(orgId, engagementId),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _HubButton(
                        icon: Icons.fact_check_outlined,
                        label: l10n.pgWageRules,
                        onTap: () => context.push(
                          AppPaths.orgWageRules(orgId, engagementId),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _HubButton(
                        icon: Icons.percent_rounded,
                        label: l10n.pgCommissionRules,
                        onTap: () => context.push(
                          AppPaths.orgCommissionRules(orgId, engagementId),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _HubButton(
                        icon: Icons.calendar_today_rounded,
                        label: l10n.pgAttendanceList,
                        onTap: () => context.push(
                          AppPaths.orgAttendance(orgId, engagementId),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _HubButton(
                        icon: Icons.person_search_rounded,
                        label: l10n.pgWorkerDetail,
                        onTap: () => context.push(
                          AppPaths.orgWorkerDetail(orgId, e.workerId),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EngMetaRow extends StatelessWidget {
  const _EngMetaRow({
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
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EngagementHomeSite extends ConsumerWidget {
  const _EngagementHomeSite({required this.orgId, required this.siteId});

  final String orgId;
  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<ProjectSite?> async = ref.watch(
      projectSiteProvider((orgId: orgId, siteId: siteId)),
    );
    return async.when(
      data: (ProjectSite? s) {
        final String line = s?.name ?? siteId;
        return InkWell(
          onTap: () => context.push(AppPaths.orgSiteDetail(orgId, siteId)),
          child: Text(
            line,
            style: textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (Object error, StackTrace stackTrace) =>
          Text(siteId, style: textTheme.bodyLarge),
    );
  }
}

class _HubButton extends StatelessWidget {
  const _HubButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
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
      metadata:
          'orgId: $orgId — PATCH /engagements/$engagementId (status, dates, default_project_site_id, compensation_profile)',
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
      metadata:
          'orgId: $orgId, engagementId: $engagementId — POST/DELETE …/work_assignments',
    );
  }
}
