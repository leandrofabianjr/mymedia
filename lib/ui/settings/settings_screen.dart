import 'package:flutter/material.dart';
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
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('URL do servidor'),
                      content: Column(
                        children: <Widget>[
                          TextField(
                            decoration: const InputDecoration(labelText: 'URL'),
                            controller: _serverUrlController,
                          ),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Porta',
                            ),
                            controller: _serverPortController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Salvar'),
                          onPressed: () {
                            widget.settingsViewModel.saveServerUrl(
                              _serverUrlController.text,
                              int.tryParse(_serverPortController.text) ?? 80,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
