/// Route paths (doc §17).
abstract final class AppPaths {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String selectOrganization = '/select-organization';
  static const String organizationCreate = '/organizations/create';
  static const String home = '/home';
  static const String devNavigationRoutes = '/dev/routes';
  static const String settings = '/settings';
  static const String forbidden = '/forbidden';
  static const String profile = '/profile';
  static const String profilePhones = '/profile/phones';
  static const String orgSwitch = '/org/switch';

  static String orgProfile(String orgId) => '/org/$orgId';

  static String orgWorkers(String orgId) => '/org/$orgId/workers';
  static String orgWorkerAdd(String orgId) => '/org/$orgId/workers/add';
  static String orgWorkerDetail(String orgId, String workerId) =>
      '/org/$orgId/workers/$workerId';
  static String orgWorkerEdit(String orgId, String workerId) =>
      '/org/$orgId/workers/$workerId/edit';

  static String orgEngagements(String orgId) => '/org/$orgId/engagements';
  static String orgEngagementDetail(String orgId, String engagementId) =>
      '/org/$orgId/engagements/$engagementId';
  static String orgEngagementEdit(String orgId, String engagementId) =>
      '/org/$orgId/engagements/$engagementId/edit';
  static String orgWageRules(String orgId, String engagementId) =>
      '/org/$orgId/engagements/$engagementId/wage-rules';
  static String orgCommissionRules(String orgId, String engagementId) =>
      '/org/$orgId/engagements/$engagementId/commission-rules';
  static String orgWorkAssignments(String orgId, String engagementId) =>
      '/org/$orgId/engagements/$engagementId/assignments';

  static String orgCalendar(String orgId) => '/org/$orgId/calendar';

  static String orgAttendance(String orgId, String engagementId) =>
      '/org/$orgId/engagements/$engagementId/attendance';
  static String orgAttendanceNew(String orgId, String engagementId) =>
      '/org/$orgId/engagements/$engagementId/attendance/new';
  static String orgAttendanceDay(
    String orgId,
    String engagementId,
    String dayId,
  ) => '/org/$orgId/engagements/$engagementId/attendance/$dayId';

  static String orgAttendancePunch(String orgId, String dayId) =>
      '/org/$orgId/attendance-days/$dayId/punch';

  static String orgSales(String orgId, String engagementId) =>
      '/org/$orgId/engagements/$engagementId/sales';
  static String orgSaleNew(String orgId, String engagementId) =>
      '/org/$orgId/engagements/$engagementId/sales/new';
  static String orgSaleDetail(
    String orgId,
    String engagementId,
    String saleId,
  ) => '/org/$orgId/engagements/$engagementId/sales/$saleId';

  static String orgSites(String orgId) => '/org/$orgId/sites';
  static String orgSiteNew(String orgId) => '/org/$orgId/sites/new';
  static String orgSiteDetail(String orgId, String siteId) =>
      '/org/$orgId/sites/$siteId';
  static String orgSiteEdit(String orgId, String siteId) =>
      '/org/$orgId/sites/$siteId/edit';

  static String orgPayPeriods(String orgId) => '/org/$orgId/pay-periods';
  static String orgPayPeriodNew(String orgId) => '/org/$orgId/pay-periods/new';
  static String orgPayPeriodDetail(String orgId, String periodId) =>
      '/org/$orgId/pay-periods/$periodId';
  static String orgPayPeriodLock(String orgId, String periodId) =>
      '/org/$orgId/pay-periods/$periodId/lock';

  static String orgPayments(String orgId) => '/org/$orgId/payments';
  static String orgPaymentNew(String orgId) => '/org/$orgId/payments/new';

  static String orgRatings(String orgId) => '/org/$orgId/ratings';
  static String orgRatingNew(String orgId) => '/org/$orgId/ratings/new';

  static String orgReportAttendance(String orgId) =>
      '/org/$orgId/reports/attendance';
  static String orgReportExport(String orgId) => '/org/$orgId/reports/export';
}
