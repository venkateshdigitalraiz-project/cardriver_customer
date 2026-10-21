import 'package:equatable/equatable.dart';
import 'booking_fare_result.dart';
import '../usecases/fare_calculator.dart';

class ChargesEntity extends Equatable {
  final String id;
  final LocalChargesEntity local;
  final OutstationChargesEntity outstation;

  const ChargesEntity({
    this.id = '',
    this.local = const LocalChargesEntity(),
    this.outstation = const OutstationChargesEntity(),
  });

  BookingFareResult calculateFareResult({
    required bool isOutstation,
    required String tripType,
    required int durationHours,
    DateTime? startDate,
    int? startHour,
    int? startMinute,
  }) {
    return FareCalculator.calculateBookingFareResult(
      charges: this,
      isOutstation: isOutstation,
      tripType: tripType,
      usageHours: durationHours,
      pickupDate: startDate,
      pickupHour: startHour,
      pickupMinute: startMinute,
    );
  }

  double calculateFare({
    required bool isOutstation,
    required String tripType,
    required int durationHours,
    DateTime? startDate,
    int? startHour,
    int? startMinute,
  }) {
    return FareCalculator.calculateFare(
      charges: this,
      isOutstation: isOutstation,
      tripType: tripType,
      usageHours: durationHours,
      pickupDate: startDate,
      pickupHour: startHour,
      pickupMinute: startMinute,
    );
  }

  @override
  List<Object?> get props => [id, local, outstation];
}

class LocalChargesEntity extends Equatable {
  final LocalTripChargesEntity oneWay;
  final LocalTripChargesEntity roundTrip;

  const LocalChargesEntity({
    this.oneWay = const LocalTripChargesEntity(
      morningHours: TimeSlotChargeEntity(
        hours: 4,
        timeRange: '06:00-18:00',
        customerPrice: 500.0,
        driverPrice: 400.0,
      ),
      nightHours: TimeSlotChargeEntity(
        hours: 4,
        timeRange: '18:00-06:00',
        customerPrice: 650.0,
        driverPrice: 500.0,
      ),
    ),
    this.roundTrip = const LocalTripChargesEntity(
      morningHours: TimeSlotChargeEntity(
        hours: 8,
        timeRange: '06:00-18:00',
        customerPrice: 900.0,
        driverPrice: 750.0,
      ),
      nightHours: TimeSlotChargeEntity(
        hours: 8,
        timeRange: '18:00-06:00',
        customerPrice: 1100.0,
        driverPrice: 900.0,
      ),
    ),
  });

  @override
  List<Object?> get props => [oneWay, roundTrip];
}

class LocalTripChargesEntity extends Equatable {
  final TimeSlotChargeEntity morningHours;
  final TimeSlotChargeEntity nightHours;

  const LocalTripChargesEntity({
    this.morningHours = const TimeSlotChargeEntity(),
    this.nightHours = const TimeSlotChargeEntity(),
  });

  @override
  List<Object?> get props => [morningHours, nightHours];
}

class TimeSlotChargeEntity extends Equatable {
  final int hours;
  final String timeRange;
  final double customerPrice;
  final double driverPrice;

  const TimeSlotChargeEntity({
    this.hours = 4,
    this.timeRange = '',
    this.customerPrice = 0.0,
    this.driverPrice = 0.0,
  });

  @override
  List<Object?> get props => [hours, timeRange, customerPrice, driverPrice];
}

class OutstationChargesEntity extends Equatable {
  final OutstationTripChargeEntity oneWay;
  final OutstationTripChargeEntity roundTrip;

  const OutstationChargesEntity({
    this.oneWay = const OutstationTripChargeEntity(
      day: 1,
      customerPrice: 2500.0,
      driverPrice: 2000.0,
    ),
    this.roundTrip = const OutstationTripChargeEntity(
      day: 1,
      customerPrice: 4500.0,
      driverPrice: 3800.0,
    ),
  });

  @override
  List<Object?> get props => [oneWay, roundTrip];
}

class OutstationTripChargeEntity extends Equatable {
  final int day;
  final double customerPrice;
  final double driverPrice;

  const OutstationTripChargeEntity({
    this.day = 1,
    this.customerPrice = 0.0,
    this.driverPrice = 0.0,
  });

  @override
  List<Object?> get props => [day, customerPrice, driverPrice];
}
