import 'package:equatable/equatable.dart';

class LocationPointEntity extends Equatable {
  final String address;
  final double? latitude;
  final double? longitude;

  const LocationPointEntity({
    required this.address,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  @override
  List<Object?> get props => [address, latitude, longitude];
}

class BookingDetailEntity extends Equatable {
  final String id; // mongo _id e.g. "6ace03e49d216de59e600169"
  final String bookingId; // e.g. "BKG-859805"
  final String userId;
  final String bookingStatus; // "pending", "confirmed", "in_progress", "completed", "cancelled"
  final String bookingMode; // "scheduled", "instant"
  final String serviceType; // "local", "outstation"
  final String tripType; // "round_trip", "one_way"
  final DateTime scheduledStartTime;
  final int durationHours;
  final DateTime? returnDate;

  // Locations
  final LocationPointEntity pickupLocation;
  final LocationPointEntity dropLocation;

  // Vehicle
  final String vehicleType; // "sedan", "hatchback", "suv"
  final String transmission; // "manual", "automatic"
  final String vehicleOwnership; // "user_vehicle"
  final String? vehicleId;
  final String vehicleNumber;
  final int numberOfPassengers;

  // Trip execution
  final double estimatedDistance;
  final double actualDistance;
  final double estimatedDuration;
  final DateTime? tripStartedAt;
  final DateTime? tripCompletedAt;

  // Fare Breakdown
  final String pricingId;
  final double baseAmount;
  final double extraKmAmount;
  final double driverAllowance;
  final double driverFee;
  final double platformFee;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;

  // Payment
  final String paymentMethod;
  final String paymentStatus;
  final String paymentId;

  // Verification & Driver
  final String startOtp;
  final String? driverId;
  final String driverName;
  final String driverMobile;
  final double? driverRating;
  final String driverVehicle;

  // Status & Notes
  final bool isUserRated;
  final bool isDriverRated;
  final String? cancelledBy;
  final String cancellationReason;
  final DateTime? cancelledAt;
  final String userNotes;
  final String adminNotes;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingDetailEntity({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.bookingStatus,
    this.bookingMode = 'scheduled',
    this.serviceType = 'local',
    this.tripType = 'round_trip',
    required this.scheduledStartTime,
    this.durationHours = 1,
    this.returnDate,
    required this.pickupLocation,
    required this.dropLocation,
    this.vehicleType = 'sedan',
    this.transmission = 'manual',
    this.vehicleOwnership = 'user_vehicle',
    this.vehicleId,
    this.vehicleNumber = '',
    this.numberOfPassengers = 1,
    this.estimatedDistance = 0,
    this.actualDistance = 0,
    this.estimatedDuration = 0,
    this.tripStartedAt,
    this.tripCompletedAt,
    this.pricingId = '',
    this.baseAmount = 0,
    this.extraKmAmount = 0,
    this.driverAllowance = 0,
    this.driverFee = 0,
    this.platformFee = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.paymentMethod = 'online',
    this.paymentStatus = 'pending',
    this.paymentId = '',
    this.startOtp = '',
    this.driverId,
    this.driverName = 'Unassigned',
    this.driverMobile = 'N/A',
    this.driverRating,
    this.driverVehicle = 'DriveU Classic',
    this.isUserRated = false,
    this.isDriverRated = false,
    this.cancelledBy,
    this.cancellationReason = '',
    this.cancelledAt,
    this.userNotes = '',
    this.adminNotes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Formatted ID for UI display (prefers bookingId if present, else short mongo ID)
  String get displayBookingId => bookingId.isNotEmpty ? bookingId : (id.length > 8 ? id.substring(id.length - 8).toUpperCase() : id);

  /// Status group for tab matching
  String get statusGroup {
    final s = bookingStatus.toLowerCase().trim();
    if (s == 'completed' || s == 'finished') {
      return 'Completed';
    } else if (s == 'cancelled' || s == 'canceled' || s == 'rejected') {
      return 'Cancelled';
    } else {
      return 'Upcoming';
    }
  }

  /// Capitalized display status
  String get displayStatus {
    if (bookingStatus.isEmpty) return 'Pending';
    final cleaned = bookingStatus.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return 'Pending';
    return cleaned.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Display trip type e.g. "Round Trip", "One Way", "Outstation"
  String get displayTripType {
    if (serviceType.toLowerCase() == 'outstation') return 'Outstation Trip';
    if (tripType.toLowerCase() == 'round_trip') return 'Round Trip';
    if (tripType.toLowerCase() == 'one_way') return 'One Way';
    final cleaned = tripType.replaceAll('_', ' ').trim();
    return cleaned.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formatted vehicle specifications
  String get displayVehicle {
    final v = vehicleType.isNotEmpty
        ? vehicleType[0].toUpperCase() + vehicleType.substring(1)
        : 'Sedan';
    final t = transmission.isNotEmpty
        ? transmission[0].toUpperCase() + transmission.substring(1)
        : 'Manual';
    return '$v ($t)';
  }

  /// Check whether driver is assigned
  bool get isDriverAssigned =>
      driverName.isNotEmpty &&
      driverName.toLowerCase() != 'unassigned' &&
      driverMobile != 'N/A' &&
      driverMobile.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        bookingId,
        userId,
        bookingStatus,
        bookingMode,
        serviceType,
        tripType,
        scheduledStartTime,
        durationHours,
        returnDate,
        pickupLocation,
        dropLocation,
        vehicleType,
        transmission,
        vehicleOwnership,
        vehicleId,
        vehicleNumber,
        numberOfPassengers,
        estimatedDistance,
        actualDistance,
        estimatedDuration,
        tripStartedAt,
        tripCompletedAt,
        pricingId,
        baseAmount,
        extraKmAmount,
        driverAllowance,
        driverFee,
        platformFee,
        taxAmount,
        discountAmount,
        totalAmount,
        paymentMethod,
        paymentStatus,
        paymentId,
        startOtp,
        driverId,
        driverName,
        driverMobile,
        driverRating,
        driverVehicle,
        isUserRated,
        isDriverRated,
        cancelledBy,
        cancellationReason,
        cancelledAt,
        userNotes,
        adminNotes,
        createdAt,
        updatedAt,
      ];
}
