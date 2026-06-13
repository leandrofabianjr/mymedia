import 'package:flutter/material.dart';
import 'package:mymedia/ui/movies/movies_viewmodel.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key, required this.viewModel});

  final MoviesViewModel viewModel;

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Movies')));
  }
}
