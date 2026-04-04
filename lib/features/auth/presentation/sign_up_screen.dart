import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import 'widgets/auth_shell.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static const String name = RouteNames.signUp;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Scaffold(
      body: AuthShell(
        showBack: true,
        onBack: () => context.go(AppPaths.login),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.authCreateAccountTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  l10n.authApiSignUpExplainer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => context.go(AppPaths.login),
              child: Text(l10n.authBackToSignIn),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              children: <Widget>[
                Text(l10n.authHasAccount, style: theme.textTheme.bodySmall),
                TextButton(
                  onPressed: () => context.go(AppPaths.login),
                  child: Text(l10n.authSignInCta),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
