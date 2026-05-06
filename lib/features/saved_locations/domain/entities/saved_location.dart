// A row from `saved_locations` (Supabase).
class SavedLocation {
  /// Supabase bigserial/int id. Nullable for pre-insert instances.
  final int? id;
  final String userId;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  const SavedLocation({
    required this.id,
    required this.userId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : (rawId is String ? int.tryParse(rawId) : null);
    return SavedLocation(
      id: parsedId,
      userId: json['user_id'] as String,
      locationName: json['location_name'] as String? ?? 'Saved place',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
