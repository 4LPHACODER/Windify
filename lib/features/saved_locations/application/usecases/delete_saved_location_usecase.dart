import '../../domain/repositories/saved_locations_repository.dart';
import '../requests/delete_saved_location_request.dart';

class DeleteSavedLocationUsecase {
  final SavedLocationsRepository repository;

  DeleteSavedLocationUsecase(this.repository);

  Future<void> call(DeleteSavedLocationRequest request) async {
    await repository.delete(id: request.id, userId: request.userId);
  }
}
