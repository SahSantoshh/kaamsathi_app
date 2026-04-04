import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String name = RouteNames.profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Map<String, dynamic>? me = ref.watch(authSessionProvider).meProfile;
    final String? fullName = me?['full_name'] as String?;
    final String? email = me?['email'] as String?;
    final Object? phonesRaw = me?['user_phone_numbers'];
    final int phoneCount = phonesRaw is List<dynamic> ? phonesRaw.length : 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgProfile)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          if (me == null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                l10n.profileMeDataHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (me != null) ...<Widget>[
            if (fullName != null && fullName.trim().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(fullName.trim()),
                subtitle: email != null && email.trim().isNotEmpty
                    ? Text(email.trim())
                    : null,
              )
            else if (email != null && email.trim().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(email.trim()),
              ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(l10n.pgProfilePhones),
            subtitle: phoneCount > 0
                ? Text(l10n.profilePhonesOnFile(phoneCount))
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppPaths.profilePhones),
          ),
          const Divider(),
          KaamEmptyState(
            title: l10n.pgProfile,
            message: l10n.placeholderPageBody,
          ),
        ],
      ),
    );
  }
}
