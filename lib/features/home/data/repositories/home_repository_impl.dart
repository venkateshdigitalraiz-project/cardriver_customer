import '../../domain/entities/valet_event_booking_item.dart';
import '../../domain/entities/valet_event_booking_response.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ValetEventBookingResponse> addValetEventBooking(
      ValetEventBookingItem booking) async {
    return await remoteDataSource.addValetEventBooking(booking);
  }
}
