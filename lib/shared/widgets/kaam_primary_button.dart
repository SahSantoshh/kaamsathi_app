import 'package:flutter/material.dart';

/// Primary actions — wraps [FilledButton] with consistent touch target (doc §12).
class KaamPrimaryButton extends StatelessWidget {
  const KaamPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
      );
    }
    return FilledButton(onPressed: onPressed, child: child);
  }
}
