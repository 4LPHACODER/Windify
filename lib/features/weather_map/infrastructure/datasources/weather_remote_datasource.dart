import '../../domain/entities/forecast_map.dart';
import 'package:latlong2/latlong.dart';

abstract class WeatherRemoteDatasource {
  Future<ForecastMap> getWeatherData(
    LatLng location,
    String layer, {
    DateTime? forecastTime,
  });
  Future<List<ForecastMap>> getWeatherTimeline(LatLng location, String layer);
}
