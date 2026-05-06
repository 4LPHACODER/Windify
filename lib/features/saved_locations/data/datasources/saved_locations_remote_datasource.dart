import '../../domain/entities/saved_location.dart';

abstract class SavedLocationsRemoteDatasource {
  Future<List<SavedLocation>> fetchForUser(String userId);

  Future<SavedLocation> insert({
    required String userId,
    required String locationName,
    required double latitude,
    required double longitude,
  });

  Future<void> delete({required int id, required String userId});
}
