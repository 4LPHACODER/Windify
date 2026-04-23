import '../dto/forecast_map_dto.dart';

abstract class WeatherRemoteDatasource {
  Future<List<ForecastMapDto>> getForecastMaps();
  Future<ForecastMapDto> getForecastMapByLayer(String layer);
}
