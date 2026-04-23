// Infrastructure service for handling external API calls
// Ready for Dio integration

class WeatherApiService {
  // TODO: Inject Dio client here
  // final Dio _dio;

  // WeatherApiService(this._dio);

  // Future<Map<String, dynamic>> fetchWeatherData(String endpoint) async {
  //   final response = await _dio.get(endpoint);
  //   return response.data;
  // }

  // For now, mock implementation
  Future<Map<String, dynamic>> fetchWeatherData(String layer) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return {'layer': layer, 'data': 'mock data for $layer'};
  }
}
