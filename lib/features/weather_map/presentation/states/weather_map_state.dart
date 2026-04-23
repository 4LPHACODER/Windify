import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/weather_layer.dart';

class WeatherMapState {
  final bool isLoading;
  final WeatherLayer selectedLayer;
  final ForecastMap? currentMap;
  final String? error;

  const WeatherMapState({
    this.isLoading = false,
    this.selectedLayer = WeatherLayer.radar,
    this.currentMap,
    this.error,
  });

  WeatherMapState copyWith({
    bool? isLoading,
    WeatherLayer? selectedLayer,
    ForecastMap? currentMap,
    String? error,
  }) {
    return WeatherMapState(
      isLoading: isLoading ?? this.isLoading,
      selectedLayer: selectedLayer ?? this.selectedLayer,
      currentMap: currentMap ?? this.currentMap,
      error: error ?? this.error,
    );
  }
}
