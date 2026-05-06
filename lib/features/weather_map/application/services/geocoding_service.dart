import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/location.dart';
import 'package:windify_v2/core/config/env_config.dart';

/// Geocoding via Mapbox Geocoding API (token from [EnvConfig.mapboxAccessToken]).
class GeocodingService {
  final Dio _dio;
  final String _accessToken;

  GeocodingService({Dio? dio, String? accessToken})
    : _dio = dio ?? Dio(),
      _accessToken = accessToken ?? EnvConfig.mapboxAccessToken ?? '';

  static const _forwardBase =
      'https://api.mapbox.com/geocoding/v5/mapbox.places';

  /// Search forward geocode; query is URL-encoded in the path per Mapbox API.
  Future<List<Location>> searchPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    if (_accessToken.isEmpty) {
      throw StateError(
        'Mapbox access token not configured. Add MAPBOX_ACCESS_TOKEN to .env',
      );
    }

    final encoded = Uri.encodeComponent(q);
    final pathUrl = '$_forwardBase/$encoded.json';

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        pathUrl,
        queryParameters: <String, dynamic>{
          'access_token': _accessToken,
          'autocomplete': true,
          'limit': 8,
          'language': 'en',
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final code = response.statusCode;
      final data = response.data;

      if (code != 200 || data == null) {
        final msg = data?['message']?.toString() ?? 'HTTP $code';
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: msg,
        );
      }

      final features = data['features'];
      if (features is! List) return [];

      final out = <Location>[];
      for (final raw in features) {
        if (raw is! Map) continue;
        final loc = _featureToLocation(Map<String, dynamic>.from(raw));
        if (loc != null) out.add(loc);
      }

      return out;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw StateError('Invalid or expired Mapbox access token');
      }
      throw StateError(
        e.message ?? 'Geocoding request failed',
      );
    } catch (e) {
      if (e is StateError) rethrow;
      throw StateError('Geocoding failed: $e');
    }
  }

  Location? _featureToLocation(Map<String, dynamic> feature) {
    final center = feature['center'];
    if (center is! List || center.length < 2) return null;

    double? lon;
    double? lat;
    try {
      lon = (center[0] as num).toDouble();
      lat = (center[1] as num).toDouble();
    } catch (_) {
      return null;
    }

    final placeName = feature['place_name']?.toString();
    final text = feature['text']?.toString();
    final primary = (text != null && text.isNotEmpty)
        ? text
        : (placeName != null && placeName.isNotEmpty)
            ? placeName.split(',').first.trim()
            : 'Unknown';

    return Location(
      coordinates: LatLng(lat, lon),
      name: primary,
      address: placeName,
    );
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

    final path =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${coordinates.longitude},${coordinates.latitude}.json';

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: <String, dynamic>{
          'access_token': _accessToken,
          'limit': 1,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final features = response.data!['features'];
        if (features is List && features.isNotEmpty) {
          final first = features.first;
          if (first is Map) {
            final loc = _featureToLocation(Map<String, dynamic>.from(first));
            if (loc != null) {
              return Location(
                coordinates: coordinates,
                name: loc.name,
                address: loc.address,
              );
            }
          }
        }
      }
    } catch (_) {}

    return Location(
      coordinates: coordinates,
      name: 'Selected Location',
      address: null,
    );
  }
}
