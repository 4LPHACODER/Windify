import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/weather_layer.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';
import '../datasources/weather_remote_datasource_impl.dart';
import 'package:latlong2/latlong.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDatasource datasource;

  WeatherRepositoryImpl({WeatherRemoteDatasource? datasource})
    : datasource = datasource ?? WeatherRemoteDatasourceImpl();

  @override
  Future<List<ForecastMap>> getWeatherForLocation(LatLng location) async {
    final futures = WeatherLayer.values.map(
      (layer) => datasource.getWeatherData(location, layer.name),
    );
    return await Future.wait(futures);
  }

  @override
  Future<ForecastMap> getWeatherForLayer(
    LatLng location,
    WeatherLayer layer, [
    DateTime? forecastTime,
  ]) async {
    return await datasource.getWeatherData(
      location,
      layer.name,
      forecastTime: forecastTime,
    );
  }

  @override
  Future<List<ForecastMap>> getTimelineForLayer(
    LatLng location,
    WeatherLayer layer,
  ) async {
    return await datasource.getWeatherTimeline(location, layer.name);
  }
}
