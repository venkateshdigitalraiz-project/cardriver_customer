import '../models/booking_rate_config_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingRateConfigModel> fetchRateConfig();
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  @override
  Future<BookingRateConfigModel> fetchRateConfig() async {
    // Simulate remote network fetch delay
    await Future.delayed(const Duration(milliseconds: 300));
    return const BookingRateConfigModel();
  }
}
