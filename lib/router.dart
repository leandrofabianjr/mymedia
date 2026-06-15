import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mymedia/routes.dart';
import 'package:mymedia/services/repositories/auth_repository.dart';
import 'package:mymedia/ui/login/login_screen.dart';
import 'package:mymedia/ui/login/login_viewmodel.dart';
import 'package:mymedia/ui/movies/movie_detail_screen.dart';
import 'package:mymedia/ui/movies/movies_screen.dart';
import 'package:mymedia/ui/movies/tmdb_match_screen.dart';
import 'package:provider/provider.dart';

final _log = Logger('router');

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.movies,
  debugLogDiagnostics: true,
  redirect: (context, state) async {
    final loggedIn = await context.read<AuthRepository>().isAuthenticated;
    final loggingIn = state.matchedLocation == Routes.login;
    if (!loggedIn) {
      _log.finer('Usuário não autenticado, redirecionando para login');
      return Routes.login;
    }

    if (loggingIn) {
      _log.finer('Usuário autenticado, redirecionando para home');
      return Routes.home;
    }

    return null;
  },
  refreshListenable: authRepository,
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        return LoginScreen(
          viewModel: LoginViewModel(authRepository: context.read()),
        );
      },
    ),
    GoRoute(
      path: Routes.movies,
      builder: (context, state) {
        return MoviesScreen(moviesViewModel: context.read());
      },
      routes: [
        // Sub-rota para manter o histórico empilhado corretamente
        GoRoute(
          path: Routes.movieDetailsRelative,
          builder: (context, state) {
            return MovieDetailScreen(moviesViewModel: context.read());
          },
          routes: [
            // Rota para abrir a tela de correção a partir da tela de detalhes
            GoRoute(
              path: 'match',
              builder: (context, state) {
                return TmdbMatchScreen(moviesViewModel: context.read());
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
