import '../entities/valet_event_booking_item.dart';
import '../entities/valet_event_booking_response.dart';
import '../repositories/home_repository.dart';

class AddValetEventBookingUseCase {
  final HomeRepository repository;

  AddValetEventBookingUseCase(this.repository);

  Future<ValetEventBookingResponse> call(ValetEventBookingItem booking) async {
    return await repository.addValetEventBooking(booking);
  }
}
