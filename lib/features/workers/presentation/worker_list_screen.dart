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
import '../data/workers_repository.dart';
import '../domain/worker_models.dart';
import 'worker_ui_helpers.dart';

class WorkerListScreen extends ConsumerStatefulWidget {
  const WorkerListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.workersList;

  @override
  ConsumerState<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends ConsumerState<WorkerListScreen> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Map<String, String> _engagementStatusByWorker(List<OrgEngagement> list) {
    final Map<String, String> m = <String, String>{};
    for (final OrgEngagement e in list) {
      m[e.workerId] = e.status;
    }
    return m;
  }

  List<Worker> _filtered(
    List<Worker> all,
    Map<String, String> statusByWorker,
  ) {
    final String q = _query.text.trim().toLowerCase();
    if (q.isEmpty) {
      return all;
    }
    return all
        .where(
          (Worker w) {
            if (w.title.toLowerCase().contains(q)) {
              return true;
            }
            final String? em = w.user?.email?.toLowerCase();
            if (em != null && em.contains(q)) {
              return true;
            }
            final String? sk = w.skills?.toLowerCase();
            if (sk != null && sk.contains(q)) {
              return true;
            }
            final String? st = statusByWorker[w.id]?.toLowerCase();
            return st != null && st.contains(q);
          },
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;
    final AsyncValue<List<Worker>> asyncWorkers =
        ref.watch(workersListProvider(widget.orgId));
    final AsyncValue<List<OrgEngagement>> asyncEngagements =
        ref.watch(engagementsListProvider(widget.orgId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workersListProvider(widget.orgId));
          ref.invalidate(engagementsListProvider(widget.orgId));
          await ref.read(workersListProvider(widget.orgId).future);
          await ref.read(engagementsListProvider(widget.orgId).future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar.large(
              title: Text(l10n.pgWorkersList),
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
                  l10n.workersRosterSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _query,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.workersSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _query.clear();
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            asyncWorkers.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object e, StackTrace _) => SliverFillRemaining(
                child: KaamErrorBanner(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(workersListProvider(widget.orgId)),
                  retryLabel: l10n.retry,
                ),
              ),
              data: (List<Worker> workers) {
                final Map<String, String> statusByWorker =
                    asyncEngagements.maybeWhen(
                  data: _engagementStatusByWorker,
                  orElse: () => <String, String>{},
                );
                final List<Worker> items = _filtered(workers, statusByWorker);
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: KaamEmptyState(
                      title: l10n.workersEmptyTitle,
                      message: l10n.workersEmptyBody,
                      icon: Icons.groups_outlined,
                      actionLabel: isManager ? l10n.workersAddWorker : null,
                      onAction: isManager
                          ? () => context
                              .push(AppPaths.orgWorkerAdd(widget.orgId))
                          : null,
                    ),
                  );
                }
                return SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final Worker w = items[index];
                        final String? engStatus = statusByWorker[w.id];
                        final String subtitle = w.user?.email ??
                            (w.skills?.isNotEmpty == true ? w.skills! : '');
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Material(
                            color: scheme.surfaceContainerLow,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: scheme.outlineVariant
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push(
                                AppPaths.orgWorkerDetail(widget.orgId, w.id),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: <Widget>[
                                    workerListAvatar(context, w),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            w.title,
                                            style: textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (subtitle.isNotEmpty) ...<Widget>[
                                            const SizedBox(height: 2),
                                            Text(
                                              subtitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  textTheme.bodySmall?.copyWith(
                                                color:
                                                    scheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        workerStatusChip(context, engStatus),
                                        const SizedBox(height: AppSpacing.xs),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: scheme.primary
                                              .withValues(alpha: 0.5),
                                        ),
                                      ],
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
      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              onPressed: () =>
                  context.push(AppPaths.orgWorkerAdd(widget.orgId)),
              icon: const Icon(Icons.person_add_rounded),
              label: Text(l10n.workersAddWorker),
            )
          : null,
    );
  }
}
