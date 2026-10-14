import '../../domain/entities/booking_detail_entity.dart';

class BookingDetailModel extends BookingDetailEntity {
  const BookingDetailModel({
    required super.id,
    required super.bookingId,
    required super.userId,
    required super.bookingStatus,
    super.bookingMode = 'scheduled',
    super.serviceType = 'local',
    super.tripType = 'round_trip',
    required super.scheduledStartTime,
    super.durationHours = 1,
    super.returnDate,
    required super.pickupLocation,
    required super.dropLocation,
    super.vehicleType = 'sedan',
    super.transmission = 'manual',
    super.vehicleOwnership = 'user_vehicle',
    super.vehicleId,
    super.vehicleNumber = '',
    super.numberOfPassengers = 1,
    super.estimatedDistance = 0,
    super.actualDistance = 0,
    super.estimatedDuration = 0,
    super.tripStartedAt,
    super.tripCompletedAt,
    super.pricingId = '',
    super.baseAmount = 0,
    super.extraKmAmount = 0,
    super.driverAllowance = 0,
    super.driverFee = 0,
    super.platformFee = 0,
    super.taxAmount = 0,
    super.discountAmount = 0,
    super.totalAmount = 0,
    super.paymentMethod = 'online',
    super.paymentStatus = 'pending',
    super.paymentId = '',
    super.startOtp = '',
    super.driverId,
    super.driverName = 'Unassigned',
    super.driverMobile = 'N/A',
    super.driverRating,
    super.driverVehicle = 'DriveU Classic',
    super.isUserRated = false,
    super.isDriverRated = false,
    super.cancelledBy,
    super.cancellationReason = '',
    super.cancelledAt,
    super.userNotes = '',
    super.adminNotes = '',
    required super.createdAt,
    required super.updatedAt,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    // Unnest if wrapped in "data" -> "booking"
    Map<String, dynamic> bMap = json;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap.containsKey('booking') && dataMap['booking'] is Map<String, dynamic>) {
        bMap = dataMap['booking'] as Map<String, dynamic>;
      } else {
        bMap = dataMap;
      }
    } else if (json.containsKey('booking') && json['booking'] is Map<String, dynamic>) {
      bMap = json['booking'] as Map<String, dynamic>;
    }

    // IDs
    final id = bMap['_id']?.toString() ?? '';
    final bookingId = bMap['bookingId']?.toString() ?? '';
    final userId = bMap['userId']?.toString() ?? '';

    // Status & Modes
    final bookingStatus = bMap['bookingStatus']?.toString() ?? 'pending';
    final bookingMode = bMap['bookingMode']?.toString() ?? 'scheduled';
    final serviceType = bMap['serviceType']?.toString() ?? 'local';
    final tripType = bMap['tripType']?.toString() ?? 'round_trip';

    // Dates
    DateTime scheduledStartTime = DateTime.now();
    if (bMap['scheduledStartTime'] != null) {
      final parsed = DateTime.tryParse(bMap['scheduledStartTime'].toString());
      if (parsed != null) scheduledStartTime = parsed;
    }

    DateTime? returnDate;
    if (bMap['returnDate'] != null) {
      returnDate = DateTime.tryParse(bMap['returnDate'].toString());
    }

    DateTime createdAt = DateTime.now();
    if (bMap['createdAt'] != null) {
      final parsed = DateTime.tryParse(bMap['createdAt'].toString());
      if (parsed != null) createdAt = parsed;
    }

    DateTime updatedAt = DateTime.now();
    if (bMap['updatedAt'] != null) {
      final parsed = DateTime.tryParse(bMap['updatedAt'].toString());
      if (parsed != null) updatedAt = parsed;
    }

    DateTime? tripStartedAt;
    if (bMap['tripStartedAt'] != null) {
      tripStartedAt = DateTime.tryParse(bMap['tripStartedAt'].toString());
    }

    DateTime? tripCompletedAt;
    if (bMap['tripCompletedAt'] != null) {
      tripCompletedAt = DateTime.tryParse(bMap['tripCompletedAt'].toString());
    }

    DateTime? cancelledAt;
    if (bMap['cancelledAt'] != null) {
      cancelledAt = DateTime.tryParse(bMap['cancelledAt'].toString());
    }

    // Duration
    int durationHours = 1;
    if (bMap['durationHours'] is num) {
      durationHours = (bMap['durationHours'] as num).toInt();
    }

    // Pickup Location
    String pickupAddr = 'Pickup location';
    double? pickupLat;
    double? pickupLng;
    if (bMap['pickupLocation'] is Map<String, dynamic>) {
      final pMap = bMap['pickupLocation'] as Map<String, dynamic>;
      pickupAddr = pMap['address']?.toString() ?? pickupAddr;
      if (pMap['location'] is Map<String, dynamic>) {
        final loc = pMap['location'] as Map<String, dynamic>;
        if (loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
          final coords = loc['coordinates'] as List;
          pickupLng = (coords[0] as num?)?.toDouble();
          pickupLat = (coords[1] as num?)?.toDouble();
        }
      }
    }
    final pickupLocation = LocationPointEntity(
      address: pickupAddr,
      latitude: pickupLat,
      longitude: pickupLng,
    );

