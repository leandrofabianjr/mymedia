import 'package:mymedia/domain/models/movie.dart';
import 'package:mymedia/services/repositories/movies_repository.dart';
import 'package:mymedia/services/repositories/remote/remote_api/remote_api.dart';
import 'package:mymedia/utils/result.dart';

class RemoteMoviesRepository extends MoviesRepository {
  RemoteMoviesRepository({required this._remoteApi});

  final RemoteApi _remoteApi;

  @override
  Future<Result<List<Movie>>> fetchMovies() async {
    return _remoteApi.fetchMovies();
  }

  @override
  Future<Result<List<MovieTmdbData>>> searchMovieMetadata(String query) async {
    return _remoteApi.searchTmdb(query);
  }

  @override
  Future<Result<Movie>> importMetadata({
    required int movieId,
    required MovieTmdbData metadata,
  }) {
    return _remoteApi.updateMovieMetadata(movieId, metadata);
  }
}
