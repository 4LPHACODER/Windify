import '../../domain/entities/forecast_map.dart';
import '../dto/forecast_map_dto.dart';

class ForecastMapMapper {
  static ForecastMap fromDto(ForecastMapDto dto) {
    return dto.toEntity();
  }

  static List<ForecastMap> fromDtoList(List<ForecastMapDto> dtos) {
    return dtos.map(fromDto).toList();
  }
}
