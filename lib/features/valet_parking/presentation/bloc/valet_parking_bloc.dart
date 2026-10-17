import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/valet_booking_entity.dart';
import '../../domain/usecases/get_valet_bookings_usecase.dart';
import '../../domain/usecases/get_valet_locations_usecase.dart';
import '../../domain/usecases/get_active_valet_tickets_usecase.dart';
import '../../domain/usecases/request_valet_booking_usecase.dart';
import '../../domain/usecases/request_vehicle_retrieval_usecase.dart';
import 'valet_parking_event.dart';
import 'valet_parking_state.dart';

class ValetParkingBloc extends Bloc<ValetParkingEvent, ValetParkingState> {
  final GetValetBookingsUseCase getValetBookingsUseCase;
  final GetValetLocationsUseCase getValetLocationsUseCase;
  final GetActiveValetTicketsUseCase getActiveValetTicketsUseCase;
  final RequestValetBookingUseCase requestValetBookingUseCase;
  final RequestVehicleRetrievalUseCase requestVehicleRetrievalUseCase;

  ValetParkingBloc({
    required this.getValetBookingsUseCase,
    required this.getValetLocationsUseCase,
    required this.getActiveValetTicketsUseCase,
    required this.requestValetBookingUseCase,
    required this.requestVehicleRetrievalUseCase,
  }) : super(const ValetParkingState()) {
    on<LoadValetParkingData>(_onLoadValetParkingData);
    on<FilterValetBookingsByStatus>(_onFilterValetBookingsByStatus);
    on<SearchValetBookings>(_onSearchValetBookings);
    on<SelectValetBooking>(_onSelectValetBooking);
    on<SearchValetLocations>(_onSearchValetLocations);
    on<SelectValetLocation>(_onSelectValetLocation);
    on<BookValetSlotSubmitted>(_onBookValetSlotSubmitted);
    on<RequestRetrievalSubmitted>(_onRequestRetrievalSubmitted);
    on<ResetValetBookingStatus>(_onResetValetBookingStatus);
  }

  Future<void> _onLoadValetParkingData(
    LoadValetParkingData event,
    Emitter<ValetParkingState> emit,
  ) async {
    emit(state.copyWith(
      status: ValetParkingStatus.loading,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final bookings = await getValetBookingsUseCase();
      final locations = await getValetLocationsUseCase(query: state.searchQuery);
      final activeTickets = await getActiveValetTicketsUseCase();

      emit(state.copyWith(
        status: ValetParkingStatus.loaded,
        bookings: bookings,
        filteredBookings: _filterBookings(bookings, state.selectedStatusFilter),
        locations: locations,
        filteredLocations: locations,
        activeTickets: activeTickets,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ValetParkingStatus.failure,
        errorMessage: 'Unable to load valet bookings: ${e.toString()}',
      ));
    }
  }

  void _onFilterValetBookingsByStatus(
    FilterValetBookingsByStatus event,
    Emitter<ValetParkingState> emit,
  ) {
    final filtered = _filterBookings(state.bookings, event.status);
    emit(state.copyWith(
      selectedStatusFilter: event.status,
      filteredBookings: filtered,
    ));
  }

  void _onSearchValetBookings(
    SearchValetBookings event,
    Emitter<ValetParkingState> emit,
  ) {
    final q = event.query.toLowerCase().trim();
    if (q.isEmpty) {
      emit(state.copyWith(
        filteredBookings: _filterBookings(state.bookings, state.selectedStatusFilter),
      ));
      return;
    }

    final filtered = state.bookings.where((b) {
      return b.eventName.toLowerCase().contains(q) ||
          b.bookingId.toLowerCase().contains(q) ||
          b.venueName.toLowerCase().contains(q) ||
          b.address.toLowerCase().contains(q) ||
          b.eventType.toLowerCase().contains(q);
    }).toList();

    emit(state.copyWith(filteredBookings: filtered));
  }

  void _onSelectValetBooking(
    SelectValetBooking event,
    Emitter<ValetParkingState> emit,
  ) {
    emit(state.copyWith(
      selectedBooking: event.booking,
      clearSelectedBooking: event.booking == null,
    ));
  }

  List<ValetBookingEntity> _filterBookings(
    List<ValetBookingEntity> list,
    String status,
  ) {
    if (status == 'all' || status.isEmpty) {
      return list;
    }
    return list
        .where((b) => b.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  Future<void> _onSearchValetLocations(
    SearchValetLocations event,
    Emitter<ValetParkingState> emit,
  ) async {
    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredLocations: state.locations,
      ));
      return;
    }

    final filtered = state.locations.where((loc) {
      return loc.name.toLowerCase().contains(query) ||
          loc.address.toLowerCase().contains(query) ||
          loc.features.any((f) => f.toLowerCase().contains(query));
    }).toList();

    emit(state.copyWith(
      searchQuery: event.query,
      filteredLocations: filtered,
    ));
  }

  void _onSelectValetLocation(
    SelectValetLocation event,
    Emitter<ValetParkingState> emit,
  ) {
    emit(state.copyWith(
      selectedLocation: event.location,
      clearSelectedLocation: event.location == null,
    ));
  }

  Future<void> _onBookValetSlotSubmitted(
    BookValetSlotSubmitted event,
    Emitter<ValetParkingState> emit,
  ) async {
    emit(state.copyWith(
      status: ValetParkingStatus.bookingInProgress,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final newTicket = await requestValetBookingUseCase(
        locationId: event.locationId,
        vehicleNumber: event.vehicleNumber,
        vehicleModel: event.vehicleModel,
        estimatedHours: event.estimatedHours,
        specialInstructions: event.specialInstructions,
      );

      final updatedTickets = [newTicket, ...state.activeTickets];

      emit(state.copyWith(
        status: ValetParkingStatus.bookingSuccess,
        activeTickets: updatedTickets,
        successMessage:
            'Valet slot booked successfully! Pass OTP: ${newTicket.valetPassOtp}',
        clearSelectedLocation: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ValetParkingStatus.failure,
        errorMessage: 'Failed to book valet slot: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRequestRetrievalSubmitted(
    RequestRetrievalSubmitted event,
    Emitter<ValetParkingState> emit,
  ) async {
    try {
      await requestVehicleRetrievalUseCase(event.ticketId);
      final updatedTickets = await getActiveValetTicketsUseCase();

      emit(state.copyWith(
        activeTickets: updatedTickets,
        successMessage:
            'Vehicle retrieval initiated. Your valet attendant is bringing your car.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ValetParkingStatus.failure,
        errorMessage: 'Could not request vehicle retrieval: ${e.toString()}',
      ));
    }
  }

  void _onResetValetBookingStatus(
    ResetValetBookingStatus event,
    Emitter<ValetParkingState> emit,
  ) {
    emit(state.copyWith(
      status: ValetParkingStatus.loaded,
      clearError: true,
      clearSuccess: true,
    ));
  }
}
