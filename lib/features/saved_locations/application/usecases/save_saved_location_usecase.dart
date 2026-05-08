import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/saved_locations_repository.dart';
import '../requests/save_saved_location_request.dart';

class SaveSavedLocationUsecase {
  final SavedLocationsRepository repository;

  SaveSavedLocationUsecase(this.repository);

  Future<SavedLocation> call(SaveSavedLocationRequest request) async {
    return await repository.save(
      userId: request.userId,
      locationName: request.locationName,
      latitude: request.latitude,
      longitude: request.longitude,
    );
  }
}
