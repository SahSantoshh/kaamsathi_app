import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/preferences/login_method_preference.dart';
import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/kaam_phone_field.dart';
import '../../../shared/widgets/kaam_pin_input.dart';
import '../data/auth_api.dart';
import '../data/auth_api_provider.dart';
import 'widgets/auth_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String name = RouteNames.login;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const int _otpResendCooldownSec = 90;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneOtp = TextEditingController();
  final TextEditingController _otpEmail = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _loginPhone = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _codeSent = false;
  bool _submitting = false;
  String? _otpSentPhoneE164;
  String? _otpSentEmail;
  PhoneNumber? _phoneOtpNumber;
  PhoneNumber? _loginPhoneNumber;
  Timer? _resendCooldownTimer;
  int _resendSecondsLeft = 0;

  LoginAuthMode _authMode = LoginAuthMode.password;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreLoginPreference());
  }

  Future<void> _restoreLoginPreference() async {
    final LoginAuthMode mode = await LoginMethodPreferenceStore.load();
    if (!mounted) {
      return;
    }
    setState(() => _authMode = mode);
  }

  @override
  void dispose() {
    _resendCooldownTimer?.cancel();
    _phoneOtp.dispose();
    _otpEmail.dispose();
    _otp.dispose();
    _email.dispose();
    _loginPhone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _cancelOTPResendCooldown() {
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = null;
    _resendSecondsLeft = 0;
  }

  void _startOTPResendCooldown() {
    _resendCooldownTimer?.cancel();
    setState(() => _resendSecondsLeft = _otpResendCooldownSec);
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendSecondsLeft <= 1) {
        t.cancel();
        _resendCooldownTimer = null;
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft -= 1);
      }
    });
  }

  String? _validateEmail(String? v, AppLocalizations l10n) {
    final String t = (v ?? '').trim();
    if (t.isEmpty) {
      return null;
    }
    if (!t.contains('@')) {
      return l10n.authErrorEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? v, AppLocalizations l10n) {
    if ((v ?? '').length < 6) {
      return l10n.authErrorPasswordShort;
    }
    return null;
  }

  void _showAuthError(Object e, AppLocalizations l10n) {
    final String msg =
        e is AuthApiException ? e.message : l10n.authErrorNetwork;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Returns `(phoneE164, email)` with at least one non-null for send OTP.
  (String?, String?) _otpIdentifiersOrThrow(AppLocalizations l10n) {
    final String nationalDigits =
        _phoneOtp.text.replaceAll(RegExp(r'\D'), '');
    final String emailRaw = _otpEmail.text.trim();
    final String? emailErr = _validateEmail(_otpEmail.text, l10n);

    if (emailRaw.isNotEmpty && emailErr != null) {
      throw AuthApiException(emailErr);
    }
    if (nationalDigits.isEmpty && emailRaw.isEmpty) {
      throw AuthApiException(l10n.authErrorOtpNeedIdentifier);
    }
    String? phoneE164;
    if (nationalDigits.isNotEmpty) {
      if (_phoneOtpNumber == null) {
        throw AuthApiException(l10n.authErrorPhoneInvalid);
      }
      phoneE164 = AuthApi.phoneNumberToE164(_phoneOtpNumber!);
    }
    final String? em = emailRaw.isEmpty ? null : emailRaw;
    return (phoneE164, em);
  }

  Future<void> _sendCode(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final (String? phoneE164, String? email) = _otpIdentifiersOrThrow(l10n);
      await ref.read(authApiProvider).requestOtp(
            phoneE164: phoneE164,
            email: email,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _codeSent = true;
        _otpSentPhoneE164 = phoneE164;
        _otpSentEmail = email;
        _otp.clear();
      });
      _startOTPResendCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authCodeSentSnackbar)),
      );
    } on AuthApiException catch (e) {
      if (mounted) {
        _showAuthError(e, l10n);
      }
    } catch (_) {
      if (mounted) {
        _showAuthError(Exception(), l10n);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _resendOtp(AppLocalizations l10n) async {
    if (!_codeSent ||
        _resendSecondsLeft > 0 ||
        (_otpSentPhoneE164 == null &&
            (_otpSentEmail == null || _otpSentEmail!.isEmpty))) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(authApiProvider).requestOtp(
            phoneE164: _otpSentPhoneE164,
            email: _otpSentEmail?.isNotEmpty == true ? _otpSentEmail : null,
          );
      if (!mounted) {
        return;
      }
      setState(() => _otp.clear());
      _startOTPResendCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authOtpResentSnackbar)),
      );
    } on AuthApiException catch (e) {
      if (mounted) {
        _showAuthError(e, l10n);
      }
    } catch (_) {
      if (mounted) {
        _showAuthError(Exception(), l10n);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String? _emailPasswordFieldError(AppLocalizations l10n) {
    final String em = _email.text.trim();
    final String phDigits = _loginPhone.text.replaceAll(RegExp(r'\D'), '');
    if (em.isEmpty && phDigits.isEmpty) {
      return l10n.authErrorEmailOrPhoneRequired;
    }
    if (em.isNotEmpty) {
      if (!em.contains('@')) {
        return l10n.authErrorEmailInvalid;
      }
    }
    return null;
  }

  Future<void> _signInWithPassword(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String? idErr = _emailPasswordFieldError(l10n);
    if (idErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(idErr)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final String em = _email.text.trim();
      final String phDigits = _loginPhone.text.replaceAll(RegExp(r'\D'), '');
      String? phoneE164;
      if (phDigits.isNotEmpty) {
        if (_loginPhoneNumber == null) {
          throw AuthApiException(l10n.authErrorPhoneInvalid);
        }
        phoneE164 = AuthApi.phoneNumberToE164(_loginPhoneNumber!);
      }
      final String token = await ref.read(authApiProvider).loginWithPassword(
            password: _password.text,
            email: em.isEmpty ? null : em,
            phoneE164: phoneE164,
          );
      final MeResponse me = await ref.read(authApiProvider).fetchMe(token);
      if (!mounted) {
        return;
      }
      await ref
          .read(authSessionProvider.notifier)
          .applyAuthenticatedFromApi(token, me);
    } on AuthApiException catch (e) {
      if (mounted) {
        _showAuthError(e, l10n);
      }
    } catch (_) {
      if (mounted) {
        _showAuthError(Exception(), l10n);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _verifyOtp(AppLocalizations l10n) async {
    if (_otp.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authErrorOtpShort)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final String token = await ref.read(authApiProvider).verifyOtp(
            code: _otp.text.trim(),
            phoneE164: _otpSentPhoneE164,
            email: _otpSentEmail,
          );
      final MeResponse me = await ref.read(authApiProvider).fetchMe(token);
      if (!mounted) {
        return;
      }
      await ref
          .read(authSessionProvider.notifier)
          .applyAuthenticatedFromApi(token, me);
    } on AuthApiException catch (e) {
      if (mounted) {
        _showAuthError(e, l10n);
      }
    } catch (_) {
      if (mounted) {
        _showAuthError(Exception(), l10n);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: AuthShell(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.authWelcomeBack,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.loginSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SegmentedButton<LoginAuthMode>(
                showSelectedIcon: false,
                segments: <ButtonSegment<LoginAuthMode>>[
                  ButtonSegment<LoginAuthMode>(
                    value: LoginAuthMode.otp,
                    label: Text(l10n.authMethodOtp),
                    icon: const Icon(Icons.sms_outlined, size: 18),
                  ),
                  ButtonSegment<LoginAuthMode>(
                    value: LoginAuthMode.password,
                    label: Text(l10n.authMethodPassword),
                    icon: const Icon(Icons.lock_outline_rounded, size: 18),
                  ),
                ],
                selected: <LoginAuthMode>{_authMode},
                onSelectionChanged: (Set<LoginAuthMode> next) {
                  final LoginAuthMode mode = next.first;
                  setState(() {
                    _authMode = mode;
                    _codeSent = false;
                    _otpSentPhoneE164 = null;
                    _otpSentEmail = null;
                    _otp.clear();
                    _cancelOTPResendCooldown();
                  });
                  unawaited(LoginMethodPreferenceStore.save(mode));
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_authMode == LoginAuthMode.otp) ..._phoneOtpFields(l10n),
              if (_authMode == LoginAuthMode.password)
                ..._passwordFields(l10n),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    l10n.authNoAccount,
                    style: theme.textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () => context.push(AppPaths.signUp),
                    child: Text(l10n.authSignUpCta),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _otpIdentifierDecoration(InputDecoration base) {
    if (!_codeSent) {
      return base;
    }
    return base.copyWith(
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  List<Widget> _phoneOtpFields(AppLocalizations l10n) {
    return <Widget>[
      KaamPhoneField(
        controller: _phoneOtp,
        onPhoneUpdate: (PhoneNumber phone) =>
            setState(() => _phoneOtpNumber = phone),
        decoration: _otpIdentifierDecoration(
          InputDecoration(
            labelText: l10n.authPhoneHint,
            helperText: l10n.authOtpPhoneOrEmailHelper,
          ),
        ),
        enabled: !_codeSent,
      ),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        controller: _otpEmail,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const <String>[AutofillHints.email],
        decoration: _otpIdentifierDecoration(
          InputDecoration(
            labelText: l10n.authEmailHintOptional,
            prefixIcon: const Icon(Icons.alternate_email_rounded),
            helperText: l10n.authOtpEmailPairingHelper,
          ),
        ),
        validator: (String? v) => _validateEmail(v, l10n),
        enabled: !_codeSent,
      ),
      if (_codeSent) ...<Widget>[
        const SizedBox(height: AppSpacing.md),
        KaamPinInput(
          controller: _otp,
          length: 6,
          autofocus: true,
          label: l10n.authOtpHint,
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.center,
          child: _resendSecondsLeft > 0
              ? Text(
                  l10n.authOtpResendIn(_resendSecondsLeft),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )
              : TextButton(
                  onPressed: _submitting ? null : () => _resendOtp(l10n),
                  child: Text(l10n.authOtpResend),
                ),
        ),
      ],
      const SizedBox(height: AppSpacing.lg),
      if (!_codeSent)
        FilledButton(
          onPressed: _submitting ? null : () => _sendCode(l10n),
          child: _submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.authSendCode),
        )
      else
        FilledButton(
          onPressed: _submitting ? null : () => _verifyOtp(l10n),
          child: _submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.authVerifyAndSignIn),
        ),
    ];
  }

  List<Widget> _passwordFields(AppLocalizations l10n) {
    return <Widget>[
      KaamPhoneField(
        controller: _loginPhone,
        onPhoneUpdate: (PhoneNumber phone) =>
            setState(() => _loginPhoneNumber = phone),
        decoration: InputDecoration(
          labelText: l10n.authPhoneHintOptional,
          helperText: l10n.authPasswordLoginIdentifierHelper,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const <String>[AutofillHints.email],
        decoration: InputDecoration(
          labelText: l10n.authEmailHintOptional,
          prefixIcon: const Icon(Icons.alternate_email_rounded),
        ),
        validator: (_) => null,
      ),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        controller: _password,
        obscureText: true,
        autofillHints: const <String>[AutofillHints.password],
        decoration: InputDecoration(
          labelText: l10n.authPasswordHint,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
        ),
        validator: (String? v) => _validatePassword(v, l10n),
      ),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: TextButton(
          onPressed: () => context.push(AppPaths.forgotPassword),
          child: Text(l10n.authForgotPasswordLink),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      FilledButton(
        onPressed: _submitting ? null : () => _signInWithPassword(l10n),
        child: _submitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.authSignInCta),
      ),
    ];
  }
}
