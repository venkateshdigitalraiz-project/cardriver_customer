import '../entities/valet_parking_location.dart';
import '../repositories/valet_parking_repository.dart';

class GetValetLocationsUseCase {
  final ValetParkingRepository repository;

  GetValetLocationsUseCase(this.repository);

  Future<List<ValetParkingLocation>> call({String query = ''}) async {
    return await repository.getValetLocations(query: query);
  }
}
