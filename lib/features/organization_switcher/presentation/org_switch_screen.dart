import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';

/// Same flow as [SelectOrganizationScreen] (doc §17.3 `/org/switch`).
class OrgSwitchScreen extends StatefulWidget {
  const OrgSwitchScreen({super.key});

  static const String name = RouteNames.orgSwitch;

  @override
  State<OrgSwitchScreen> createState() => _OrgSwitchScreenState();
}

class _OrgSwitchScreenState extends State<OrgSwitchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(AppPaths.selectOrganization);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.orgSwitchRedirecting),
          ],
        ),
      ),
    );
  }
}
