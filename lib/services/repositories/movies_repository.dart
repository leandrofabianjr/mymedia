import 'package:flutter/foundation.dart';
import 'package:mymedia/domain/models/movie.dart';
import 'package:mymedia/utils/result.dart';

abstract class MoviesRepository extends ChangeNotifier {
  Future<Result<List<Movie>>> fetchMovies();
  Future<Result<List<MovieTmdbData>>> searchMovieMetadata(String query);
  Future<Result<Movie>> importMetadata({
    required int movieId,
    required MovieTmdbData metadata,
  });
}
