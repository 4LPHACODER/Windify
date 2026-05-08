import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_preferences.dart';

const _mapStyleKey = 'settings.map_style';
const _notificationsEnabledKey = 'settings.notifications_enabled';
const _temperatureUnitKey = 'settings.temperature_unit';
const _windSpeedUnitKey = 'settings.wind_speed_unit';

class AppPreferencesStorageService {
  Future<AppPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mapStyleIndex = prefs.getInt(_mapStyleKey) ?? 0;
    final notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    final temperatureUnitIndex = prefs.getInt(_temperatureUnitKey) ?? 0;
    final windSpeedUnitIndex = prefs.getInt(_windSpeedUnitKey) ?? 0;
    final safeMapStyleIndex = mapStyleIndex.clamp(
      0,
      MapStylePreference.values.length - 1,
    );
    final safeTemperatureUnitIndex = temperatureUnitIndex.clamp(
      0,
      TemperatureUnitPreference.values.length - 1,
    );
    final safeWindSpeedUnitIndex = windSpeedUnitIndex.clamp(
      0,
      WindSpeedUnitPreference.values.length - 1,
    );

    return AppPreferences(
      isLoaded: true,
      mapStyle: MapStylePreference.values[safeMapStyleIndex],
      notificationsEnabled: notificationsEnabled,
      temperatureUnit:
          TemperatureUnitPreference.values[safeTemperatureUnitIndex],
      windSpeedUnit: WindSpeedUnitPreference.values[safeWindSpeedUnitIndex],
    );
  }

  Future<void> saveMapStyle(MapStylePreference value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_mapStyleKey, value.index);
  }

  Future<void> saveNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  Future<void> saveTemperatureUnit(TemperatureUnitPreference value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_temperatureUnitKey, value.index);
  }

  Future<void> saveWindSpeedUnit(WindSpeedUnitPreference value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_windSpeedUnitKey, value.index);
  }
}
