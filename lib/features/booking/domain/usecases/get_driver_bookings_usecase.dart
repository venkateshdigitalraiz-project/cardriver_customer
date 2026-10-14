import 'package:equatable/equatable.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetDriverBookingsParams extends Equatable {
  final int page;
  final int limit;
  final String status;
  final String startDate;
  final String endDate;
  final String search;

  const GetDriverBookingsParams({
    this.page = 1,
    this.limit = 5,
    this.status = '',
    this.startDate = '',
    this.endDate = '',
    this.search = '',
  });

  @override
  List<Object?> get props => [page, limit, status, startDate, endDate, search];
}

class GetDriverBookingsUseCase {
  final BookingRepository repository;

  GetDriverBookingsUseCase(this.repository);

  Future<BookingListResponseEntity> call({
    GetDriverBookingsParams params = const GetDriverBookingsParams(),
  }) async {
    return await repository.getDriverBookings(
      page: params.page,
      limit: params.limit,
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
      search: params.search,
    );
  }
}
