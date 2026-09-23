import 'package:equatable/equatable.dart';

abstract class BookingFlowEvent extends Equatable {
  const BookingFlowEvent();

  @override
  List<Object?> get props => [];
}

class NextStepEvent extends BookingFlowEvent {}

class PreviousStepEvent extends BookingFlowEvent {}

class UpdateLocationVehicleEvent extends BookingFlowEvent {
  final String? pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String? dropAddress;
  final double? dropLat;
  final double? dropLng;
  final String? carType;
  final String? transmission;
  final String? vehicleCategory;

  const UpdateLocationVehicleEvent({
    this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.dropAddress,
    this.dropLat,
    this.dropLng,
    this.carType,
    this.transmission,
    this.vehicleCategory,
  });

  @override
  List<Object?> get props => [
        pickupAddress,
        pickupLat,
        pickupLng,
        dropAddress,
        dropLat,
        dropLng,
        carType,
        transmission,
        vehicleCategory,
      ];
}

class ClearLocationEvent extends BookingFlowEvent {}

class UpdateScheduleEvent extends BookingFlowEvent {
  final DateTime date;
  final int hour;
  final int minute;

  const UpdateScheduleEvent({
    required this.date,
    required this.hour,
    required this.minute,
  });

  @override
  List<Object?> get props => [date, hour, minute];
}

class UpdateDurationEvent extends BookingFlowEvent {
  final int durationHours;

  const UpdateDurationEvent(this.durationHours);

  @override
  List<Object?> get props => [durationHours];
}

class SubmitBookingEvent extends BookingFlowEvent {}

class UpdateTripTypeEvent extends BookingFlowEvent {
  final bool isOutstation;

  const UpdateTripTypeEvent(this.isOutstation);

  @override
  List<Object?> get props => [isOutstation];
}
