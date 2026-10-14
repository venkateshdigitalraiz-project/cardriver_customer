import 'package:cardriver_customer/core/error/failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_booking_detail_usecase.dart';
import 'booking_detail_event.dart';
import 'booking_detail_state.dart';

class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  final GetBookingDetailUseCase getBookingDetailUseCase;

  BookingDetailBloc({required this.getBookingDetailUseCase})
    : super(BookingDetailInitial()) {
    on<FetchBookingDetail>(_onFetchBookingDetail);
    on<RefreshBookingDetail>(_onRefreshBookingDetail);
  }

  Future<void> _onFetchBookingDetail(
    FetchBookingDetail event,
    Emitter<BookingDetailState> emit,
  ) async {
    emit(BookingDetailLoading());
    try {
      final booking = await getBookingDetailUseCase(event.bookingId);
      emit(BookingDetailLoaded(booking));
    } on Failure catch (e) {
      emit(BookingDetailError(e.message));
    } catch (e) {
      emit(BookingDetailError(e.toString()));
    }
  }

  Future<void> _onRefreshBookingDetail(
    RefreshBookingDetail event,
    Emitter<BookingDetailState> emit,
  ) async {
    try {
      final booking = await getBookingDetailUseCase(event.bookingId);
      emit(BookingDetailLoaded(booking));
    } on Failure catch (e) {
      emit(BookingDetailError(e.message));
    } catch (e) {
      emit(BookingDetailError(e.toString()));
    }
  }
}
