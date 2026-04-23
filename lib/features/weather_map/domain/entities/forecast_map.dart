import 'package:latlong2/latlong.dart';
import 'weather_layer.dart';
import 'weather_data.dart';

class ForecastMap {
  final String id;
  final WeatherLayer layer;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime updatedAt;
  final LatLng? coordinates;
  final CurrentWeather? currentWeather;
  final WindInfo? windInfo;
  final WaveInfo? waveInfo;

  const ForecastMap({
    required this.id,
    required this.layer,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.updatedAt,
    this.coordinates,
    this.currentWeather,
    this.windInfo,
    this.waveInfo,
  });

  ForecastMap copyWith({
    String? id,
    WeatherLayer? layer,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? updatedAt,
    LatLng? coordinates,
    CurrentWeather? currentWeather,
    WindInfo? windInfo,
    WaveInfo? waveInfo,
  }) {
    return ForecastMap(
      id: id ?? this.id,
      layer: layer ?? this.layer,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      coordinates: coordinates ?? this.coordinates,
      currentWeather: currentWeather ?? this.currentWeather,
      windInfo: windInfo ?? this.windInfo,
      waveInfo: waveInfo ?? this.waveInfo,
    );
  }
}
