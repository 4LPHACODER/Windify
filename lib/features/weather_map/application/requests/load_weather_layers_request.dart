import 'package:latlong2/latlong.dart';

class LoadWeatherLayersRequest {
  final LatLng location;

  const LoadWeatherLayersRequest({required this.location});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadWeatherLayersRequest &&
          runtimeType == other.runtimeType &&
          location == other.location;

  @override
  int get hashCode => location.hashCode;
}
