import '../entities/driver_entity.dart';
import '../entities/driver_search_type.dart';
import '../repositories/driver_repository.dart';

class GetDriversUseCase {
  final DriverRepository repository;

  GetDriversUseCase(this.repository);

  Future<List<DriverEntity>> call({
    required DriverSearchType searchType,
    double? userLat,
    double? userLng,
  }) {
    return repository.getDrivers(
      searchType: searchType,
      userLat: userLat,
      userLng: userLng,
    );
  }
}
