import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/widgets.dart';

class ProfilePhonesScreen extends StatelessWidget {
  const ProfilePhonesScreen({super.key});

  static const String name = RouteNames.profilePhones;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgProfilePhones,
      metadata: '/user_phone_numbers',
    );
  }
}
