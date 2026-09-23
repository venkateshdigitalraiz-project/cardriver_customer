import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadRateConfigEvent extends BookingEvent {
  const LoadRateConfigEvent();
}

class LocalBookingSelectedEvent extends BookingEvent {
  const LocalBookingSelectedEvent();
}

class LocalHoursChangedEvent extends BookingEvent {
  final int hours;

  const LocalHoursChangedEvent({required this.hours});

  @override
  List<Object?> get props => [hours];
}

class LocalStartTimeChangedEvent extends BookingEvent {
  final int startHour;
  final int startMinute;

  const LocalStartTimeChangedEvent({
    required this.startHour,
    required this.startMinute,
  });

  @override
  List<Object?> get props => [startHour, startMinute];
}

class CalculateLocalBookingFareEvent extends BookingEvent {
  final int startHour;
  final int startMinute;
  final int durationHours;

  const CalculateLocalBookingFareEvent({
    required this.startHour,
    required this.startMinute,
    required this.durationHours,
  });

  @override
  List<Object?> get props => [startHour, startMinute, durationHours];
}

class CalculateOutstationBookingFareEvent extends BookingEvent {
  final int totalDays;

  const CalculateOutstationBookingFareEvent({required this.totalDays});

  @override
  List<Object?> get props => [totalDays];
}

class CheckRadiusEvent extends BookingEvent {
  final double pickupLat;
  final double pickupLng;
  final double currentLat;
  final double currentLng;

  const CheckRadiusEvent({
    required this.pickupLat,
    required this.pickupLng,
    required this.currentLat,
    required this.currentLng,
  });

  @override
  List<Object?> get props => [pickupLat, pickupLng, currentLat, currentLng];
}
