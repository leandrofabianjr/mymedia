import 'package:flutter/foundation.dart';
import 'package:mymedia/services/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required this._settingsRepository});

  final SettingsRepository _settingsRepository;

  String? _serverUrl;
  String get serverUrl => _serverUrl ?? '';

  int? _serverPort;
  int get serverPort => _serverPort ?? 80;

  Future<void> init() async {
    _serverUrl = await _settingsRepository.fetchServerUrl();
    _serverPort = await _settingsRepository.fetchServerPort();
    notifyListeners();
  }

  void saveServerUrl(String? url, int port) {
    _settingsRepository.saveServerUrl(url);
    _serverUrl = url;
    _settingsRepository.saveServerPort(port);
    _serverPort = port;
    notifyListeners();
  }
}
