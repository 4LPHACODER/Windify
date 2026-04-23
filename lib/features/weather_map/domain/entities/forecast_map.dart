import 'weather_layer.dart';

class ForecastMap {
  final String id;
  final WeatherLayer layer;
  final String title;
  final String description;
  final String? imageUrl; // For animated map or thumbnail
  final DateTime updatedAt;

  const ForecastMap({
    required this.id,
    required this.layer,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.updatedAt,
  });

  ForecastMap copyWith({
    String? id,
    WeatherLayer? layer,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? updatedAt,
  }) {
    return ForecastMap(
      id: id ?? this.id,
      layer: layer ?? this.layer,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
