import '../../domain/entities/forecast_map.dart';
import '../../domain/entities/weather_layer.dart';

class ForecastMapDto {
  final String id;
  final String layer;
  final String title;
  final String description;
  final String? imageUrl;
  final String updatedAt;

  const ForecastMapDto({
    required this.id,
    required this.layer,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.updatedAt,
  });

  factory ForecastMapDto.fromJson(Map<String, dynamic> json) {
    return ForecastMapDto(
      id: json['id'] as String,
      layer: json['layer'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'layer': layer,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'updatedAt': updatedAt,
    };
  }

  ForecastMap toEntity() {
    WeatherLayer weatherLayer;
    switch (layer) {
      case 'radar':
        weatherLayer = WeatherLayer.radar;
        break;
      case 'wind':
        weatherLayer = WeatherLayer.wind;
        break;
      case 'wave':
        weatherLayer = WeatherLayer.wave;
        break;
      default:
        throw Exception('Unknown layer: $layer');
    }

    return ForecastMap(
      id: id,
      layer: weatherLayer,
      title: title,
      description: description,
      imageUrl: imageUrl,
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
