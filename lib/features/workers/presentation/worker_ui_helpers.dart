import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

String workerInitials(String displayName) {
  final List<String> parts =
      displayName.trim().split(RegExp(r'\s+')).where((String s) => s.isNotEmpty).toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    final String w = parts[0];
    return w.length >= 2 ? w.substring(0, 2).toUpperCase() : w.toUpperCase();
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

Widget workerStatusChip(BuildContext context, String? status) {
  if (status == null || status.isEmpty) {
    return const SizedBox.shrink();
  }
  final ColorScheme scheme = Theme.of(context).colorScheme;
  final bool onLeave = status.toLowerCase().contains('leave');
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: onLeave
          ? scheme.secondaryContainer.withValues(alpha: 0.85)
          : scheme.primaryContainer.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: onLeave
                ? scheme.onSecondaryContainer
                : scheme.onPrimaryContainer,
          ),
    ),
  );
}
