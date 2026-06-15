import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:mymedia/domain/models/movie.dart';
import 'package:mymedia/services/repositories/remote/remote_api/errors.dart';
import 'package:mymedia/services/repositories/remote/remote_api/models/remote_auth_token.dart';
import 'package:mymedia/services/repositories/remote/remote_api/models/remote_movie.dart';
import 'package:mymedia/utils/result.dart';

export 'errors.dart';
export 'models/remote_auth_token.dart';

typedef AuthHeaderProvider = Future<String?> Function();

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

  AuthHeaderProvider? _authHeaderProvider;

  void Function()? _notAuthorizedCallback;

  set notAuthorizedCallback(Future<void> Function() notAuthorizedCallback) {
    _notAuthorizedCallback = notAuthorizedCallback;
  }

  set authHeaderProvider(AuthHeaderProvider authHeaderProvider) {
    _authHeaderProvider = authHeaderProvider;
  }

  Future<void> _authHeader(HttpHeaders headers) async {
    final header = await _authHeaderProvider?.call();
    _log.info('Auth header: $header');
    if (header != null) {
      headers.add(HttpHeaders.authorizationHeader, header);
    }
  }

  Future<HttpClientRequest> get(HttpClient client, String path) async {
    final request = await client.get(_apiHost, _apiPort, path);
    await _authHeader(request.headers);
    return request;
  }

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

  Future<Result<List<Movie>>> fetchMovies() async {
    final client = _clientFactory();

    client.connectionTimeout = const Duration(seconds: 5);
    try {
      final request = await get(client, '/movies/');
      final response = await request.close();
      if (response.statusCode == 401) {
        _notAuthorizedCallback?.call();
        return const Result.failure(HttpException("Usuário não autenticado."));
      }
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        return Result.success(
          json.map((element) => RemoteMovie.jsonToMovie(element)).toList(),
        );
      } else {
        return const Result.failure(HttpException("Erro ao buscar filmes"));
      }
    } on Exception catch (error) {
      return Result.failure(error);
    } catch (error) {
      return Result.failure(Exception("Erro inesperado ao buscar filmes"));
    } finally {
      client.close();
    }
  }

  Future<Result<List<MovieTmdbData>>> searchTmdb(String query) async {
    final client = _clientFactory();
    client.connectionTimeout = const Duration(seconds: 5);
    try {
      final path = '/movies/tmdb/search?q=${Uri.encodeComponent(query)}';
      final request = await get(client, path);
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final decodedBody = jsonDecode(stringData) as Map<String, dynamic>;

        final list = decodedBody['results'] as List<dynamic>? ?? [];

        return Result.success(
          list.map((e) => MovieTmdbData.fromJson(e)).toList(),
        );
      } else {
        return const Result.failure(
          HttpException("Erro ao buscar dados no TMDB"),
        );
      }
    } on Exception catch (e) {
      return Result.failure(e);
    } finally {
      client.close();
    }
  }

  Future<Result<Movie>> updateMovieMetadata(
    int movieId,
    MovieTmdbData tmdbPayload,
  ) async {
    final client = _clientFactory();
    client.connectionTimeout = const Duration(seconds: 5);
    try {
      final request = await client.put(
        _apiHost,
        _apiPort,
        '/movies/$movieId/metadata',
      );
      await _authHeader(request.headers);

      request.headers.contentType = ContentType(
        'application',
        'json',
        charset: 'utf-8',
      );

      request.write(tmdbPayload.originalJsonString);

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as Map<String, dynamic>;
        final movie = RemoteMovie.jsonToMovie(json['movie']);
        return Result.success(movie);
      } else {
        return const Result.failure(
          HttpException("Falha ao salvar metadados no servidor"),
        );
      }
    } catch (e) {
      return Result.failure(Exception(e));
    } finally {
      client.close();
    }
  }
}
