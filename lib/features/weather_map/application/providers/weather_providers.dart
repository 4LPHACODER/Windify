import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/weather_repository.dart';
import '../../infrastructure/repositories/weather_repository_impl.dart';
import '../services/weather_map_service.dart';
import '../usecases/get_forecast_map_usecase.dart';
import '../usecases/get_weather_layers_usecase.dart';

// Repository provider
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl();
});

// Usecase providers
final getWeatherLayersUsecaseProvider = Provider<GetWeatherLayersUsecase>((
  ref,
) {
  final repository = ref.watch(weatherRepositoryProvider);
  return GetWeatherLayersUsecase(repository);
});

final getForecastMapUsecaseProvider = Provider<GetForecastMapUsecase>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return GetForecastMapUsecase(repository);
});

// Service provider
final weatherMapServiceProvider = Provider<WeatherMapService>((ref) {
  final getWeatherLayersUsecase = ref.watch(getWeatherLayersUsecaseProvider);
  final getForecastMapUsecase = ref.watch(getForecastMapUsecaseProvider);
  return WeatherMapService(getWeatherLayersUsecase, getForecastMapUsecase);
});
