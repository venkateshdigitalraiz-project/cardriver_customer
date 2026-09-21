import '../entities/driver_entity.dart';
import '../entities/driver_search_type.dart';

abstract class DriverRepository {
  Future<List<DriverEntity>> getDrivers({
    required DriverSearchType searchType,
    double? userLat,
    double? userLng,
  });
}
