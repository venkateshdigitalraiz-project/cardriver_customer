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

      final double customerPrice = tripCharge.customerPrice > 0
          ? tripCharge.customerPrice
          : (isRoundTrip ? 4500.0 : 2500.0);
      final double driverPrice = tripCharge.driverPrice > 0
          ? tripCharge.driverPrice
          : (isRoundTrip ? 3800.0 : 2000.0);

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

      final int morningPkgHours =
          morning.hours > 0 ? morning.hours : (isRoundTrip ? 8 : 4);
      final int nightPkgHours =
          night.hours > 0 ? night.hours : (isRoundTrip ? 8 : 4);

      final double morningCustomerPrice = morning.customerPrice > 0
          ? morning.customerPrice
          : (isRoundTrip ? 900.0 : 500.0);
      final double morningDriverPrice = morning.driverPrice > 0
          ? morning.driverPrice
          : (isRoundTrip ? 750.0 : 400.0);

      final double nightCustomerPrice = night.customerPrice > 0
          ? night.customerPrice
          : (isRoundTrip ? 1100.0 : 650.0);
      final double nightDriverPrice = night.driverPrice > 0
          ? night.driverPrice
          : (isRoundTrip ? 900.0 : 500.0);

      final double morningHourlyCustomer =
          morningCustomerPrice / morningPkgHours;
      final double morningHourlyDriver = morningDriverPrice / morningPkgHours;

      final double nightHourlyCustomer = nightCustomerPrice / nightPkgHours;
      final double nightHourlyDriver = nightDriverPrice / nightPkgHours;

      final int sHour = startHour ?? DateTime.now().hour;
      final int sMinute = startMinute ?? 0;
      final int totalMinutes =
          durationHours > 0 ? (durationHours * 60) : ((isRoundTrip ? 8 : 4) * 60);

      int dayMinutes = 0;
      int nightMinutes = 0;

      for (int m = 0; m < totalMinutes; m++) {
        final int minuteOfDay = (sHour * 60 + sMinute + m) % 1440;
        // Day hours: 6:00 AM (360 min) to 6:00 PM (1080 min)
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
          (dayHours * morningHourlyDriver) +
          (nightHours * nightHourlyDriver);

      return BookingFareResult(
        customerFare: customerFare.roundToDouble(),
        driverEarnings: driverEarnings.roundToDouble(),
        dayHours: dayHours.round(),
        nightHours: nightHours.round(),
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
