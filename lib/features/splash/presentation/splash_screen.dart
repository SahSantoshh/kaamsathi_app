import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/data/auth_api_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const String name = RouteNames.splash;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
    _controller.forward();
    _scheduleNavigation();
  }

  Future<void> _scheduleNavigation() async {
    final Future<void> bootstrap = _bootstrapSession();
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    await bootstrap;
    if (!mounted) {
      return;
    }
    final auth = ref.read(authSessionProvider);
    if (!auth.isAuthenticated) {
      context.go(AppPaths.login);
    } else if (auth.selectedOrganizationId == null) {
      context.go(AppPaths.selectOrganization);
    } else {
      context.go(AppPaths.home);
    }
  }

  /// Restore secure storage, then refresh profile when we have a JWT.
  Future<void> _bootstrapSession() async {
    await ref.read(authSessionProvider.notifier).restorePersistedSession();
    if (!mounted) {
      return;
    }
    final auth = ref.read(authSessionProvider);
    final String? token = auth.accessToken;
    if (token == null || token.isEmpty) {
      return;
    }
    try {
      final MeResponse me = await ref.read(authApiProvider).fetchMe(token);
      if (!mounted) {
        return;
      }
      await ref
          .read(authSessionProvider.notifier)
          .applyAuthenticatedFromApi(token, me);
    } on AuthApiException {
      if (!mounted) {
        return;
      }
      await ref.read(authSessionProvider.notifier).signOut();
    } catch (_) {
      if (!mounted) {
        return;
      }
      await ref.read(authSessionProvider.notifier).signOut();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              scheme.primary,
              Color.lerp(scheme.primary, scheme.tertiary, 0.5)!,
              scheme.primaryContainer,
            ],
            stops: const <double>[0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg + 4),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.groups_2_rounded,
                    size: 72,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: <Widget>[
                    Text(
                      l10n.appTitle,
                      style: textTheme.headlineMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        l10n.authBrandTagline,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.92),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.lg + bottomInset),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          backgroundColor:
                              scheme.onPrimary.withValues(alpha: 0.25),
                          color: scheme.onPrimary,
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.splashLoading,
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
