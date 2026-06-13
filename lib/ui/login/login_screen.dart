import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymedia/routes.dart';
import 'package:mymedia/ui/login/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin');

  @override
  void initState() {
    super.initState();
    widget.viewModel.login.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.login.removeListener(_onResult);
    widget.viewModel.login.addListener(_onResult);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    widget.viewModel.login.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'DESTROYERSRV',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Usuário'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              const SizedBox(height: 32),
              ListenableBuilder(
                listenable: widget.viewModel.login,
                builder: (context, _) {
                  return FilledButton(
                    onPressed: () {
                      widget.viewModel.login.execute((
                        username: _usernameController.text,
                        password: _passwordController.text,
                      ));
                    },
                    child: Text('Entrar'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.login.completed) {
      widget.viewModel.login.clearResult();
      context.go(Routes.home);
    }

    if (widget.viewModel.login.failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text(widget.viewModel.login.errorAsString)],
          ),
        ),
      );
      widget.viewModel.login.clearResult();
    }
  }
}
