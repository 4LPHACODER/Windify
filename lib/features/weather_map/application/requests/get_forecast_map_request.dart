import 'package:latlong2/latlong.dart';

class GetForecastMapRequest {
  final String layer;
  final LatLng location;
  final DateTime? forecastTime;

  const GetForecastMapRequest({
    required this.layer,
    required this.location,
    this.forecastTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetForecastMapRequest &&
          runtimeType == other.runtimeType &&
          layer == other.layer &&
          location == other.location &&
          forecastTime == other.forecastTime;

  @override
  int get hashCode => layer.hashCode ^ location.hashCode ^ forecastTime.hashCode;
}
