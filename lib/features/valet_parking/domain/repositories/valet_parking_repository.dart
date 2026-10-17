import '../entities/valet_booking_entity.dart';
import '../entities/valet_parking_location.dart';
import '../entities/valet_parking_ticket.dart';

abstract class ValetParkingRepository {
  Future<List<ValetBookingEntity>> getValetBookings({int page = 1, int limit = 10});

  Future<List<ValetParkingLocation>> getValetLocations({String query = ''});
  
  Future<List<ValetParkingTicket>> getActiveTickets();

  Future<ValetParkingTicket> requestValetBooking({
    required String locationId,
    required String vehicleNumber,
    required String vehicleModel,
    required int estimatedHours,
    String? specialInstructions,
  });

  Future<void> requestVehicleRetrieval(String ticketId);
}
