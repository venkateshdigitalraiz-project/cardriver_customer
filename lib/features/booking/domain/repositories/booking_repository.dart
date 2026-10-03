import '../entities/booking_rate_config_entity.dart';

abstract class BookingRepository {
  Future<BookingRateConfigEntity> getRateConfig();
  Future<Map<String, dynamic>> submitBooking(Map<String, dynamic> payload);
}
