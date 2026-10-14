import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver_customer/features/booking/data/models/charges_model.dart';
import 'package:cardriver_customer/features/booking/domain/entities/charges_entity.dart';
import 'package:cardriver_customer/features/booking/domain/usecases/calculate_fare_usecase.dart';

void main() {
  late CalculateFareUseCase calculateFareUseCase;
  late ChargesEntity sampleCharges;

  setUp(() {
    calculateFareUseCase = CalculateFareUseCase();

    // Standard API response structure from GET /api/common/charges
    final apiJson = {
      "_id": "6ab6668b9f3e3c8ba8df7597",
      "local": {
        "one_way": {
          "morningHours": {
            "hours": 4,
            "timeRange": "06:00-18:00",
            "customerPrice": 500.0,
            "driverPrice": 400.0,
          },
          "nightHours": {
            "hours": 4,
            "timeRange": "18:00-06:00",
            "customerPrice": 650.0,
            "driverPrice": 500.0,
          },
        },
        "round_trip": {
          "morningHours": {
            "hours": 8,
            "timeRange": "06:00-18:00",
            "customerPrice": 900.0,
            "driverPrice": 750.0,
          },
          "nightHours": {
            "hours": 8,
            "timeRange": "18:00-06:00",
            "customerPrice": 1100.0,
            "driverPrice": 900.0,
          },
        },
      },
      "outstation": {
        "one_way": {
          "day": 1,
          "customerPrice": 2500.0,
          "driverPrice": 2000.0,
        },
        "round_trip": {
          "day": 1,
          "customerPrice": 4500.0,
          "driverPrice": 3800.0,
        },
      },
    };

    sampleCharges = ChargesModel.fromJson(apiJson);
  });

  group('Combination 1: Local + One Way Tests', () {
    test('Day/Night boundary crossing: 4:00 PM to 8:00 PM (Exact Prompt Example)', () {
      // 4:00 PM (16:00) to 8:00 PM (20:00) = 4 hours
      // Day hours (4:00 PM - 6:00 PM): 2h @ 500/4 = 250 customer, 400/4 = 200 driver
      // Night hours (6:00 PM - 8:00 PM): 2h @ 650/4 = 325 customer, 500/4 = 250 driver
      // Expected Total Customer Fare: 250 + 325 = 575
      // Expected Total Driver Earnings: 200 + 250 = 450
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: false,
        tripType: 'One Way',
        durationHours: 4,
        startHour: 16,
        startMinute: 0,
      );

      expect(result.customerFare, 575.0);
      expect(result.driverEarnings, 450.0);
      expect(result.dayHours, 2);
      expect(result.nightHours, 2);
      expect(result.isCrossedDayNight, isTrue);
    });

    test('Pure Day: 9:00 AM to 1:00 PM (4 hours)', () {
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: false,
        tripType: 'One Way',
        durationHours: 4,
        startHour: 9,
        startMinute: 0,
      );

      expect(result.customerFare, 500.0);
      expect(result.driverEarnings, 400.0);
      expect(result.dayHours, 4);
      expect(result.nightHours, 0);
      expect(result.isCrossedDayNight, isFalse);
    });

    test('Pure Night: 8:00 PM to 12:00 AM (4 hours)', () {
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: false,
        tripType: 'One Way',
        durationHours: 4,
        startHour: 20,
        startMinute: 0,
      );

      expect(result.customerFare, 650.0);
      expect(result.driverEarnings, 500.0);
      expect(result.dayHours, 0);
      expect(result.nightHours, 4);
      expect(result.isCrossedDayNight, isFalse);
    });

    test('Midnight crossing: 10:00 PM to 2:00 AM (4 hours)', () {
      // 10 PM (22:00) to 2 AM (02:00) = 4 hours purely in night window (18:00-06:00)
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: false,
        tripType: 'One Way',
        durationHours: 4,
        startHour: 22,
        startMinute: 0,
      );

      expect(result.customerFare, 650.0);
      expect(result.driverEarnings, 500.0);
      expect(result.dayHours, 0);
      expect(result.nightHours, 4);
    });
  });

  group('Combination 2: Local + Round Trip Tests', () {
    test('Pure Day: 8:00 AM to 4:00 PM (8 hours configured package)', () {
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: false,
        tripType: 'Round Trip',
        durationHours: 8,
        startHour: 8,
        startMinute: 0,
      );

      expect(result.customerFare, 900.0);
      expect(result.driverEarnings, 750.0);
      expect(result.dayHours, 8);
      expect(result.nightHours, 0);
      expect(result.isCrossedDayNight, isFalse);
    });

    test('Crossing Day/Night: 4:00 PM to 12:00 AM (8 hours)', () {
      // 4 PM to 6 PM: 2 hours Day @ (900 / 8) = 225 customer, (750 / 8) = 187.5 driver
      // 6 PM to 12 AM: 6 hours Night @ (1100 / 8) = 825 customer, (900 / 8) = 675 driver
      // Customer: 225 + 825 = 1050
      // Driver: 187.5 + 675 = 862.5 -> 863 rounded
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: false,
        tripType: 'Round Trip',
        durationHours: 8,
        startHour: 16,
        startMinute: 0,
      );

      expect(result.customerFare, 1050.0);
      expect(result.driverEarnings, 863.0);
      expect(result.dayHours, 2);
      expect(result.nightHours, 6);
      expect(result.isCrossedDayNight, isTrue);
    });

    test('10 Hours duration (Partial/Extra package duration)', () {
      // 8 AM to 6 PM (10 hours pure day)
      // Customer: 10 * (900 / 8) = 1125.0
      // Driver: 10 * (750 / 8) = 937.5 -> 938.0
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: false,
        tripType: 'Round Trip',
        durationHours: 10,
        startHour: 8,
        startMinute: 0,
      );

      expect(result.customerFare, 1125.0);
      expect(result.driverEarnings, 938.0);
    });
  });

  group('Combination 3: Outstation + One Way Tests', () {
    test('1 Day Outstation One Way', () {
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: true,
        tripType: 'One Way',
        durationHours: 1,
      );

      expect(result.customerFare, 2500.0);
      expect(result.driverEarnings, 2000.0);
      expect(result.totalDays, 1);
    });

    test('2 Days Outstation One Way', () {
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: true,
        tripType: 'One Way',
        durationHours: 2,
      );

      expect(result.customerFare, 5000.0);
      expect(result.driverEarnings, 4000.0);
      expect(result.totalDays, 2);
    });

    test('3 Days Outstation One Way', () {
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: true,
        tripType: 'One Way',
        durationHours: 3,
      );

      expect(result.customerFare, 7500.0);
      expect(result.driverEarnings, 6000.0);
      expect(result.totalDays, 3);
    });
  });

  group('Combination 4: Outstation + Round Trip Tests', () {
    test('1 Day Outstation Round Trip', () {
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: true,
        tripType: 'Round Trip',
        durationHours: 1,
      );

      expect(result.customerFare, 4500.0);
      expect(result.driverEarnings, 3800.0);
      expect(result.totalDays, 1);
    });

    test('2 Days Outstation Round Trip', () {
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: true,
        tripType: 'Round Trip',
        durationHours: 2,
      );

      expect(result.customerFare, 9000.0);
      expect(result.driverEarnings, 7600.0);
      expect(result.totalDays, 2);
    });

    test('3 Days Outstation Round Trip', () {
      final result = calculateFareUseCase.calculateDynamicFare(
        charges: sampleCharges,
        isOutstation: true,
        tripType: 'Round Trip',
        durationHours: 3,
      );

      expect(result.customerFare, 13500.0);
      expect(result.driverEarnings, 11400.0);
      expect(result.totalDays, 3);
    });
  });
}
