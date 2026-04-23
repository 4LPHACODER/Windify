import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/weather_layer.dart';
import '../requests/change_weather_layer_request.dart';
import '../requests/get_forecast_map_request.dart';
import '../requests/load_weather_layers_request.dart';
import '../usecases/get_forecast_map_usecase.dart';
import '../usecases/get_weather_layers_usecase.dart';

class WeatherMapService {
  final GetWeatherLayersUsecase _getWeatherLayersUsecase;
  final GetForecastMapUsecase _getForecastMapUsecase;

  WeatherMapService(this._getWeatherLayersUsecase, this._getForecastMapUsecase);

  Future<List<ForecastMap>> loadWeatherLayers() async {
    const request = LoadWeatherLayersRequest();
    return await _getWeatherLayersUsecase(request);
  }

  Future<ForecastMap> getForecastMap(WeatherLayer layer) async {
    final request = GetForecastMapRequest(layer: layer.name);
    return await _getForecastMapUsecase(request);
  }

  Future<ForecastMap> changeWeatherLayer(
    ChangeWeatherLayerRequest request,
  ) async {
    final layer = WeatherLayer.values.firstWhere(
      (l) => l.name == request.layer,
      orElse: () => WeatherLayer.radar,
    );
    return await getForecastMap(layer);
  }
}
