import '../../domain/entities/booking_rate_config_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_detail_entity.dart';
import '../../domain/entities/charges_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BookingRateConfigEntity> getRateConfig() async {
    return await remoteDataSource.fetchRateConfig();
  }

  @override
  Future<ChargesEntity> getCharges() async {
    return await remoteDataSource.fetchCharges();
  }

  @override
  Future<Map<String, dynamic>> submitBooking(Map<String, dynamic> payload) async {
    return await remoteDataSource.submitBooking(payload);
  }

  @override
  Future<BookingListResponseEntity> getDriverBookings({
    int page = 1,
    int limit = 5,
    String status = '',
    String startDate = '',
    String endDate = '',
    String search = '',
  }) async {
    return await remoteDataSource.getDriverBookings(
      page: page,
      limit: limit,
      status: status,
      startDate: startDate,
      endDate: endDate,
      search: search,
    );
  }

  @override
  Future<BookingDetailEntity> getBookingDetail(String bookingId) async {
    return await remoteDataSource.getBookingDetail(bookingId);
  }
}

