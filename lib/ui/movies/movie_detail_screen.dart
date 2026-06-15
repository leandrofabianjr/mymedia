import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymedia/domain/models/movie.dart';
import 'package:mymedia/routes.dart';
import 'package:mymedia/ui/core/ui/placeholder_movie_poster.dart';
import 'package:mymedia/ui/movies/movies_viewmodel.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.moviesViewModel});

  final MoviesViewModel moviesViewModel;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isPlayFocused = false;

  Movie get movie => widget.moviesViewModel.selectedMovie;

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
                // Define se a tela atual se comporta como Mobile/Vertical
                final isMobile = constraints.maxWidth < 720;

                // Componente isolado do Pôster para reaproveitamento
                final posterWidget = ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: isMobile ? size.width * 0.45 : size.width * 0.22,
                    child: movie.posterUrl != null
                        ? Image.network(movie.posterUrl!, fit: BoxFit.cover)
                        : AspectRatio(
                            aspectRatio:
                                2 /
                                3, // Perfeito para o formato de poster na vertical
                            child: PlaceholderMoviePoster(),
                          ),
                  ),
                );

                // Componente isolado dos Textos, Metadados e Botões
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

                    // Bloco de Ações (Botões) adaptável para quebras de linha em telas pequenas
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Focus(
                          autofocus: true,
                          onFocusChange: (hasFocus) =>
                              setState(() => _isPlayFocused = hasFocus),
                          onKeyEvent: (node, event) {
                            if (_isPlayFocused &&
                                event.logicalKey.keyLabel == 'Select') {
                              debugPrint(
                                'Iniciando o player para: ${movie.filePath}',
                              );
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: GestureDetector(
                            onTap: () =>
                                debugPrint('Iniciando player no clique/touch'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: _isPlayFocused
                                    ? Colors.blueAccent
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _isPlayFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.blueAccent.withAlpha(
                                            128,
                                          ),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: _isPlayFocused
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Assistir Filme',
                                    style: TextStyle(
                                      color: _isPlayFocused
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _FixMetadataButton(
                          onPressed: () {
                            context.push(Routes.movieDetailsMatch);
                          },
                        ),
                      ],
                    ),
                  ],
                );

                // ESTRATÉGIA DE RENDERIZAÇÃO RESPONSIVA
                if (isMobile) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        posterWidget,
                        const SizedBox(height: 32),
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
                        // CORREÇÃO AQUI: Envolvemos com SingleChildScrollView + IntrinsicHeight
                        // para permitir rolagem vertical caso a sinopse empurre os botões para fora da TV
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

          // Botão Voltar fixo no topo da Stack (Garante acessibilidade independente do scroll)
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

class _FixMetadataButton extends StatefulWidget {
  const _FixMetadataButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_FixMetadataButton> createState() => _FixMetadataButtonState();
}

class _FixMetadataButtonState extends State<_FixMetadataButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      onKeyEvent: (node, event) {
        if (_isFocused && event.logicalKey.keyLabel == 'Select') {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _isFocused ? Colors.amber : const Color(0xFF1F232C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isFocused ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_note,
                color: _isFocused ? Colors.black : Colors.amber,
              ),
              const SizedBox(width: 8),
              Text(
                'Corrigir Informações',
                style: TextStyle(
                  color: _isFocused ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
