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

  List<WorkerSummary> _filtered(AppLocalizations l10n) {
    final List<WorkerSummary> all =
        WorkersMockData.summariesForOrg(widget.orgId);
    final String q = _query.text.trim().toLowerCase();
    if (q.isEmpty) {
      return all;
    }
    return all
        .where(
          (WorkerSummary w) =>
              w.displayName.toLowerCase().contains(q) ||
              w.phoneE164.toLowerCase().contains(q) ||
              (w.skillsSummary?.toLowerCase().contains(q) ?? false),
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
    final List<WorkerSummary> items = _filtered(l10n);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            setState(() {});
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar.large(
              title: Text(l10n.pgWorkersList),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                  child: Center(
                    child: _SampleDataChip(label: l10n.workersDemoBadge),
                  ),
                ),
              ],
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
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: KaamEmptyState(
                  title: l10n.workersEmptyTitle,
                  message: l10n.workersEmptyBody,
                  icon: Icons.groups_outlined,
                  actionLabel: isManager ? l10n.workersAddWorker : null,
                  onAction: isManager
                      ? () => context.push(AppPaths.orgWorkerAdd(widget.orgId))
                      : null,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final WorkerSummary w = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Material(
                          color: scheme.surfaceContainerLow,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: scheme.outlineVariant.withValues(alpha: 0.3),
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
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor:
                                        scheme.primaryContainer.withValues(
                                      alpha: 0.7,
                                    ),
                                    child: Text(
                                      workerInitials(w.displayName),
                                      style: textTheme.titleMedium?.copyWith(
                                        color: scheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          w.displayName,
                                          style: textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          w.phoneE164,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                        if (w.skillsSummary != null) ...<Widget>[
                                          const SizedBox(height: 6),
                                          Text(
                                            w.skillsSummary!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: textTheme.bodySmall?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      workerStatusChip(
                                        context,
                                        w.statusLabel,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: scheme.primary.withValues(alpha: 0.5),
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

class _SampleDataChip extends StatelessWidget {
  const _SampleDataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
