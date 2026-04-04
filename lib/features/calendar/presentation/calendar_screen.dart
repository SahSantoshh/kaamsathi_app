import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/widgets.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.calendar;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgCalendar,
      metadata: 'orgId: $orgId — GET /calendar/assignments?from=&to=',
    );
  }
}
