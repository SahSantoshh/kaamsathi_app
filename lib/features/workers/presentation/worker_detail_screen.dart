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
import '../../engagements/data/engagements_repository.dart';
import '../../engagements/domain/engagement_models.dart';
import '../../project_sites/data/project_site_repository.dart';
import '../../project_sites/domain/project_site_models.dart';
import '../data/workers_repository.dart';
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

  OrgEngagement? _engagementForWorker(
    List<OrgEngagement> list,
    String wid,
  ) {
    for (final OrgEngagement e in list) {
      if (e.workerId == wid) {
        return e;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;
    final AsyncValue<Worker> asyncWorker = ref.watch(
      workerDetailProvider((orgId: orgId, workerId: workerId)),
    );
    final AsyncValue<List<OrgEngagement>> asyncEngagements =
        ref.watch(engagementsListProvider(orgId));

    return asyncWorker.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.pgWorkerDetail)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object e, StackTrace _) => Scaffold(
        appBar: AppBar(title: Text(l10n.pgWorkerDetail)),
        body: KaamErrorBanner(
          message: e.toString(),
          onRetry: () => ref.invalidate(
            workerDetailProvider((orgId: orgId, workerId: workerId)),
          ),
          retryLabel: l10n.retry,
        ),
      ),
      data: (Worker worker) {
        final OrgEngagement? eng = asyncEngagements.maybeWhen(
          data: (List<OrgEngagement> list) =>
              _engagementForWorker(list, worker.id),
          orElse: () => null,
        );
        final String? siteId = eng?.defaultProjectSiteId;

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(worker.title),
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
                          workerListAvatar(context, worker, radius: 40),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (eng != null)
                                  workerStatusChip(context, eng.status),
                                if (worker.skills != null &&
                                    worker.skills!.trim().isNotEmpty) ...<Widget>[
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    worker.skills!,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.workersContactSection,
                        style: _sectionStyle(context),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (worker.user?.email != null &&
                          worker.user!.email!.trim().isNotEmpty)
                        _InfoTile(
                          icon: Icons.mail_outline_rounded,
                          label: l10n.workersEmail,
                          value: worker.user!.email!,
                        ),
                      if (worker.experience != null &&
                          worker.experience!.trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.workersExperienceLabel,
                          style: _sectionStyle(context),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          worker.experience!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.workersPayoutSection,
                        style: _sectionStyle(context),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _InfoTile(
                        icon: Icons.account_balance_rounded,
                        label: l10n.workersBankAccount,
                        value: worker.bankAccountName ??
                            worker.bankAccountNumber ??
                            '—',
                      ),
                      if (isManager &&
                          worker.bankIfsc != null &&
                          worker.bankIfsc!.isNotEmpty)
                        _InfoTile(
                          icon: Icons.tag_rounded,
                          label: 'IFSC',
                          value: worker.bankIfsc!,
                        ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.engagementSectionTitle,
                        style: _sectionStyle(context),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (eng == null)
                        Text(
                          l10n.engagementMissingForWorker,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        )
                      else ...<Widget>[
                        _InfoTile(
                          icon: Icons.flag_outlined,
                          label: l10n.engagementStatusLabel,
                          value: eng.status,
                        ),
                        if (eng.compensationProfile != null &&
                            eng.compensationProfile!.isNotEmpty)
                          _InfoTile(
                            icon: Icons.payments_outlined,
                            label: l10n.engagementCompensationLabel,
                            value: eng.compensationProfile!,
                          ),
                        if (eng.startsOn != null)
                          _InfoTile(
                            icon: Icons.play_circle_outline_rounded,
                            label: l10n.engagementStartsLabel,
                            value: MaterialLocalizations.of(context)
                                .formatMediumDate(eng.startsOn!.toLocal()),
                          ),
                        if (eng.endsOn != null)
                          _InfoTile(
                            icon: Icons.stop_circle_outlined,
                            label: l10n.engagementEndsLabel,
                            value: MaterialLocalizations.of(context)
                                .formatMediumDate(eng.endsOn!.toLocal()),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.engagementHomeSiteLabel,
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (siteId == null)
                          Text('—', style: textTheme.bodyLarge)
                        else
                          _HomeSiteName(
                            orgId: orgId,
                            siteId: siteId,
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton.tonalIcon(
                          onPressed: () => context.push(
                            AppPaths.orgEngagementDetail(orgId, eng.id),
                          ),
                          icon: const Icon(Icons.handshake_rounded, size: 22),
                          label: Text(l10n.engagementOpenHub),
                        ),
                        if (isManager) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: () => context.push(
                              AppPaths.orgEngagementEdit(orgId, eng.id),
                            ),
                            icon: const Icon(Icons.edit_rounded, size: 20),
                            label: Text(l10n.pgEngagementEdit),
                          ),
                        ],
                      ],
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

  TextStyle? _sectionStyle(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        );
  }
}

class _HomeSiteName extends ConsumerWidget {
  const _HomeSiteName({required this.orgId, required this.siteId});

  final String orgId;
  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<ProjectSite?> async = ref.watch(
      projectSiteProvider((orgId: orgId, siteId: siteId)),
    );
    return async.when(
      data: (ProjectSite? s) => Text(
        s?.name ?? siteId,
        style: textTheme.bodyLarge,
      ),
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (Object error, StackTrace stackTrace) =>
          Text(siteId, style: textTheme.bodyLarge),
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
