import 'package:equatable/equatable.dart';
import '../../../../features/drivers/domain/entities/driver_search_type.dart';

/// Domain Entity representing computed fare result
class BookingFareResult extends Equatable {
  final double customerFare;
  final double driverEarnings;
  final int dayHours;
  final int nightHours;
  final int totalDays;
  final DriverSearchType searchType;
  final bool isCrossedDayNight;
  final double distanceFromPickupKm;
  final bool isLocalRadius;

  const BookingFareResult({
    required this.customerFare,
    required this.driverEarnings,
    this.dayHours = 0,
    this.nightHours = 0,
    this.totalDays = 0,
    required this.searchType,
    this.isCrossedDayNight = false,
    this.distanceFromPickupKm = 0.0,
    this.isLocalRadius = true,
  });

  @override
  List<Object?> get props => [
        customerFare,
        driverEarnings,
        dayHours,
        nightHours,
        totalDays,
        searchType,
        isCrossedDayNight,
        distanceFromPickupKm,
        isLocalRadius,
      ];
}
