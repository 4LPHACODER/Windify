import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/location.dart';
import 'package:windify_v2/core/config/env_config.dart';

/// Geocoding service using Mapbox Geocoding API
class GeocodingService {
  final Dio _dio;
  final String _accessToken;

  GeocodingService({Dio? dio, String? accessToken})
    : _dio = dio ?? Dio(),
      _accessToken = accessToken ?? EnvConfig.mapboxAccessToken ?? '';

  /// Search for a place by query text
  /// Returns list of matching locations
  Future<List<Location>> searchPlaces(String query) async {
    if (_accessToken.isEmpty) {
      throw Exception('Mapbox access token not configured');
    }

    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/{query}.json',
        queryParameters: {
          'access_token': _accessToken,
          'autocomplete': true,
          'limit': 5,
          'language': 'en',
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final features = response.data['features'] as List?;
        if (features == null) return [];

        return features.map((feature) {
          final coords = feature['center'] as List;
          final latitude = coords[1] as double;
          final longitude = coords[0] as double;
          final placeName = feature['place_name'] as String? ?? 'Unknown';
          return Location(
            coordinates: LatLng(latitude, longitude),
            name: placeName.split(',')[0], // primary name
            address: placeName,
          );
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid Mapbox access token');
      }
      throw Exception('Geocoding failed: ${e.message}');
    } catch (e) {
      return [];
    }
  }

  /// Reverse geocode coordinates to place name/address
  Future<Location> reverseGeocode(LatLng coordinates) async {
    if (_accessToken.isEmpty) {
      return Location(
        coordinates: coordinates,
        name: 'Unknown Location',
        address: null,
      );
    }

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${coordinates.longitude},${coordinates.latitude}.json',
        queryParameters: {'access_token': _accessToken, 'limit': 1},
      );

      if (response.statusCode == 200 && response.data != null) {
        final features = response.data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final feature = features.first;
          final placeName = feature['place_name'] as String? ?? 'Unknown';
          return Location(
            coordinates: coordinates,
            name: placeName.split(',')[0],
            address: placeName,
          );
        }
      }
    } catch (_) {
      // ignore errors, return basic location
    }

    return Location(
      coordinates: coordinates,
      name: 'Selected Location',
      address: null,
    );
  }
}
