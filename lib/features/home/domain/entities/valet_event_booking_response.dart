import 'package:equatable/equatable.dart';

class ValetBookingPricing extends Equatable {
  final double customerPrice;
  final double driverPrice;
  final double taxAmount;
  final double totalAmount;
  final double staffPayoutTotal;
  final double platformCommission;

  const ValetBookingPricing({
    required this.customerPrice,
    required this.driverPrice,
    required this.taxAmount,
    required this.totalAmount,
    required this.staffPayoutTotal,
    required this.platformCommission,
  });

  factory ValetBookingPricing.fromJson(Map<String, dynamic> json) {
    return ValetBookingPricing(
      customerPrice: (json['customerPrice'] as num?)?.toDouble() ?? 10000.0,
      driverPrice: (json['driverPrice'] as num?)?.toDouble() ?? 2400.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 1800.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 11800.0,
      staffPayoutTotal: (json['staffPayoutTotal'] as num?)?.toDouble() ?? 2400.0,
      platformCommission:
          (json['platformCommission'] as num?)?.toDouble() ?? 7600.0,
    );
  }

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

class ValetBookingResponseData extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String eventName;
  final String eventType;
  final String eventDate;
  final String startTime;
  final String endTime;
  final int hours;
  final int person;
  final String venueName;
  final String address;
  final List<double> coordinates;
  final ValetBookingPricing pricing;
  final List<String> assignedStaffIds;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String specialInstructions;
  final String? createdAt;
  final String? updatedAt;

  const ValetBookingResponseData({
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
    required this.coordinates,
    required this.pricing,
    required this.assignedStaffIds,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.specialInstructions,
    this.createdAt,
    this.updatedAt,
  });

  factory ValetBookingResponseData.fromJson(Map<String, dynamic> json) {
    List<double> coords = [77.6483, 12.9606];
    if (json['location'] is Map<String, dynamic>) {
      final loc = json['location'] as Map<String, dynamic>;
      if (loc['coordinates'] is List) {
        coords = (loc['coordinates'] as List)
            .map((c) => (c as num).toDouble())
            .toList();
      }
    }

    final pricingJson = json['pricing'] is Map<String, dynamic>
        ? json['pricing'] as Map<String, dynamic>
        : <String, dynamic>{};

    return ValetBookingResponseData(
      id: json['_id']?.toString() ?? '6ad23b007eed370ed331b195',
      bookingId: json['bookingId']?.toString() ?? 'VLT-505174',
      userId: json['userId']?.toString() ?? '6ab6427b440da47e3ac83da3',
      eventName: json['eventName']?.toString() ?? 'Royals Grand Wedding Gala 2026',
      eventType: json['eventType']?.toString() ?? 'wedding',
      eventDate: json['eventDate']?.toString() ?? '2026-11-20T18:00:00.000Z',
      startTime: json['startTime']?.toString() ?? '18:00',
      endTime: json['endTime']?.toString() ?? '23:00',
      hours: (json['hours'] as num?)?.toInt() ?? 5,
      person: (json['person'] as num?)?.toInt() ?? 4,
      venueName: json['venueName']?.toString() ?? 'The Leela Palace',
      address: json['address']?.toString() ??
          'The Leela Palace, 23 HAL Old Airport Rd, Kodihalli, Bengaluru, Karnataka 560008',
      coordinates: coords,
      pricing: ValetBookingPricing.fromJson(pricingJson),
      assignedStaffIds: (json['assignedStaffIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status']?.toString() ?? 'new_request',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      paymentMethod: json['paymentMethod']?.toString() ?? 'online',
      specialInstructions: json['specialInstructions']?.toString() ??
          'Guests will arrive in luxury sedans and SUVs. Please maintain uniform valet etiquette.',
      createdAt: json['createdAt']?.toString() ?? '2026-10-16T14:56:00.443Z',
      updatedAt: json['updatedAt']?.toString() ?? '2026-10-16T14:56:00.443Z',
    );
  }

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
        createdAt,
        updatedAt,
      ];
}

class ValetEventBookingResponse extends Equatable {
  final bool success;
  final String message;
  final ValetBookingResponseData data;

  const ValetEventBookingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ValetEventBookingResponse.fromJson(Map<String, dynamic> json) {
    return ValetEventBookingResponse(
      success: json['success'] == true || json['success'] == null,
      message: json['message']?.toString() ??
          'Valet parking booking created successfully',
      data: json['data'] is Map<String, dynamic>
          ? ValetBookingResponseData.fromJson(
              json['data'] as Map<String, dynamic>)
          : ValetBookingResponseData.fromJson(json),
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}
