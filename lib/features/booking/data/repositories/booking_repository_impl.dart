import '../../domain/entities/booking_rate_config_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BookingRateConfigEntity> getRateConfig() async {
    return await remoteDataSource.fetchRateConfig();
  }
}
