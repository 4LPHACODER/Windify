import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/weather_layer.dart';

const Object _unset = Object();

class WeatherMapState {
  static const LatLng fallbackCoordinates = LatLng(9.0780, 126.1986);
  static const String fallbackLabel = 'Tandag';

  final bool isLoadingWeather;
  final WeatherLayer selectedLayer;
  final ForecastMap? currentMap;
  final String? error;
  final LatLng? userLocation;
  final String? userLocationLabel;
  final LatLng? selectedLocation;
  final String? selectedLocationLabel;
  final List<Location> searchResults;
  final bool isSearching;
  final bool isInfoExpanded;
  final bool isRequestingLocation;
  final LocationPermission locationPermissionStatus;

  const WeatherMapState({
    this.isLoadingWeather = false,
    this.selectedLayer = WeatherLayer.radar,
    this.currentMap,
    this.error,
    this.userLocation,
    this.userLocationLabel,
    this.selectedLocation,
    this.selectedLocationLabel,
    this.searchResults = const [],
    this.isSearching = false,
    this.isInfoExpanded = true,
    this.isRequestingLocation = false,
    this.locationPermissionStatus = LocationPermission.denied,
  });

  LatLng get activeLocationForWeather =>
      selectedLocation ?? userLocation ?? fallbackCoordinates;

  String get activeLocationLabel {
    if (selectedLocation != null) {
      return selectedLocationLabel ?? 'Selected location';
    }
    if (userLocation != null) {
      return userLocationLabel ?? 'Your location';
    }
    return fallbackLabel;
  }

  WeatherMapState copyWith({
    bool? isLoadingWeather,
    WeatherLayer? selectedLayer,
    Object? currentMap = _unset,
    Object? error = _unset,
    Object? userLocation = _unset,
    Object? userLocationLabel = _unset,
    Object? selectedLocation = _unset,
    Object? selectedLocationLabel = _unset,
    List<Location>? searchResults,
    bool? isSearching,
    bool? isInfoExpanded,
    bool? isRequestingLocation,
    LocationPermission? locationPermissionStatus,
  }) {
    return WeatherMapState(
      isLoadingWeather: isLoadingWeather ?? this.isLoadingWeather,
      selectedLayer: selectedLayer ?? this.selectedLayer,
      currentMap: currentMap == _unset
          ? this.currentMap
          : currentMap as ForecastMap?,
      error: error == _unset ? this.error : error as String?,
      userLocation: userLocation == _unset
          ? this.userLocation
          : userLocation as LatLng?,
      userLocationLabel: userLocationLabel == _unset
          ? this.userLocationLabel
          : userLocationLabel as String?,
      selectedLocation: selectedLocation == _unset
          ? this.selectedLocation
          : selectedLocation as LatLng?,
      selectedLocationLabel: selectedLocationLabel == _unset
          ? this.selectedLocationLabel
          : selectedLocationLabel as String?,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isInfoExpanded: isInfoExpanded ?? this.isInfoExpanded,
      isRequestingLocation:
          isRequestingLocation ?? this.isRequestingLocation,
      locationPermissionStatus:
          locationPermissionStatus ?? this.locationPermissionStatus,
    );
  }
}
