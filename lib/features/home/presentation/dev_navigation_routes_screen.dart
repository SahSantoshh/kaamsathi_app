import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/router/route_placeholders.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';

/// Debug-only catalog of registered routes with sample IDs ([RoutePlaceholders]).
class DevNavigationRoutesScreen extends ConsumerWidget {
  const DevNavigationRoutesScreen({super.key});

  static const String name = RouteNames.devNavigationRoutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String? orgId = ref.watch(authSessionProvider).selectedOrganizationId;
    if (orgId == null || orgId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.pgDevNavigationRoutes)),
        body: Center(child: Text(l10n.selectOrgEmpty)),
      );
    }
    final String o = orgId;
    final String w = RoutePlaceholders.workerId;
    final String e = RoutePlaceholders.engagementId;
    final String s = RoutePlaceholders.siteId;
    final String p = RoutePlaceholders.payPeriodId;
    final String d = RoutePlaceholders.attendanceDayId;
    final String sale = RoutePlaceholders.saleId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgDevNavigationRoutes)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              l10n.devRoutesSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          _section(context, scheme, l10n.dashboardSectionShell, <_DevDashLink>[
            _DevDashLink(
              l10n.pgSelectOrganization,
              AppPaths.selectOrganization,
            ),
            _DevDashLink(
              l10n.pgOrganizationCreate,
              AppPaths.organizationCreate,
            ),
            _DevDashLink(l10n.pgOrgSwitch, AppPaths.orgSwitch),
            _DevDashLink(l10n.pgForbidden, AppPaths.forbidden),
          ]),
          _section(
            context,
            scheme,
            l10n.dashboardSectionProfile,
            <_DevDashLink>[
              _DevDashLink(l10n.pgProfile, AppPaths.profile),
              _DevDashLink(l10n.pgProfilePhones, AppPaths.profilePhones),
            ],
          ),
          _section(context, scheme, l10n.dashboardSectionOrg, <_DevDashLink>[
            _DevDashLink(l10n.pgOrgProfile, AppPaths.orgProfile(o)),
          ]),
          _section(context, scheme, l10n.dashboardSectionRoster, <_DevDashLink>[
            _DevDashLink(l10n.pgWorkersList, AppPaths.orgWorkers(o)),
            _DevDashLink(l10n.pgWorkerAdd, AppPaths.orgWorkerAdd(o)),
            _DevDashLink(l10n.pgWorkerDetail, AppPaths.orgWorkerDetail(o, w)),
            _DevDashLink(l10n.pgWorkerEdit, AppPaths.orgWorkerEdit(o, w)),
          ]),
          _section(
            context,
            scheme,
            l10n.dashboardSectionEngagements,
            <_DevDashLink>[
              _DevDashLink(l10n.pgEngagementsList, AppPaths.orgEngagements(o)),
              _DevDashLink(
                l10n.pgEngagementDetail,
                AppPaths.orgEngagementDetail(o, e),
              ),
              _DevDashLink(
                l10n.pgEngagementEdit,
                AppPaths.orgEngagementEdit(o, e),
              ),
              _DevDashLink(l10n.pgWageRules, AppPaths.orgWageRules(o, e)),
              _DevDashLink(
                l10n.pgCommissionRules,
                AppPaths.orgCommissionRules(o, e),
              ),
              _DevDashLink(
                l10n.pgWorkAssignments,
                AppPaths.orgWorkAssignments(o, e),
              ),
            ],
          ),
          _section(
            context,
            scheme,
            l10n.dashboardSectionSchedule,
            <_DevDashLink>[
              _DevDashLink(l10n.pgCalendar, AppPaths.orgCalendar(o)),
            ],
          ),
          _section(context, scheme, l10n.dashboardSectionAttendance, <
            _DevDashLink
          >[
            _DevDashLink(l10n.pgAttendanceList, AppPaths.orgAttendance(o, e)),
            _DevDashLink(l10n.pgAttendanceNew, AppPaths.orgAttendanceNew(o, e)),
            _DevDashLink(
              l10n.pgAttendanceDay,
              AppPaths.orgAttendanceDay(o, e, d),
            ),
            _DevDashLink(l10n.pgTimePunch, AppPaths.orgAttendancePunch(o, d)),
          ]),
          _section(context, scheme, l10n.dashboardSectionSales, <_DevDashLink>[
            _DevDashLink(l10n.pgSalesList, AppPaths.orgSales(o, e)),
            _DevDashLink(l10n.pgSaleNew, AppPaths.orgSaleNew(o, e)),
            _DevDashLink(l10n.pgSaleDetail, AppPaths.orgSaleDetail(o, e, sale)),
          ]),
          _section(context, scheme, l10n.dashboardSectionSites, <_DevDashLink>[
            _DevDashLink(l10n.pgSitesList, AppPaths.orgSites(o)),
            _DevDashLink(l10n.pgSiteNew, AppPaths.orgSiteNew(o)),
            _DevDashLink(l10n.pgSiteDetail, AppPaths.orgSiteDetail(o, s)),
            _DevDashLink(l10n.pgSiteEdit, AppPaths.orgSiteEdit(o, s)),
          ]),
          _section(context, scheme, l10n.dashboardSectionPayroll, <
            _DevDashLink
          >[
            _DevDashLink(l10n.pgPayPeriodsList, AppPaths.orgPayPeriods(o)),
            _DevDashLink(l10n.pgPayPeriodNew, AppPaths.orgPayPeriodNew(o)),
            _DevDashLink(
              l10n.pgPayPeriodDetail,
              AppPaths.orgPayPeriodDetail(o, p),
            ),
            _DevDashLink(l10n.pgPayPeriodLock, AppPaths.orgPayPeriodLock(o, p)),
            _DevDashLink(l10n.pgPaymentsList, AppPaths.orgPayments(o)),
            _DevDashLink(l10n.pgPaymentNew, AppPaths.orgPaymentNew(o)),
          ]),
          _section(
            context,
            scheme,
            l10n.dashboardSectionRatingsReports,
            <_DevDashLink>[
              _DevDashLink(l10n.pgRatingsList, AppPaths.orgRatings(o)),
              _DevDashLink(l10n.pgRatingNew, AppPaths.orgRatingNew(o)),
              _DevDashLink(
                l10n.pgReportAttendance,
                AppPaths.orgReportAttendance(o),
              ),
              _DevDashLink(l10n.pgReportExport, AppPaths.orgReportExport(o)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  static Widget _section(
    BuildContext context,
    ColorScheme scheme,
    String title,
    List<_DevDashLink> links,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
              for (int i = 0; i < links.length; i++) ...<Widget>[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ListTile(
                  title: Text(links[i].label),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  onTap: () => context.push(links[i].path),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DevDashLink {
  const _DevDashLink(this.label, this.path);

  final String label;
  final String path;
}
