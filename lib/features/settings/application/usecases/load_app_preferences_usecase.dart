import '../../domain/entities/app_preferences.dart';
import '../requests/load_app_preferences_request.dart';
import '../services/app_preferences_storage_service.dart';

class LoadAppPreferencesUsecase {
  final AppPreferencesStorageService storage;

  LoadAppPreferencesUsecase(this.storage);

  Future<AppPreferences> call(LoadAppPreferencesRequest request) async {
    return await storage.load();
  }
}
