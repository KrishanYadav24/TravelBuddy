import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static bool _isInitialized = false;

  /// Initialize environment variables from `.env` file safely
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
    } catch (_) {
      // If .env file is missing or fails to load, gracefully proceed with defaults
      _isInitialized = true;
    }
  }

  /// Check whether to use Mock/Demo mode fallback
  static bool get useMockData {
    final value = dotenv.maybeGet('USE_MOCK_DATA')?.toLowerCase();
    if (value == 'false') {
      return false;
    }
    return true; // Default to true for robust demo & testing fallback
  }

  /// OpenWeatherMap API Key
  static String get openWeatherApiKey {
    final key = dotenv.maybeGet('OPENWEATHER_API_KEY');
    if (key == null || key.isEmpty || key == 'mock_openweather_key') {
      return '';
    }
    return key;
  }

  /// Firebase Project ID
  static String get firebaseProjectId {
    return dotenv.maybeGet('FIREBASE_PROJECT_ID') ?? 'travelbuddy-india-demo';
  }

  /// Check if a valid OpenWeatherMap API key is configured
  static bool get isWeatherApiConfigured {
    return openWeatherApiKey.isNotEmpty;
  }
}
