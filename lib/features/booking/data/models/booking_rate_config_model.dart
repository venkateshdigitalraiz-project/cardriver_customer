import '../../domain/entities/booking_rate_config_entity.dart';

class BookingRateConfigModel extends BookingRateConfigEntity {
  const BookingRateConfigModel({
    super.dayCustomerRatePerHour,
    super.nightCustomerRatePerHour,
    super.dayDriverRatePerHour,
    super.nightDriverRatePerHour,
    super.outstationCustomerRatePerDay,
    super.outstationDriverRatePerDay,
    super.outstationDayDefinition,
    super.localRadiusKm,
  });

  factory BookingRateConfigModel.fromJson(Map<String, dynamic> json) {
    return BookingRateConfigModel(
      dayCustomerRatePerHour:
          (json['day_customer_rate_per_hour'] as num?)?.toDouble() ?? 200.0,
      nightCustomerRatePerHour:
          (json['night_customer_rate_per_hour'] as num?)?.toDouble() ?? 300.0,
      dayDriverRatePerHour:
          (json['day_driver_rate_per_hour'] as num?)?.toDouble() ?? 150.0,
      nightDriverRatePerHour:
          (json['night_driver_rate_per_hour'] as num?)?.toDouble() ?? 220.0,
      outstationCustomerRatePerDay:
          (json['outstation_customer_rate_per_day'] as num?)?.toDouble() ?? 2500.0,
      outstationDriverRatePerDay:
          (json['outstation_driver_rate_per_day'] as num?)?.toDouble() ?? 1800.0,
      outstationDayDefinition: OutstationDayDefinition.twentyFourHours,
      localRadiusKm: (json['local_radius_km'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_customer_rate_per_hour': dayCustomerRatePerHour,
      'night_customer_rate_per_hour': nightCustomerRatePerHour,
      'day_driver_rate_per_hour': dayDriverRatePerHour,
      'night_driver_rate_per_hour': nightDriverRatePerHour,
      'outstation_customer_rate_per_day': outstationCustomerRatePerDay,
      'outstation_driver_rate_per_day': outstationDriverRatePerDay,
      'outstation_day_definition': outstationDayDefinition.name,
      'local_radius_km': localRadiusKm,
    };
  }
}
