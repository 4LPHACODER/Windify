import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/weather_layer.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';
import '../datasources/weather_remote_datasource_impl.dart';
import '../mappers/forecast_map_mapper.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDatasource datasource;

  WeatherRepositoryImpl({WeatherRemoteDatasource? datasource})
    : datasource = datasource ?? WeatherRemoteDatasourceImpl();

  @override
  Future<List<ForecastMap>> getForecastMaps() async {
    final dtos = await datasource.getForecastMaps();
    return ForecastMapMapper.fromDtoList(dtos);
  }

  @override
  Future<ForecastMap> getForecastMapByLayer(WeatherLayer layer) async {
    final dto = await datasource.getForecastMapByLayer(layer.name);
    return ForecastMapMapper.fromDto(dto);
  }
}
