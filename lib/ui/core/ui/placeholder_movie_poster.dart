import 'package:flutter/material.dart';

class PlaceholderMoviePoster extends StatelessWidget {
  const PlaceholderMoviePoster({super.key});

  static ImageErrorWidgetBuilder errorBuilder = (context, error, stackTrace) {
    return const PlaceholderMoviePoster();
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_creation_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(height: 8),
          Text(
            'Sem Capa',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
