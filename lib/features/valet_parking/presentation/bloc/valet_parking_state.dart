import 'package:equatable/equatable.dart';
import '../../domain/entities/valet_booking_entity.dart';
import '../../domain/entities/valet_parking_location.dart';
import '../../domain/entities/valet_parking_ticket.dart';

enum ValetParkingStatus {
  initial,
  loading,
  loaded,
  bookingInProgress,
  bookingSuccess,
  failure,
}

class ValetParkingState extends Equatable {
  final ValetParkingStatus status;
  final List<ValetBookingEntity> bookings;
  final List<ValetBookingEntity> filteredBookings;
  final String selectedStatusFilter; // 'all', 'in_progress', 'completed', 'pending'
  final List<ValetParkingLocation> locations;
  final List<ValetParkingLocation> filteredLocations;
  final List<ValetParkingTicket> activeTickets;
  final ValetParkingLocation? selectedLocation;
  final ValetBookingEntity? selectedBooking;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const ValetParkingState({
    this.status = ValetParkingStatus.initial,
    this.bookings = const [],
    this.filteredBookings = const [],
    this.selectedStatusFilter = 'all',
    this.locations = const [],
    this.filteredLocations = const [],
    this.activeTickets = const [],
    this.selectedLocation,
    this.selectedBooking,
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  int get inProgressCount =>
      bookings.where((b) => b.status.toLowerCase() == 'in_progress').length;

  int get completedCount =>
      bookings.where((b) => b.status.toLowerCase() == 'completed').length;

  ValetParkingState copyWith({
    ValetParkingStatus? status,
    List<ValetBookingEntity>? bookings,
    List<ValetBookingEntity>? filteredBookings,
    String? selectedStatusFilter,
    List<ValetParkingLocation>? locations,
    List<ValetParkingLocation>? filteredLocations,
    List<ValetParkingTicket>? activeTickets,
    ValetParkingLocation? selectedLocation,
    bool clearSelectedLocation = false,
    ValetBookingEntity? selectedBooking,
    bool clearSelectedBooking = false,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ValetParkingState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      filteredBookings: filteredBookings ?? this.filteredBookings,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      locations: locations ?? this.locations,
      filteredLocations: filteredLocations ?? this.filteredLocations,
      activeTickets: activeTickets ?? this.activeTickets,
      selectedLocation: clearSelectedLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
      selectedBooking: clearSelectedBooking
          ? null
          : (selectedBooking ?? this.selectedBooking),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        bookings,
        filteredBookings,
        selectedStatusFilter,
        locations,
        filteredLocations,
        activeTickets,
        selectedLocation,
        selectedBooking,
        searchQuery,
        errorMessage,
        successMessage,
      ];
}
