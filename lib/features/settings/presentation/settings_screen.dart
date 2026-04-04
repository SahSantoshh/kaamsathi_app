import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/product/product_scope.dart';
import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_state.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/data/auth_api_provider.dart';
import '../../../shared/widgets/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String name = RouteNames.settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AuthState session = ref.watch(authSessionProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgSettings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          Text(
            l10n.settingsSessionSection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        l10n.sessionYourRoleTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        session.role == AppMembershipRole.manager
                            ? l10n.sessionRoleOrganizationOwner
                            : l10n.sessionRoleWorkerLabel,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (ProductScope
                          .organizationOwnerExperienceFirst) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.settingsBuildFocusHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.sessionClearOrg),
                  subtitle: session.selectedOrganizationId != null
                      ? Text(
                          session.selectedOrganizationId!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  enabled: session.isAuthenticated,
                  onTap: session.isAuthenticated
                      ? () => ref
                            .read(authSessionProvider.notifier)
                            .clearOrganization()
                      : null,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    l10n.sessionSignOut,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  enabled: session.isAuthenticated,
                  onTap: session.isAuthenticated
                      ? () async {
                          final String? t = session.accessToken;
                          if (t != null && t.isNotEmpty) {
                            await ref.read(authApiProvider).logout(t);
                          }
                          await ref
                              .read(authSessionProvider.notifier)
                              .signOut();
                          if (context.mounted) {
                            context.go(AppPaths.login);
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
          if (kDebugMode) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.settingsDevToolsSection,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: ListTile(
                leading: const Icon(Icons.route_outlined),
                title: Text(l10n.pgDevNavigationRoutes),
                subtitle: Text(l10n.devRoutesSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(AppPaths.devNavigationRoutes),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          KaamEmptyState(
            title: l10n.pgSettings,
            message: l10n.placeholderPageBody,
          ),
        ],
      ),
    );
  }
}
