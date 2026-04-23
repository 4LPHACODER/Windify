import 'package:dio/dio.dart';

import '../../domain/entities/weather_data.dart';
import '../../../../core/config/env_config.dart';

/// Service for fetching weather data from OpenWeather API
class WeatherApiService {
  final Dio _dio;
  final String _apiKey;

  WeatherApiService({Dio? dio, String? apiKey})
    : _dio = dio ?? Dio(),
      _apiKey = apiKey ?? EnvConfig.openWeatherApiKey ?? '';

  /// Fetch current weather by coordinates
  Future<CurrentWeather> getCurrentWeatherByCoords({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenWeather API key not configured in .env');
    }

    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': units,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return CurrentWeather.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } on DioException catch (e) {
      throw Exception('Weather API error: ${e.message}');
    }
  }

  /// Get 5-day forecast (useful for wind/wave trends)
  Future<Map<String, dynamic>> getForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenWeather API key not configured');
    }

    final response = await _dio.get(
      'https://api.openweathermap.org/data/2.5/forecast',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': _apiKey,
        'units': units,
      },
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch forecast');
    }
  }

  /// Get precipitation/rain data (for radar simulation)
  Future<Map<String, dynamic>?> getPrecipitation({
    required double lat,
    required double lon,
  }) async {
    try {
      final weather = await getCurrentWeatherByCoords(lat: lat, lon: lon);
      return {
        'precipitation': weather.precipitation ?? 0,
        'timestamp': weather.timestamp.toIso8601String(),
      };
    } catch (_) {
      return null;
    }
  }
}
