import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../organization/data/organization_detail_provider.dart';
import '../../organization/data/organizations_api.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String name = RouteNames.home;

  static String _payFrequencyLabel(String code, AppLocalizations l10n) {
    switch (code) {
      case 'monthly':
        return l10n.orgPayFrequencyMonthly;
      case 'weekly':
        return l10n.orgPayFrequencyWeekly;
      case 'biweekly':
        return l10n.orgPayFrequencyBiweekly;
      default:
        return l10n.orgPayFrequencyCustom(code);
    }
  }

  static String? _formatOrgAddress(OrganizationEntity o) {
    if (o.addressSingleLine != null && o.addressSingleLine!.trim().isNotEmpty) {
      return o.addressSingleLine!.trim();
    }
    final String joined = <String?>[
      o.addressLine1,
      o.city,
      o.region,
      o.postalCode,
      o.countryCode,
    ].whereType<String>().where((String x) => x.trim().isNotEmpty).join(', ');
    return joined.isEmpty ? null : joined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? orgId = ref.watch(authSessionProvider).selectedOrganizationId;
    if (orgId == null || orgId.isEmpty) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final String o = orgId;
    final AppMembershipRole role = ref.watch(authSessionProvider).role;
    final bool isManager = role == AppMembershipRole.manager;
    final Map<String, dynamic>? me = ref.watch(authSessionProvider).meProfile;
    final String? displayName = me?['full_name'] as String?;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AsyncValue<OrganizationEntity> orgDetail = ref.watch(
      organizationDetailProvider(o),
    );
    final String orgTitle = orgDetail.when(
      data: (OrganizationEntity e) =>
          e.name.trim().isNotEmpty ? e.name.trim() : l10n.dashboardOrgFallback,
      loading: () => l10n.dashboardOrgFallback,
      error: (Object _, StackTrace stackTrace) => l10n.dashboardOrgFallback,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pgHome),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: l10n.dashboardSwitchOrg,
            onPressed: () => context.push(AppPaths.selectOrganization),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.pgSettings,
            onPressed: () => context.push(AppPaths.settings),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: l10n.pgProfile,
            onPressed: () => context.push(AppPaths.profile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        children: <Widget>[
          _DashboardHero(
            l10n: l10n,
            scheme: scheme,
            organizationName: orgTitle,
            displayName: displayName,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.dashboardOrgSummaryTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          orgDetail.when(
            loading: () => Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            error: (Object _, StackTrace stackTrace) => Card(
              child: ListTile(
                title: Text(orgTitle),
                subtitle: Text(l10n.orgProfileLoadError),
              ),
            ),
            data: (OrganizationEntity org) => _OrgSummaryCard(
              l10n: l10n,
              scheme: scheme,
              org: org,
              payFrequencyLabel: (String c) => _payFrequencyLabel(c, l10n),
              addressLine: _formatOrgAddress(org),
              onOpenProfile: () => context.push(AppPaths.orgProfile(o)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isManager) ...<Widget>[
            Text(
              l10n.dashboardManagerActionsTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: () => context.push(AppPaths.orgWorkerAdd(o)),
                  icon: const Icon(Icons.person_add_rounded),
                  label: Text(l10n.pgWorkerAdd),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.push(AppPaths.orgSiteNew(o)),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: Text(l10n.pgSiteNew),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.push(AppPaths.orgPayPeriodNew(o)),
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(l10n.pgPayPeriodNew),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            l10n.dashboardPrimaryTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double w = (c.maxWidth - AppSpacing.sm) / 2;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  _DashTile(
                    width: w,
                    icon: Icons.groups_rounded,
                    label: l10n.pgWorkersList,
                    onTap: () => context.push(AppPaths.orgWorkers(o)),
                  ),
                  _DashTile(
                    width: w,
                    icon: Icons.apartment_rounded,
                    label: l10n.pgSitesList,
                    onTap: () => context.push(AppPaths.orgSites(o)),
                  ),
                  _DashTile(
                    width: w,
                    icon: Icons.handshake_rounded,
                    label: l10n.pgEngagementsList,
                    onTap: () => context.push(AppPaths.orgEngagements(o)),
                  ),
                  _DashTile(
                    width: w,
                    icon: Icons.payments_outlined,
                    label: l10n.pgPayPeriodsList,
                    onTap: () => context.push(AppPaths.orgPayPeriods(o)),
                  ),
                  _DashTile(
                    width: w,
                    icon: Icons.calendar_month_rounded,
                    label: l10n.pgCalendar,
                    onTap: () => context.push(AppPaths.orgCalendar(o)),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.dashboardMoreTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.swap_horiz_rounded),
                  title: Text(l10n.dashboardSwitchOrg),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppPaths.selectOrganization),
                ),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.35),
                ),
                ListTile(
                  leading: const Icon(Icons.add_business_outlined),
                  title: Text(l10n.dashboardNewOrganization),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppPaths.organizationCreate),
                ),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.35),
                ),
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded),
                  title: Text(l10n.dashboardRatingsReports),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppPaths.orgRatings(o)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _OrgSummaryCard extends StatelessWidget {
  const _OrgSummaryCard({
    required this.l10n,
    required this.scheme,
    required this.org,
    required this.payFrequencyLabel,
    required this.addressLine,
    required this.onOpenProfile,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final OrganizationEntity org;
  final String Function(String code) payFrequencyLabel;
  final String? addressLine;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final String freq = payFrequencyLabel(org.payScheduleFrequencyLabel());
    final String payLine = l10n.dashboardPayScheduleLine(
      freq,
      org.payScheduleAnchorDay(),
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onOpenProfile,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.business_rounded, color: scheme.primary, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      org.name.trim().isNotEmpty ? org.name.trim() : org.id,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: scheme.primary),
                ],
              ),
              if (org.organizationType != null &&
                  org.organizationType!.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${l10n.orgFieldType}: ${org.organizationType}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${l10n.orgVerificationStatus}: ${(org.verificationStatus?.trim().isNotEmpty ?? false) ? org.verificationStatus! : l10n.orgMetaUnknown}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (addressLine != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  addressLine!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                payLine,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.dashboardViewOrgProfile,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  const _DashTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, size: 32, color: scheme.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.l10n,
    required this.scheme,
    required this.organizationName,
    required this.displayName,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final String organizationName;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String trimmed = displayName?.trim() ?? '';
    final String greetingLine = trimmed.isNotEmpty
        ? l10n.dashboardGreetingNamed(trimmed)
        : l10n.dashboardGreeting;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            scheme.primary,
            Color.lerp(scheme.primary, scheme.tertiary, 0.35)!,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.waving_hand_rounded,
                color: scheme.onPrimary.withValues(alpha: 0.95),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  greetingLine,
                  style: textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            organizationName,
            style: textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.dashboardSubtitle,
            style: textTheme.titleSmall?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.92),
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
