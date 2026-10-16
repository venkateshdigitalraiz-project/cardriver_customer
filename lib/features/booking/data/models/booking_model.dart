import 'package:flutter/foundation.dart';
import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    super.dbId = '',
    required super.status,
    required super.tripType,
    super.serviceType = 'local',
    super.bookingMode = 'scheduled',
    required super.pickupAddress,
    super.dropAddress,
    required super.scheduleDate,
    required super.duration,
    required super.fare,
    super.driverName = 'Unassigned',
    super.driverMobile = 'N/A',
    super.driverVehicle = 'DriveU Classic',
    super.startOtp = '',
    super.paymentStatus = 'pending',
    super.paymentMethod = 'online',
    super.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Booking identifier: prefer bookingId (e.g. BKG-859805), fallback to _id
    final bookingId = json['bookingId']?.toString();
    final mongoId = json['_id']?.toString() ?? '';
    final id = (bookingId != null && bookingId.isNotEmpty) ? bookingId : mongoId;

    // Status: bookingStatus from API
    final rawStatus = json['bookingStatus']?.toString() ?? 'pending';

    // Trip type & service type
    final rawTripType = json['tripType']?.toString() ?? 'round_trip';
    final rawServiceType = json['serviceType']?.toString() ?? 'local';

    String formattedTripType = 'Local';
    if (rawServiceType.toLowerCase() == 'outstation') {
      formattedTripType = 'Outstation';
    } else if (rawTripType.toLowerCase() == 'round_trip') {
      formattedTripType = 'Round Trip';
    } else if (rawTripType.toLowerCase() == 'one_way') {
      formattedTripType = 'One Way';
    } else if (rawTripType.isNotEmpty) {
      formattedTripType = rawTripType[0].toUpperCase() + rawTripType.substring(1);
    }

    // Pickup & Drop address
    String pickupAddr = 'Pickup location';
    if (json['pickupLocation'] is Map<String, dynamic>) {
      pickupAddr = json['pickupLocation']['address']?.toString() ?? 'Pickup location';
    }
    String? dropAddr;
    if (json['dropLocation'] is Map<String, dynamic>) {
      dropAddr = json['dropLocation']['address']?.toString();
    }

    // Schedule date
    DateTime schedule = DateTime.now();
    if (json['scheduledStartTime'] != null) {
      final parsed = DateTime.tryParse(json['scheduledStartTime'].toString());
      if (parsed != null) schedule = parsed;
    } else if (json['createdAt'] != null) {
      final parsed = DateTime.tryParse(json['createdAt'].toString());
      if (parsed != null) schedule = parsed;
    }

    // Duration (in hours or days)
    int duration = 1;
    if (json['durationDays'] is num && rawServiceType.toLowerCase() == 'outstation') {
      duration = (json['durationDays'] as num).toInt();
    } else if (json['durationHours'] is num) {
      duration = (json['durationHours'] as num).toInt();
    } else if (json['durationDays'] is num) {
      duration = (json['durationDays'] as num).toInt();
    }

    // Fare amount
    double fare = 0.0;
    if (json['totalAmount'] is num) {
      fare = (json['totalAmount'] as num).toDouble();
    } else if (json['baseAmount'] is num) {
      fare = (json['baseAmount'] as num).toDouble();
    }

    // Driver details
    String dName = 'Unassigned';
    String dMobile = 'N/A';
    if (json['driverId'] != null) {
      if (json['driverId'] is Map<String, dynamic>) {
        final dMap = json['driverId'] as Map<String, dynamic>;
        dName = dMap['name']?.toString() ??
            '${dMap['firstName'] ?? ''} ${dMap['lastName'] ?? ''}'.trim();
        if (dName.isEmpty) dName = 'Assigned Driver';
        dMobile = dMap['phone']?.toString() ?? dMap['mobile']?.toString() ?? 'N/A';
      } else if (json['driverId'] is String && json['driverId'].toString().isNotEmpty) {
        dName = 'Driver Assigned';
      }
    }

    // Vehicle description
    String vehicleDesc = 'Car Driver Classic';
    final vType = json['vehicleType']?.toString();
    final transmission = json['transmission']?.toString();
    if (vType != null && vType.isNotEmpty) {
      final capVType = vType[0].toUpperCase() + vType.substring(1);
      if (transmission != null && transmission.isNotEmpty) {
        final capTrans = transmission[0].toUpperCase() + transmission.substring(1);
        vehicleDesc = '$capVType ($capTrans)';
      } else {
        vehicleDesc = capVType;
      }
    }

    final startOtp = json['startOtp']?.toString() ?? '';
    final paymentStatus = json['paymentStatus']?.toString() ?? 'pending';
    final paymentMethod = json['paymentMethod']?.toString() ?? 'online';
    final bookingMode = json['bookingMode']?.toString() ?? 'scheduled';

    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt'].toString());
    }

    return BookingModel(
      id: id,
      dbId: mongoId,
      status: rawStatus,
      tripType: formattedTripType,
      serviceType: rawServiceType,
      bookingMode: bookingMode,
      pickupAddress: pickupAddr,
      dropAddress: dropAddr,
      scheduleDate: schedule,
      duration: duration,
      fare: fare,
      driverName: dName,
      driverMobile: dMobile,
      driverVehicle: vehicleDesc,
      startOtp: startOtp,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
    );
  }
}

class BookingPaginationModel extends BookingPaginationEntity {
  const BookingPaginationModel({
    super.total = 0,
    super.page = 1,
    super.limit = 5,
    super.totalPages = 1,
  });

  factory BookingPaginationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingPaginationModel();
    return BookingPaginationModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 5,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class BookingListResponseModel extends BookingListResponseEntity {
  const BookingListResponseModel({
    required super.bookings,
    required super.pagination,
  });

  factory BookingListResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingListResponseModel.fromAny(json);
  }

  factory BookingListResponseModel.fromAny(dynamic json) {
    if (json == null) {
      return const BookingListResponseModel(
        bookings: [],
        pagination: BookingPaginationModel(),
      );
    }

    List<dynamic>? rawBookings;
    Map<String, dynamic>? paginationMap;

    if (json is List) {
      rawBookings = json;
    } else if (json is Map<String, dynamic>) {
      // Check if wrapped in data
      if (json['data'] is Map<String, dynamic>) {
        final dataMap = json['data'] as Map<String, dynamic>;
        if (dataMap['bookings'] is List) rawBookings = dataMap['bookings'] as List;
        if (dataMap['pagination'] is Map<String, dynamic>) {
          paginationMap = dataMap['pagination'] as Map<String, dynamic>;
        }
      } else if (json['data'] is List) {
        rawBookings = json['data'] as List;
      }

      if (rawBookings == null && json['bookings'] is List) {
        rawBookings = json['bookings'] as List;
      }
      if (paginationMap == null && json['pagination'] is Map<String, dynamic>) {
        paginationMap = json['pagination'] as Map<String, dynamic>;
      }
    }

    final List<BookingModel> bookings = [];
    if (rawBookings != null) {
      for (var item in rawBookings) {
        if (item is Map<String, dynamic>) {
          try {
            bookings.add(BookingModel.fromJson(item));
          } catch (e) {
            debugPrint('⚠️ Error parsing single booking item: $e');
          }
        }
      }
    }

    final pagination = BookingPaginationModel.fromJson(
      paginationMap ?? {
        'total': bookings.length,
        'page': 1,
        'limit': bookings.isNotEmpty ? bookings.length : 5,
        'totalPages': 1,
      },
    );

    return BookingListResponseModel(
      bookings: bookings,
      pagination: pagination,
    );
  }
}
