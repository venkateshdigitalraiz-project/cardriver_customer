import 'package:equatable/equatable.dart';
import 'booking_fare_result.dart';
import '../../../../features/drivers/domain/entities/driver_search_type.dart';

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
    int? startHour,
    int? startMinute,
  }) {
    final isRoundTrip = tripType.toLowerCase().contains('round');

    if (isOutstation) {
      final tripCharge = isRoundTrip ? outstation.roundTrip : outstation.oneWay;
      final int packageDay = tripCharge.day > 0 ? tripCharge.day : 1;
      final int days = durationHours > 0 ? durationHours : 1;

      final double customerPrice = tripCharge.customerPrice;
      final double driverPrice = tripCharge.driverPrice;

      final double customerFare = days * (customerPrice / packageDay);
      final double driverEarnings = days * (driverPrice / packageDay);

      return BookingFareResult(
        customerFare: customerFare.roundToDouble(),
        driverEarnings: driverEarnings.roundToDouble(),
        totalDays: days,
        searchType: DriverSearchType.outstation,
        isCrossedDayNight: false,
        isLocalRadius: false,
      );
    } else {
      final tripCharge = isRoundTrip ? local.roundTrip : local.oneWay;
      final morning = tripCharge.morningHours;
      final night = tripCharge.nightHours;

      final int morningPkgHours = morning.hours > 0
          ? morning.hours
          : (isRoundTrip ? 8 : 4);
      final int nightPkgHours = night.hours > 0
          ? night.hours
          : (isRoundTrip ? 8 : 4);

      final double morningCustomerPrice = morning.customerPrice;
      final double morningDriverPrice = morning.driverPrice;

      final double nightCustomerPrice = night.customerPrice;
      final double nightDriverPrice = night.driverPrice;

      final double morningHourlyCustomer =
          morningPkgHours > 0 ? (morningCustomerPrice / morningPkgHours) : 0.0;
      final double morningHourlyDriver =
          morningPkgHours > 0 ? (morningDriverPrice / morningPkgHours) : 0.0;

      final double nightHourlyCustomer =
          nightPkgHours > 0 ? (nightCustomerPrice / nightPkgHours) : 0.0;
      final double nightHourlyDriver =
          nightPkgHours > 0 ? (nightDriverPrice / nightPkgHours) : 0.0;

      final now = DateTime.now();
      final int sHour = startHour ?? now.hour;
      final int sMinute = startMinute ?? now.minute;
      final int totalMinutes = durationHours > 0
          ? (durationHours * 60)
          : ((isRoundTrip ? 8 : 4) * 60);

      int dayMinutes = 0;
      int nightMinutes = 0;

      for (int m = 0; m < totalMinutes; m++) {
        final int minuteOfDay = (sHour * 60 + sMinute + m) % 1440;
        // Day hours: 06:00 (360 min) to 18:00 (1080 min)
        // Night hours: 18:00 (1080 min) to 06:00 (360 min)
        if (minuteOfDay >= 360 && minuteOfDay < 1080) {
          dayMinutes++;
        } else {
          nightMinutes++;
        }
      }

      final double dayHours = dayMinutes / 60.0;
      final double nightHours = nightMinutes / 60.0;

      final double customerFare =
          (dayHours * morningHourlyCustomer) +
          (nightHours * nightHourlyCustomer);
      final double driverEarnings =
          (dayHours * morningHourlyDriver) + (nightHours * nightHourlyDriver);

      return BookingFareResult(
        customerFare: customerFare.roundToDouble(),
        driverEarnings: driverEarnings.roundToDouble(),
        dayHours: dayMinutes ~/ 60,
        nightHours: nightMinutes ~/ 60,
        dayMinutes: dayMinutes,
        nightMinutes: nightMinutes,
        totalDays: 0,
        searchType: DriverSearchType.local,
        isCrossedDayNight: dayMinutes > 0 && nightMinutes > 0,
        isLocalRadius: true,
      );
    }
  }

  double calculateFare({
    required bool isOutstation,
    required String tripType,
    required int durationHours,
    int? startHour,
    int? startMinute,
  }) {
    return calculateFareResult(
      isOutstation: isOutstation,
      tripType: tripType,
      durationHours: durationHours,
      startHour: startHour,
      startMinute: startMinute,
    ).customerFare;
  }

  @override
  List<Object?> get props => [id, local, outstation];
}

class LocalChargesEntity extends Equatable {
  final LocalTripChargesEntity oneWay;
  final LocalTripChargesEntity roundTrip;

  const LocalChargesEntity({
    this.oneWay = const LocalTripChargesEntity(),
    this.roundTrip = const LocalTripChargesEntity(),
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
    this.oneWay = const OutstationTripChargeEntity(),
    this.roundTrip = const OutstationTripChargeEntity(),
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
