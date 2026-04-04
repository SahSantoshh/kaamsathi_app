/// Environment from `--dart-define` (see [apiContractDocumentationPath] §3).
///
/// **Android emulator → Rails on your computer:** `API_BASE_URL=http://10.0.2.2:PORT`
/// **iOS simulator:** `http://127.0.0.1:PORT`
/// **Physical device:** use your machine's LAN IP (same Wi‑Fi), e.g. `http://192.168.x.x:3000`
///
/// HTTP (not HTTPS) on Android requires cleartext enabled (see `AndroidManifest`).
abstract final class AppConfig {
  /// **Single source of truth** for API + client contracts (organizations, auth, etc.).
  /// Update the Flutter app when this doc changes.
  static const String apiContractDocumentationPath =
      '/Users/sahsantoshh/Documents/Projects/kaam_sathi/KaamSathi_web/docs/flutter_app.md';

  /// Prefer `API_BASE_URL` (docs).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.100.77:3005',
  );

  static const String apiVersionPrefix = String.fromEnvironment(
    'API_VERSION_PREFIX',
    defaultValue: '/api/v1',
  );

  /// Origin without trailing slash + version prefix (e.g. `http://localhost:3000/api/v1`).
  static String get apiRoot {
    final String base = apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final String prefix = apiVersionPrefix.startsWith('/')
        ? apiVersionPrefix
        : '/$apiVersionPrefix';
    return '$base$prefix';
  }
}
