import '../entities/booking_detail_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingDetailUseCase {
  final BookingRepository repository;

  GetBookingDetailUseCase(this.repository);

  Future<BookingDetailEntity> call(String bookingId) async {
    return await repository.getBookingDetail(bookingId);
  }
}
