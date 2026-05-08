class SaveSavedLocationRequest {
  final String userId;
  final String locationName;
  final double latitude;
  final double longitude;

  const SaveSavedLocationRequest({
    required this.userId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });
}
