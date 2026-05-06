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
  Future<ForecastMap> getWeatherData(
    LatLng location,
    String layer, {
    DateTime? forecastTime,
  }) async {
    if (forecastTime != null) {
      final timeline = await getWeatherTimeline(location, layer);
      if (timeline.isNotEmpty) {
        return _pickClosestByTime(timeline, forecastTime);
      }
    }

    final currentWeather = await _weatherApi.getCurrentWeatherByCoords(
      lat: location.latitude,
      lon: location.longitude,
    );
    final placeName = await _resolvePlaceName(location);

    return _buildForecastMap(
      layer: layer,
      location: location,
      placeName: placeName,
      weather: currentWeather,
      idSeed: 'current',
    );
  }

  @override
  Future<List<ForecastMap>> getWeatherTimeline(LatLng location, String layer) async {
    final placeName = await _resolvePlaceName(location);
    final currentWeather = await _weatherApi.getCurrentWeatherByCoords(
      lat: location.latitude,
      lon: location.longitude,
    );
    final forecastResponse = await _weatherApi.getForecast(
      lat: location.latitude,
      lon: location.longitude,
    );
    final list = (forecastResponse['list'] as List?) ?? const [];

    final timeline = <ForecastMap>[
      _buildForecastMap(
        layer: layer,
        location: location,
        placeName: placeName,
        weather: currentWeather,
        idSeed: 'current',
      ),
    ];

    for (final item in list.take(24)) {
      if (item is! Map<String, dynamic>) continue;
      final weather = CurrentWeather.fromJson(item);
      timeline.add(
        _buildForecastMap(
          layer: layer,
          location: location,
          placeName: placeName,
          weather: weather,
          idSeed: weather.timestamp.toIso8601String(),
        ),
      );
    }

    final deduped = <DateTime, ForecastMap>{};
    for (final entry in timeline) {
      deduped[entry.updatedAt] = entry;
    }
    final result = deduped.values.toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    return result;
  }

  Future<String> _resolvePlaceName(LatLng location) async {
    String placeName = 'Selected Location';
    try {
      final loc = await _geocoding.reverseGeocode(location);
      placeName = loc.name ?? loc.address ?? placeName;
    } catch (_) {
      // ignore
    }
    return placeName;
  }

  ForecastMap _buildForecastMap({
    required String layer,
    required LatLng location,
    required String placeName,
    required CurrentWeather weather,
    required String idSeed,
  }) {
    final windInfo = WindInfo(
      speed: weather.windSpeed,
      direction: weather.windDirection,
      directionName: _getCompassDirection(weather.windDirection),
      gust: weather.windGust,
    );

    final waveInfo = WaveInfo.estimate(
      windSpeed: weather.windSpeed,
      weatherMain: weather.description,
    );

    return ForecastMap(
      id: '${layer}_$idSeed',
      layer: _parseLayer(layer),
      title: _getTitleForLayer(layer),
      description: '$placeName • ${weather.description}',
      coordinates: location,
      currentWeather: weather,
      windInfo: windInfo,
      waveInfo: waveInfo,
      updatedAt: weather.timestamp,
    );
  }

  ForecastMap _pickClosestByTime(List<ForecastMap> timeline, DateTime target) {
    ForecastMap closest = timeline.first;
    var smallestDiff = closest.updatedAt.difference(target).abs();
    for (final map in timeline.skip(1)) {
      final diff = map.updatedAt.difference(target).abs();
      if (diff < smallestDiff) {
        smallestDiff = diff;
        closest = map;
      }
    }
    return closest;
  }

  WeatherLayer _parseLayer(String layer) {
    switch (layer) {
      case 'radar':
        return WeatherLayer.radar;
      case 'wind':
        return WeatherLayer.wind;
      case 'wave':
        return WeatherLayer.wave;
      case 'cloud':
        return WeatherLayer.cloud;
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
      case 'cloud':
        return 'Cloud Cover';
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
