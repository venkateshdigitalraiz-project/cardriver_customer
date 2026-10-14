import '../entities/booking_rate_config_entity.dart';
import '../entities/booking_entity.dart';
import '../entities/booking_detail_entity.dart';
import '../entities/charges_entity.dart';

abstract class BookingRepository {
  Future<BookingRateConfigEntity> getRateConfig();
  Future<ChargesEntity> getCharges();
  Future<Map<String, dynamic>> submitBooking(Map<String, dynamic> payload);
  Future<BookingListResponseEntity> getDriverBookings({
    int page = 1,
    int limit = 5,
    String status = '',
    String startDate = '',
    String endDate = '',
    String search = '',
  });
  Future<BookingDetailEntity> getBookingDetail(String bookingId);
}

