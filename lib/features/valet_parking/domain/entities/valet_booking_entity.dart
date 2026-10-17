import 'package:equatable/equatable.dart';

class ValetBookingPricingEntity extends Equatable {
  final double customerPrice;
  final double driverPrice;
  final double taxAmount;
  final double totalAmount;
  final double staffPayoutTotal;
  final double platformCommission;

  const ValetBookingPricingEntity({
    required this.customerPrice,
    required this.driverPrice,
    required this.taxAmount,
    required this.totalAmount,
    required this.staffPayoutTotal,
    required this.platformCommission,
  });

  @override
  List<Object?> get props => [
        customerPrice,
        driverPrice,
        taxAmount,
        totalAmount,
        staffPayoutTotal,
        platformCommission,
      ];
}

class ValetBookingEntity extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String eventName;
  final String eventType;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final int hours;
  final int person;
  final String venueName;
  final String address;
  final List<double>? coordinates;
  final ValetBookingPricingEntity pricing;
  final List<String> assignedStaffIds;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String specialInstructions;
  final String adminNotes;
  final String cancellationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ValetBookingEntity({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.hours,
    required this.person,
    required this.venueName,
    required this.address,
    this.coordinates,
    required this.pricing,
    required this.assignedStaffIds,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.specialInstructions,
    this.adminNotes = '',
    this.cancellationReason = '',
    this.createdAt,
    this.updatedAt,
  });

  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  @override
  List<Object?> get props => [
        id,
        bookingId,
        userId,
        eventName,
        eventType,
        eventDate,
        startTime,
        endTime,
        hours,
        person,
        venueName,
        address,
        coordinates,
        pricing,
        assignedStaffIds,
        status,
        paymentStatus,
        paymentMethod,
        specialInstructions,
        adminNotes,
        cancellationReason,
        createdAt,
        updatedAt,
      ];
}

class ValetBookingPaginationEntity extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const ValetBookingPaginationEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}
