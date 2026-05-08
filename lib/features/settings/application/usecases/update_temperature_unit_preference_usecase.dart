import '../requests/update_temperature_unit_preference_request.dart';
import '../services/app_preferences_storage_service.dart';

class UpdateTemperatureUnitPreferenceUsecase {
  final AppPreferencesStorageService storage;

  UpdateTemperatureUnitPreferenceUsecase(this.storage);

  Future<void> call(UpdateTemperatureUnitPreferenceRequest request) async {
    await storage.saveTemperatureUnit(request.value);
  }
}
