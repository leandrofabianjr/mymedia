abstract final class Routes {
  static const home = movies;

  static const movies = '/movies';
  static const movieDetailsRelative = 'details';
  static const movieDetails = '$movies/$movieDetailsRelative';
  static const movieDetailsMatchRelative = 'match';
  static const movieDetailsMatch = '$movieDetails/$movieDetailsMatchRelative';

  static const login = '/login';

  static const settings = '/settings';

  static String get nouser => '/nouser';
}
