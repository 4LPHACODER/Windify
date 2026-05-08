import '../../domain/entities/app_preferences.dart';
import '../requests/load_app_preferences_request.dart';
import '../requests/update_map_style_preference_request.dart';
import '../requests/update_notifications_enabled_request.dart';
import '../requests/update_temperature_unit_preference_request.dart';
import '../requests/update_wind_speed_unit_preference_request.dart';
import '../usecases/load_app_preferences_usecase.dart';
import '../usecases/update_map_style_preference_usecase.dart';
import '../usecases/update_notifications_enabled_usecase.dart';
import '../usecases/update_temperature_unit_preference_usecase.dart';
import '../usecases/update_wind_speed_unit_preference_usecase.dart';

class AppPreferencesService {
  final LoadAppPreferencesUsecase _loadAppPreferencesUsecase;
  final UpdateMapStylePreferenceUsecase _updateMapStylePreferenceUsecase;
  final UpdateNotificationsEnabledUsecase _updateNotificationsEnabledUsecase;
  final UpdateTemperatureUnitPreferenceUsecase
      _updateTemperatureUnitPreferenceUsecase;
  final UpdateWindSpeedUnitPreferenceUsecase
      _updateWindSpeedUnitPreferenceUsecase;

  AppPreferencesService(
    this._loadAppPreferencesUsecase,
    this._updateMapStylePreferenceUsecase,
    this._updateNotificationsEnabledUsecase,
    this._updateTemperatureUnitPreferenceUsecase,
    this._updateWindSpeedUnitPreferenceUsecase,
  );

  Future<AppPreferences> load(LoadAppPreferencesRequest request) async {
    return await _loadAppPreferencesUsecase(request);
  }

  Future<void> updateMapStyle(UpdateMapStylePreferenceRequest request) async {
    await _updateMapStylePreferenceUsecase(request);
  }

  Future<void> updateNotificationsEnabled(
    UpdateNotificationsEnabledRequest request,
  ) async {
    await _updateNotificationsEnabledUsecase(request);
  }

  Future<void> updateTemperatureUnit(
    UpdateTemperatureUnitPreferenceRequest request,
  ) async {
    await _updateTemperatureUnitPreferenceUsecase(request);
  }

  Future<void> updateWindSpeedUnit(
    UpdateWindSpeedUnitPreferenceRequest request,
  ) async {
    await _updateWindSpeedUnitPreferenceUsecase(request);
  }
}
