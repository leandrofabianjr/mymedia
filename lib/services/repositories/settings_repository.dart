import 'package:flutter/foundation.dart';
import 'package:mymedia/services/repositories/remote/remote_api/remote_api.dart';
import 'package:mymedia/services/shared_preferences_service.dart';

class SettingsRepository extends ChangeNotifier {
  SettingsRepository({
    required RemoteApi remoteApi,
    required this._sharedPreferencesService,
  }) {
    remoteApi.apiUrlProvider = _apiUrlProvider;
  }

  final SharedPreferencesService _sharedPreferencesService;

  Future<(String, int)> _apiUrlProvider() async {
    final url = await _sharedPreferencesService.fetchServerUrl();
    final port = await _sharedPreferencesService.fetchServerPort();
    return (url ?? '', port ?? 80);
  }

  Future<String?> fetchServerUrl() async {
    return await _sharedPreferencesService.fetchServerUrl();
  }

  Future<void> saveServerUrl(String? url) async {
    await _sharedPreferencesService.saveServerUrl(url);
    notifyListeners();
  }

  Future<int> fetchServerPort() async {
    final port = await _sharedPreferencesService.fetchServerPort();
    return port ?? 80;
  }

  Future<void> saveServerPort(int? port) async {
    await _sharedPreferencesService.saveServerPort(port);
    notifyListeners();
  }
}
