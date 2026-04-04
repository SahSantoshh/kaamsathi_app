import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  static const String name = RouteNames.forbidden;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgForbidden)),
      body: Column(
        children: <Widget>[
          Expanded(
            child: KaamEmptyState(
              title: l10n.pgForbidden,
              message: l10n.placeholderPageBody,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: KaamOutlinedButton(
              label: l10n.backToHome,
              onPressed: () => context.go(AppPaths.home),
            ),
          ),
        ],
      ),
    );
  }
}
