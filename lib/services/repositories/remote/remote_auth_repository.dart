import 'package:logging/logging.dart';
import 'package:mymedia/services/repositories/auth_repository.dart';
import 'package:mymedia/services/shared_preferences_service.dart';
import 'package:mymedia/utils/result.dart';

import 'remote_api/remote_api.dart';

class RemoteAuthRepository extends AuthRepository {
  RemoteAuthRepository({
    required this._remoteApi,
    required this._sharedPreferencesService,
  }) {
    _remoteApi.authHeaderProvider = _authHeaderProvider;
    _remoteApi.notAuthorizedCallback = _notAuthorizedCallback;
  }

  final RemoteApi _remoteApi;
  final SharedPreferencesService _sharedPreferencesService;

  bool? _isAuthenticated;
  String? _authToken;
  final _log = Logger('RemoteAuthRepository');

  @override
  Future<bool> get isAuthenticated async {
    if (_isAuthenticated != null) {
      return _isAuthenticated!;
    }
    try {
      final token = await _sharedPreferencesService.fetchToken();
      if (token != null && token.isNotEmpty) {
        _authToken = token;
        _isAuthenticated = true;
      } else {
        _authToken = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      _log.severe('Falha ao ler o token do SharedPreferences', e);
      _authToken = null;
      _isAuthenticated = false;
    }

    return _isAuthenticated!;
  }

  @override
  Future<Result<void>> login(LoginCredentials credentials) async {
    try {
      final tokenResponse = await _remoteApi.login(
        credentials.username,
        credentials.password,
      );

      _log.info('Usuário autenticado com sucesso.');

      _isAuthenticated = true;
      _authToken = tokenResponse.accessToken;
      await _sharedPreferencesService.saveToken(_authToken);
      return const Result.success(null);
    } on RemoteApiUsernameOrPasswordInvalidException catch (e) {
      return Result.failure(e);
    } catch (e) {
      _log.warning('Erro ao realizar login: $e');
      return Result.failure(e);
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      _isAuthenticated = false;
      _authToken = null;
      await _sharedPreferencesService.saveToken(null);
      return const Result.success(null);
    } catch (e) {
      _log.warning('Erro ao realizar logout: $e');
      return Result.failure(e);
    }
  }

  Future<String?> _authHeaderProvider() async =>
      _authToken != null ? 'Bearer $_authToken' : null;

  Future<void> _notAuthorizedCallback() async {
    _log.info('Requisição sem autorização');

    // await _sharedPreferencesService.saveToken(null);

    // Limpa os dados em memória volatil
    _authToken = null;
    _isAuthenticated = false;
  }
}
