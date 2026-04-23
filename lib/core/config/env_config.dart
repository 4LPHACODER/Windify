import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static const String supabaseUrlKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';
  static const String googleWebClientIdKey = 'GOOGLE_WEB_CLIENT_ID';
  static const String googleAndroidClientIdKey = 'GOOGLE_ANDROID_CLIENT_ID';
  static const String googleIosClientIdKey = 'GOOGLE_IOS_CLIENT_ID';
  static const String mapboxAccessTokenKey = 'MAPBOX_ACCESS_TOKEN';
  static const String openWeatherApiKeyKey = 'OPENWEATHER_API_KEY';
  static const String openWeatherBaseUrlKey = 'OPENWEATHER_BASE_URL';

  static String get supabaseUrl => _getRequired(supabaseUrlKey);
  static String get supabaseAnonKey => _getRequired(supabaseAnonKeyKey);
  static String? get mapboxAccessToken => _getString(mapboxAccessTokenKey);
  static String? get openWeatherApiKey => _getString(openWeatherApiKeyKey);
  static String? get openWeatherBaseUrl => _getString(openWeatherBaseUrlKey);

  /// Returns the appropriate Google Client ID for the current platform
  /// Web uses GOOGLE_WEB_CLIENT_ID
  /// Android uses GOOGLE_ANDROID_CLIENT_ID
  /// iOS uses GOOGLE_IOS_CLIENT_ID (if provided)
  ///
  /// Falls back to web client on unsupported platforms if none match
  static String get googleClientId {
    if (kIsWeb) {
      return _getRequired(googleWebClientIdKey);
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _getString(googleAndroidClientIdKey) ??
          _getString(googleWebClientIdKey)!;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _getString(googleIosClientIdKey) ??
          _getString(googleWebClientIdKey)!;
    }

    // fallback for other platforms (e.g., web on flutter desktop)
    return _getString(googleWebClientIdKey) ??
        _getString(googleAndroidClientIdKey)!;
  }

  /// Returns web-specific client ID (for serverAuthCode usage)
  /// May be empty on non-web platforms
  static String? get googleWebClientId => _getString(googleWebClientIdKey);

  /// Returns Android client ID if available
  static String? get googleAndroidClientId =>
      _getString(googleAndroidClientIdKey);

  /// Returns iOS client ID if available
  static String? get googleIosClientId => _getString(googleIosClientIdKey);

  /// Safely get optional value (can be null or empty)
  static String? _getString(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// Get required env value - throws if missing
  static String _getRequired(String key) {
    final value = _getString(key);
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required environment variable: $key. '
        'Please check your .env file.',
      );
    }
    return value;
  }

  /// Load environment variables
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}
