import '../../domain/entities/valet_booking_entity.dart';

class ValetBookingPricingModel extends ValetBookingPricingEntity {
  const ValetBookingPricingModel({
    required super.customerPrice,
    required super.driverPrice,
    required super.taxAmount,
    required super.totalAmount,
    required super.staffPayoutTotal,
    required super.platformCommission,
  });

  factory ValetBookingPricingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ValetBookingPricingModel(
        customerPrice: 0.0,
        driverPrice: 0.0,
        taxAmount: 0.0,
        totalAmount: 0.0,
        staffPayoutTotal: 0.0,
        platformCommission: 0.0,
      );
    }
    return ValetBookingPricingModel(
      customerPrice: (json['customerPrice'] as num?)?.toDouble() ?? 0.0,
      driverPrice: (json['driverPrice'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      staffPayoutTotal: (json['staffPayoutTotal'] as num?)?.toDouble() ?? 0.0,
      platformCommission:
          (json['platformCommission'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerPrice': customerPrice,
      'driverPrice': driverPrice,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'staffPayoutTotal': staffPayoutTotal,
      'platformCommission': platformCommission,
    };
  }
}

class ValetBookingModel extends ValetBookingEntity {
  const ValetBookingModel({
    required super.id,
    required super.bookingId,
    required super.userId,
    required super.eventName,
    required super.eventType,
    required super.eventDate,
    required super.startTime,
    required super.endTime,
    required super.hours,
    required super.person,
    required super.venueName,
    required super.address,
    super.coordinates,
    required super.pricing,
    required super.assignedStaffIds,
    required super.status,
    required super.paymentStatus,
    required super.paymentMethod,
    required super.specialInstructions,
    super.adminNotes = '',
    super.cancellationReason = '',
    super.createdAt,
    super.updatedAt,
  });

  factory ValetBookingModel.fromJson(Map<String, dynamic> json) {
    // Extract coordinates if present in location
    List<double>? coords;
    if (json['location'] is Map<String, dynamic>) {
      final loc = json['location'] as Map<String, dynamic>;
      if (loc['coordinates'] is List) {
        coords = (loc['coordinates'] as List)
            .map((c) => (c as num).toDouble())
            .toList();
      }
    }

    // Extract pricing
    final pricingJson = json['pricing'] is Map<String, dynamic>
        ? json['pricing'] as Map<String, dynamic>
        : null;

    // Assigned staff IDs
    final staffIds = (json['assignedStaffIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return ValetBookingModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      eventName: json['eventName'] as String? ?? 'Valet Service Event',
      eventType: json['eventType'] as String? ?? 'valet',
      eventDate: json['eventDate'] != null
          ? DateTime.tryParse(json['eventDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      hours: json['hours'] as int? ?? 1,
      person: json['person'] as int? ?? 1,
      venueName: json['venueName'] as String? ?? 'Venue Location',
      address: json['address'] as String? ??
          (json['location'] is Map ? json['location']['address'] ?? '' : ''),
      coordinates: coords,
      pricing: ValetBookingPricingModel.fromJson(pricingJson),
      assignedStaffIds: staffIds,
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      paymentMethod: json['paymentMethod'] as String? ?? 'online',
      specialInstructions: json['specialInstructions'] as String? ?? '',
      adminNotes: json['adminNotes'] as String? ?? '',
      cancellationReason: json['cancellationReason'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bookingId': bookingId,
      'userId': userId,
      'eventName': eventName,
      'eventType': eventType,
      'eventDate': eventDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'hours': hours,
      'person': person,
      'venueName': venueName,
      'address': address,
      'location': {
        'type': 'Point',
        'coordinates': coordinates ?? [],
        'address': address,
      },
      'pricing': (pricing as ValetBookingPricingModel).toJson(),
      'assignedStaffIds': assignedStaffIds,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'specialInstructions': specialInstructions,
      'adminNotes': adminNotes,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
