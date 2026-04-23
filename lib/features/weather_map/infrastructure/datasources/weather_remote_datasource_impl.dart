import 'weather_remote_datasource.dart';
import '../dto/forecast_map_dto.dart';

class WeatherRemoteDatasourceImpl implements WeatherRemoteDatasource {
  @override
  Future<List<ForecastMapDto>> getForecastMaps() async {
    // Mock data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [
      const ForecastMapDto(
        id: '1',
        layer: 'radar',
        title: 'Weather Radar',
        description: 'Real-time weather radar map',
        imageUrl: 'https://example.com/radar.gif',
        updatedAt: '2023-10-01T10:00:00Z',
      ),
      const ForecastMapDto(
        id: '2',
        layer: 'wind',
        title: 'Wind Forecast',
        description: 'Wind speed and direction forecast',
        imageUrl: 'https://example.com/wind.gif',
        updatedAt: '2023-10-01T10:00:00Z',
      ),
      const ForecastMapDto(
        id: '3',
        layer: 'wave',
        title: 'Wave Forecast',
        description: 'Ocean wave height and direction',
        imageUrl: 'https://example.com/wave.gif',
        updatedAt: '2023-10-01T10:00:00Z',
      ),
    ];
  }

  @override
  Future<ForecastMapDto> getForecastMapByLayer(String layer) async {
    final maps = await getForecastMaps();
    return maps.firstWhere((map) => map.layer == layer);
  }
}
