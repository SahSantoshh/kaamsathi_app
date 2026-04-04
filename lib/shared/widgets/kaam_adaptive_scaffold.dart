import 'package:flutter/material.dart';

import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_spacing.dart';

class KaamNavDestination {
  const KaamNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Phone: bottom nav. Tablet/web: [NavigationRail] + content (doc §12).
class KaamAdaptiveScaffold extends StatefulWidget {
  const KaamAdaptiveScaffold({
    super.key,
    required this.title,
    required this.destinations,
    required this.children,
    this.actions,
  });

  final String title;
  final List<KaamNavDestination> destinations;
  final List<Widget> children;
  final List<Widget>? actions;

  @override
  State<KaamAdaptiveScaffold> createState() => _KaamAdaptiveScaffoldState();
}

class _KaamAdaptiveScaffoldState extends State<KaamAdaptiveScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    assert(
      widget.destinations.length == widget.children.length,
      'destinations and children must match',
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useRail =
            AppBreakpoints.isMediumOrWider(constraints.maxWidth);

        if (useRail) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              actions: widget.actions,
            ),
            body: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (int i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: <NavigationRailDestination>[
                    for (final KaamNavDestination d in widget.destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: widget.children[_index],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: widget.actions,
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: widget.children[_index],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (int i) => setState(() => _index = i),
            destinations: <NavigationDestination>[
              for (final KaamNavDestination d in widget.destinations)
                NavigationDestination(icon: Icon(d.icon), label: d.label),
            ],
          ),
        );
      },
    );
  }
}
