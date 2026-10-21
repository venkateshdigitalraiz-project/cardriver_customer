import '../entities/booking_fare_result.dart';
import '../entities/charges_entity.dart';
import '../../../../features/drivers/domain/entities/driver_search_type.dart';

/// Pure Dart fare calculation engine for customer bookings.
/// Has zero Flutter or BLoC dependencies.
class FareCalculator {
  /// Calculates the customer fare based on trip type, slots, and API charges.
  static double calculateFare({
    required ChargesEntity? charges,
    required bool isOutstation,
    required String tripType,
    DateTime? pickupDate,
    int? pickupHour,
    int? pickupMinute,
    DateTime? pickupDateTime,
    int? usageHours,
    int? days,
  }) {
    if (charges == null) return 0.0;

    final isRound = tripType.toLowerCase().contains('round');

    // 1. OUTSTATION FARE CALCULATION
    if (isOutstation) {
      final tripCharge = isRound
          ? charges.outstation.roundTrip
          : charges.outstation.oneWay;
      final pricePerDay = tripCharge.customerPrice;

      // Minimum 1 day
      int numDays = days ?? (usageHours != null && usageHours > 0
          ? (usageHours >= 24 && usageHours % 24 == 0
              ? usageHours ~/ 24
              : usageHours)
          : 1);
      if (numDays < 1) numDays = 1;

      return pricePerDay * numDays;
    }

    // 2. LOCAL FARE CALCULATION
    final tripCharge =
        isRound ? charges.local.roundTrip : charges.local.oneWay;
    final morning = tripCharge.morningHours;
    final night = tripCharge.nightHours;

    final double morningRate = (morning.hours > 0)
        ? (morning.customerPrice / morning.hours)
        : 0.0;
    final double nightRate =
        (night.hours > 0) ? (night.customerPrice / night.hours) : 0.0;

    final int duration = (usageHours != null && usageHours > 0)
        ? usageHours
        : (isRound ? 8 : 4);
    final int totalMinutes = duration * 60;

    // Resolve trip start DateTime
    final now = DateTime.now();
    final DateTime start;
    if (pickupDateTime != null) {
      start = pickupDateTime;
    } else {
      final date = pickupDate ?? now;
      final hour = pickupHour ?? date.hour;
      final minute = pickupMinute ?? date.minute;
      start = DateTime(date.year, date.month, date.day, hour, minute);
    }

    int morningMinutes = 0;
    int nightMinutes = 0;

    for (int i = 0; i < totalMinutes; i++) {
      final current = start.add(Duration(minutes: i));
      // Morning slot: 06:00 to 18:00 (hours 6 through 17 inclusive)
      // Night slot: 18:00 to 06:00
      if (current.hour >= 6 && current.hour < 18) {
        morningMinutes++;
      } else {
        nightMinutes++;
      }
    }

    // Round each slot's minutes UP to the next full hour
    final int billedMorningHours = (morningMinutes / 60.0).ceil();
    final int billedNightHours = (nightMinutes / 60.0).ceil();

    // Fare = morningHours x morningRate + nightHours x nightRate
    return (billedMorningHours * morningRate) + (billedNightHours * nightRate);
  }

  /// Calculates full booking fare details including customer fare and driver earnings.
  static BookingFareResult calculateBookingFareResult({
    required ChargesEntity? charges,
    required bool isOutstation,
    required String tripType,
    DateTime? pickupDate,
    int? pickupHour,
    int? pickupMinute,
    DateTime? pickupDateTime,
    int? usageHours,
    int? days,
  }) {
    if (charges == null) {
      return const BookingFareResult(
        customerFare: 0.0,
        driverEarnings: 0.0,
        dayHours: 0,
        nightHours: 0,
        totalDays: 0,
        searchType: DriverSearchType.local,
      );
    }

    final isRound = tripType.toLowerCase().contains('round');

    if (isOutstation) {
      final tripCharge = isRound
          ? charges.outstation.roundTrip
          : charges.outstation.oneWay;
      int numDays = days ?? (usageHours != null && usageHours > 0
          ? (usageHours >= 24 && usageHours % 24 == 0
              ? usageHours ~/ 24
              : usageHours)
          : 1);
      if (numDays < 1) numDays = 1;

      final customerFare = tripCharge.customerPrice * numDays;
      final driverEarnings = tripCharge.driverPrice * numDays;

      return BookingFareResult(
        customerFare: customerFare.roundToDouble(),
        driverEarnings: driverEarnings.roundToDouble(),
        totalDays: numDays,
        searchType: DriverSearchType.outstation,
        isCrossedDayNight: false,
        isLocalRadius: false,
      );
    } else {
      final tripCharge =
          isRound ? charges.local.roundTrip : charges.local.oneWay;
      final morning = tripCharge.morningHours;
      final night = tripCharge.nightHours;

      final double morningCustomerRate = (morning.hours > 0)
          ? (morning.customerPrice / morning.hours)
          : 0.0;
      final double morningDriverRate = (morning.hours > 0)
          ? (morning.driverPrice / morning.hours)
          : 0.0;

      final double nightCustomerRate = (night.hours > 0)
          ? (night.customerPrice / night.hours)
          : 0.0;
      final double nightDriverRate =
          (night.hours > 0) ? (night.driverPrice / night.hours) : 0.0;

      final int duration = (usageHours != null && usageHours > 0)
          ? usageHours
          : (isRound ? 8 : 4);
      final int totalMinutes = duration * 60;

      final now = DateTime.now();
      final DateTime start;
      if (pickupDateTime != null) {
        start = pickupDateTime;
      } else {
        final date = pickupDate ?? now;
        final hour = pickupHour ?? date.hour;
        final minute = pickupMinute ?? date.minute;
        start = DateTime(date.year, date.month, date.day, hour, minute);
      }

      int morningMinutes = 0;
      int nightMinutes = 0;

      for (int i = 0; i < totalMinutes; i++) {
        final current = start.add(Duration(minutes: i));
        if (current.hour >= 6 && current.hour < 18) {
          morningMinutes++;
        } else {
          nightMinutes++;
        }
      }

      final int billedMorningHours = (morningMinutes / 60.0).ceil();
      final int billedNightHours = (nightMinutes / 60.0).ceil();

      final double customerFare = (billedMorningHours * morningCustomerRate) +
          (billedNightHours * nightCustomerRate);
      final double driverEarnings = (billedMorningHours * morningDriverRate) +
          (billedNightHours * nightDriverRate);

      return BookingFareResult(
        customerFare: customerFare.roundToDouble(),
        driverEarnings: driverEarnings.roundToDouble(),
        dayHours: billedMorningHours,
        nightHours: billedNightHours,
        dayMinutes: morningMinutes,
        nightMinutes: nightMinutes,
        totalDays: 0,
        searchType: DriverSearchType.local,
        isCrossedDayNight: morningMinutes > 0 && nightMinutes > 0,
        isLocalRadius: true,
      );
    }
  }
}
