import '../requests/update_wind_speed_unit_preference_request.dart';
import '../services/app_preferences_storage_service.dart';

class UpdateWindSpeedUnitPreferenceUsecase {
  final AppPreferencesStorageService storage;

  UpdateWindSpeedUnitPreferenceUsecase(this.storage);

  Future<void> call(UpdateWindSpeedUnitPreferenceRequest request) async {
    await storage.saveWindSpeedUnit(request.value);
  }
}
