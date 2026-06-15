import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Garante o acesso ao context.pop()
import 'package:mymedia/domain/models/movie.dart';
import 'package:mymedia/ui/core/ui/placeholder_movie_poster.dart';
import 'package:mymedia/ui/movies/movies_viewmodel.dart';
import 'package:mymedia/utils/result.dart';

class TmdbMatchScreen extends StatefulWidget {
  const TmdbMatchScreen({super.key, required this.moviesViewModel});

  final MoviesViewModel moviesViewModel;

  @override
  State<TmdbMatchScreen> createState() => _TmdbMatchScreenState();
}

class _TmdbMatchScreenState extends State<TmdbMatchScreen> {
  late final TextEditingController _searchController;
  List<MovieTmdbData> _results = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _message;
  bool _isSuccess = false;
  Movie get movie => widget.moviesViewModel.selectedMovie;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: movie.title);
    widget.moviesViewModel.searchMovieMetadata.addListener(
      _searchMovieMetadataListener,
    );
    widget.moviesViewModel.importMetadata.addListener(_importMetadataListener);
    // Dispara a busca inicial assim que a tela abre
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTmdbResults());
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.moviesViewModel.searchMovieMetadata.removeListener(
      _searchMovieMetadataListener,
    );
    widget.moviesViewModel.importMetadata.removeListener(
      _importMetadataListener,
    );
    super.dispose();
  }

  Future<void> _fetchTmdbResults() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    widget.moviesViewModel.searchMovieMetadata.execute(query);
  }

  void _importMetadata(MovieTmdbData candidate) {
    widget.moviesViewModel.importMetadata.execute(movie.id, candidate);
  }

  void _searchMovieMetadataListener() {
    if (widget.moviesViewModel.searchMovieMetadata.isRunning) {
      if (_isLoading) return;
      setState(() => _isLoading = true);
    } else if (widget.moviesViewModel.searchMovieMetadata.failed) {
      setState(() {
        _isLoading = false;
        _message = widget.moviesViewModel.searchMovieMetadata.errorAsString;
      });
    } else {
      setState(() {
        _isLoading = false;
        _message = null;
        _results =
            (widget.moviesViewModel.searchMovieMetadata.result
                    as Success<List<MovieTmdbData>>)
                .value;
      });
    }
  }

  void _importMetadataListener() {
    if (widget.moviesViewModel.importMetadata.isRunning) {
      if (_isSaving) return;
      setState(() {
        _isSaving = true;
        _message = null;
      });
    } else if (widget.moviesViewModel.importMetadata.failed) {
      setState(() {
        _isSaving = false;
        _message = widget.moviesViewModel.importMetadata.errorAsString;
      });
    } else {
      setState(() {
        _isSaving = false;
        _message = 'Metadados importados com sucesso!';
        _isSuccess = true;
      });

      // 1. Dispara a atualização em background da lista principal do catálogo
      // widget.moviesViewModel.fetchMovies.execute();

      // 2. Aguarda um breve momento (500ms) para o usuário ver a mensagem de sucesso na tela
      Future.delayed(const Duration(milliseconds: 500), () {
        // 3. Garante que o usuário não fechou a tela manualmente antes do timer acabar
        if (mounted) {
          context.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        title: Text('Corrigir Metadados: ${movie.title}'),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 720;

          // Widget do Formulário de Busca Isolado
          final searchFormWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Editar termo de busca:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFF1F232C),
                ),
                onSubmitted: (_) => _fetchTmdbResults(),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchTmdbResults,
                icon: const Icon(Icons.search),
                label: const Text('Refazer Busca'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? Colors.green.withAlpha(40)
                        : Colors.red.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSuccess ? Colors.green : Colors.redAccent,
                    ),
                  ),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _isSuccess ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          );

          // Widget de Resultados Isolado
          final resultsWidget = _isLoading || _isSaving
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                )
              : _results.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum resultado encontrado do TMDB.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final candidate = _results[index];
                    return _TmdbCandidateTile(
                      candidate: candidate,
                      onSelect: () => _importMetadata(candidate),
                    );
                  },
                );

          // MONTAGEM DO LAYOUT RESPONSIVO
          if (isMobile) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchFormWidget,
                  const SizedBox(height: 24),
                  const Text(
                    'Resultados encontrados:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: resultsWidget),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: searchFormWidget),
                  const SizedBox(width: 48),
                  Expanded(child: resultsWidget),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class _TmdbCandidateTile extends StatefulWidget {
  const _TmdbCandidateTile({required this.candidate, required this.onSelect});

  final MovieTmdbData candidate;
  final VoidCallback onSelect;

  @override
  State<_TmdbCandidateTile> createState() => _TmdbCandidateTileState();
}

class _TmdbCandidateTileState extends State<_TmdbCandidateTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      onKeyEvent: (node, event) {
        if (_isFocused && event.logicalKey.keyLabel == 'Select') {
          widget.onSelect();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isFocused
                ? Colors.blueAccent.withAlpha(60)
                : const Color(0xFF1F232C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isFocused ? Colors.blueAccent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 50,
                  height: 75,
                  color: const Color(0xFF0F1115),
                  child: widget.candidate.posterPath != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w92${widget.candidate.posterPath}',
                          fit: BoxFit.cover,
                          errorBuilder: PlaceholderMoviePoster.errorBuilder,
                        )
                      : const Icon(Icons.movie, size: 24, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.candidate.title ?? 'Título desconhecido',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.candidate.releaseDate != null
                          ? widget.candidate.releaseDate!.year.toString()
                          : 'Ano desconhecido',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    if (widget.candidate.overview != null)
                      Text(
                        widget.candidate.overview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
