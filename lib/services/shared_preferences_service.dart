import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const _tokenKey = 'TOKEN';
  static const _serverUrlKey = 'SERVER_URL';
  static const _serverPortKey = 'SERVER_PORT';

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

  Future<String?> fetchServerUrl() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_serverUrlKey);
  }

  Future<void> saveServerUrl(String? url) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (url == null || url.isEmpty) {
      await sharedPreferences.remove(_serverUrlKey);
    } else {
      await sharedPreferences.setString(_serverUrlKey, url);
    }
  }

  Future<int?> fetchServerPort() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(_serverPortKey);
  }

  Future<void> saveServerPort(int? port) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (port == null) {
      await sharedPreferences.remove(_serverPortKey);
    } else {
      await sharedPreferences.setInt(_serverPortKey, port);
    }
  }
}
