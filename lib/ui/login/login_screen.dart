import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final FocusNode _settingsFocusNode = FocusNode();
  final _usernameController = TextEditingController(
    text: const String.fromEnvironment('USERNAME', defaultValue: ''),
  );
  final _passwordController = TextEditingController(
    text: const String.fromEnvironment('PASSWORD', defaultValue: ''),
  );

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
    _settingsFocusNode.dispose();
    widget.viewModel.login.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            focusNode: _settingsFocusNode,
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(Routes.settings),
            // Correção do estilo usando WidgetStateProperty:
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.5);
                }
                return Colors
                    .transparent; // Fundo transparente quando não focado
              }),
              iconColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return Colors
                      .blueAccent; // O ícone fica azul brilhante ao ser focado
                }
                return Theme.of(context).colorScheme.onSurface;
              }),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'MYMEDIA',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Focus(
                onKeyEvent: (node, event) {
                  // Se o usuário apertar a seta para CIMA (D-pad Up) no controle remoto
                  if (event is KeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      _settingsFocusNode
                          .requestFocus(); // Força o foco a ir para o botão de configurações na AppBar
                      return KeyEventResult
                          .handled; // Avisa o sistema que o clique já foi resolvido
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      FocusScope.of(context).nextFocus();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _usernameController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Usuário'),
                ),
              ),
              const SizedBox(height: 16),
              Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      FocusScope.of(context).previousFocus();
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      FocusScope.of(context).nextFocus();
                      return KeyEventResult
                          .handled; // Avisa o sistema que o clique já foi resolvido
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction
                      .done, // Fecha o teclado virtual ou foca o botão
                  decoration: const InputDecoration(labelText: 'Senha'),
                ),
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
                    // 2. ADICIONA RETORNO VISUAL DE FOCO PARA O BOTÃO DA TV
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.focused)) {
                          return Colors
                              .blueAccent; // Destaca o botão azul quando selecionado no controle
                        }
                        return Theme.of(context).colorScheme.primary;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.focused)) {
                          return Colors.white;
                        }
                        return Theme.of(context).colorScheme.onPrimary;
                      }),
                    ),
                    child: const Text('Entrar'),
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
