/// Paths that must **not** send [X-Organization-Id] per KaamSathi_web/docs/flutter_app.md §6.
bool pathOmitsOrganizationHeader(String requestPath) {
  final String p = requestPath.split('?').first;
  if (p == '/me' || p.startsWith('/auth/')) {
    return true;
  }
  if (p == '/organizations') {
    return true;
  }
  if (RegExp(r'^/organizations/[^/]+$').hasMatch(p)) {
    return true;
  }
  if (p.startsWith('/user_phone_numbers')) {
    return true;
  }
  return false;
}
