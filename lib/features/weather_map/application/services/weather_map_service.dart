import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/weather_layer.dart';
import '../requests/change_weather_layer_request.dart';
import '../requests/get_forecast_map_request.dart';
import '../requests/load_weather_layers_request.dart';
import '../usecases/get_forecast_map_usecase.dart';
import '../usecases/get_weather_layers_usecase.dart';
import 'package:latlong2/latlong.dart';

class WeatherMapService {
  final GetWeatherLayersUsecase _getWeatherLayersUsecase;
  final GetForecastMapUsecase _getForecastMapUsecase;

  WeatherMapService(this._getWeatherLayersUsecase, this._getForecastMapUsecase);

  Future<List<ForecastMap>> loadWeatherLayers(LatLng location) async {
    final request = LoadWeatherLayersRequest(location: location);
    return await _getWeatherLayersUsecase(request);
  }

  Future<ForecastMap> getForecastMap({
    required WeatherLayer layer,
    required LatLng location,
  }) async {
    final request = GetForecastMapRequest(
      layer: layer.name,
      location: location,
    );
    return await _getForecastMapUsecase(request);
  }

  Future<ForecastMap> changeWeatherLayer(
    ChangeWeatherLayerRequest request,
  ) async {
    final layer = WeatherLayer.values.firstWhere(
      (l) => l.name == request.layer,
      orElse: () => WeatherLayer.radar,
    );
    return await getForecastMap(layer: layer, location: request.location);
  }
}
