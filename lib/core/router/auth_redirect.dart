import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../session/app_membership_role.dart';
import '../session/auth_state.dart';
import 'app_paths.dart';

bool _isPublicPath(String path) {
  return path == AppPaths.splash ||
      path == AppPaths.login ||
      path == AppPaths.signUp ||
      path == AppPaths.forgotPassword;
}

bool _isUserScopePath(String path) {
  return path == AppPaths.selectOrganization ||
      path == AppPaths.organizationCreate ||
      path == AppPaths.profile ||
      path == AppPaths.profilePhones ||
      path == AppPaths.orgSwitch ||
      path == AppPaths.devNavigationRoutes ||
      path == AppPaths.settings ||
      path == AppPaths.forbidden;
}

/// First segment after `/org/` when it is a tenant id (not `switch`).
String? _tenantOrgIdFromPath(String path) {
  const String prefix = '/org/';
  if (!path.startsWith(prefix)) {
    return null;
  }
  final String rest = path.substring(prefix.length);
  if (rest.isEmpty) {
    return null;
  }
  final int slash = rest.indexOf('/');
  final String segment = slash == -1 ? rest : rest.substring(0, slash);
  if (segment.isEmpty || segment == 'switch') {
    return null;
  }
  return segment;
}

bool _requiresSelectedOrganization(String path) {
  if (path == AppPaths.home ||
      path == AppPaths.devNavigationRoutes ||
      path == AppPaths.search) {
    return true;
  }
  return _tenantOrgIdFromPath(path) != null;
}

/// Routes that only **organization owners** (`AppMembershipRole.manager`) may open.
/// Workers are redirected to [AppPaths.forbidden]. See `lib/core/product/product_scope.dart`.
bool isManagerOnlyPath(String path) {
  if (_managerRouteRegexes.any((RegExp r) => r.hasMatch(path))) {
    return true;
  }
  return _isManagerOnlySiteDetail(path);
}

final List<RegExp> _managerRouteRegexes = <RegExp>[
  RegExp(r'^/org/[^/]+/workers/add$'),
  RegExp(r'^/org/[^/]+/workers/[^/]+/edit$'),
  RegExp(r'^/org/[^/]+/engagements/[^/]+/edit$'),
  RegExp(r'^/org/[^/]+/engagements/[^/]+/wage-rules$'),
  RegExp(r'^/org/[^/]+/engagements/[^/]+/commission-rules$'),
  RegExp(r'^/org/[^/]+/engagements/[^/]+/assignments$'),
  RegExp(r'^/org/[^/]+/sites/new$'),
  RegExp(r'^/org/[^/]+/sites/[^/]+/edit$'),
  RegExp(r'^/org/[^/]+/pay-periods/new$'),
  RegExp(r'^/org/[^/]+/pay-periods/[^/]+/lock$'),
  RegExp(r'^/org/[^/]+/payments/new$'),
  RegExp(r'^/org/[^/]+/reports/attendance$'),
  RegExp(r'^/org/[^/]+/reports/export$'),
];

bool _isManagerOnlySiteDetail(String path) {
  final RegExpMatch? m = RegExp(r'^/org/[^/]+/sites/([^/]+)$').firstMatch(path);
  if (m == null) {
    return false;
  }
  return m.group(1) != 'new';
}

String? computeAuthRedirect({
  required AuthState auth,
  required GoRouterState state,
}) {
  final String path = state.uri.path;

  if (path == AppPaths.devNavigationRoutes && !kDebugMode) {
    return auth.isAuthenticated ? AppPaths.home : AppPaths.login;
  }

  if (path == AppPaths.forbidden) {
    if (!auth.isAuthenticated) {
      return AppPaths.login;
    }
    return null;
  }

  if (_isPublicPath(path)) {
    // Splash drives navigation after its intro animation (see SplashScreen).
    if (path == AppPaths.splash) {
      return null;
    }
    if ((path == AppPaths.login ||
            path == AppPaths.signUp ||
            path == AppPaths.forgotPassword) &&
        auth.isAuthenticated) {
      if (auth.selectedOrganizationId == null) {
        return AppPaths.selectOrganization;
      }
      return AppPaths.home;
    }
    return null;
  }

  if (!auth.isAuthenticated) {
    return AppPaths.login;
  }

  if (_requiresSelectedOrganization(path)) {
    if (auth.selectedOrganizationId == null) {
      return AppPaths.selectOrganization;
    }
    final String? tenant = _tenantOrgIdFromPath(path);
    if (tenant != null && tenant != auth.selectedOrganizationId) {
      return AppPaths.selectOrganization;
    }
  }

  if (auth.role == AppMembershipRole.worker && isManagerOnlyPath(path)) {
    return AppPaths.forbidden;
  }

  if (_isUserScopePath(path)) {
    return null;
  }

  return null;
}
