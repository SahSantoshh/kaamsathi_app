// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KaamSathi';

  @override
  String get navHome => 'Home';

  @override
  String get navAccount => 'Account';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get authBrandTagline => 'Work, wages, and trust — in one place.';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authCreateAccountTitle => 'Create your account';

  @override
  String get authForgotPasswordTitle => 'Reset password';

  @override
  String get authMethodPhone => 'Phone';

  @override
  String get authMethodEmail => 'Email';

  @override
  String get authPhoneHint => 'Mobile number';

  @override
  String get authPhoneHelper => 'We’ll send a one-time code by SMS.';

  @override
  String get authEmailHintOptional => 'Email (optional)';

  @override
  String get authPhoneHintOptional => 'Phone (optional)';

  @override
  String get authOtpPhoneOrEmailHelper =>
      'Enter phone or email (or both if the server asks). The 6-digit code is sent to your account email.';

  @override
  String get authOtpEmailPairingHelper =>
      'If sign-up asks for it, add the email that matches this phone.';

  @override
  String get authPasswordLoginIdentifierHelper =>
      'Use your email, your phone, or both if your account requires it.';

  @override
  String get authErrorOtpNeedIdentifier =>
      'Enter at least a phone number or an email.';

  @override
  String get authErrorEmailOrPhoneRequired =>
      'Enter your email or phone number (or both).';

  @override
  String get authOtpHint => '6-digit code';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authVerifyAndSignIn => 'Verify & sign in';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authConfirmPasswordHint => 'Confirm password';

  @override
  String get authFullNameHint => 'Full name';

  @override
  String get authSignInCta => 'Sign in';

  @override
  String get authSignUpCta => 'Create account';

  @override
  String get authForgotPasswordCta => 'Send reset link';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email or phone. We’ll send instructions to get you back in.';

  @override
  String get authResetSentTitle => 'Check your inbox';

  @override
  String get authResetSentBody =>
      'If an account exists for that address, you’ll receive reset instructions shortly.';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authNoAccount => 'Don’t have an account?';

  @override
  String get authHasAccount => 'Already have an account?';

  @override
  String get authForgotPasswordLink => 'Forgot password?';

  @override
  String get authTermsPrefix => 'I agree to the ';

  @override
  String get authTermsLink => 'Terms';

  @override
  String get authTermsAnd => ' and ';

  @override
  String get authPrivacyLink => 'Privacy Policy';

  @override
  String get authErrorPhoneInvalid => 'Enter a valid phone number';

  @override
  String get authErrorEmailInvalid => 'Enter a valid email';

  @override
  String get authErrorPasswordShort => 'At least 6 characters';

  @override
  String get authErrorOtpShort => 'Enter the code we sent you';

  @override
  String get authErrorTerms => 'Please accept the terms to continue';

  @override
  String get authErrorNetwork =>
      'Something went wrong. Check your connection and try again.';

  @override
  String get authApiSignUpExplainer =>
      'New accounts are created when you sign in with a sign-in code: on the login screen, choose Phone, enter your phone and/or email, and confirm the 6-digit code sent to your account email. If the server returns an error, add the missing phone or email and try again.';

  @override
  String get authForgotPasswordStep1Subtitle =>
      'Enter the phone number or email on your account. We’ll email a 6-digit reset code (use that code here — not a login code).';

  @override
  String get authForgotPasswordStep2Subtitle =>
      'Enter the code from the email and choose a new password.';

  @override
  String get authForgotPasswordNewPasswordCta => 'Save new password & sign in';

  @override
  String get authUsePhoneSignInCta => 'Use phone sign-in';

  @override
  String get authCodeSentSnackbar => 'Code sent — check your messages.';

  @override
  String get authForgotResetCodeSentSnackbar =>
      'If that account exists, we emailed a reset code. Check your inbox.';

  @override
  String get authErrorNameShort => 'Enter your name';

  @override
  String get authPasswordMismatch => 'Passwords must match';

  @override
  String get authTermsShort => 'I agree to the Terms and Privacy Policy';

  @override
  String get authSignUpSuccessSnackbar =>
      'Account request received. Sign in when your org invites you.';

  @override
  String get loginSubtitle =>
      'Sign in to manage your organization—roster, sites, payroll, and reports. Worker-focused tools will grow in a later release; contractee (client) experiences may come as separate flows when the product expands.';

  @override
  String get goToLogin => 'Go to login';

  @override
  String get retry => 'Retry';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get emptyStateCta => 'Get started';

  @override
  String get authPlaceholderAction => 'OTP / password flow (soon)';

  @override
  String get backToHome => 'Back to home';

  @override
  String get sessionSignOut => 'Sign out';

  @override
  String get sessionYourRoleTitle => 'Your role in this organization';

  @override
  String get sessionRoleOrganizationOwner => 'Organization owner';

  @override
  String get sessionRoleWorkerLabel => 'Worker';

  @override
  String get settingsBuildFocusHint =>
      'This version is built for organization owners (contractors). Worker and contractee journeys will be expanded as the product grows.';

  @override
  String get sessionClearOrg => 'Clear selected organization';

  @override
  String get settingsSessionSection => 'Account';

  @override
  String get loginGuestHint =>
      'Sign in to open the home dashboard and org routes.';

  @override
  String get placeholderPageBody =>
      'This area is coming soon. You’ll manage everything here once connected to your account.';

  @override
  String get featureComingSoonDetail =>
      'Backend: KaamSathi API (see project docs).';

  @override
  String get splashLoading => 'Loading…';

  @override
  String get selectOrgTitle => 'Which organization?';

  @override
  String get selectOrgSubtitle =>
      'Choose the organization you’re managing. You can switch anytime.';

  @override
  String get selectOrgLoadError =>
      'Could not load your organizations. Check your connection and try again.';

  @override
  String get selectOrgRetry => 'Retry';

  @override
  String get selectOrgEmpty =>
      'You’re not a member of any organization yet. Create one or ask an admin to invite you.';

  @override
  String get selectOrgTapToOpen => 'Tap to open this workspace';

  @override
  String get selectOrgUnnamed => 'Organization';

  @override
  String get orgSetAsDefault => 'Set as default';

  @override
  String get orgDefaultBadge => 'Default on this device';

  @override
  String get orgDefaultSavedSnackbar =>
      'Default organization saved on this device';

  @override
  String get orgCreateNameLabel => 'Organization name';

  @override
  String get orgCreateNameValidation => 'Enter a name';

  @override
  String get orgCreateTypeLabel => 'Type (optional)';

  @override
  String get orgCreateTypeNone => 'None';

  @override
  String get orgCreateTypeContractor => 'Contractor';

  @override
  String get orgCreateTypeCompany => 'Company';

  @override
  String get orgCreateAddressLabel => 'Address (optional)';

  @override
  String get orgCreateSubmit => 'Create organization';

  @override
  String get orgCreateSuccessSnackbar => 'Organization created — opening home';

  @override
  String get orgCreateErrorGeneric => 'Could not create organization';

  @override
  String get orgProfileLoadError => 'Could not load this organization.';

  @override
  String get orgProfileReadOnly =>
      'You can view this profile. Only managers can edit details.';

  @override
  String get orgProfileEdit => 'Edit';

  @override
  String get orgProfileSave => 'Save changes';

  @override
  String get orgProfileSavedSnackbar => 'Organization updated';

  @override
  String get orgFieldName => 'Name';

  @override
  String get orgFieldType => 'Type';

  @override
  String get orgFieldAddress => 'Address';

  @override
  String get orgVerificationStatus => 'Verification';

  @override
  String get orgCreatedAt => 'Created';

  @override
  String get orgMetaUnknown => '—';

  @override
  String get orgPayScheduleSection => 'Pay schedule';

  @override
  String get orgPayScheduleHelper =>
      'Used for reminders and future payroll automation. Pay periods today still use explicit start and end dates.';

  @override
  String get orgPayScheduleFrequency => 'Payroll cadence (frequency)';

  @override
  String get orgPayScheduleAnchorDay => 'Anchor day (1–31)';

  @override
  String get orgPayScheduleAnchorDayError => 'Enter a day from 1 to 31';

  @override
  String get orgPayFrequencyMonthly => 'Monthly';

  @override
  String get orgPayFrequencyWeekly => 'Weekly';

  @override
  String get orgPayFrequencyBiweekly => 'Bi-weekly';

  @override
  String orgPayFrequencyCustom(String value) {
    return 'Custom: $value';
  }

  @override
  String get orgDelete => 'Delete organization';

  @override
  String get orgDeleteConfirmTitle => 'Delete this organization?';

  @override
  String get orgDeleteConfirmMessage =>
      'This permanently removes the organization and related data you are allowed to delete on the server. You cannot undo this.';

  @override
  String get orgDeleteConfirmCta => 'Delete';

  @override
  String get orgDeletedSnackbar => 'Organization deleted';

  @override
  String get orgDeleteError => 'Could not delete organization';

  @override
  String get orgSwitchRedirecting => 'Opening organization list…';

  @override
  String get dashboardCurrentOrgLabel => 'Current workspace';

  @override
  String get dashboardOrgFallback => 'Your organization';

  @override
  String get dashboardGreeting => 'Hello';

  @override
  String dashboardGreetingNamed(String name) {
    return 'Hello, $name';
  }

  @override
  String get dashboardSubtitle =>
      'Run your team, sites, and payroll from one place';

  @override
  String get dashboardOrgSummaryTitle => 'Workspace';

  @override
  String get dashboardViewOrgProfile => 'Organization profile';

  @override
  String dashboardPayScheduleLine(String frequency, int day) {
    return 'Pay schedule: $frequency · anchor day $day';
  }

  @override
  String get dashboardPrimaryTitle => 'Explore';

  @override
  String get dashboardManagerActionsTitle => 'Quick add';

  @override
  String get dashboardSwitchOrg => 'Switch organization';

  @override
  String get dashboardNewOrganization => 'New organization';

  @override
  String get dashboardMoreTitle => 'More';

  @override
  String get dashboardRatingsReports => 'Ratings & reports';

  @override
  String get pgDevNavigationRoutes => 'Navigation catalog (debug)';

  @override
  String get devRoutesSubtitle =>
      'All registered routes with sample IDs for development.';

  @override
  String get settingsDevToolsSection => 'Developer';

  @override
  String get dashboardSectionShell => 'App shell';

  @override
  String get dashboardSectionProfile => 'Profile & phones';

  @override
  String get dashboardSectionOrg => 'Organization';

  @override
  String get dashboardSectionRoster => 'Workers & roster';

  @override
  String get dashboardSectionEngagements => 'Engagements';

  @override
  String get dashboardSectionSchedule => 'Schedule';

  @override
  String get dashboardSectionAttendance => 'Attendance';

  @override
  String get dashboardSectionSales => 'Commission sales';

  @override
  String get dashboardSectionSites => 'Project sites';

  @override
  String get dashboardSectionPayroll => 'Payroll';

  @override
  String get dashboardSectionRatingsReports => 'Ratings & reports';

  @override
  String get pgSplash => 'Starting…';

  @override
  String get pgSelectOrganization => 'Select organization';

  @override
  String get pgOrganizationCreate => 'Create organization';

  @override
  String get pgHome => 'Home';

  @override
  String get pgSettings => 'Settings';

  @override
  String get pgForbidden => 'No access';

  @override
  String get pgProfile => 'Profile';

  @override
  String get profileMeDataHint =>
      'Your account details will appear here after the app refreshes your session.';

  @override
  String profilePhonesOnFile(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phone numbers on your profile',
      one: '1 phone number on your profile',
    );
    return '$_temp0';
  }

  @override
  String get pgProfilePhones => 'Phone numbers';

  @override
  String get pgOrgSwitch => 'Switch organization';

  @override
  String get pgOrgProfile => 'Organization profile';

  @override
  String get pgWorkersList => 'Workers';

  @override
  String get pgWorkerDetail => 'Worker';

  @override
  String get pgWorkerEdit => 'Edit worker';

  @override
  String get pgWorkerAdd => 'Add worker';

  @override
  String get pgEngagementsList => 'Engagements';

  @override
  String get pgEngagementDetail => 'Engagement';

  @override
  String get pgEngagementEdit => 'Edit engagement';

  @override
  String get pgWageRules => 'Wage rules';

  @override
  String get pgCommissionRules => 'Commission rules';

  @override
  String get pgWorkAssignments => 'Work assignments';

  @override
  String get pgCalendar => 'Calendar';

  @override
  String get pgAttendanceList => 'Attendance';

  @override
  String get pgAttendanceNew => 'New attendance day';

  @override
  String get pgAttendanceDay => 'Attendance day';

  @override
  String get pgTimePunch => 'Time punch';

  @override
  String get pgSalesList => 'Commission sales';

  @override
  String get pgSaleNew => 'New sale';

  @override
  String get pgSaleDetail => 'Sale';

  @override
  String get pgSitesList => 'Project sites';

  @override
  String get pgSiteDetail => 'Site';

  @override
  String get pgSiteNew => 'New site';

  @override
  String get pgSiteEdit => 'Edit site';

  @override
  String get pgPayPeriodsList => 'Pay periods';

  @override
  String get pgPayPeriodDetail => 'Pay period';

  @override
  String get pgPayPeriodNew => 'New pay period';

  @override
  String get pgPayPeriodLock => 'Lock pay period';

  @override
  String get pgPaymentsList => 'Payments';

  @override
  String get pgPaymentNew => 'Record payment';

  @override
  String get pgRatingsList => 'Ratings';

  @override
  String get pgRatingNew => 'Rate organization';

  @override
  String get pgReportAttendance => 'Attendance report';

  @override
  String get pgReportExport => 'Export report';

  @override
  String get workersRosterSubtitle =>
      'People engaged with your organization. Pull to refresh when live data is on.';

  @override
  String get workersSearchHint => 'Search by name or phone';

  @override
  String get workersAddWorker => 'Add worker';

  @override
  String get workersContactSection => 'Contact';

  @override
  String get workersSkillsSection => 'Skills & role';

  @override
  String get workersPayoutSection => 'Payout';

  @override
  String get workersNotesSection => 'Notes';

  @override
  String get workersPhone => 'Phone';

  @override
  String get workersEmail => 'Email';

  @override
  String get workersJoined => 'Joined';

  @override
  String get workersBankAccount => 'Bank account';

  @override
  String get workersSaveChanges => 'Save changes';

  @override
  String get workersSearchByPhoneTitle => 'Find by phone';

  @override
  String get workersSearchByPhoneSubtitle =>
      'Search an E.164 number to link an existing user or start onboarding.';

  @override
  String get workersSearchButton => 'Search';

  @override
  String get workersSearchMatchTitle => 'Match found';

  @override
  String get workersSearchMatchSubtitle =>
      'Review details before adding this person to the roster.';

  @override
  String get workersAddToOrganization => 'Add to organization';

  @override
  String get workersEmptyTitle => 'No workers yet';

  @override
  String get workersEmptyBody =>
      'When your team is connected, everyone engaged with this organization will appear here.';

  @override
  String get workersNotFoundTitle => 'Worker not found';

  @override
  String get workersNotFoundBody =>
      'This worker could not be found. Open the list and pick someone from your team.';

  @override
  String get workersSnackbarSaved => 'Changes saved';

  @override
  String get workersSnackbarAdded => 'Worker added';

  @override
  String get workersDemoBadge => 'Sample data';
}
