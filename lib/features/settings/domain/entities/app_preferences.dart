enum MapStylePreference { satellite, streets, dark }

extension MapStylePreferenceExtension on MapStylePreference {
  String get label {
    switch (this) {
      case MapStylePreference.satellite:
        return 'Satellite';
      case MapStylePreference.streets:
        return 'Streets';
      case MapStylePreference.dark:
        return 'Dark';
    }
  }

  String get mapboxStyleId {
    switch (this) {
      case MapStylePreference.satellite:
        return 'mapbox/satellite-streets-v12';
      case MapStylePreference.streets:
        return 'mapbox/streets-v12';
      case MapStylePreference.dark:
        return 'mapbox/dark-v11';
    }
  }
}

enum TemperatureUnitPreference { celsius, fahrenheit }

extension TemperatureUnitPreferenceExtension on TemperatureUnitPreference {
  String get label {
    switch (this) {
      case TemperatureUnitPreference.celsius:
        return 'Celsius (C)';
      case TemperatureUnitPreference.fahrenheit:
        return 'Fahrenheit (F)';
    }
  }
}

enum WindSpeedUnitPreference { metersPerSecond, kilometersPerHour, milesPerHour }

extension WindSpeedUnitPreferenceExtension on WindSpeedUnitPreference {
  String get label {
    switch (this) {
      case WindSpeedUnitPreference.metersPerSecond:
        return 'Meters/second (m/s)';
      case WindSpeedUnitPreference.kilometersPerHour:
        return 'Kilometers/hour (km/h)';
      case WindSpeedUnitPreference.milesPerHour:
        return 'Miles/hour (mph)';
    }
  }
}

class AppPreferences {
  final bool isLoaded;
  final MapStylePreference mapStyle;
  final bool notificationsEnabled;
  final TemperatureUnitPreference temperatureUnit;
  final WindSpeedUnitPreference windSpeedUnit;

  const AppPreferences({
    this.isLoaded = false,
    this.mapStyle = MapStylePreference.satellite,
    this.notificationsEnabled = true,
    this.temperatureUnit = TemperatureUnitPreference.celsius,
    this.windSpeedUnit = WindSpeedUnitPreference.metersPerSecond,
  });

  AppPreferences copyWith({
    bool? isLoaded,
    MapStylePreference? mapStyle,
    bool? notificationsEnabled,
    TemperatureUnitPreference? temperatureUnit,
    WindSpeedUnitPreference? windSpeedUnit,
  }) {
    return AppPreferences(
      isLoaded: isLoaded ?? this.isLoaded,
      mapStyle: mapStyle ?? this.mapStyle,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      windSpeedUnit: windSpeedUnit ?? this.windSpeedUnit,
    );
  }
}
