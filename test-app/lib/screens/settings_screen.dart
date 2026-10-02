import 'package:featurama/client.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _baseUrlController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: Config.apiKey);
    _baseUrlController = TextEditingController(text: Config.baseUrl);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  void _save() {
    final apiKey = _apiKeyController.text;
    final baseUrl = _baseUrlController.text;

    try {
      FeaturamaClient.validateApiKey(apiKey);
      FeaturamaClient.validateBaseUrl(baseUrl);
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message.toString())),
      );
      return;
    }

    Config.apiKey = apiKey;
    Config.baseUrl = FeaturamaClient.validateBaseUrl(baseUrl);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Settings saved')));

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Project SDK key from this backend',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Backend origin',
                hintText: FeaturamaClient.defaultBaseUrl,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 16),
            const Text(
              'Use a project SDK key issued by the selected backend. '
              'The default is https://newapi.featurama.app. Legacy keys need '
              'https://api.featurama.app explicitly. Changing this URL does not '
              'migrate your key or project. Do not enter dashboard credentials. '
              'Enter only the origin, without /api or /api/public. '
              'HTTP is allowed only for loopback development.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
