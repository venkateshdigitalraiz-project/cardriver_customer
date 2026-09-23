import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver_customer/features/booking/domain/entities/booking_rate_config_entity.dart';
import 'package:cardriver_customer/features/booking/domain/usecases/calculate_fare_usecase.dart';
import 'package:cardriver_customer/features/booking/domain/usecases/check_booking_radius_usecase.dart';
import 'package:cardriver_customer/features/drivers/domain/entities/driver_search_type.dart';

void main() {
  group('CalculateFareUseCase Tests', () {
    final useCase = CalculateFareUseCase();
    const rates = BookingRateConfigEntity(
      dayCustomerRatePerHour: 200.0,
      nightCustomerRatePerHour: 300.0,
      dayDriverRatePerHour: 150.0,
      nightDriverRatePerHour: 220.0,
      outstationCustomerRatePerDay: 2500.0,
      outstationDriverRatePerDay: 1800.0,
    );

    test('Local Booking 10 PM + 5 hours (Crossing Day/Night) -> 2 Day hrs + 3 Night hrs', () {
      final result = useCase.calculateLocalFare(
        startHour: 22, // 10 PM
        startMinute: 0,
        durationHours: 5,
        rates: rates,
      );

      expect(result.searchType, DriverSearchType.local);
      expect(result.dayHours, 2); // 10 PM-11 PM, 11 PM-12 AM
      expect(result.nightHours, 3); // 12 AM-1 AM, 1 AM-2 AM, 2 AM-3 AM
      expect(result.isCrossedDayNight, isTrue);

      // Customer: (2 * 200) + (3 * 300) = 400 + 900 = 1300
      expect(result.customerFare, 1300.0);
      // Driver: (2 * 150) + (3 * 220) = 300 + 660 = 960
      expect(result.driverEarnings, 960.0);
    });

    test('Local Booking Pure Day (8 AM + 4 hours) -> 4 Day hrs, 0 Night hrs', () {
      final result = useCase.calculateLocalFare(
        startHour: 8,
        startMinute: 0,
        durationHours: 4,
        rates: rates,
      );

      expect(result.dayHours, 4);
      expect(result.nightHours, 0);
      expect(result.isCrossedDayNight, isFalse);
      expect(result.customerFare, 800.0);
      expect(result.driverEarnings, 600.0);
    });

    test('Outstation Booking 3 days calculation', () {
      final result = useCase.calculateOutstationFare(
        totalDays: 3,
        rates: rates,
      );

      expect(result.searchType, DriverSearchType.outstation);
      expect(result.totalDays, 3);
      expect(result.customerFare, 7500.0); // 3 * 2500
      expect(result.driverEarnings, 5400.0); // 3 * 1800
    });
  });

  group('CheckBookingRadiusUseCase Tests', () {
    final radiusUseCase = CheckBookingRadiusUseCase();

    test('Distance <= 100 KM is Local', () {
      // Pickup at Hyderabad Center (17.3850, 78.4867)
      // Driver at Sangareddy (~60 KM away, 17.6294, 78.0917)
      final result = radiusUseCase(
        pickupLat: 17.3850,
        pickupLng: 78.4867,
        currentLat: 17.6294,
        currentLng: 78.0917,
      );

      expect(result.isLocalRadius, isTrue);
      expect(result.distanceKm, lessThanOrEqualTo(100.0));
    });

    test('Distance > 100 KM is Outstation', () {
      // Pickup at Hyderabad (17.3850, 78.4867)
      // Driver at Vijayawada (~250 KM away, 16.5062, 80.6480)
      final result = radiusUseCase(
        pickupLat: 17.3850,
        pickupLng: 78.4867,
        currentLat: 16.5062,
        currentLng: 80.6480,
      );

      expect(result.isLocalRadius, isFalse);
      expect(result.distanceKm, greaterThan(100.0));
    });
  });
}
