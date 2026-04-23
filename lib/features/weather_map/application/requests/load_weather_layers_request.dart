class LoadWeatherLayersRequest {
  const LoadWeatherLayersRequest();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadWeatherLayersRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
