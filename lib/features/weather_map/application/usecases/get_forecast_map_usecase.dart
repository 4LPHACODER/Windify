import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/weather_layer.dart';
import '../../domain/repositories/weather_repository.dart';
import '../requests/get_forecast_map_request.dart';

import 'package:latlong2/latlong.dart';

class GetForecastMapUsecase {
  final WeatherRepository repository;

  GetForecastMapUsecase(this.repository);

  Future<ForecastMap> call(GetForecastMapRequest request) async {
    final layer = WeatherLayer.values.firstWhere(
      (l) => l.name == request.layer,
      orElse: () => WeatherLayer.radar,
    );
    return await repository.getWeatherForLayer(
      request.location,
      layer,
      request.forecastTime,
    );
  }

  Future<List<ForecastMap>> getTimelineForLayer(
    LatLng location,
    WeatherLayer layer,
  ) async {
    return await repository.getTimelineForLayer(location, layer);
  }
}
