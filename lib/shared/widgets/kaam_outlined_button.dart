import 'package:flutter/material.dart';

/// Secondary actions — wraps [OutlinedButton] with consistent touch target.
class KaamOutlinedButton extends StatelessWidget {
  const KaamOutlinedButton({
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
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
      );
    }
    return OutlinedButton(onPressed: onPressed, child: child);
  }
}
