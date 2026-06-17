import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymedia/domain/models/movie.dart';
import 'package:mymedia/routes.dart';
import 'package:mymedia/ui/core/ui/placeholder_movie_poster.dart';
import 'package:mymedia/ui/movies/movies_viewmodel.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.moviesViewModel});

  final MoviesViewModel moviesViewModel;

  Movie get movie => moviesViewModel.selectedMovie;

  @override
  Widget build(BuildContext context) {
    final tmdb = movie.tmdbData;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Stack(
        children: [
          // 1. Imagem de Fundo (Backdrop) com Gradiente para Escurecer
          if (tmdb?.backdropPath != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.25,
                child: Image.network(
                  'https://image.tmdb.org/t/p/w1280${tmdb!.backdropPath}',
                  fit: BoxFit.cover,
                  errorBuilder: PlaceholderMoviePoster.errorBuilder,
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1115), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // 2. Conteúdo Principal Dinâmico e Responsivo
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 720;

                final posterWidget = ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: isMobile ? size.width * 0.45 : size.width * 0.22,
                    child: movie.posterUrl != null
                        ? Image.network(movie.posterUrl!, fit: BoxFit.cover)
                        : AspectRatio(
                            aspectRatio: 2 / 3,
                            child: PlaceholderMoviePoster(),
                          ),
                  ),
                );

                final infoWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Metadados Linha: Ano | Mídia | Nota
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          movie.year?.toString() ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F232C),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            movie.extension.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (tmdb?.voteAverage != null &&
                            tmdb!.voteAverage! > 0) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tmdb.voteAverage?.toStringAsFixed(1) ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sinopse
                    Text(
                      tmdb?.overview ??
                          'Sinopse não disponível para este arquivo de mídia.',
                      maxLines: isMobile ? 10 : 6,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        // Botão Principal: Assistir Filme (Filled Button M3)
                        FilledButton.icon(
                          autofocus: true, // Auto-foco na abertura (TV)
                          onPressed: () {
                            debugPrint(
                              'Iniciando o player para: ${movie.filePath}',
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Assistir Filme'),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.blueAccent;
                              }
                              return Colors
                                  .white; // Fundo padrão M3 invertido para destaque cinematográfico
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.white;
                              }
                              return Colors.black;
                            }),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        // Botão Secundário: Corrigir Informações (Outlined Button M3)
                        OutlinedButton.icon(
                          onPressed: () {
                            context.push(Routes.movieDetailsMatch);
                          },
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Corrigir Informações'),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.amber;
                              }
                              return const Color(0xFF1F232C);
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.black;
                              }
                              return Colors.amber;
                            }),
                            side: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.focused)) {
                                return const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                );
                              }
                              return const BorderSide(
                                color: Colors.transparent,
                              );
                            }),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );

                if (isMobile) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        posterWidget,
                        const SizedBox(height: 32, width: double.infinity),
                        infoWidget,
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(48, 80, 48, 48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        posterWidget,
                        const SizedBox(width: 48),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: infoWidget,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          // Botão Voltar fixo no topo da Stack
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}
