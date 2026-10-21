import '../entities/booking_fare_result.dart';
import '../entities/booking_rate_config_entity.dart';
import '../entities/charges_entity.dart';
import '../../../../features/drivers/domain/entities/driver_search_type.dart';

import 'fare_calculator.dart';

class CalculateFareUseCase {
  /// Pure fare calculation returning customer fare
  double calculateFare({
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
    return FareCalculator.calculateFare(
      charges: charges,
      isOutstation: isOutstation,
      tripType: tripType,
      pickupDate: pickupDate,
      pickupHour: pickupHour,
      pickupMinute: pickupMinute,
      pickupDateTime: pickupDateTime,
      usageHours: usageHours,
      days: days,
    );
  }

  BookingFareResult calculateDynamicFare({
    required ChargesEntity? charges,
    required bool isOutstation,
    required String tripType,
    required int durationHours,
    DateTime? startDate,
    int? startHour,
    int? startMinute,
  }) {
    return FareCalculator.calculateBookingFareResult(
      charges: charges,
      isOutstation: isOutstation,
      tripType: tripType,
      usageHours: durationHours,
      pickupDate: startDate,
      pickupHour: startHour,
      pickupMinute: startMinute,
    );
  }
  BookingFareResult calculateLocalFare({
    required int startHour,
    required int startMinute,
    required int durationHours,
    required BookingRateConfigEntity rates,
  }) {
    double customerFare = 0.0;
    double driverEarnings = 0.0;
    int dayHours = 0;
    int nightHours = 0;

    for (int i = 0; i < durationHours; i++) {
      int sliceStartMinute = (startHour * 60 + startMinute + i * 60) % (24 * 60);

      // Day definition: 4:00 AM (240 minutes) to 12:00 AM Midnight (1440 minutes)
      // Night definition: 12:00 AM (0 minutes) to 4:00 AM (240 minutes)
      bool isDayHour = sliceStartMinute >= 240;

      if (isDayHour) {
        dayHours++;
        customerFare += rates.dayCustomerRatePerHour;
        driverEarnings += rates.dayDriverRatePerHour;
      } else {
        nightHours++;
        customerFare += rates.nightCustomerRatePerHour;
        driverEarnings += rates.nightDriverRatePerHour;
      }
    }

    bool isCrossedDayNight = dayHours > 0 && nightHours > 0;

    return BookingFareResult(
      customerFare: customerFare,
      driverEarnings: driverEarnings,
      dayHours: dayHours,
      nightHours: nightHours,
      totalDays: 0,
      searchType: DriverSearchType.local,
      isCrossedDayNight: isCrossedDayNight,
      isLocalRadius: true,
    );
  }

  BookingFareResult calculateOutstationFare({
    required int totalDays,
    DateTime? startDateTime,
    DateTime? endDateTime,
    required BookingRateConfigEntity rates,
  }) {
    int calculatedDays = totalDays;
    if (startDateTime != null && endDateTime != null) {
      final duration = endDateTime.difference(startDateTime);
      switch (rates.outstationDayDefinition) {
        case OutstationDayDefinition.calendarDay:
          final startDay = DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
          final endDay = DateTime(endDateTime.year, endDateTime.month, endDateTime.day);
          calculatedDays = endDay.difference(startDay).inDays + 1;
          break;
        case OutstationDayDefinition.twentyFourHours:
          calculatedDays = (duration.inMinutes / (24 * 60)).ceil();
          break;
        case OutstationDayDefinition.fixedServicePeriod:
          calculatedDays = (duration.inMinutes / (12 * 60)).ceil();
          break;
      }
    }

    final effectiveDays = calculatedDays > 0 ? calculatedDays : 1;
    final customerFare = effectiveDays * rates.outstationCustomerRatePerDay;
    final driverEarnings = effectiveDays * rates.outstationDriverRatePerDay;

    return BookingFareResult(
      customerFare: customerFare,
      driverEarnings: driverEarnings,
      dayHours: 0,
      nightHours: 0,
      totalDays: effectiveDays,
      searchType: DriverSearchType.outstation,
      isCrossedDayNight: false,
      isLocalRadius: false,
    );
  }
}
