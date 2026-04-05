import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/worker_models.dart';

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
  final String lower = status.toLowerCase();
  final bool muted = lower.contains('leave') ||
      lower.contains('terminated') ||
      lower.contains('offboard');
  final bool onboarding = lower.contains('onboarding');
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: onboarding
          ? scheme.tertiaryContainer.withValues(alpha: 0.85)
          : muted
              ? scheme.secondaryContainer.withValues(alpha: 0.85)
              : scheme.primaryContainer.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: onboarding
                ? scheme.onTertiaryContainer
                : muted
                    ? scheme.onSecondaryContainer
                    : scheme.onPrimaryContainer,
          ),
    ),
  );
}

Widget workerListAvatar(
  BuildContext context,
  Worker worker, {
  double radius = 28,
}) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  final TextTheme textTheme = Theme.of(context).textTheme;
  final String? url = worker.effectiveAvatarUrl;
  final String label = worker.title;
  if (url != null && url.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer.withValues(alpha: 0.5),
      backgroundImage: NetworkImage(url),
      onBackgroundImageError:
          (Object exception, StackTrace? stackTrace) {},
    );
  }
  return CircleAvatar(
    radius: radius,
    backgroundColor: scheme.primaryContainer.withValues(alpha: 0.7),
    child: Text(
      workerInitials(label),
      style: textTheme.titleMedium?.copyWith(
        color: scheme.onPrimaryContainer,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
