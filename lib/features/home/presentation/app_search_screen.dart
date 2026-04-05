import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../organization_switcher/data/select_org_data_provider.dart';
import '../../project_sites/data/project_site_repository.dart';
import '../../project_sites/domain/project_site_models.dart';
import '../../workers/data/workers_repository.dart';
import '../../workers/domain/worker_models.dart';

/// Fast search across organizations you belong to, project sites, and workers in
/// the current organization (client-side filter on loaded lists).
class AppSearchScreen extends ConsumerStatefulWidget {
  const AppSearchScreen({super.key});

  static const String name = RouteNames.appSearch;

  @override
  ConsumerState<AppSearchScreen> createState() => _AppSearchScreenState();
}

class _AppSearchScreenState extends ConsumerState<AppSearchScreen> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(String haystack, String q) {
    if (q.isEmpty) {
      return false;
    }
    return haystack.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? orgId = ref.watch(authSessionProvider).selectedOrganizationId;
    final String q = _query.text.trim().toLowerCase();

    final AsyncValue<List<SelectOrgRow>> asyncOrgs = ref.watch(selectOrgDataProvider);
    final AsyncValue<List<ProjectSite>>? asyncSites =
        orgId == null ? null : ref.watch(projectSitesProvider(orgId));
    final AsyncValue<List<Worker>>? asyncWorkers =
        orgId == null ? null : ref.watch(workersListProvider(orgId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appSearchTitle),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: TextField(
              controller: _query,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.appSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: q.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _query.clear();
                          setState(() {});
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (q.length < 2)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    l10n.appSearchMinChars,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: <Widget>[
                  asyncOrgs.when(
                    loading: () => const LinearProgressIndicator(minHeight: 2),
                    error: (Object e, StackTrace st) => Text(e.toString()),
                    data: (List<SelectOrgRow> rows) {
                      final List<SelectOrgRow> hits = rows
                          .where(
                            (SelectOrgRow r) =>
                                _matches(r.org.name, q) ||
                                (r.org.organizationType ?? '')
                                    .toLowerCase()
                                    .contains(q),
                          )
                          .toList();
                      if (hits.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _SectionLabel(text: l10n.appSearchSectionOrgs),
                          ...hits.map(
                            (SelectOrgRow r) => ListTile(
                              leading: Icon(Icons.business_rounded,
                                  color: scheme.primary),
                              title: Text(r.org.name),
                              subtitle: Text(l10n.appSearchSectionOrgs),
                              trailing: orgId == r.org.id
                                  ? Icon(Icons.check_circle_rounded,
                                      color: scheme.primary)
                                  : null,
                              onTap: () {
                                ref
                                    .read(authSessionProvider.notifier)
                                    .selectOrganization(
                                      r.org.id,
                                      role: r.role,
                                    );
                                context.pop();
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      );
                    },
                  ),
                  if (orgId != null && asyncSites != null)
                    asyncSites.when(
                      loading: () => const SizedBox.shrink(),
                      error: (Object e, StackTrace st) => const SizedBox.shrink(),
                      data: (List<ProjectSite> sites) {
                        final List<ProjectSite> hits = sites
                            .where(
                              (ProjectSite s) =>
                                  _matches(s.name, q) ||
                                  _matches(s.addressLine, q) ||
                                  _matches(
                                    s.contractee?.displayName ?? '',
                                    q,
                                  ) ||
                                  _matches(
                                    s.contractee?.email ?? '',
                                    q,
                                  ),
                            )
                            .toList();
                        if (hits.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _SectionLabel(text: l10n.appSearchSectionSites),
                            ...hits.map(
                              (ProjectSite s) => ListTile(
                                leading: Icon(Icons.apartment_rounded,
                                    color: scheme.tertiary),
                                title: Text(s.name),
                                subtitle: Text(
                                  s.addressLine.isNotEmpty
                                      ? s.addressLine
                                      : l10n.pgSitesList,
                                ),
                                onTap: () => context.push(
                                  AppPaths.orgSiteDetail(orgId, s.id),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      },
                    ),
                  if (orgId != null && asyncWorkers != null)
                    asyncWorkers.when(
                      loading: () => const SizedBox.shrink(),
                      error: (Object e, StackTrace st) => const SizedBox.shrink(),
                      data: (List<Worker> workers) {
                        final List<Worker> hits = workers
                            .where(
                              (Worker w) =>
                                  _matches(w.title, q) ||
                                  _matches(w.skills ?? '', q) ||
                                  _matches(w.user?.email ?? '', q),
                            )
                            .toList();
                        if (hits.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _SectionLabel(text: l10n.appSearchSectionWorkers),
                            ...hits.map(
                              (Worker w) => ListTile(
                                leading: Icon(Icons.person_rounded,
                                    color: scheme.secondary),
                                title: Text(w.title),
                                subtitle: Text(
                                  w.user?.email?.isNotEmpty == true
                                      ? w.user!.email!
                                      : (w.skills?.isNotEmpty == true
                                          ? w.skills!
                                          : l10n.pgWorkersList),
                                ),
                                onTap: () => context.push(
                                  AppPaths.orgWorkerDetail(orgId, w.id),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  if (q.length >= 2)
                    Builder(
                      builder: (BuildContext context) {
                        final bool anyOrgs = asyncOrgs.maybeWhen(
                          data: (List<SelectOrgRow> rows) => rows.any(
                            (SelectOrgRow r) =>
                                _matches(r.org.name, q) ||
                                (r.org.organizationType ?? '')
                                    .toLowerCase()
                                    .contains(q),
                          ),
                          orElse: () => false,
                        );
                        final bool anySites = asyncSites?.maybeWhen(
                              data: (List<ProjectSite> sites) => sites.any(
                                (ProjectSite s) =>
                                    _matches(s.name, q) ||
                                    _matches(s.addressLine, q) ||
                                    _matches(
                                      s.contractee?.displayName ?? '',
                                      q,
                                    ) ||
                                    _matches(s.contractee?.email ?? '', q),
                              ),
                              orElse: () => false,
                            ) ??
                            false;
                        final bool anyWorkers = asyncWorkers?.maybeWhen(
                              data: (List<Worker> workers) => workers.any(
                                (Worker w) =>
                                    _matches(w.title, q) ||
                                    _matches(w.skills ?? '', q) ||
                                    _matches(w.user?.email ?? '', q),
                              ),
                              orElse: () => false,
                            ) ??
                            false;
                        if (anyOrgs || anySites || anyWorkers) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xl),
                          child: Center(
                            child: Text(
                              l10n.appSearchNoResults,
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
