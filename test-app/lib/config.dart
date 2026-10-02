import 'package:featurama/client.dart';

/// Configuration for the Featurama test app.
class Config {
  // Keep each project SDK key paired with the backend that issued it.
  // Build-time defines are part of the app bundle, not secret storage.
  static String apiKey = const String.fromEnvironment('FEATURAMA_API_KEY');
  static String baseUrl = const String.fromEnvironment(
    'FEATURAMA_BASE_URL',
    defaultValue: FeaturamaClient.defaultBaseUrl,
  );
}
