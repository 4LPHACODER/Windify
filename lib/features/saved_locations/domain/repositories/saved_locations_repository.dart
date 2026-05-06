import '../entities/saved_location.dart';

abstract class SavedLocationsRepository {
  Future<List<SavedLocation>> fetchForCurrentUser();

  Future<SavedLocation> save({
    required String userId,
    required String locationName,
    required double latitude,
    required double longitude,
  });

  Future<void> delete({required int id, required String userId});
}
