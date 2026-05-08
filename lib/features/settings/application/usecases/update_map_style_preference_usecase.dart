import '../requests/update_map_style_preference_request.dart';
import '../services/app_preferences_storage_service.dart';

class UpdateMapStylePreferenceUsecase {
  final AppPreferencesStorageService storage;

  UpdateMapStylePreferenceUsecase(this.storage);

  Future<void> call(UpdateMapStylePreferenceRequest request) async {
    await storage.saveMapStyle(request.value);
  }
}
