import 'package:equatable/equatable.dart';

class BookingRequestEntity extends Equatable {
  final String? pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String? dropAddress;
  final double? dropLat;
  final double? dropLng;
  final String carType;
  final String transmission;
  final String vehicleCategory;
  final DateTime? scheduleDate;
  final int? scheduleHour; // 0-23
  final int? scheduleMinute;
  final int durationHours;
  final bool isOutstation;
  final String tripType;
  final double? estimatedFare;
  final bool includeRapidoCharges;
  final String outstationReturnMode; // 'bus' or 'train'
  final List<String> returnVehicles;

  const BookingRequestEntity({
    this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.dropAddress,
    this.dropLat,
    this.dropLng,
    this.carType = 'Honda City',
    this.transmission = 'Manual',
    this.vehicleCategory = 'Hatchback',
    this.scheduleDate,
    this.scheduleHour,
    this.scheduleMinute,
    this.durationHours = 3, // Default for local one-way package (3 hrs)
    this.isOutstation = false,
    this.tripType = 'One Way',
    this.estimatedFare,
    this.includeRapidoCharges = false,
    this.outstationReturnMode = 'bus',
    this.returnVehicles = const [],
  });

  BookingRequestEntity copyWith({
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    String? dropAddress,
    double? dropLat,
    double? dropLng,
    String? carType,
    String? transmission,
    String? vehicleCategory,
    DateTime? scheduleDate,
    int? scheduleHour,
    int? scheduleMinute,
    int? durationHours,
    bool? isOutstation,
    String? tripType,
    double? estimatedFare,
    bool? includeRapidoCharges,
    String? outstationReturnMode,
    List<String>? returnVehicles,
  }) {
    return BookingRequestEntity(
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropAddress: dropAddress ?? this.dropAddress,
      dropLat: dropLat ?? this.dropLat,
      dropLng: dropLng ?? this.dropLng,
      carType: carType ?? this.carType,
      transmission: transmission ?? this.transmission,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      scheduleHour: scheduleHour ?? this.scheduleHour,
      scheduleMinute: scheduleMinute ?? this.scheduleMinute,
      durationHours: durationHours ?? this.durationHours,
      isOutstation: isOutstation ?? this.isOutstation,
      tripType: tripType ?? this.tripType,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      includeRapidoCharges: includeRapidoCharges ?? this.includeRapidoCharges,
      outstationReturnMode: outstationReturnMode ?? this.outstationReturnMode,
      returnVehicles: returnVehicles ?? this.returnVehicles,
    );
  }

  BookingRequestEntity clearLocations() {
    return BookingRequestEntity(
      pickupAddress: null,
      pickupLat: null,
      pickupLng: null,
      dropAddress: null,
      dropLat: null,
      dropLng: null,
      carType: carType,
      scheduleDate: scheduleDate,
      scheduleHour: scheduleHour,
      scheduleMinute: scheduleMinute,
      durationHours: durationHours,
      isOutstation: isOutstation,
      tripType: tripType,
      estimatedFare: estimatedFare,
      includeRapidoCharges: includeRapidoCharges,
      outstationReturnMode: outstationReturnMode,
      returnVehicles: returnVehicles,
    );
  }

  @override
  List<Object?> get props => [
    pickupAddress,
    pickupLat,
    pickupLng,
    dropAddress,
    dropLat,
    dropLng,
    carType,
    scheduleDate,
    scheduleHour,
    scheduleMinute,
    durationHours,
    isOutstation,
    tripType,
    estimatedFare,
    includeRapidoCharges,
    outstationReturnMode,
    returnVehicles,
  ];
}