    // Drop Location
    String dropAddr = 'Drop location';
    double? dropLat;
    double? dropLng;
    if (bMap['dropLocation'] is Map<String, dynamic>) {
      final dMap = bMap['dropLocation'] as Map<String, dynamic>;
      dropAddr = dMap['address']?.toString() ?? dropAddr;
      if (dMap['location'] is Map<String, dynamic>) {
        final loc = dMap['location'] as Map<String, dynamic>;
        if (loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
          final coords = loc['coordinates'] as List;
          dropLng = (coords[0] as num?)?.toDouble();
          dropLat = (coords[1] as num?)?.toDouble();
        }
      }
    }
    final dropLocation = LocationPointEntity(
      address: dropAddr,
      latitude: dropLat,
      longitude: dropLng,
    );

    // Vehicle
    final vehicleType = bMap['vehicleType']?.toString() ?? 'sedan';
    final transmission = bMap['transmission']?.toString() ?? 'manual';
    final vehicleOwnership = bMap['vehicleOwnership']?.toString() ?? 'user_vehicle';
    final vehicleId = bMap['vehicleId']?.toString();
    final vehicleNumber = bMap['vehicleNumber']?.toString() ?? '';
    int numberOfPassengers = 1;
    if (bMap['numberOfPassengers'] is num) {
      numberOfPassengers = (bMap['numberOfPassengers'] as num).toInt();
    }

    // Numbers
    double numToDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final estimatedDistance = numToDouble(bMap['estimatedDistance']);
    final actualDistance = numToDouble(bMap['actualDistance']);
    final estimatedDuration = numToDouble(bMap['estimatedDuration']);

    // Pricing breakdown
    final pricingId = bMap['pricingId']?.toString() ?? '';
    final baseAmount = numToDouble(bMap['baseAmount']);
    final extraKmAmount = numToDouble(bMap['extraKmAmount']);
    final driverAllowance = numToDouble(bMap['driverAllowance']);
    final driverFee = numToDouble(bMap['driverFee']);
    final platformFee = numToDouble(bMap['platformFee']);
    final taxAmount = numToDouble(bMap['taxAmount']);
    final discountAmount = numToDouble(bMap['discountAmount']);
    final totalAmount = numToDouble(bMap['totalAmount']);

    // Payment
    final paymentMethod = bMap['paymentMethod']?.toString() ?? 'online';
    final paymentStatus = bMap['paymentStatus']?.toString() ?? 'pending';
    final paymentId = bMap['paymentId']?.toString() ?? '';

    // OTP
    final startOtp = bMap['startOtp']?.toString() ?? '';

    // Driver
    String? driverId;
    String driverName = 'Unassigned';
    String driverMobile = 'N/A';
    double? driverRating;
    String driverVehicle = 'DriveU Classic';

    if (bMap['driverId'] != null) {
      if (bMap['driverId'] is Map<String, dynamic>) {
        final dMap = bMap['driverId'] as Map<String, dynamic>;
        driverId = dMap['_id']?.toString() ?? dMap['id']?.toString();
        driverName = dMap['name']?.toString() ??
            '${dMap['firstName'] ?? ''} ${dMap['lastName'] ?? ''}'.trim();
        if (driverName.isEmpty) driverName = 'Assigned Driver';
        driverMobile = dMap['phone']?.toString() ?? dMap['mobile']?.toString() ?? 'N/A';
        if (dMap['rating'] is num) {
          driverRating = (dMap['rating'] as num).toDouble();
        }
        if (dMap['vehicle'] != null) {
          driverVehicle = dMap['vehicle'].toString();
        }
      } else if (bMap['driverId'] is String && bMap['driverId'].toString().isNotEmpty) {
        driverId = bMap['driverId'].toString();
        driverName = 'Driver Partner';
      }
    }

    // Other notes & rating
    final isUserRated = bMap['isUserRated'] == true;
    final isDriverRated = bMap['isDriverRated'] == true;
    final cancelledBy = bMap['cancelledBy']?.toString();
    final cancellationReason = bMap['cancellationReason']?.toString() ?? '';
    final userNotes = bMap['userNotes']?.toString() ?? '';
    final adminNotes = bMap['adminNotes']?.toString() ?? '';

    return BookingDetailModel(
      id: id,
      bookingId: bookingId,
      userId: userId,
      bookingStatus: bookingStatus,
      bookingMode: bookingMode,
      serviceType: serviceType,
      tripType: tripType,
      scheduledStartTime: scheduledStartTime,
      durationHours: durationHours,
      returnDate: returnDate,
      pickupLocation: pickupLocation,
      dropLocation: dropLocation,
      vehicleType: vehicleType,
      transmission: transmission,
      vehicleOwnership: vehicleOwnership,
      vehicleId: vehicleId,
      vehicleNumber: vehicleNumber,
      numberOfPassengers: numberOfPassengers,
      estimatedDistance: estimatedDistance,
      actualDistance: actualDistance,
      estimatedDuration: estimatedDuration,
      tripStartedAt: tripStartedAt,
      tripCompletedAt: tripCompletedAt,
      pricingId: pricingId,
      baseAmount: baseAmount,
      extraKmAmount: extraKmAmount,
      driverAllowance: driverAllowance,
      driverFee: driverFee,
      platformFee: platformFee,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      paymentId: paymentId,
      startOtp: startOtp,
      driverId: driverId,
      driverName: driverName,
      driverMobile: driverMobile,
      driverRating: driverRating,
      driverVehicle: driverVehicle,
      isUserRated: isUserRated,
      isDriverRated: isDriverRated,
      cancelledBy: cancelledBy,
      cancellationReason: cancellationReason,
      cancelledAt: cancelledAt,
      userNotes: userNotes,
      adminNotes: adminNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
