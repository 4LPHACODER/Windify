import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/weather_layer.dart';
import '../../domain/entities/location.dart';
import 'package:latlong2/latlong.dart';

class WeatherMapState {
  final bool isLoading;
  final WeatherLayer selectedLayer;
  final ForecastMap? currentMap;
  final String? error;
  final LatLng selectedLocation;
  final String? locationName;
  final List<Location> searchResults;
  final bool isSearching;
  final bool isInfoExpanded;

  const WeatherMapState({
    this.isLoading = false,
    this.selectedLayer = WeatherLayer.radar,
    this.currentMap,
    this.error,
    this.selectedLocation = const LatLng(9.0780, 126.1986),
    this.locationName,
    this.searchResults = const [],
    this.isSearching = false,
    this.isInfoExpanded = true,
  });

  WeatherMapState copyWith({
    bool? isLoading,
    WeatherLayer? selectedLayer,
    ForecastMap? currentMap,
    String? error,
    LatLng? selectedLocation,
    String? locationName,
    List<Location>? searchResults,
    bool? isSearching,
    bool? isInfoExpanded,
  }) {
    return WeatherMapState(
      isLoading: isLoading ?? this.isLoading,
      selectedLayer: selectedLayer ?? this.selectedLayer,
      currentMap: currentMap ?? this.currentMap,
      error: error ?? this.error,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      locationName: locationName ?? this.locationName,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isInfoExpanded: isInfoExpanded ?? this.isInfoExpanded,
    );
  }
}
