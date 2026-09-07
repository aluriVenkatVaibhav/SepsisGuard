import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyLoggedIn = "logged_in";

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<void> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // remove accidental spaces
    final u = username.trim();
    final p = password.trim();

    // DEBUG (optional)
    print("LOGIN ATTEMPT -> user:$u pass:$p");

    if (u == "doctor" && p == "1234") {
      await prefs.setBool(_keyLoggedIn, true);
      return;
    }

    throw Exception("Invalid credentials");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
  }
}
