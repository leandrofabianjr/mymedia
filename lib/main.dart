import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mymedia/router.dart';
import 'package:mymedia/services/repositories/auth_repository.dart';
import 'package:mymedia/services/repositories/remote/remote_api/remote_api.dart';
import 'package:mymedia/services/repositories/remote/remote_auth_repository.dart';
import 'package:mymedia/services/shared_preferences_service.dart';
import 'package:mymedia/ui/movies/movies_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() {
  Logger.root.level = Level.ALL;

  runApp(MultiProvider(providers: providers, child: const MainApp()));
}

List<SingleChildWidget> get providers {
  final remoteApi = RemoteApi();
  final sharedPreferencesService = SharedPreferencesService();
  final authRepository = RemoteAuthRepository(
    remoteApi: remoteApi,
    sharedPreferencesService: sharedPreferencesService,
  );
  return [
    ChangeNotifierProvider.value(value: authRepository as AuthRepository),
    ChangeNotifierProvider.value(value: MoviesViewModel()),
  ];
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: router(context.read()),
    );
  }
}
