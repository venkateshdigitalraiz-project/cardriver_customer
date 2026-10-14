import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_driver_bookings_usecase.dart';
import 'my_bookings_event.dart';
import 'my_bookings_state.dart';

class MyBookingsBloc extends Bloc<MyBookingsEvent, MyBookingsState> {
  final GetDriverBookingsUseCase getDriverBookingsUseCase;

  MyBookingsBloc({required this.getDriverBookingsUseCase}) : super(MyBookingsInitial()) {
    on<LoadMyBookings>(_onLoadMyBookings);
    on<RefreshMyBookings>(_onRefreshMyBookings);
    on<LoadMoreMyBookings>(_onLoadMoreMyBookings);
  }

  Future<void> _onLoadMyBookings(
    LoadMyBookings event,
    Emitter<MyBookingsState> emit,
  ) async {
    emit(MyBookingsLoading());

    try {
      final result = await getDriverBookingsUseCase(
        params: GetDriverBookingsParams(
          page: event.page,
          limit: event.limit,
          status: event.status,
          startDate: event.startDate,
          endDate: event.endDate,
          search: event.search,
        ),
      );

      final hasReachedMax = result.pagination.page >= result.pagination.totalPages;

      emit(MyBookingsLoaded(
        result.bookings,
        pagination: result.pagination,
        hasReachedMax: hasReachedMax,
        currentStatus: event.status,
      ));
    } catch (e) {
      emit(MyBookingsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefreshMyBookings(
    RefreshMyBookings event,
    Emitter<MyBookingsState> emit,
  ) async {
    try {
      final result = await getDriverBookingsUseCase(
        params: GetDriverBookingsParams(
          page: 1,
          limit: event.limit,
          status: event.status,
          startDate: event.startDate,
          endDate: event.endDate,
          search: event.search,
        ),
      );

      final hasReachedMax = result.pagination.page >= result.pagination.totalPages;

      emit(MyBookingsLoaded(
        result.bookings,
        pagination: result.pagination,
        hasReachedMax: hasReachedMax,
        currentStatus: event.status,
      ));
    } catch (e) {
      emit(MyBookingsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMoreMyBookings(
    LoadMoreMyBookings event,
    Emitter<MyBookingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MyBookingsLoaded) return;
    if (currentState.isLoadingMore || currentState.hasReachedMax) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.pagination.page + 1;
      final result = await getDriverBookingsUseCase(
        params: GetDriverBookingsParams(
          page: nextPage,
          limit: currentState.pagination.limit,
          status: currentState.currentStatus,
        ),
      );

      final updatedBookings = List.of(currentState.bookings)..addAll(result.bookings);
      final hasReachedMax = result.pagination.page >= result.pagination.totalPages;

      emit(currentState.copyWith(
        bookings: updatedBookings,
        pagination: result.pagination,
        isLoadingMore: false,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}

