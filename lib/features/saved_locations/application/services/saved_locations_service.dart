import '../../domain/entities/saved_location.dart';
import '../requests/delete_saved_location_request.dart';
import '../requests/list_saved_locations_request.dart';
import '../requests/save_saved_location_request.dart';
import '../usecases/delete_saved_location_usecase.dart';
import '../usecases/list_saved_locations_usecase.dart';
import '../usecases/save_saved_location_usecase.dart';

class SavedLocationsService {
  final ListSavedLocationsUsecase _listSavedLocationsUsecase;
  final SaveSavedLocationUsecase _saveSavedLocationUsecase;
  final DeleteSavedLocationUsecase _deleteSavedLocationUsecase;

  SavedLocationsService(
    this._listSavedLocationsUsecase,
    this._saveSavedLocationUsecase,
    this._deleteSavedLocationUsecase,
  );

  Future<List<SavedLocation>> list(ListSavedLocationsRequest request) async {
    return await _listSavedLocationsUsecase(request);
  }

  Future<SavedLocation> save(SaveSavedLocationRequest request) async {
    return await _saveSavedLocationUsecase(request);
  }

  Future<void> delete(DeleteSavedLocationRequest request) async {
    await _deleteSavedLocationUsecase(request);
  }
}
