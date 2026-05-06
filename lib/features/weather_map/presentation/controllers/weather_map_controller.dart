import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../application/providers/weather_providers.dart';
import '../../application/services/geocoding_service.dart';
import '../../application/services/geolocation_service.dart';
import '../../application/services/weather_map_service.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/weather_layer.dart';
import '../map/weather_map_debug_log.dart';
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
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _refreshWeatherForActiveLocation();
    await _resolveDeviceLocationInBackground();
  }

  Future<void> _refreshWeatherForActiveLocation() async {
    final loc = state.activeLocationForWeather;
    state = state.copyWith(isLoadingWeather: true, error: null);
    try {
      final map = await _weatherMapService.getForecastMap(
        layer: state.selectedLayer,
        location: loc,
      );
      state = state.copyWith(
        isLoadingWeather: false,
        currentMap: map,
        error: null,
      );
      WeatherMapDebugLog.activeWeatherTarget(
        state.activeLocationForWeather,
        state.activeLocationLabel,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingWeather: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _resolveDeviceLocationInBackground() async {
    state = state.copyWith(isRequestingLocation: true);

    var perm = await _geolocationService.checkPermission();
    state = state.copyWith(locationPermissionStatus: perm);

    if (perm == LocationPermission.denied) {
      perm = await _geolocationService.requestPermission();
    }

    state = state.copyWith(locationPermissionStatus: perm);

    if (perm != LocationPermission.always &&
        perm != LocationPermission.whileInUse) {
      state = state.copyWith(
        isRequestingLocation: false,
        error:
            'Location unavailable. Showing ${WeatherMapState.fallbackLabel}.',
      );
      return;
    }

    try {
      final location = await _geolocationService.getCurrentLocation();
      state = state.copyWith(
        userLocation: location.coordinates,
        userLocationLabel: location.name,
        isRequestingLocation: false,
        error: null,
      );
      if (state.selectedLocation == null) {
        await _refreshWeatherForActiveLocation();
      }
    } catch (e) {
      state = state.copyWith(
        isRequestingLocation: false,
        error: 'Could not read GPS ($e). Map location unchanged.',
      );
    }
  }

  Future<void> fetchCurrentLocation() async {
    state = state.copyWith(isRequestingLocation: true, error: null);
    var perm = await _geolocationService.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await _geolocationService.requestPermission();
    }
    state = state.copyWith(locationPermissionStatus: perm);

    if (perm != LocationPermission.always &&
        perm != LocationPermission.whileInUse) {
      state = state.copyWith(
        isRequestingLocation: false,
        error:
            'Location permission denied. Showing ${WeatherMapState.fallbackLabel}.',
      );
      return;
    }

    try {
      final location = await _geolocationService.getCurrentLocation();
      state = state.copyWith(
        userLocation: location.coordinates,
        userLocationLabel: location.name,
        isRequestingLocation: false,
        error: null,
      );
      if (state.selectedLocation == null) {
        await _refreshWeatherForActiveLocation();
      }
    } catch (e) {
      state = state.copyWith(
        isRequestingLocation: false,
        error: 'Could not get location: $e',
      );
    }
  }

  Future<List<Location>> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    return _geocodingService.searchPlaces(query);
  }

  Future<void> selectSearchResult(Location location) async {
    state = state.copyWith(
      selectedLocation: location.coordinates,
      selectedLocationLabel:
          location.name ?? location.address ?? 'Selected place',
    );
    WeatherMapDebugLog.selectedPinSet(
      location.coordinates,
      state.selectedLocationLabel,
    );
    await _refreshWeatherForActiveLocation();
  }

  Future<void> pinLocation(LatLng coordinates) async {
    var label = 'Pinned';
    try {
      final loc = await _geocodingService.reverseGeocode(coordinates);
      label = loc.name ?? loc.address ?? 'Pinned';
    } catch (_) {}
    state = state.copyWith(
      selectedLocation: coordinates,
      selectedLocationLabel: label,
    );
    WeatherMapDebugLog.selectedPinSet(coordinates, label);
    await _refreshWeatherForActiveLocation();
  }

  /// Apply a saved place: selected pin + label, refresh forecast for current layer (radar/wind/wave).
  Future<void> visitSavedLocation(LatLng coordinates, String locationName) async {
    state = state.copyWith(
      selectedLocation: coordinates,
      selectedLocationLabel: locationName,
    );
    WeatherMapDebugLog.selectedPinSet(coordinates, locationName);
    await _refreshWeatherForActiveLocation();
  }

  Future<void> selectLayer(WeatherLayer layer) async {
    if (layer == state.selectedLayer) return;

    state = state.copyWith(
      selectedLayer: layer,
      isLoadingWeather: true,
      error: null,
    );

    try {
      final map = await _weatherMapService.getForecastMap(
        layer: layer,
        location: state.activeLocationForWeather,
      );
      state = state.copyWith(isLoadingWeather: false, currentMap: map);
    } catch (e) {
      state = state.copyWith(isLoadingWeather: false, error: e.toString());
    }
  }

  /// Sidebar "Refresh": clear selected pin, use GPS or fallback for weather, keep map camera (no logic here).
  Future<void> refresh() async {
    WeatherMapDebugLog.sidebarRefreshPressed();
    state = state.copyWith(
      selectedLocation: null,
      selectedLocationLabel: null,
    );
    WeatherMapDebugLog.selectedPinCleared('sidebar_refresh');
    await _refreshWeatherForActiveLocation();
  }

  /// Error-banner retry: refetch weather only; keep selected pin and camera.
  Future<void> reloadWeatherOnly() async {
    WeatherMapDebugLog.reloadWeatherOnlyPressed();
    await _refreshWeatherForActiveLocation();
  }

  void toggleInfoExpanded() {
    state = state.copyWith(isInfoExpanded: !state.isInfoExpanded);
  }

  void dismissError() {
    state = state.copyWith(error: null);
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
