import 'package:logging/logging.dart';
import 'package:mymedia/services/repositories/auth_repository.dart';
import 'package:mymedia/utils/command.dart';
import 'package:mymedia/utils/result.dart';

class LoginViewModel {
  LoginViewModel({required this._authRepository}) {
    login = Command1<void, LoginCredentials>(_login);
  }

  final AuthRepository _authRepository;
  final _log = Logger('LoginViewModel');

  late Command1 login;

  Future<Result<void>> _login(LoginCredentials credentials) async {
    final result = await _authRepository.login(credentials);
    if (result is Failure<void>) {
      _log.warning('Erro ao realizar login: ${result.error}');
    }
    return result;
  }
}
