import '../repositories/booking_repository.dart';

class SubmitBookingUseCase {
  final BookingRepository repository;

  SubmitBookingUseCase(this.repository);

  Future<Map<String, dynamic>> call(Map<String, dynamic> payload) async {
    return await repository.submitBooking(payload);
  }
}
