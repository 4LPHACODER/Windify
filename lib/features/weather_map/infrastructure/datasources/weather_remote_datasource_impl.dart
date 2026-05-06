import 'weather_remote_datasource.dart';
import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/weather_layer.dart';
import '../../domain/entities/weather_data.dart';
import '../services/weather_api_service.dart';
import '../../application/services/geocoding_service.dart';
import 'package:latlong2/latlong.dart';

class WeatherRemoteDatasourceImpl implements WeatherRemoteDatasource {
  final WeatherApiService _weatherApi;
  final GeocodingService _geocoding;

  WeatherRemoteDatasourceImpl({
    WeatherApiService? weatherApi,
    GeocodingService? geocoding,
  }) : _weatherApi = weatherApi ?? WeatherApiService(),
       _geocoding = geocoding ?? GeocodingService();

  @override
  Future<ForecastMap> getWeatherData(LatLng location, String layer) async {
    // Fetch current weather from OpenWeather
    final currentWeather = await _weatherApi.getCurrentWeatherByCoords(
      lat: location.latitude,
      lon: location.longitude,
    );

    // Reverse geocode to get place name
    String placeName = 'Selected Location';
    try {
      final loc = await _geocoding.reverseGeocode(location);
      placeName = loc.name ?? loc.address ?? placeName;
    } catch (_) {
      // ignore
    }

    // Wind info
    final windInfo = WindInfo(
      speed: currentWeather.windSpeed,
      direction: currentWeather.windDirection,
      directionName: _getCompassDirection(currentWeather.windDirection),
      gust: currentWeather.windGust,
    );

    // Wave estimate
    final waveInfo = WaveInfo.estimate(
      windSpeed: currentWeather.windSpeed,
      weatherMain: currentWeather.description,
    );

    return ForecastMap(
      id: '${layer}_${DateTime.now().millisecondsSinceEpoch}',
      layer: _parseLayer(layer),
      title: _getTitleForLayer(layer),
      description: '$placeName • ${currentWeather.description}',
      coordinates: location,
      currentWeather: currentWeather,
      windInfo: windInfo,
      waveInfo: waveInfo,
      updatedAt: currentWeather.timestamp,
    );
  }

  WeatherLayer _parseLayer(String layer) {
    switch (layer) {
      case 'radar':
        return WeatherLayer.radar;
      case 'wind':
        return WeatherLayer.wind;
      case 'wave':
        return WeatherLayer.wave;
      default:
        return WeatherLayer.radar;
    }
  }

  String _getTitleForLayer(String layer) {
    switch (layer) {
      case 'radar':
        return 'Weather Radar';
      case 'wind':
        return 'Wind Forecast';
      case 'wave':
        return 'Wave Forecast';
      default:
        return 'Weather';
    }
  }

  String _getCompassDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor() % 8;
    return directions[index];
  }
}
