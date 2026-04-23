class GetForecastMapRequest {
  final String layer;

  const GetForecastMapRequest({required this.layer});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetForecastMapRequest &&
          runtimeType == other.runtimeType &&
          layer == other.layer;

  @override
  int get hashCode => layer.hashCode;
}
