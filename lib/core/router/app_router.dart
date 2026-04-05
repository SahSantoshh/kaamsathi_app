import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../session/auth_state.dart';
import '../session/auth_session_notifier.dart';
import '../../features/attendance/presentation/attendance_screens.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/commission_sales/presentation/commission_sale_screens.dart';
import '../../features/engagements/presentation/engagement_screens.dart';
import '../../features/forbidden/presentation/forbidden_screen.dart';
import '../../features/home/presentation/app_search_screen.dart';
import '../../features/home/presentation/dev_navigation_routes_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/organization/presentation/org_profile_screen.dart';
import '../../features/organization_switcher/presentation/org_switch_screen.dart';
import '../../features/organization_switcher/presentation/organization_create_screen.dart';
import '../../features/organization_switcher/presentation/select_organization_screen.dart';
import '../../features/payroll/presentation/payroll_screens.dart';
import '../../features/profile/presentation/profile_phones_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/project_sites/presentation/project_site_screens.dart';
import '../../features/ratings_reports/presentation/ratings_reports_screens.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/workers/presentation/worker_screens.dart';
import 'app_paths.dart';
import 'auth_redirect.dart';

final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<int> authTick = ValueNotifier<int>(0);
  ref.listen(authSessionProvider, (AuthState? previous, AuthState next) {
    authTick.value++;
  });
  ref.onDispose(authTick.dispose);

  final GoRouter router = GoRouter(
    initialLocation: AppPaths.splash,
    debugLogDiagnostics: false,
    refreshListenable: authTick,
    redirect: (BuildContext context, GoRouterState state) {
      return computeAuthRedirect(
        auth: ref.read(authSessionProvider),
        state: state,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (BuildContext context, GoRouterState state) =>
            AppPaths.splash,
      ),
      GoRoute(
        path: AppPaths.splash,
        name: SplashScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: AppPaths.login,
        name: LoginScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppPaths.signUp,
        name: SignUpScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: AppPaths.forgotPassword,
        name: ForgotPasswordScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: AppPaths.selectOrganization,
        name: SelectOrganizationScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const SelectOrganizationScreen();
        },
      ),
      GoRoute(
        path: AppPaths.organizationCreate,
        name: OrganizationCreateScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const OrganizationCreateScreen();
        },
      ),
      GoRoute(
        path: AppPaths.home,
        name: HomeScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: AppPaths.search,
        name: AppSearchScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const AppSearchScreen();
        },
      ),
      GoRoute(
        path: AppPaths.devNavigationRoutes,
        name: DevNavigationRoutesScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const DevNavigationRoutesScreen();
        },
      ),
      GoRoute(
        path: AppPaths.settings,
        name: SettingsScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: AppPaths.forbidden,
        name: ForbiddenScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const ForbiddenScreen();
        },
      ),
      GoRoute(
        path: AppPaths.profile,
        name: ProfileScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileScreen();
        },
      ),
      GoRoute(
        path: AppPaths.profilePhones,
        name: ProfilePhonesScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const ProfilePhonesScreen();
        },
      ),
      GoRoute(
        path: AppPaths.orgSwitch,
        name: OrgSwitchScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return const OrgSwitchScreen();
        },
      ),
      // —— Org-scoped: register specific paths before `/org/:orgId`. ——
      GoRoute(
        path: '/org/:orgId/workers/add',
        name: WorkerAddScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return WorkerAddScreen(
            orgId: state.pathParameters['orgId']!,
            projectSiteId: state.uri.queryParameters['site'],
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/workers/:workerId/edit',
        name: WorkerEditScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return WorkerEditScreen(
            orgId: state.pathParameters['orgId']!,
            workerId: state.pathParameters['workerId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/workers/:workerId',
        name: WorkerDetailScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return WorkerDetailScreen(
            orgId: state.pathParameters['orgId']!,
            workerId: state.pathParameters['workerId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/workers',
        name: WorkerListScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return WorkerListScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/attendance/new',
        name: AttendanceDayNewScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return AttendanceDayNewScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/attendance/:dayId',
        name: AttendanceDayScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return AttendanceDayScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
            dayId: state.pathParameters['dayId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/attendance',
        name: AttendanceListScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return AttendanceListScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/sales/new',
        name: CommissionSaleNewScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return CommissionSaleNewScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/sales/:saleId',
        name: CommissionSaleDetailScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return CommissionSaleDetailScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
            saleId: state.pathParameters['saleId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/sales',
        name: CommissionSalesListScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return CommissionSalesListScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/edit',
        name: EngagementEditScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return EngagementEditScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/wage-rules',
        name: WageRulesScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return WageRulesScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/commission-rules',
        name: CommissionRulesScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return CommissionRulesScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId/assignments',
        name: WorkAssignmentsScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return WorkAssignmentsScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements/:engagementId',
        name: EngagementDetailScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return EngagementDetailScreen(
            orgId: state.pathParameters['orgId']!,
            engagementId: state.pathParameters['engagementId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/engagements',
        name: EngagementListScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return EngagementListScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/attendance-days/:dayId/punch',
        name: TimePunchScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return TimePunchScreen(
            orgId: state.pathParameters['orgId']!,
            dayId: state.pathParameters['dayId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/calendar',
        name: CalendarScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return CalendarScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/sites/new',
        name: ProjectSiteNewScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return ProjectSiteNewScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/sites/:siteId/edit',
        name: ProjectSiteEditScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return ProjectSiteEditScreen(
            orgId: state.pathParameters['orgId']!,
            siteId: state.pathParameters['siteId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/sites/:siteId',
        name: ProjectSiteDetailScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return ProjectSiteDetailScreen(
            orgId: state.pathParameters['orgId']!,
            siteId: state.pathParameters['siteId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/sites',
        name: ProjectSitesListScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return ProjectSitesListScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/pay-periods/new',
        name: PayPeriodNewScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return PayPeriodNewScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/pay-periods/:periodId/lock',
        name: PayPeriodLockScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return PayPeriodLockScreen(
            orgId: state.pathParameters['orgId']!,
            periodId: state.pathParameters['periodId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/pay-periods/:periodId',
        name: PayPeriodDetailScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return PayPeriodDetailScreen(
            orgId: state.pathParameters['orgId']!,
            periodId: state.pathParameters['periodId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/pay-periods',
        name: PayPeriodsListScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return PayPeriodsListScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/payments/new',
        name: PaymentRecordNewScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return PaymentRecordNewScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/payments',
        name: PaymentRecordsListScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return PaymentRecordsListScreen(
            orgId: state.pathParameters['orgId']!,
          );
        },
      ),
      GoRoute(
        path: '/org/:orgId/ratings/new',
        name: OrgRatingNewScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return OrgRatingNewScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/ratings',
        name: OrgRatingsListScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return OrgRatingsListScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/reports/attendance',
        name: ReportsAttendanceScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return ReportsAttendanceScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId/reports/export',
        name: ReportsExportScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return ReportsExportScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
      GoRoute(
        path: '/org/:orgId',
        name: OrgProfileScreen.name,
        builder: (BuildContext context, GoRouterState state) {
          return OrgProfileScreen(orgId: state.pathParameters['orgId']!);
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
