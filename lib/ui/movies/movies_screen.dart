import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymedia/domain/models/movie.dart';
import 'package:mymedia/routes.dart';
import 'package:mymedia/ui/core/ui/placeholder_movie_poster.dart';
import 'package:mymedia/ui/movies/movies_viewmodel.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key, required this.moviesViewModel});

  final MoviesViewModel moviesViewModel;

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  @override
  void initState() {
    super.initState();
    widget.moviesViewModel.fetchMovies.execute();
  }

  @override
  Widget build(BuildContext context) {
    final fetchMovies = widget.moviesViewModel.fetchMovies;
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Biblioteca de Filmes')),
      body: ListenableBuilder(
        listenable: widget.moviesViewModel,
        child: const Center(child: CircularProgressIndicator()),
        builder: (context, child) {
          if (fetchMovies.isRunning) {
            return child!;
          }

          if (fetchMovies.failed) {
            return Center(
              child: Text(
                fetchMovies.errorAsString,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 16,
                ),
              ),
            );
          }

          if (widget.moviesViewModel.movies.isEmpty) {
            return Center(
              child: Text(
                'Nenhum filme encontrado',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            );
          }

          // Grid responsivo e otimizado para TV
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:
                  180, // Largura máxima ideal para posters na TV
              childAspectRatio:
                  2 /
                  3.2, // Proporção perfeita para conter o poster + título embaixo
              crossAxisSpacing: 20,
              mainAxisSpacing: 24,
            ),
            itemCount: widget.moviesViewModel.movies.length,
            itemBuilder: (context, index) {
              return _MovieGridItem(
                movie: widget.moviesViewModel.movies[index],
                onSelect: (movie) {
                  widget.moviesViewModel.selectMovie(movie);
                  context.push(Routes.movieDetails);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MovieGridItem extends StatefulWidget {
  const _MovieGridItem({required this.movie, required this.onSelect});

  final Movie movie;
  final void Function(Movie movie) onSelect;

  @override
  State<_MovieGridItem> createState() => _MovieGridItemState();
}

class _MovieGridItemState extends State<_MovieGridItem> {
  @override
  Widget build(BuildContext context) {
    // O widget Focus captura a navegação do controle remoto da TV
    return GestureDetector(
      onTap: () {
        widget.onSelect(widget.movie);
      },

      // AnimatedContainer cria a transição suave de escala e brilho ao navegar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Área do Poster com cantos arredondados
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                width: double.infinity,
                child: widget.movie.posterUrl != null
                    ? Image.network(
                        widget.movie.posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: PlaceholderMoviePoster.errorBuilder,
                      )
                    : const PlaceholderMoviePoster(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Título e Ano do filme embaixo do card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.movie.year?.toString() ?? 'N/A',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
