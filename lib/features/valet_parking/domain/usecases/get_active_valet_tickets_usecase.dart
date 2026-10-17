import '../entities/valet_parking_ticket.dart';
import '../repositories/valet_parking_repository.dart';

class GetActiveValetTicketsUseCase {
  final ValetParkingRepository repository;

  GetActiveValetTicketsUseCase(this.repository);

  Future<List<ValetParkingTicket>> call() async {
    return await repository.getActiveTickets();
  }
}
