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
import '../data/project_site_repository.dart';
import '../domain/project_site_models.dart';

class ProjectSitesListScreen extends ConsumerStatefulWidget {
  const ProjectSitesListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.sitesList;

  @override
  ConsumerState<ProjectSitesListScreen> createState() =>
      _ProjectSitesListScreenState();
}

class _ProjectSitesListScreenState extends ConsumerState<ProjectSitesListScreen> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;
    final asyncSites = ref.watch(projectSitesProvider(widget.orgId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(projectSitesProvider(widget.orgId).future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar.large(
              title: Text(l10n.pgSitesList),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _query,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search sites...',
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
            asyncSites.when(
              data: (sites) {
                final filtered = sites.where((s) {
                  final q = _query.text.trim().toLowerCase();
                  return s.name.toLowerCase().contains(q) ||
                      s.address.toLowerCase().contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: KaamEmptyState(
                      title: 'No project sites found',
                      message: 'Your organization’s active sites will appear here.',
                      icon: Icons.location_on_outlined,
                      actionLabel: isManager ? 'Add Site' : null,
                      onAction: isManager
                          ? () => context.push(AppPaths.orgSiteNew(widget.orgId))
                          : null,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final ProjectSite site = filtered[index];
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
                                AppPaths.orgSiteDetail(widget.orgId, site.id),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: scheme.primaryContainer
                                            .withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.business_rounded,
                                        color: scheme.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            site.name,
                                            style: textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            site.address,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: textTheme.bodySmall?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: scheme.primary.withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppPaths.orgSiteNew(widget.orgId)),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Add Site'),
            )
          : null,
    );
  }
}

class ProjectSiteNewScreen extends ConsumerStatefulWidget {
  const ProjectSiteNewScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.siteNew;

  @override
  ConsumerState<ProjectSiteNewScreen> createState() => _ProjectSiteNewScreenState();
}

class _ProjectSiteNewScreenState extends ConsumerState<ProjectSiteNewScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgSiteNew)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Site Name',
                hintText: 'e.g. Skyline Towers',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Full location address',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional details about the project',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final newSite = ProjectSite(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    orgId: widget.orgId,
                    name: _nameController.text,
                    address: _addressController.text,
                    description: _descriptionController.text,
                  );
                  await ref.read(projectSiteRepositoryProvider).addSite(newSite);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Site created')),
                    );
                    ref.invalidate(projectSitesProvider(widget.orgId));
                    context.pop();
                  }
                },
                child: const Text('Create Project Site'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectSiteDetailScreen extends ConsumerWidget {
  const ProjectSiteDetailScreen({
    super.key,
    required this.orgId,
    required this.siteId,
  });

  final String orgId;
  final String siteId;

  static const String name = RouteNames.siteDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final asyncSite = ref.watch(projectSiteProvider((orgId: orgId, siteId: siteId)));
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;

    return Scaffold(
      body: KaamAsyncBody<ProjectSite?>(
        isLoading: asyncSite.isLoading,
        errorMessage: asyncSite.hasError ? asyncSite.error.toString() : null,
        data: asyncSite.value,
        padding: EdgeInsets.zero,
        dataBuilder: (context, site) {
          if (site == null) {
            return KaamEmptyState(
              title: 'Site not found',
              message: 'This project site could not be located.',
              icon: Icons.error_outline_rounded,
              actionLabel: 'Back to sites',
              onAction: () => context.pop(),
            );
          }

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(site.name),
                actions: <Widget>[
                  if (isManager)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () =>
                          context.push(AppPaths.orgSiteEdit(orgId, siteId)),
                    ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    _DetailSection(
                      title: 'Location Information',
                      children: <Widget>[
                        _DetailTile(
                          label: 'Address',
                          value: site.address,
                          icon: Icons.location_on_outlined,
                        ),
                        if (site.description != null && site.description!.isNotEmpty)
                          _DetailTile(
                            label: 'Description',
                            value: site.description!,
                            icon: Icons.description_outlined,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _DetailSection(
                      title: 'Status',
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: site.isActive
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: site.isActive
                                      ? Colors.green.withValues(alpha: 0.5)
                                      : Colors.grey.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                site.status.toUpperCase(),
                                style: textTheme.labelSmall?.copyWith(
                                  color: site.isActive
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Material(
                      color: scheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.insights_rounded,
                              color: scheme.primary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Site Insights Coming Soon',
                              style: textTheme.titleSmall?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Soon you’ll be able to see attendance, worker allocation, and budget tracking for this site.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectSiteEditScreen extends ConsumerStatefulWidget {
  const ProjectSiteEditScreen({
    super.key,
    required this.orgId,
    required this.siteId,
  });

  final String orgId;
  final String siteId;

  static const String name = RouteNames.siteEdit;

  @override
  ConsumerState<ProjectSiteEditScreen> createState() => _ProjectSiteEditScreenState();
}

class _ProjectSiteEditScreenState extends ConsumerState<ProjectSiteEditScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final asyncSite = ref.watch(projectSiteProvider((orgId: widget.orgId, siteId: widget.siteId)));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgSiteEdit)),
      body: KaamAsyncBody<ProjectSite?>(
        isLoading: asyncSite.isLoading,
        errorMessage: asyncSite.hasError ? asyncSite.error.toString() : null,
        data: asyncSite.value,
        dataBuilder: (context, site) {
          if (site == null) return const Center(child: Text('Site not found'));

          if (_nameController.text.isEmpty) {
            _nameController.text = site.name;
            _addressController.text = site.address;
            _descriptionController.text = site.description ?? '';
          }

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Site Name',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final updated = site.copyWith(
                        name: _nameController.text,
                        address: _addressController.text,
                        description: _descriptionController.text,
                      );
                      await ref.read(projectSiteRepositoryProvider).updateSite(updated);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Site updated')),
                        );
                        ref.invalidate(projectSiteProvider((orgId: widget.orgId, siteId: widget.siteId)));
                        ref.invalidate(projectSitesProvider(widget.orgId));
                        context.pop();
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension on ProjectSite {
  ProjectSite copyWith({
    String? name,
    String? address,
    String? description,
    String? status,
  }) {
    return ProjectSite(
      id: id,
      orgId: orgId,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
