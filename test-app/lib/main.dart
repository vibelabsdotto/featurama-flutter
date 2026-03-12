import 'package:flutter/material.dart';
import 'package:featurama/featurama.dart';

import 'config.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const FTFlutterApp());
}

class FTFlutterApp extends StatelessWidget {
  const FTFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FT Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _rebuildKey = 0;

  Future<void> _openSettings() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    if (result == true) setState(() => _rebuildKey++);
  }

  @override
  Widget build(BuildContext context) {
    if (Config.apiKey.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('FT Flutter')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please configure your API key first.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _openSettings,
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    return FeaturamaScreen(
      key: ValueKey(_rebuildKey),
      client: FeaturamaClient(
        apiKey: Config.apiKey,
        baseUrl: Config.baseUrl,
      ),
      accentColor: const Color(0xFF6366F1),
      brightness: Brightness.light,
      onClose: _openSettings,
    );
  }
}
