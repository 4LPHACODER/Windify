import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/location.dart';

/// Service for accessing device location using geolocator
class GeolocationService {
  /// Get current precise location
  Future<Location> getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        timeLimit: Duration(seconds: 10),
      ),
    );

    return Location(
      coordinates: LatLng(position.latitude, position.longitude),
      name: 'Current Location',
    );
  }

  /// Get last known location (may be cached, no permission prompt)
  Future<Location?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return Location(
        coordinates: LatLng(position.latitude, position.longitude),
        name: 'Last Known',
      );
    } catch (_) {
      return null;
    }
  }

  /// Continuous location updates
  Stream<Location> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).map(
      (pos) => Location(
        coordinates: LatLng(pos.latitude, pos.longitude),
        name: 'Current Location',
      ),
    );
  }

  /// Check permission status
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  /// Request permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check if location service enabled
  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
