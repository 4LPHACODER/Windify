import 'package:latlong2/latlong.dart';

class ChangeWeatherLayerRequest {
  final String layer;
  final LatLng location;

  const ChangeWeatherLayerRequest({
    required this.layer,
    required this.location,
  });
}
