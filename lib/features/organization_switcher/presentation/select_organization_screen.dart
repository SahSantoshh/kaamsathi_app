import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/select_org_data_provider.dart';

class SelectOrganizationScreen extends ConsumerWidget {
  const SelectOrganizationScreen({super.key});

  static const String name = RouteNames.selectOrganization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<List<SelectOrgRow>> rowsAsync = ref.watch(
      selectOrgDataProvider,
    );
    final AsyncValue<String?> defaultAsync = ref.watch(
      defaultOrganizationIdProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pgSelectOrganization),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            tooltip: l10n.retry,
            onPressed: () {
              ref.invalidate(selectOrgDataProvider);
              ref.invalidate(defaultOrganizationIdProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: rowsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object _, StackTrace _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  l10n.selectOrgLoadError,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => ref.invalidate(selectOrgDataProvider),
                  child: Text(l10n.selectOrgRetry),
                ),
              ],
            ),
          ),
        ),
        data: (List<SelectOrgRow> rows) => defaultAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object _, StackTrace stackTrace) => _OrgListBody(
            l10n: l10n,
            scheme: scheme,
            textTheme: textTheme,
            rows: rows,
            defaultOrgId: null,
          ),
          data: (String? defaultOrgId) => _OrgListBody(
            l10n: l10n,
            scheme: scheme,
            textTheme: textTheme,
            rows: rows,
            defaultOrgId: defaultOrgId,
          ),
        ),
      ),
    );
  }
}

class _OrgListBody extends ConsumerWidget {
  const _OrgListBody({
    required this.l10n,
    required this.scheme,
    required this.textTheme,
    required this.rows,
    required this.defaultOrgId,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final List<SelectOrgRow> rows;
  final String? defaultOrgId;

  String _roleSubtitle(AppMembershipRole role) {
    return role == AppMembershipRole.worker
        ? l10n.sessionRoleWorkerLabel
        : l10n.sessionRoleOrganizationOwner;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        Text(
          l10n.selectOrgTitle,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.selectOrgSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (rows.isEmpty) ...<Widget>[
          Text(
            l10n.selectOrgEmpty,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ] else
          ...rows.map((SelectOrgRow row) {
            final String id = row.org.id;
            final String titleName = row.org.name.trim().isNotEmpty
                ? row.org.name.trim()
                : id;
            final bool isDefault = defaultOrgId != null && defaultOrgId == id;
            return Padding(
              key: ValueKey<String>(id),
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _OrgPickCard(
                title: titleName,
                subtitle: _roleSubtitle(row.role),
                isDefault: isDefault,
                onOpen: () {
                  ref
                      .read(authSessionProvider.notifier)
                      .selectOrganization(id, role: row.role);
                  context.go(AppPaths.home);
                },
                onSetDefault: () async {
                  await ref
                      .read(authSessionProvider.notifier)
                      .setDefaultOrganization(id);
                  ref.invalidate(defaultOrganizationIdProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.orgDefaultSavedSnackbar)),
                    );
                  }
                },
              ),
            );
          }),
        OutlinedButton.icon(
          onPressed: () => context.push(AppPaths.organizationCreate),
          icon: const Icon(Icons.add_business_outlined),
          label: Text(l10n.pgOrganizationCreate),
        ),
      ],
    );
  }
}

class _OrgPickCard extends StatelessWidget {
  const _OrgPickCard({
    required this.title,
    required this.subtitle,
    required this.isDefault,
    required this.onOpen,
    required this.onSetDefault,
  });

  final String title;
  final String subtitle;
  final bool isDefault;
  final VoidCallback onOpen;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Material(
      color: scheme.surface,
      elevation: 1,
      shadowColor: scheme.shadow.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  color: scheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (isDefault) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: scheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.orgDefaultBadge,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: scheme.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    tooltip: l10n.orgSetAsDefault,
                    onPressed: onSetDefault,
                    icon: Icon(
                      isDefault
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: scheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
