import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/weather_providers.dart';
import '../../application/services/weather_map_service.dart';
import '../../domain/entities/weather_layer.dart';
import '../states/weather_map_state.dart';

class WeatherMapNotifier extends StateNotifier<WeatherMapState> {
  final WeatherMapService _weatherMapService;

  WeatherMapNotifier(this._weatherMapService) : super(const WeatherMapState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final maps = await _weatherMapService.loadWeatherLayers();
      final initialMap = maps.firstWhere(
        (map) => map.layer == state.selectedLayer,
        orElse: () => maps.first,
      );
      state = state.copyWith(isLoading: false, currentMap: initialMap);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectLayer(WeatherLayer layer) async {
    if (layer == state.selectedLayer) return;

    state = state.copyWith(selectedLayer: layer, isLoading: true, error: null);
    try {
      final map = await _weatherMapService.getForecastMap(layer);
      state = state.copyWith(isLoading: false, currentMap: map);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final weatherMapNotifierProvider =
    StateNotifierProvider<WeatherMapNotifier, WeatherMapState>((ref) {
      final weatherMapService = ref.watch(weatherMapServiceProvider);
      return WeatherMapNotifier(weatherMapService);
    });
