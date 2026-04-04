import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/auth_api.dart';
import '../data/auth_api_provider.dart';
import 'widgets/auth_shell.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String name = RouteNames.forgotPassword;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _step2 = false;
  bool _submitting = false;
  String? _sentPhoneE164;
  String? _sentEmail;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validatePhoneDigits(String? v, AppLocalizations l10n) {
    final String t = (v ?? '').trim().replaceAll(RegExp(r'\s'), '');
    if (t.isEmpty) {
      return null;
    }
    if (t.length < 10) {
      return l10n.authErrorPhoneInvalid;
    }
    return null;
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

  (String?, String?) _identifiersOrThrow(AppLocalizations l10n) {
    final String phoneRaw = _phone.text.trim();
    final String emailRaw = _email.text.trim();
    final String? emailErr = _validateEmail(_email.text, l10n);
    final String? phoneErr =
        phoneRaw.isEmpty ? null : _validatePhoneDigits(_phone.text, l10n);
    if (phoneRaw.isNotEmpty && phoneErr != null) {
      throw AuthApiException(phoneErr);
    }
    if (emailRaw.isNotEmpty && emailErr != null) {
      throw AuthApiException(emailErr);
    }
    if (phoneRaw.isEmpty && emailRaw.isEmpty) {
      throw AuthApiException(l10n.authErrorOtpNeedIdentifier);
    }
    String? phoneE164;
    if (phoneRaw.isNotEmpty) {
      phoneE164 = AuthApi.normalizePhoneE164(phoneRaw);
    }
    final String? em = emailRaw.isEmpty ? null : emailRaw;
    return (phoneE164, em);
  }

  void _showError(Object e, AppLocalizations l10n) {
    final String msg =
        e is AuthApiException ? e.message : l10n.authErrorNetwork;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _sendForgot(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final (String? phoneE164, String? email) = _identifiersOrThrow(l10n);
      await ref.read(authApiProvider).requestPasswordForgot(
            phoneE164: phoneE164,
            email: email,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _step2 = true;
        _sentPhoneE164 = phoneE164;
        _sentEmail = email;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authForgotResetCodeSentSnackbar)),
      );
    } on AuthApiException catch (e) {
      if (mounted) {
        _showError(e, l10n);
      }
    } catch (_) {
      if (mounted) {
        _showError(Exception(), l10n);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _resetPassword(AppLocalizations l10n) async {
    if (_code.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authErrorOtpShort)),
      );
      return;
    }
    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authErrorPasswordShort)),
      );
      return;
    }
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authPasswordMismatch)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final String token = await ref.read(authApiProvider).resetPasswordWithCode(
            code: _code.text.trim(),
            password: _password.text,
            passwordConfirmation: _confirm.text,
            phoneE164: _sentPhoneE164,
            email: _sentEmail,
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
        _showError(e, l10n);
      }
    } catch (_) {
      if (mounted) {
        _showError(Exception(), l10n);
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
    final ColorScheme scheme = theme.colorScheme;

    return Scaffold(
      body: AuthShell(
        showBack: true,
        onBack: () => context.go(AppPaths.login),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.authForgotPasswordTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _step2
                      ? l10n.authForgotPasswordStep2Subtitle
                      : l10n.authForgotPasswordStep1Subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!_step2) ...<Widget>[
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.authPhoneHint,
                      prefixIcon: const Icon(Icons.phone_rounded),
                    ),
                    validator: (String? v) => _validatePhoneDigits(v, l10n),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.authEmailHintOptional,
                      prefixIcon:
                          const Icon(Icons.alternate_email_rounded),
                    ),
                    validator: (String? v) => _validateEmail(v, l10n),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _submitting ? null : () => _sendForgot(l10n),
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.authForgotPasswordCta),
                  ),
                ] else ...<Widget>[
                  TextFormField(
                    controller: _code,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.authOtpHint,
                      prefixIcon: const Icon(Icons.pin_rounded),
                    ),
                    maxLength: 6,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.authPasswordHint,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _confirm,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.authConfirmPasswordHint,
                      prefixIcon: const Icon(Icons.lock_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed:
                        _submitting ? null : () => _resetPassword(l10n),
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.authForgotPasswordNewPasswordCta),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () => context.go(AppPaths.login),
                  child: Text(l10n.authBackToSignIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
