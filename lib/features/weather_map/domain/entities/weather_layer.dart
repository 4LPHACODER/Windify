enum WeatherLayer { radar, wind, wave }

extension WeatherLayerExtension on WeatherLayer {
  String get displayName {
    switch (this) {
      case WeatherLayer.radar:
        return 'Weather Radar';
      case WeatherLayer.wind:
        return 'Wind Forecast';
      case WeatherLayer.wave:
        return 'Wave Forecast';
    }
  }

  String get iconPath {
    switch (this) {
      case WeatherLayer.radar:
        return 'assets/icons/radar.png';
      case WeatherLayer.wind:
        return 'assets/icons/wind.png';
      case WeatherLayer.wave:
        return 'assets/icons/wave.png';
    }
  }
}
