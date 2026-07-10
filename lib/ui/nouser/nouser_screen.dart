import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymedia/routes.dart';

class NoUserScreen extends StatefulWidget {
  const NoUserScreen({super.key});

  @override
  State<NoUserScreen> createState() => _NoUserScreenState();
}

class _NoUserScreenState extends State<NoUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go(Routes.login),
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to mymedia app!')),
    );
  }
}
