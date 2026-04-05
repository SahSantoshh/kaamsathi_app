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
            icon: const Icon(Icons.search_rounded),
            tooltip: l10n.dashboardSearchTooltip,
            onPressed: () => context.push(AppPaths.search),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {}, // Add notifications if available
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.pgSettings,
            onPressed: () => context.push(AppPaths.settings),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          _DashboardHero(
            l10n: l10n,
            scheme: scheme,
            organizationName: orgTitle,
            displayName: displayName,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.dashboardOrgSummaryTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () => context.push(AppPaths.profile),
                child: Text(l10n.pgProfile),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          orgDetail.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickActionChip(
                    onPressed: () => context.push(AppPaths.orgWorkerAdd(o)),
                    icon: Icons.person_add_rounded,
                    label: l10n.pgWorkerAdd,
                    color: Colors.blue.shade50,
                    iconColor: Colors.blue.shade700,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionChip(
                    onPressed: () => context.push(AppPaths.orgSiteNew(o)),
                    icon: Icons.add_location_alt_outlined,
                    label: l10n.pgSiteNew,
                    color: Colors.orange.shade50,
                    iconColor: Colors.orange.shade700,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionChip(
                    onPressed: () => context.push(AppPaths.orgPayPeriodNew(o)),
                    icon: Icons.date_range_outlined,
                    label: l10n.pgPayPeriodNew,
                    color: Colors.green.shade50,
                    iconColor: Colors.green.shade700,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            l10n.dashboardPrimaryTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.1,
            children: <Widget>[
              _DashTile(
                icon: Icons.groups_rounded,
                label: l10n.pgWorkersList,
                color: Colors.indigo.shade50,
                iconColor: Colors.indigo.shade700,
                onTap: () => context.push(AppPaths.orgWorkers(o)),
              ),
              _DashTile(
                icon: Icons.apartment_rounded,
                label: l10n.pgSitesList,
                color: Colors.purple.shade50,
                iconColor: Colors.purple.shade700,
                onTap: () => context.push(AppPaths.orgSites(o)),
              ),
              _DashTile(
                icon: Icons.handshake_rounded,
                label: l10n.pgEngagementsList,
                color: Colors.teal.shade50,
                iconColor: Colors.teal.shade700,
                onTap: () => context.push(AppPaths.orgEngagements(o)),
              ),
              _DashTile(
                icon: Icons.payments_outlined,
                label: l10n.pgPayPeriodsList,
                color: Colors.amber.shade50,
                iconColor: Colors.amber.shade900,
                onTap: () => context.push(AppPaths.orgPayPeriods(o)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DashTileFull(
            icon: Icons.calendar_month_rounded,
            label: l10n.pgCalendar,
            onTap: () => context.push(AppPaths.orgCalendar(o)),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashTileFull extends StatelessWidget {
  const _DashTileFull({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, size: 32, color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: scheme.primary),
            ],
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
