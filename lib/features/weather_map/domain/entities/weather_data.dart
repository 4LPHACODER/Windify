// import 'package:latlong2/latlong.dart'; // Not used currently

/// Weather data for a specific location
class CurrentWeather {
  final double temperature; // Celsius
  final int humidity; // %
  final double windSpeed; // m/s
  final int windDirection; // degrees
  final double? windGust; // m/s
  final int? precipitation; // mm (last hour)
  final String description; // weather condition
  final String icon; // weather icon code
  final DateTime timestamp;

  const CurrentWeather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    this.windGust,
    this.precipitation,
    required this.description,
    required this.icon,
    required this.timestamp,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>?;
    final wind = json['wind'] as Map<String, dynamic>?;
    final weather = (json['weather'] as List?)?.first as Map<String, dynamic>?;
    final rain = json['rain'] as Map<String, dynamic>?;

    return CurrentWeather(
      temperature: (main?['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: (main?['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind?['speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (wind?['deg'] as num?)?.toInt() ?? 0,
      windGust: (wind?['gust'] as num?)?.toDouble(),
      precipitation: (rain?['1h'] as num?)?.toInt(),
      description: weather?['description'] as String? ?? 'Clear',
      icon: weather?['icon'] as String? ?? '01d',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as int?) ?? 0) * 1000,
      ),
    );
  }
}

/// Quick wind reading for UI
class WindInfo {
  final double speed; // m/s
  final int direction; // degrees
  final String directionName; // N, NE, E, etc.
  final double? gust; // m/s

  const WindInfo({
    required this.speed,
    required this.direction,
    required this.directionName,
    this.gust,
  });

  factory WindInfo.fromJson(Map<String, dynamic> json) {
    final wind = json['wind'] as Map<String, dynamic>?;
    final speed = (wind?['speed'] as num?)?.toDouble() ?? 0.0;
    final deg = (wind?['deg'] as num?)?.toInt() ?? 0;

    return WindInfo(
      speed: speed,
      direction: deg,
      directionName: _getCompassDirection(deg),
      gust: (wind?['gust'] as num?)?.toDouble(),
    );
  }

  static String _getCompassDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor() % 8;
    return directions[index];
  }
}

/// Represents wave/sea conditions (best effort from available data)
class WaveInfo {
  final double? swellHeight; // meters (if available)
  final int? swellPeriod; // seconds
  final int? swellDirection; // degrees
  final String description; // e.g., "calm", "choppy", "rough"

  const WaveInfo({
    this.swellHeight,
    this.swellPeriod,
    this.swellDirection,
    required this.description,
  });

  /// Estimate waves from weather and wind (fallback)
  factory WaveInfo.estimate({
    required double windSpeed,
    required String weatherMain,
  }) {
    // Simple heuristic for demo purposes
    String desc;
    double? height;

    if (weatherMain.contains('storm') || windSpeed > 20) {
      desc = 'Rough - Dangerous';
      height = 4.0;
    } else if (windSpeed > 15) {
      desc = 'Very Choppy';
      height = 2.5;
    } else if (windSpeed > 10) {
      desc = 'Choppy';
      height = 1.5;
    } else if (weatherMain.contains('rain') || windSpeed > 5) {
      desc = 'Moderate';
      height = 0.8;
    } else {
      desc = 'Calm';
      height = 0.3;
    }

    return WaveInfo(swellHeight: height, description: desc);
  }
}
