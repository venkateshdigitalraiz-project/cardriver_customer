import '../entities/booking_rate_config_entity.dart';

abstract class BookingRepository {
  Future<BookingRateConfigEntity> getRateConfig();
}
