import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_preferences.dart';
import '../requests/load_app_preferences_request.dart';
import '../requests/update_map_style_preference_request.dart';
import '../requests/update_notifications_enabled_request.dart';
import '../requests/update_temperature_unit_preference_request.dart';
import '../requests/update_wind_speed_unit_preference_request.dart';
import '../services/app_preferences_service.dart';
import '../services/app_preferences_storage_service.dart';
import '../usecases/load_app_preferences_usecase.dart';
import '../usecases/update_map_style_preference_usecase.dart';
import '../usecases/update_notifications_enabled_usecase.dart';
import '../usecases/update_temperature_unit_preference_usecase.dart';
import '../usecases/update_wind_speed_unit_preference_usecase.dart';

final appPreferencesStorageServiceProvider = Provider<AppPreferencesStorageService>(
  (ref) => AppPreferencesStorageService(),
);

final loadAppPreferencesUsecaseProvider = Provider<LoadAppPreferencesUsecase>((
  ref,
) {
  final storage = ref.watch(appPreferencesStorageServiceProvider);
  return LoadAppPreferencesUsecase(storage);
});

final updateMapStylePreferenceUsecaseProvider =
    Provider<UpdateMapStylePreferenceUsecase>((ref) {
      final storage = ref.watch(appPreferencesStorageServiceProvider);
      return UpdateMapStylePreferenceUsecase(storage);
    });

final updateNotificationsEnabledUsecaseProvider =
    Provider<UpdateNotificationsEnabledUsecase>((ref) {
      final storage = ref.watch(appPreferencesStorageServiceProvider);
      return UpdateNotificationsEnabledUsecase(storage);
    });

final updateTemperatureUnitPreferenceUsecaseProvider =
    Provider<UpdateTemperatureUnitPreferenceUsecase>((ref) {
      final storage = ref.watch(appPreferencesStorageServiceProvider);
      return UpdateTemperatureUnitPreferenceUsecase(storage);
    });

final updateWindSpeedUnitPreferenceUsecaseProvider =
    Provider<UpdateWindSpeedUnitPreferenceUsecase>((ref) {
      final storage = ref.watch(appPreferencesStorageServiceProvider);
      return UpdateWindSpeedUnitPreferenceUsecase(storage);
    });

final appPreferencesServiceProvider = Provider<AppPreferencesService>((ref) {
  final load = ref.watch(loadAppPreferencesUsecaseProvider);
  final updateMapStyle = ref.watch(updateMapStylePreferenceUsecaseProvider);
  final updateNotifications = ref.watch(updateNotificationsEnabledUsecaseProvider);
  final updateTemperature = ref.watch(updateTemperatureUnitPreferenceUsecaseProvider);
  final updateWindSpeed = ref.watch(updateWindSpeedUnitPreferenceUsecaseProvider);
  return AppPreferencesService(
    load,
    updateMapStyle,
    updateNotifications,
    updateTemperature,
    updateWindSpeed,
  );
});

class AppPreferencesNotifier extends StateNotifier<AppPreferences> {
  final AppPreferencesService _service;

  AppPreferencesNotifier(this._service) : super(const AppPreferences()) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = await _service.load(const LoadAppPreferencesRequest());
    } catch (_) {
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> setMapStyle(MapStylePreference value) async {
    state = state.copyWith(mapStyle: value);
    await _service.updateMapStyle(UpdateMapStylePreferenceRequest(value: value));
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _service.updateNotificationsEnabled(
      UpdateNotificationsEnabledRequest(value: value),
    );
  }

  Future<void> setTemperatureUnit(TemperatureUnitPreference value) async {
    state = state.copyWith(temperatureUnit: value);
    await _service.updateTemperatureUnit(
      UpdateTemperatureUnitPreferenceRequest(value: value),
    );
  }

  Future<void> setWindSpeedUnit(WindSpeedUnitPreference value) async {
    state = state.copyWith(windSpeedUnit: value);
    await _service.updateWindSpeedUnit(
      UpdateWindSpeedUnitPreferenceRequest(value: value),
    );
  }
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferences>((ref) {
      final service = ref.watch(appPreferencesServiceProvider);
      return AppPreferencesNotifier(service);
    });
