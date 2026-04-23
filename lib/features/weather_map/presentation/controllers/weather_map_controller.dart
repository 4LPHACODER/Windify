import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../application/providers/weather_providers.dart';
import '../../application/services/weather_map_service.dart';
import '../../application/services/geolocation_service.dart';
import '../../application/services/geocoding_service.dart';
import '../../domain/entities/weather_layer.dart';
import '../../domain/entities/location.dart';
import '../states/weather_map_state.dart';

class WeatherMapNotifier extends StateNotifier<WeatherMapState> {
  final WeatherMapService _weatherMapService;
  final GeolocationService _geolocationService;
  final GeocodingService _geocodingService;

  WeatherMapNotifier(
    this._weatherMapService,
    this._geolocationService,
    this._geocodingService,
  ) : super(const WeatherMapState()) {
    _loadForCurrentLocation();
  }

  Future<void> _loadForLocation(LatLng location, {String? placeName}) async {
    state = state.copyWith(
      isLoading: true,
      selectedLocation: location,
      locationName: placeName,
      error: null,
    );

    try {
      final map = await _weatherMapService.getForecastMap(
        layer: state.selectedLayer,
        location: location,
      );
      state = state.copyWith(isLoading: false, currentMap: map);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadForCurrentLocation() async {
    final lastKnown = await _geolocationService.getLastKnownLocation();
    if (lastKnown != null) {
      await _loadForLocation(lastKnown.coordinates, placeName: lastKnown.name);
      return;
    }

    await fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    final hasPermission = await _geolocationService.hasPermission();
    if (!hasPermission) {
      try {
        await _geolocationService.requestPermission();
      } catch (_) {}
    }

    if (!await _geolocationService.hasPermission()) {
      state = state.copyWith(
        error: 'Location permission denied. Using default location.',
      );
      await _loadForLocation(
        const LatLng(9.0780, 126.1986),
        placeName: 'Default',
      );
      return;
    }

    try {
      final location = await _geolocationService.getCurrentLocation();
      await _loadForLocation(location.coordinates, placeName: location.name);
    } catch (e) {
      state = state.copyWith(
        error: 'Could not get location: $e. Using default.',
      );
      await _loadForLocation(
        const LatLng(9.0780, 126.1986),
        placeName: 'Default',
      );
    }
  }

  Future<List<Location>> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final results = await _geocodingService.searchPlaces(query);
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<void> selectSearchResult(Location location) async {
    await _loadForLocation(location.coordinates, placeName: location.name);
  }

  Future<void> pinLocation(LatLng coordinates) async {
    String name = 'Pinned Location';
    try {
      final loc = await _geocodingService.reverseGeocode(coordinates);
      if (loc.name != null) name = loc.name!;
    } catch (_) {}

    await _loadForLocation(coordinates, placeName: name);
  }

  Future<void> selectLayer(WeatherLayer layer) async {
    if (layer == state.selectedLayer) return;

    state = state.copyWith(selectedLayer: layer, isLoading: true, error: null);

    try {
      final map = await _weatherMapService.getForecastMap(
        layer: layer,
        location: state.selectedLocation,
      );
      state = state.copyWith(isLoading: false, currentMap: map);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadForLocation(
      state.selectedLocation,
      placeName: state.locationName,
    );
  }
}

final weatherMapNotifierProvider =
    StateNotifierProvider<WeatherMapNotifier, WeatherMapState>((ref) {
      final weatherMapService = ref.watch(weatherMapServiceProvider);
      final geolocationService = GeolocationService();
      final geocodingService = GeocodingService();
      return WeatherMapNotifier(
        weatherMapService,
        geolocationService,
        geocodingService,
      );
    });
