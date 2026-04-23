class ChangeWeatherLayerRequest {
  final String layer;

  const ChangeWeatherLayerRequest({required this.layer});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeWeatherLayerRequest &&
          runtimeType == other.runtimeType &&
          layer == other.layer;

  @override
  int get hashCode => layer.hashCode;
}
