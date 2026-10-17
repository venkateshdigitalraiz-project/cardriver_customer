import '../../domain/entities/valet_parking_location.dart';

class ValetParkingLocationModel extends ValetParkingLocation {
  const ValetParkingLocationModel({
    required super.id,
    required super.name,
    required super.address,
    required super.distanceKm,
    required super.rating,
    required super.totalReviews,
    required super.ratePerHour,
    required super.isOpen,
    required super.availableSlots,
    required super.totalSlots,
    required super.operatingHours,
    required super.features,
  });

  factory ValetParkingLocationModel.fromJson(Map<String, dynamic> json) {
    return ValetParkingLocationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      ratePerHour: (json['rate_per_hour'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['is_open'] as bool? ?? true,
      availableSlots: json['available_slots'] as int? ?? 0,
      totalSlots: json['total_slots'] as int? ?? 0,
      operatingHours: json['operating_hours'] as String? ?? '24/7',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distance_km': distanceKm,
      'rating': rating,
      'total_reviews': totalReviews,
      'rate_per_hour': ratePerHour,
      'is_open': isOpen,
      'available_slots': availableSlots,
      'total_slots': totalSlots,
      'operating_hours': operatingHours,
      'features': features,
    };
  }
}
