import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:featurama/featurama.dart';

import 'config.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FTFlutterApp());
}

class FTFlutterApp extends StatefulWidget {
  const FTFlutterApp({super.key});

  @override
  State<FTFlutterApp> createState() => _FTFlutterAppState();
}

class _FTFlutterAppState extends State<FTFlutterApp> {
  SemanticsHandle? _semanticsHandle;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) _semanticsHandle = SemanticsBinding.instance.ensureSemantics();
  }

  @override
  void dispose() {
    _semanticsHandle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FT Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
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
  FeaturamaClient? _client;
  String? _configurationError;

  @override
  void initState() {
    super.initState();
    _replaceClient();
  }

  void _replaceClient() {
    final previous = _client;
    _configurationError = null;
    try {
      _client = Config.apiKey.isEmpty
          ? null
          : FeaturamaClient(apiKey: Config.apiKey, baseUrl: Config.baseUrl);
    } on ArgumentError catch (error) {
      _client = null;
      _configurationError = error.message.toString();
    }
    previous?.close();
  }

  @override
  void dispose() {
    _client?.close();
    super.dispose();
  }

  Future<void> _openSettings() async {
    final result = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    if (!mounted || result != true) return;
    setState(() {
      _replaceClient();
      _rebuildKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('FT Flutter')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_configurationError ??
                    'Please configure your API key first.'),
              ),
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
    return Scaffold(
      body: FeaturamaScreen(
        key: ValueKey(_rebuildKey),
        client: _client!,
        accentColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
        onClose: _openSettings,
      ),
    );
  }
}
