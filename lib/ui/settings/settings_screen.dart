import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymedia/ui/settings/settings_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settingsViewModel});

  final SettingsViewModel settingsViewModel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController();
  final _serverPortController = TextEditingController();

  @override
  void initState() {
    widget.settingsViewModel.init();
    super.initState();
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _serverPortController.dispose();
    super.dispose();
  }

  void _openEditDialog() {
    _serverUrlController.text = widget.settingsViewModel.serverUrl;
    _serverPortController.text = widget.settingsViewModel.serverPort.toString();

    // 1. Cria o nó de foco para o botão Salvar
    final FocusNode salvarFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('URL do servidor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  // Move o foco nativamente para o próximo campo abaixo (Porta)
                  FocusScope.of(context).nextFocus();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: _serverUrlController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'URL (ex: 192.168.0.177)',
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 2. Envolvemos o campo da Porta em um Focus para interceptar a seta para baixo
            Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  salvarFocusNode
                      .requestFocus(); // Força o foco a ir para o botão Salvar
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: _serverPortController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Porta'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: 0.5);
                }
                return Colors.transparent;
              }),
            ),
            child: const Text('Cancelar'),
          ),
          TextButton(
            focusNode: salvarFocusNode, // 3. Vincula o nó de foco aqui
            onPressed: () {
              widget.settingsViewModel.saveServerUrl(
                _serverUrlController.text,
                int.tryParse(_serverPortController.text) ?? 80,
              );
              // É boa prática dar dispose no node local quando o diálogo fecha
              salvarFocusNode.dispose();
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return Colors.blueAccent;
                }
                return Colors.transparent;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return Colors.white;
                }
                return Theme.of(context).colorScheme.primary;
              }),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    ).then((_) {
      // Garante que o node seja destruído se o usuário fechar o diálogo clicando fora ou no voltar da TV
      salvarFocusNode.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              title: const Text('URL do servidor'),
              subtitle: ListenableBuilder(
                listenable: widget.settingsViewModel,
                builder: (context, _) {
                  final serverUrl = widget.settingsViewModel.serverUrl;
                  final serverPort = widget.settingsViewModel.serverPort;
                  if (serverUrl.isEmpty) {
                    return Text(
                      'Nenhuma URL configurada',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    );
                  } else {
                    return Text('$serverUrl:$serverPort');
                  }
                },
              ),
              // Feedback de foco no botão de edição do próprio ListTile
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.focused)) {
                      return Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.5);
                    }
                    return Colors.transparent;
                  }),
                  iconColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.focused)) {
                      return Colors.blueAccent;
                    }
                    return Theme.of(context).colorScheme.onSurface;
                  }),
                ),
                onPressed: _openEditDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
