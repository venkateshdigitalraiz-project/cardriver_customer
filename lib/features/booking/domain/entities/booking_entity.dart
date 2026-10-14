import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String dbId;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String tripType; // 'Local', 'Outstation', 'Round Trip', etc.
  final String serviceType; // 'local', 'outstation'
  final String bookingMode; // 'scheduled', 'instant'
  final String pickupAddress;
  final String? dropAddress;
  final DateTime scheduleDate;
  final int duration; // in hours or days
  final double fare;
  final String driverName;
  final String driverMobile;
  final String driverVehicle;
  final String startOtp;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? createdAt;

  const BookingEntity({
    required this.id,
    this.dbId = '',
    required this.status,
    required this.tripType,
    this.serviceType = 'local',
    this.bookingMode = 'scheduled',
    required this.pickupAddress,
    this.dropAddress,
    required this.scheduleDate,
    required this.duration,
    required this.fare,
    this.driverName = 'Unassigned',
    this.driverMobile = 'N/A',
    this.driverVehicle = 'DriveU Classic',
    this.startOtp = '',
    this.paymentStatus = 'pending',
    this.paymentMethod = 'online',
    this.createdAt,
  });

  /// Group status into 'Upcoming', 'Completed', or 'Cancelled' for tab categorization
  String get statusGroup {
    final s = status.toLowerCase().trim();
    if (s == 'completed' || s == 'finished') {
      return 'Completed';
    } else if (s == 'cancelled' || s == 'canceled' || s == 'rejected') {
      return 'Cancelled';
    } else {
      // 'pending', 'confirmed', 'assigned', 'accepted', 'in_progress', 'upcoming', 'scheduled'
      return 'Upcoming';
    }
  }

  /// Capitalized display status for UI badge
  String get displayStatus {
    if (status.isEmpty) return 'Pending';
    final cleaned = status.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return 'Pending';
    return cleaned.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  List<Object?> get props => [
        id,
        dbId,
        status,
        tripType,
        serviceType,
        bookingMode,
        pickupAddress,
        dropAddress,
        scheduleDate,
        duration,
        fare,
        driverName,
        driverMobile,
        driverVehicle,
        startOtp,
        paymentStatus,
        paymentMethod,
        createdAt,
      ];
}

class BookingPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const BookingPaginationEntity({
    this.total = 0,
    this.page = 1,
    this.limit = 5,
    this.totalPages = 1,
  });

  bool get hasNextPage => page < totalPages;

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class BookingListResponseEntity extends Equatable {
  final List<BookingEntity> bookings;
  final BookingPaginationEntity pagination;

  const BookingListResponseEntity({
    required this.bookings,
    required this.pagination,
  });

  @override
  List<Object?> get props => [bookings, pagination];
}

