import 'package:equatable/equatable.dart';
import '../../domain/entities/valet_booking_entity.dart';
import '../../domain/entities/valet_parking_location.dart';

abstract class ValetParkingEvent extends Equatable {
  const ValetParkingEvent();

  @override
  List<Object?> get props => [];
}

class LoadValetParkingData extends ValetParkingEvent {
  final bool refresh;
  const LoadValetParkingData({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class FilterValetBookingsByStatus extends ValetParkingEvent {
  final String status;
  const FilterValetBookingsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchValetBookings extends ValetParkingEvent {
  final String query;
  const SearchValetBookings(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectValetBooking extends ValetParkingEvent {
  final ValetBookingEntity? booking;
  const SelectValetBooking(this.booking);

  @override
  List<Object?> get props => [booking];
}

class SearchValetLocations extends ValetParkingEvent {
  final String query;

  const SearchValetLocations(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectValetLocation extends ValetParkingEvent {
  final ValetParkingLocation? location;

  const SelectValetLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class BookValetSlotSubmitted extends ValetParkingEvent {
  final String locationId;
  final String vehicleNumber;
  final String vehicleModel;
  final int estimatedHours;
  final String? specialInstructions;

  const BookValetSlotSubmitted({
    required this.locationId,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.estimatedHours,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
        locationId,
        vehicleNumber,
        vehicleModel,
        estimatedHours,
        specialInstructions,
      ];
}

class RequestRetrievalSubmitted extends ValetParkingEvent {
  final String ticketId;

  const RequestRetrievalSubmitted(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class ResetValetBookingStatus extends ValetParkingEvent {
  const ResetValetBookingStatus();
}
