import 'package:equatable/equatable.dart';

/// Enum representing Outstation Day Definition config
enum OutstationDayDefinition {
  twentyFourHours,
  calendarDay,
  fixedServicePeriod,
}

/// Domain Entity for Admin-configured Rates
class BookingRateConfigEntity extends Equatable {
  final double dayCustomerRatePerHour;
  final double nightCustomerRatePerHour;
  final double dayDriverRatePerHour;
  final double nightDriverRatePerHour;
  final double outstationCustomerRatePerDay;
  final double outstationDriverRatePerDay;
  final OutstationDayDefinition outstationDayDefinition;
  final double localRadiusKm;

  const BookingRateConfigEntity({
    this.dayCustomerRatePerHour = 200.0,
    this.nightCustomerRatePerHour = 300.0,
    this.dayDriverRatePerHour = 150.0,
    this.nightDriverRatePerHour = 220.0,
    this.outstationCustomerRatePerDay = 2500.0,
    this.outstationDriverRatePerDay = 1800.0,
    this.outstationDayDefinition = OutstationDayDefinition.twentyFourHours,
    this.localRadiusKm = 100.0,
  });

  @override
  List<Object?> get props => [
        dayCustomerRatePerHour,
        nightCustomerRatePerHour,
        dayDriverRatePerHour,
        nightDriverRatePerHour,
        outstationCustomerRatePerDay,
        outstationDriverRatePerDay,
        outstationDayDefinition,
        localRadiusKm,
      ];
}
