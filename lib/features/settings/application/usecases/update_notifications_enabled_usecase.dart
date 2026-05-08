import '../requests/update_notifications_enabled_request.dart';
import '../services/app_preferences_storage_service.dart';

class UpdateNotificationsEnabledUsecase {
  final AppPreferencesStorageService storage;

  UpdateNotificationsEnabledUsecase(this.storage);

  Future<void> call(UpdateNotificationsEnabledRequest request) async {
    await storage.saveNotificationsEnabled(request.value);
  }
}
