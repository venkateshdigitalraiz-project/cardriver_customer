import '../entities/valet_parking_ticket.dart';
import '../repositories/valet_parking_repository.dart';

class RequestValetBookingUseCase {
  final ValetParkingRepository repository;

  RequestValetBookingUseCase(this.repository);

  Future<ValetParkingTicket> call({
    required String locationId,
    required String vehicleNumber,
    required String vehicleModel,
    required int estimatedHours,
    String? specialInstructions,
  }) async {
    return await repository.requestValetBooking(
      locationId: locationId,
      vehicleNumber: vehicleNumber,
      vehicleModel: vehicleModel,
      estimatedHours: estimatedHours,
      specialInstructions: specialInstructions,
    );
  }
}
