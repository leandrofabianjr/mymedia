import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mymedia/domain/models/movie.dart';
import 'package:mymedia/services/repositories/movies_repository.dart';
import 'package:mymedia/utils/command.dart';
import 'package:mymedia/utils/result.dart';

class MoviesViewModel extends ChangeNotifier {
  MoviesViewModel({required this._moviesRepository}) {
    fetchMovies = Command0(_fetchMovies);

    searchMovieMetadata = Command1(_searchMovieMetadata);

    importMetadata = Command2(_importMetadata);
  }

  final _log = Logger('MoviesViewModel');

  final MoviesRepository _moviesRepository;

  late final Command0<List<Movie>> fetchMovies;

  late final Command1<List<MovieTmdbData>, String> searchMovieMetadata;

  late final Command2<void, int, MovieTmdbData> importMetadata;

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  Movie? _selectedMovie;
  Movie get selectedMovie => _selectedMovie!;

  @override
  void dispose() {
    fetchMovies.dispose();
    super.dispose();
  }

  void selectMovie(Movie movie) {
    _selectedMovie = movie;
    notifyListeners();
  }

  Future<Result<List<Movie>>> _fetchMovies() async {
    final result = await _moviesRepository.fetchMovies();
    if (result.isFailure) {
      _log.warning('Erro ao buscar filmes: ${result.errorAsString}');
    }
    if (result.isSuccess) {
      _movies = (result as Success<List<Movie>>).value;
      notifyListeners();
    }
    return result;
  }

  Future<Result<List<MovieTmdbData>>> _searchMovieMetadata(String query) async {
    final result = await _moviesRepository.searchMovieMetadata(query);
    if (result.isFailure) {
      _log.warning(
        'Erro ao buscar metadados do filme: ${result.errorAsString}',
      );
    }
    return result;
  }

  Future<Result<void>> _importMetadata(
    int movieId,
    MovieTmdbData metadata,
  ) async {
    final result = await _moviesRepository.importMetadata(
      movieId: movieId,
      metadata: metadata,
    );
    if (result.isFailure) {
      _log.warning(
        'Erro ao importar metadados do filme: ${result.errorAsString}',
      );
    }
    if (result.isSuccess) {
      final updatedMovie = (result as Success<Movie>).value;
      final updatedMovies = movies.map((oldMovie) {
        if (oldMovie.id == movieId) {
          return updatedMovie;
        }
        return oldMovie;
      });
      _movies = updatedMovies.toList();
      _selectedMovie = updatedMovie;
      notifyListeners();
    }

    return result;
  }
}
