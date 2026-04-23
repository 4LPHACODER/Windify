import '../../domain/entities/forecast_map.dart';
import '../../domain/repositories/weather_repository.dart';
import '../requests/load_weather_layers_request.dart';

class GetWeatherLayersUsecase {
  final WeatherRepository repository;

  GetWeatherLayersUsecase(this.repository);

  Future<List<ForecastMap>> call(LoadWeatherLayersRequest request) async {
    return await repository.getForecastMaps();
  }
}
