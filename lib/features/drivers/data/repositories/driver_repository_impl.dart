import 'package:geolocator/geolocator.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/driver_search_type.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remoteDataSource;

  DriverRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DriverEntity>> getDrivers({
    required DriverSearchType searchType,
    double? userLat,
    double? userLng,
  }) async {
    final rawDrivers = await remoteDataSource.fetchDrivers();

    // Calculate real distance if user position is provided
    final List<DriverEntity> updatedDrivers = rawDrivers.map((driver) {
      double calcDistance = driver.distance;
      if (userLat != null && userLng != null) {
        final distInMeters = Geolocator.distanceBetween(
          userLat,
          userLng,
          driver.latitude,
          driver.longitude,
        );
        calcDistance = double.parse((distInMeters / 1000.0).toStringAsFixed(1));
      }
      return driver.copyWith(distance: calcDistance);
    }).toList();

    // Distance filtering logic:
    // Local: distance <= 100.0 KM
    // Outstation: distance > 100.0 KM
    final filteredDrivers = updatedDrivers.where((driver) {
      if (searchType == DriverSearchType.local) {
        return driver.distance <= 100.0;
      } else {
        return driver.distance > 100.0;
      }
    }).toList();

    // Sort by distance ascending (nearest driver first)
    filteredDrivers.sort((a, b) => a.distance.compareTo(b.distance));

    return filteredDrivers;
  }
}
