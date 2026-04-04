import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'KaamSathi'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @authBrandTagline.
  ///
  /// In en, this message translates to:
  /// **'Work, wages, and trust — in one place.'**
  String get authBrandTagline;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authCreateAccountTitle;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authMethodPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get authMethodPhone;

  /// No description provided for @authMethodEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authMethodEmail;

  /// No description provided for @authMethodOtp.
  ///
  /// In en, this message translates to:
  /// **'One-time code'**
  String get authMethodOtp;

  /// No description provided for @authMethodPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authMethodPassword;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get authPhoneHint;

  /// No description provided for @phoneCountrySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search country or code'**
  String get phoneCountrySearchHint;

  /// No description provided for @authPhoneHelper.
  ///
  /// In en, this message translates to:
  /// **'We’ll send a one-time code by SMS.'**
  String get authPhoneHelper;

  /// No description provided for @authEmailHintOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get authEmailHintOptional;

  /// No description provided for @authPhoneHintOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get authPhoneHintOptional;

  /// No description provided for @authOtpPhoneOrEmailHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter phone or email (or both if the server asks). The 6-digit code is sent to your account email.'**
  String get authOtpPhoneOrEmailHelper;

  /// No description provided for @authOtpEmailPairingHelper.
  ///
  /// In en, this message translates to:
  /// **'If sign-up asks for it, add the email that matches this phone.'**
  String get authOtpEmailPairingHelper;

  /// No description provided for @authPasswordLoginIdentifierHelper.
  ///
  /// In en, this message translates to:
  /// **'Use your email, your phone, or both if your account requires it.'**
  String get authPasswordLoginIdentifierHelper;

  /// No description provided for @authErrorOtpNeedIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Enter at least a phone number or an email.'**
  String get authErrorOtpNeedIdentifier;

  /// No description provided for @authErrorEmailOrPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number (or both).'**
  String get authErrorEmailOrPhoneRequired;

  /// No description provided for @authOtpHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get authOtpHint;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authVerifyAndSignIn.
  ///
  /// In en, this message translates to:
  /// **'Verify & sign in'**
  String get authVerifyAndSignIn;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullNameHint;

  /// No description provided for @authSignInCta.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInCta;

  /// No description provided for @authSignUpCta.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUpCta;

  /// No description provided for @authForgotPasswordCta.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authForgotPasswordCta;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone. We’ll send instructions to get you back in.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authResetSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get authResetSentTitle;

  /// No description provided for @authResetSentBody.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that address, you’ll receive reset instructions shortly.'**
  String get authResetSentBody;

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get authNoAccount;

  /// No description provided for @authHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHasAccount;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPasswordLink;

  /// No description provided for @authTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get authTermsPrefix;

  /// No description provided for @authTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get authTermsLink;

  /// No description provided for @authTermsAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get authTermsAnd;

  /// No description provided for @authPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyLink;

  /// No description provided for @authErrorPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get authErrorPhoneInvalid;

  /// No description provided for @authErrorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authErrorEmailInvalid;

  /// No description provided for @authErrorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authErrorPasswordShort;

  /// No description provided for @authErrorOtpShort.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent you'**
  String get authErrorOtpShort;

  /// No description provided for @authErrorTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue'**
  String get authErrorTerms;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Check your connection and try again.'**
  String get authErrorNetwork;

  /// No description provided for @authApiSignUpExplainer.
  ///
  /// In en, this message translates to:
  /// **'New accounts are created when you sign in with a sign-in code: on the login screen, choose One-time code, enter your phone and/or email, and confirm the 6-digit code sent to your account email. If the server returns an error, add the missing phone or email and try again.'**
  String get authApiSignUpExplainer;

  /// No description provided for @authForgotPasswordStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number or email on your account. We’ll email a 6-digit reset code (use that code here — not a login code).'**
  String get authForgotPasswordStep1Subtitle;

  /// No description provided for @authForgotPasswordStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from the email and choose a new password.'**
  String get authForgotPasswordStep2Subtitle;

  /// No description provided for @authForgotPasswordNewPasswordCta.
  ///
  /// In en, this message translates to:
  /// **'Save new password & sign in'**
  String get authForgotPasswordNewPasswordCta;

  /// No description provided for @authUsePhoneSignInCta.
  ///
  /// In en, this message translates to:
  /// **'Use phone sign-in'**
  String get authUsePhoneSignInCta;

  /// No description provided for @authCodeSentSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Code sent — check your messages.'**
  String get authCodeSentSnackbar;

  /// No description provided for @authForgotResetCodeSentSnackbar.
  ///
  /// In en, this message translates to:
  /// **'If that account exists, we emailed a reset code. Check your inbox.'**
  String get authForgotResetCodeSentSnackbar;

  /// No description provided for @authErrorNameShort.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authErrorNameShort;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords must match'**
  String get authPasswordMismatch;

  /// No description provided for @authTermsShort.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Privacy Policy'**
  String get authTermsShort;

  /// No description provided for @authSignUpSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Account request received. Sign in when your org invites you.'**
  String get authSignUpSuccessSnackbar;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your organization—roster, sites, payroll, and reports. Worker-focused tools will grow in a later release; contractee (client) experiences may come as separate flows when the product expands.'**
  String get loginSubtitle;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateCta.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get emptyStateCta;

  /// No description provided for @authPlaceholderAction.
  ///
  /// In en, this message translates to:
  /// **'OTP / password flow (soon)'**
  String get authPlaceholderAction;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @sessionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get sessionSignOut;

  /// No description provided for @sessionYourRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Your role in this organization'**
  String get sessionYourRoleTitle;

  /// No description provided for @sessionRoleOrganizationOwner.
  ///
  /// In en, this message translates to:
  /// **'Organization owner'**
  String get sessionRoleOrganizationOwner;

  /// No description provided for @sessionRoleWorkerLabel.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get sessionRoleWorkerLabel;

  /// No description provided for @settingsBuildFocusHint.
  ///
  /// In en, this message translates to:
  /// **'This version is built for organization owners (contractors). Worker and contractee journeys will be expanded as the product grows.'**
  String get settingsBuildFocusHint;

  /// No description provided for @sessionClearOrg.
  ///
  /// In en, this message translates to:
  /// **'Clear selected organization'**
  String get sessionClearOrg;

  /// No description provided for @settingsSessionSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSessionSection;

  /// No description provided for @loginGuestHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to open the home dashboard and org routes.'**
  String get loginGuestHint;

  /// No description provided for @placeholderPageBody.
  ///
  /// In en, this message translates to:
  /// **'This area is coming soon. You’ll manage everything here once connected to your account.'**
  String get placeholderPageBody;

  /// No description provided for @featureComingSoonDetail.
  ///
  /// In en, this message translates to:
  /// **'Backend: KaamSathi API (see project docs).'**
  String get featureComingSoonDetail;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get splashLoading;

  /// No description provided for @selectOrgTitle.
  ///
  /// In en, this message translates to:
  /// **'Which organization?'**
  String get selectOrgTitle;

  /// No description provided for @selectOrgSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the organization you’re managing. You can switch anytime.'**
  String get selectOrgSubtitle;

  /// No description provided for @selectOrgLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your organizations. Check your connection and try again.'**
  String get selectOrgLoadError;

  /// No description provided for @selectOrgRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get selectOrgRetry;

  /// No description provided for @selectOrgEmpty.
  ///
  /// In en, this message translates to:
  /// **'You’re not a member of any organization yet. Create one or ask an admin to invite you.'**
  String get selectOrgEmpty;

  /// No description provided for @selectOrgTapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open this workspace'**
  String get selectOrgTapToOpen;

  /// No description provided for @selectOrgUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get selectOrgUnnamed;

  /// No description provided for @orgSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get orgSetAsDefault;

  /// No description provided for @orgDefaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default on this device'**
  String get orgDefaultBadge;

  /// No description provided for @orgDefaultSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Default organization saved on this device'**
  String get orgDefaultSavedSnackbar;

  /// No description provided for @orgCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Organization name'**
  String get orgCreateNameLabel;

  /// No description provided for @orgCreateNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get orgCreateNameValidation;

  /// No description provided for @orgCreateTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type (optional)'**
  String get orgCreateTypeLabel;

  /// No description provided for @orgCreateTypeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get orgCreateTypeNone;

  /// No description provided for @orgCreateTypeContractor.
  ///
  /// In en, this message translates to:
  /// **'Contractor'**
  String get orgCreateTypeContractor;

  /// No description provided for @orgCreateTypeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get orgCreateTypeCompany;

  /// No description provided for @orgCreateAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get orgCreateAddressLabel;

  /// No description provided for @orgCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create organization'**
  String get orgCreateSubmit;

  /// No description provided for @orgCreateSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Organization created — opening home'**
  String get orgCreateSuccessSnackbar;

  /// No description provided for @orgCreateErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not create organization'**
  String get orgCreateErrorGeneric;

  /// No description provided for @orgProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this organization.'**
  String get orgProfileLoadError;

  /// No description provided for @orgProfileReadOnly.
  ///
  /// In en, this message translates to:
  /// **'You can view this profile. Only managers can edit details.'**
  String get orgProfileReadOnly;

  /// No description provided for @orgProfileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get orgProfileEdit;

  /// No description provided for @orgProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get orgProfileSave;

  /// No description provided for @orgProfileSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Organization updated'**
  String get orgProfileSavedSnackbar;

  /// No description provided for @orgFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get orgFieldName;

  /// No description provided for @orgFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get orgFieldType;

  /// No description provided for @orgFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get orgFieldAddress;

  /// No description provided for @orgVerificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get orgVerificationStatus;

  /// No description provided for @orgCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get orgCreatedAt;

  /// No description provided for @orgMetaUnknown.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get orgMetaUnknown;

  /// No description provided for @orgPayScheduleSection.
  ///
  /// In en, this message translates to:
  /// **'Pay schedule'**
  String get orgPayScheduleSection;

  /// No description provided for @orgPayScheduleHelper.
  ///
  /// In en, this message translates to:
  /// **'Used for reminders and future payroll automation. Pay periods today still use explicit start and end dates.'**
  String get orgPayScheduleHelper;

  /// No description provided for @orgPayScheduleFrequency.
  ///
  /// In en, this message translates to:
  /// **'Payroll cadence (frequency)'**
  String get orgPayScheduleFrequency;

  /// No description provided for @orgPayScheduleAnchorDay.
  ///
  /// In en, this message translates to:
  /// **'Anchor day (1–31)'**
  String get orgPayScheduleAnchorDay;

  /// No description provided for @orgPayScheduleAnchorDayError.
  ///
  /// In en, this message translates to:
  /// **'Enter a day from 1 to 31'**
  String get orgPayScheduleAnchorDayError;

  /// No description provided for @orgPayFrequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get orgPayFrequencyMonthly;

  /// No description provided for @orgPayFrequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get orgPayFrequencyWeekly;

  /// No description provided for @orgPayFrequencyBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Bi-weekly'**
  String get orgPayFrequencyBiweekly;

  /// No description provided for @orgPayFrequencyCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom: {value}'**
  String orgPayFrequencyCustom(String value);

  /// No description provided for @orgDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete organization'**
  String get orgDelete;

  /// No description provided for @orgDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this organization?'**
  String get orgDeleteConfirmTitle;

  /// No description provided for @orgDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the organization and related data you are allowed to delete on the server. You cannot undo this.'**
  String get orgDeleteConfirmMessage;

  /// No description provided for @orgDeleteConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get orgDeleteConfirmCta;

  /// No description provided for @orgDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Organization deleted'**
  String get orgDeletedSnackbar;

  /// No description provided for @orgDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete organization'**
  String get orgDeleteError;

  /// No description provided for @orgSwitchRedirecting.
  ///
  /// In en, this message translates to:
  /// **'Opening organization list…'**
  String get orgSwitchRedirecting;

  /// No description provided for @dashboardCurrentOrgLabel.
  ///
  /// In en, this message translates to:
  /// **'Current workspace'**
  String get dashboardCurrentOrgLabel;

  /// No description provided for @dashboardOrgFallback.
  ///
  /// In en, this message translates to:
  /// **'Your organization'**
  String get dashboardOrgFallback;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get dashboardGreeting;

  /// No description provided for @dashboardGreetingNamed.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String dashboardGreetingNamed(String name);

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run your team, sites, and payroll from one place'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardOrgSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get dashboardOrgSummaryTitle;

  /// No description provided for @dashboardViewOrgProfile.
  ///
  /// In en, this message translates to:
  /// **'Organization profile'**
  String get dashboardViewOrgProfile;

  /// No description provided for @dashboardPayScheduleLine.
  ///
  /// In en, this message translates to:
  /// **'Pay schedule: {frequency} · anchor day {day}'**
  String dashboardPayScheduleLine(String frequency, int day);

  /// No description provided for @dashboardPrimaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get dashboardPrimaryTitle;

  /// No description provided for @dashboardManagerActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get dashboardManagerActionsTitle;

  /// No description provided for @dashboardSwitchOrg.
  ///
  /// In en, this message translates to:
  /// **'Switch organization'**
  String get dashboardSwitchOrg;

  /// No description provided for @dashboardMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get dashboardMoreTitle;

  /// No description provided for @dashboardRatingsReports.
  ///
  /// In en, this message translates to:
  /// **'Ratings & reports'**
  String get dashboardRatingsReports;

  /// No description provided for @pgDevNavigationRoutes.
  ///
  /// In en, this message translates to:
  /// **'Navigation catalog (debug)'**
  String get pgDevNavigationRoutes;

  /// No description provided for @devRoutesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All registered routes with sample IDs for development.'**
  String get devRoutesSubtitle;

  /// No description provided for @settingsDevToolsSection.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsDevToolsSection;

  /// No description provided for @dashboardSectionShell.
  ///
  /// In en, this message translates to:
  /// **'App shell'**
  String get dashboardSectionShell;

  /// No description provided for @dashboardSectionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile & phones'**
  String get dashboardSectionProfile;

  /// No description provided for @dashboardSectionOrg.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get dashboardSectionOrg;

  /// No description provided for @dashboardSectionRoster.
  ///
  /// In en, this message translates to:
  /// **'Workers & roster'**
  String get dashboardSectionRoster;

  /// No description provided for @dashboardSectionEngagements.
  ///
  /// In en, this message translates to:
  /// **'Engagements'**
  String get dashboardSectionEngagements;

  /// No description provided for @dashboardSectionSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get dashboardSectionSchedule;

  /// No description provided for @dashboardSectionAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get dashboardSectionAttendance;

  /// No description provided for @dashboardSectionSales.
  ///
  /// In en, this message translates to:
  /// **'Commission sales'**
  String get dashboardSectionSales;

  /// No description provided for @dashboardSectionSites.
  ///
  /// In en, this message translates to:
  /// **'Project sites'**
  String get dashboardSectionSites;

  /// No description provided for @dashboardSectionPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get dashboardSectionPayroll;

  /// No description provided for @dashboardSectionRatingsReports.
  ///
  /// In en, this message translates to:
  /// **'Ratings & reports'**
  String get dashboardSectionRatingsReports;

  /// No description provided for @pgSplash.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get pgSplash;

  /// No description provided for @pgSelectOrganization.
  ///
  /// In en, this message translates to:
  /// **'Select organization'**
  String get pgSelectOrganization;

  /// No description provided for @pgOrganizationCreate.
  ///
  /// In en, this message translates to:
  /// **'Create organization'**
  String get pgOrganizationCreate;

  /// No description provided for @pgHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get pgHome;

  /// No description provided for @pgSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get pgSettings;

  /// No description provided for @pgForbidden.
  ///
  /// In en, this message translates to:
  /// **'No access'**
  String get pgForbidden;

  /// No description provided for @pgProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get pgProfile;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionOrganizations.
  ///
  /// In en, this message translates to:
  /// **'Organizations'**
  String get profileSectionOrganizations;

  /// No description provided for @profileFieldUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get profileFieldUserId;

  /// No description provided for @profileFieldMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get profileFieldMemberSince;

  /// No description provided for @profileFieldNameParts.
  ///
  /// In en, this message translates to:
  /// **'Legal name'**
  String get profileFieldNameParts;

  /// No description provided for @profileFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFieldFullName;

  /// No description provided for @profileFieldFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get profileFieldFirstName;

  /// No description provided for @profileFieldMiddleName.
  ///
  /// In en, this message translates to:
  /// **'Middle name'**
  String get profileFieldMiddleName;

  /// No description provided for @profileFieldLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get profileFieldLastName;

  /// No description provided for @profileFieldMembershipSince.
  ///
  /// In en, this message translates to:
  /// **'In this organization since'**
  String get profileFieldMembershipSince;

  /// No description provided for @profilePhonePrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get profilePhonePrimary;

  /// No description provided for @profilePhoneVerifiedOn.
  ///
  /// In en, this message translates to:
  /// **'Verified {date}'**
  String profilePhoneVerifiedOn(String date);

  /// No description provided for @profilePhoneNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet'**
  String get profilePhoneNotVerified;

  /// No description provided for @profileOpenPhoneSettings.
  ///
  /// In en, this message translates to:
  /// **'Phone number settings'**
  String get profileOpenPhoneSettings;

  /// No description provided for @profileNoPhonesDetail.
  ///
  /// In en, this message translates to:
  /// **'Add or verify numbers in settings when available.'**
  String get profileNoPhonesDetail;

  /// No description provided for @profileNoMembershipsDetail.
  ///
  /// In en, this message translates to:
  /// **'Create or join an organization from the home flow.'**
  String get profileNoMembershipsDetail;

  /// No description provided for @profileOrgYourRole.
  ///
  /// In en, this message translates to:
  /// **'Your role'**
  String get profileOrgYourRole;

  /// No description provided for @profileCurrentWorkspaceBadge.
  ///
  /// In en, this message translates to:
  /// **'Current workspace'**
  String get profileCurrentWorkspaceBadge;

  /// No description provided for @profileMeDataHint.
  ///
  /// In en, this message translates to:
  /// **'Your account details will appear here after the app refreshes your session.'**
  String get profileMeDataHint;

  /// No description provided for @profilePhonesOnFile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 phone number on your profile} other{{count} phone numbers on your profile}}'**
  String profilePhonesOnFile(num count);

  /// No description provided for @pgProfilePhones.
  ///
  /// In en, this message translates to:
  /// **'Phone numbers'**
  String get pgProfilePhones;

  /// No description provided for @pgOrgSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch organization'**
  String get pgOrgSwitch;

  /// No description provided for @pgOrgProfile.
  ///
  /// In en, this message translates to:
  /// **'Organization profile'**
  String get pgOrgProfile;

  /// No description provided for @pgWorkersList.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get pgWorkersList;

  /// No description provided for @pgWorkerDetail.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get pgWorkerDetail;

  /// No description provided for @pgWorkerEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit worker'**
  String get pgWorkerEdit;

  /// No description provided for @pgWorkerAdd.
  ///
  /// In en, this message translates to:
  /// **'Add worker'**
  String get pgWorkerAdd;

  /// No description provided for @pgEngagementsList.
  ///
  /// In en, this message translates to:
  /// **'Engagements'**
  String get pgEngagementsList;

  /// No description provided for @pgEngagementDetail.
  ///
  /// In en, this message translates to:
  /// **'Engagement'**
  String get pgEngagementDetail;

  /// No description provided for @pgEngagementEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit engagement'**
  String get pgEngagementEdit;

  /// No description provided for @pgWageRules.
  ///
  /// In en, this message translates to:
  /// **'Wage rules'**
  String get pgWageRules;

  /// No description provided for @pgCommissionRules.
  ///
  /// In en, this message translates to:
  /// **'Commission rules'**
  String get pgCommissionRules;

  /// No description provided for @pgWorkAssignments.
  ///
  /// In en, this message translates to:
  /// **'Work assignments'**
  String get pgWorkAssignments;

  /// No description provided for @pgCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get pgCalendar;

  /// No description provided for @pgAttendanceList.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get pgAttendanceList;

  /// No description provided for @pgAttendanceNew.
  ///
  /// In en, this message translates to:
  /// **'New attendance day'**
  String get pgAttendanceNew;

  /// No description provided for @pgAttendanceDay.
  ///
  /// In en, this message translates to:
  /// **'Attendance day'**
  String get pgAttendanceDay;

  /// No description provided for @pgTimePunch.
  ///
  /// In en, this message translates to:
  /// **'Time punch'**
  String get pgTimePunch;

  /// No description provided for @pgSalesList.
  ///
  /// In en, this message translates to:
  /// **'Commission sales'**
  String get pgSalesList;

  /// No description provided for @pgSaleNew.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get pgSaleNew;

  /// No description provided for @pgSaleDetail.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get pgSaleDetail;

  /// No description provided for @pgSitesList.
  ///
  /// In en, this message translates to:
  /// **'Project sites'**
  String get pgSitesList;

  /// No description provided for @pgSiteDetail.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get pgSiteDetail;

  /// No description provided for @pgSiteNew.
  ///
  /// In en, this message translates to:
  /// **'New site'**
  String get pgSiteNew;

  /// No description provided for @pgSiteEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit site'**
  String get pgSiteEdit;

  /// No description provided for @pgPayPeriodsList.
  ///
  /// In en, this message translates to:
  /// **'Pay periods'**
  String get pgPayPeriodsList;

  /// No description provided for @pgPayPeriodDetail.
  ///
  /// In en, this message translates to:
  /// **'Pay period'**
  String get pgPayPeriodDetail;

  /// No description provided for @pgPayPeriodNew.
  ///
  /// In en, this message translates to:
  /// **'New pay period'**
  String get pgPayPeriodNew;

  /// No description provided for @pgPayPeriodLock.
  ///
  /// In en, this message translates to:
  /// **'Lock pay period'**
  String get pgPayPeriodLock;

  /// No description provided for @pgPaymentsList.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get pgPaymentsList;

  /// No description provided for @pgPaymentNew.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get pgPaymentNew;

  /// No description provided for @pgRatingsList.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get pgRatingsList;

  /// No description provided for @pgRatingNew.
  ///
  /// In en, this message translates to:
  /// **'Rate organization'**
  String get pgRatingNew;

  /// No description provided for @pgReportAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance report'**
  String get pgReportAttendance;

  /// No description provided for @pgReportExport.
  ///
  /// In en, this message translates to:
  /// **'Export report'**
  String get pgReportExport;

  /// No description provided for @workersRosterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People engaged with your organization. Pull to refresh when live data is on.'**
  String get workersRosterSubtitle;

  /// No description provided for @workersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get workersSearchHint;

  /// No description provided for @workersAddWorker.
  ///
  /// In en, this message translates to:
  /// **'Add worker'**
  String get workersAddWorker;

  /// No description provided for @workersContactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get workersContactSection;

  /// No description provided for @workersSkillsSection.
  ///
  /// In en, this message translates to:
  /// **'Skills & role'**
  String get workersSkillsSection;

  /// No description provided for @workersPayoutSection.
  ///
  /// In en, this message translates to:
  /// **'Payout'**
  String get workersPayoutSection;

  /// No description provided for @workersNotesSection.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get workersNotesSection;

  /// No description provided for @workersPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get workersPhone;

  /// No description provided for @workersEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get workersEmail;

  /// No description provided for @workersJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get workersJoined;

  /// No description provided for @workersBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get workersBankAccount;

  /// No description provided for @workersSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get workersSaveChanges;

  /// No description provided for @workersSearchByPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Find by phone'**
  String get workersSearchByPhoneTitle;

  /// No description provided for @workersSearchByPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search an E.164 number to link an existing user or start onboarding.'**
  String get workersSearchByPhoneSubtitle;

  /// No description provided for @workersSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get workersSearchButton;

  /// No description provided for @workersSearchMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Match found'**
  String get workersSearchMatchTitle;

  /// No description provided for @workersSearchMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review details before adding this person to the roster.'**
  String get workersSearchMatchSubtitle;

  /// No description provided for @workersAddToOrganization.
  ///
  /// In en, this message translates to:
  /// **'Add to organization'**
  String get workersAddToOrganization;

  /// No description provided for @workersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workers yet'**
  String get workersEmptyTitle;

  /// No description provided for @workersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When your team is connected, everyone engaged with this organization will appear here.'**
  String get workersEmptyBody;

  /// No description provided for @workersNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Worker not found'**
  String get workersNotFoundTitle;

  /// No description provided for @workersNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This worker could not be found. Open the list and pick someone from your team.'**
  String get workersNotFoundBody;

  /// No description provided for @workersSnackbarSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get workersSnackbarSaved;

  /// No description provided for @workersSnackbarAdded.
  ///
  /// In en, this message translates to:
  /// **'Worker added'**
  String get workersSnackbarAdded;

  /// No description provided for @workersDemoBadge.
  ///
  /// In en, this message translates to:
  /// **'Sample data'**
  String get workersDemoBadge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
