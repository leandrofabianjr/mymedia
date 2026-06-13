import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const _tokenKey = 'TOKEN';

  Future<String?> fetchToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString(_tokenKey);
    return token;
  }

  Future<void> saveToken(String? token) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await sharedPreferences.remove(_tokenKey);
    } else {
      await sharedPreferences.setString(_tokenKey, token);
    }
  }
}
