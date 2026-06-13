import 'package:flutter/foundation.dart';
import 'package:mymedia/utils/result.dart';

typedef LoginCredentials = ({String username, String password});

abstract class AuthRepository extends ChangeNotifier {
  Future<bool> get isAuthenticated;

  Future<Result<void>> login(LoginCredentials credentials);

  Future<Result<void>> logout();
}
