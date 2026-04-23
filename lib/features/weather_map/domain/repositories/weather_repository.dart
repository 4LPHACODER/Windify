import '../entities/forecast_map.dart';
import '../entities/weather_layer.dart';

abstract class WeatherRepository {
  Future<List<ForecastMap>> getForecastMaps();
  Future<ForecastMap> getForecastMapByLayer(WeatherLayer layer);
}
