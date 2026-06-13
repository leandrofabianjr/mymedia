import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:mymedia/services/repositories/remote/remote_api/errors.dart';
import 'package:mymedia/services/repositories/remote/remote_api/models/remote_auth_token.dart';

export 'errors.dart';
export 'models/remote_auth_token.dart';

typedef AuthHeaderProvider = String? Function();

const String _apiHost = String.fromEnvironment(
  'API_HOST',
  defaultValue: '127.0.0.1',
);

const int _apiPort = int.fromEnvironment('API_PORT', defaultValue: 80);

class RemoteApi {
  RemoteApi({HttpClient Function()? clientFactory})
    : _clientFactory = clientFactory ?? HttpClient.new;

  final HttpClient Function() _clientFactory;

  final _log = Logger('RemoteApi');

  Future<RemoteAuthToken> login(String username, String password) async {
    final client = _clientFactory();
    client.connectionTimeout = const Duration(seconds: 5);

    _log.finer('Realizando login');
    try {
      final request = await client.post(_apiHost, _apiPort, '/auth/token');

      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );

      final body =
          'username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}';
      request.write(body);

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as Map<String, dynamic>;
        _log.finer('Login realizado com sucesso');
        return RemoteAuthToken.fromJson(json);
      } else {
        _log.finer('Usuário ou senha inválidos');
        throw const RemoteApiUsernameOrPasswordInvalidException();
      }
    } finally {
      client.close();
    }
  }
}
