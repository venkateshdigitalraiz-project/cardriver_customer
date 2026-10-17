import '../entities/valet_booking_entity.dart';
import '../repositories/valet_parking_repository.dart';

class GetValetBookingsUseCase {
  final ValetParkingRepository repository;

  GetValetBookingsUseCase(this.repository);

  Future<List<ValetBookingEntity>> call({int page = 1, int limit = 10}) async {
    return await repository.getValetBookings(page: page, limit: limit);
  }
}
