import '../repositories/valet_parking_repository.dart';

class RequestVehicleRetrievalUseCase {
  final ValetParkingRepository repository;

  RequestVehicleRetrievalUseCase(this.repository);

  Future<void> call(String ticketId) async {
    return await repository.requestVehicleRetrieval(ticketId);
  }
}
