import '../../domain/entities/valet_booking_entity.dart';
import '../../domain/entities/valet_parking_location.dart';
import '../../domain/entities/valet_parking_ticket.dart';
import '../../domain/repositories/valet_parking_repository.dart';
import '../datasources/valet_parking_remote_datasource.dart';

class ValetParkingRepositoryImpl implements ValetParkingRepository {
  final ValetParkingRemoteDataSource remoteDataSource;

  ValetParkingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ValetBookingEntity>> getValetBookings({int page = 1, int limit = 10}) async {
    return await remoteDataSource.getValetBookings(page: page, limit: limit);
  }

  @override
  Future<List<ValetParkingLocation>> getValetLocations({String query = ''}) async {
    return await remoteDataSource.getValetLocations(query: query);
  }

  @override
  Future<List<ValetParkingTicket>> getActiveTickets() async {
    return await remoteDataSource.getActiveTickets();
  }

  @override
  Future<ValetParkingTicket> requestValetBooking({
    required String locationId,
    required String vehicleNumber,
    required String vehicleModel,
    required int estimatedHours,
    String? specialInstructions,
  }) async {
    return await remoteDataSource.requestValetBooking(
      locationId: locationId,
      vehicleNumber: vehicleNumber,
      vehicleModel: vehicleModel,
      estimatedHours: estimatedHours,
      specialInstructions: specialInstructions,
    );
  }

  @override
  Future<void> requestVehicleRetrieval(String ticketId) async {
    return await remoteDataSource.requestVehicleRetrieval(ticketId);
  }
}
