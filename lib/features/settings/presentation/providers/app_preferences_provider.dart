import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_preferences.dart';

const _mapStyleKey = 'settings.map_style';
const _notificationsEnabledKey = 'settings.notifications_enabled';
const _temperatureUnitKey = 'settings.temperature_unit';
const _windSpeedUnitKey = 'settings.wind_speed_unit';

class AppPreferencesNotifier extends StateNotifier<AppPreferences> {
  AppPreferencesNotifier() : super(const AppPreferences()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapStyleIndex = prefs.getInt(_mapStyleKey) ?? 0;
      final notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      final temperatureUnitIndex = prefs.getInt(_temperatureUnitKey) ?? 0;
      final windSpeedUnitIndex = prefs.getInt(_windSpeedUnitKey) ?? 0;
      final safeMapStyleIndex =
          mapStyleIndex.clamp(0, MapStylePreference.values.length - 1);
      final safeTemperatureUnitIndex = temperatureUnitIndex.clamp(
        0,
        TemperatureUnitPreference.values.length - 1,
      );
      final safeWindSpeedUnitIndex = windSpeedUnitIndex.clamp(
        0,
        WindSpeedUnitPreference.values.length - 1,
      );

      state = state.copyWith(
        isLoaded: true,
        mapStyle: MapStylePreference.values[safeMapStyleIndex],
        notificationsEnabled: notificationsEnabled,
        temperatureUnit: TemperatureUnitPreference.values[safeTemperatureUnitIndex],
        windSpeedUnit: WindSpeedUnitPreference.values[safeWindSpeedUnitIndex],
      );
    } catch (_) {
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> setMapStyle(MapStylePreference value) async {
    state = state.copyWith(mapStyle: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_mapStyleKey, value.index);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  Future<void> setTemperatureUnit(TemperatureUnitPreference value) async {
    state = state.copyWith(temperatureUnit: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_temperatureUnitKey, value.index);
  }

  Future<void> setWindSpeedUnit(WindSpeedUnitPreference value) async {
    state = state.copyWith(windSpeedUnit: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_windSpeedUnitKey, value.index);
  }
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferences>(
      (ref) => AppPreferencesNotifier(),
    );
