import '../entities/forecast_map.dart';
import '../entities/weather_layer.dart';
import 'package:latlong2/latlong.dart';

abstract class WeatherRepository {
  Future<List<ForecastMap>> getWeatherForLocation(LatLng location);
  Future<ForecastMap> getWeatherForLayer(
    LatLng location,
    WeatherLayer layer, [
    DateTime? forecastTime,
  ]);
  Future<List<ForecastMap>> getTimelineForLayer(
    LatLng location,
    WeatherLayer layer,
  );
}
