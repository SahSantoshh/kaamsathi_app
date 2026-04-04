import 'package:flutter/material.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../../core/theme/app_spacing.dart';

/// Shared layout: brand header + rounded surface card for auth flows.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.footer,
    this.showBack = false,
    this.onBack,
  });

  final Widget child;
  final Widget? footer;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _AuthHeader(
              colorScheme: scheme,
              showBack: showBack,
              onBack: onBack,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: Material(
                elevation: 2,
                shadowColor: scheme.shadow.withValues(alpha: 0.12),
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: child,
                ),
              ),
            ),
          ),
          if (footer != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(child: footer!),
            ),
        ],
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.colorScheme,
    required this.showBack,
    this.onBack,
  });

  final ColorScheme colorScheme;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextTheme text = Theme.of(context).textTheme;
    final double topPad = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm,
        topPad,
        AppSpacing.lg,
        AppSpacing.xl + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primary,
            Color.lerp(colorScheme.primary, colorScheme.tertiary, 0.45)!,
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          if (showBack && onBack != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: colorScheme.onPrimary,
                ),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack,
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              top: showBack ? 48 : AppSpacing.lg,
              right: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.groups_2_rounded,
                    size: 36,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.appTitle,
                  style: text.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.authBrandTagline,
                  style: text.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.92),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
