import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/saved_locations_repository.dart';
import '../requests/list_saved_locations_request.dart';

class ListSavedLocationsUsecase {
  final SavedLocationsRepository repository;

  ListSavedLocationsUsecase(this.repository);

  Future<List<SavedLocation>> call(ListSavedLocationsRequest request) async {
    return await repository.fetchForCurrentUser();
  }
}
