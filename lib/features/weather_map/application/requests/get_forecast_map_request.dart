import 'package:latlong2/latlong.dart';

class GetForecastMapRequest {
  final String layer;
  final LatLng location;

  const GetForecastMapRequest({required this.layer, required this.location});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetForecastMapRequest &&
          runtimeType == other.runtimeType &&
          layer == other.layer &&
          location == other.location;

  @override
  int get hashCode => layer.hashCode ^ location.hashCode;
}
