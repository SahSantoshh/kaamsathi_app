import 'package:shared_preferences/shared_preferences.dart';

/// Last sign-in path the user chose on the login screen (SharedPreferences).
enum LoginAuthMode {
  otp,
  password,
}

abstract final class LoginMethodPreferenceStore {
  static const String _key = 'kaam_login_auth_mode';

  static Future<LoginAuthMode> load() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final String? raw = p.getString(_key);
    if (raw == 'otp') {
      return LoginAuthMode.otp;
    }
    return LoginAuthMode.password;
  }

  static Future<void> save(LoginAuthMode mode) async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setString(
      _key,
      mode == LoginAuthMode.otp ? 'otp' : 'password',
    );
  }
}
