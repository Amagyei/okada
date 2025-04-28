// lib/providers/config_provider.dart (New File)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  final String appName;
  final String apiBaseUrl;
  final String googleMapsApiKey;

  AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.googleMapsApiKey,
  });

  // Factory to load from dotenv (call this *after* dotenv.load)
  factory AppConfig.fromEnv() {
    return AppConfig(
      appName: dotenv.env['APP_NAME'] ?? 'Okada App', // Default name
      apiBaseUrl: dotenv.env['API_BASE_URL'] ?? 'MISSING_BASE_URL', // Default error value
      googleMapsApiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'MISSING_API_KEY', // Default error value
    );
  }
}

// Riverpod provider for the AppConfig
// Load config once when provider is first read
final appConfigProvider = Provider<AppConfig>((ref) {
  print("[AppConfig Provider] Creating AppConfig from env.");
  // dotenv should already be loaded by main_dev.dart or main_prod.dart
  return AppConfig.fromEnv();
});
