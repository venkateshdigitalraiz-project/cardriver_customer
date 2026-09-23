import '../../domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  const DriverModel({
    required super.driverId,
    required super.name,
    required super.mobileNumber,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.profileImage,
    required super.carName,
    required super.carType,
    required super.rating,
    required super.distance,
    super.price = 250.0,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      driverId: json['driverId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Driver',
      mobileNumber: json['mobileNumber'] as String? ?? json['phone'] as String? ?? '',
      address: json['address'] as String? ?? 'Hyderabad',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 17.4850,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 78.3887,
      profileImage: json['profileImage'] as String? ?? json['avatarUrl'] as String?,
      carName: json['carName'] as String? ?? 'Sedan Premium',
      carType: json['carType'] as String? ?? 'Sedan',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 250.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'name': name,
      'mobileNumber': mobileNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'profileImage': profileImage,
      'carName': carName,
      'carType': carType,
      'rating': rating,
      'distance': distance,
      'price': price,
    };
  }
}
