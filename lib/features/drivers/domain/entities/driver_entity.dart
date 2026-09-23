import 'package:equatable/equatable.dart';

/// Domain Entity representing a Driver
class DriverEntity extends Equatable {
  final String driverId;
  final String name;
  final String mobileNumber;
  final String address;
  final double latitude;
  final double longitude;
  final String? profileImage;
  final String carName;
  final String carType;
  final double rating;
  final double distance; // Distance from current location in KM
  final double price; // Rate per hour/trip in INR

  const DriverEntity({
    required this.driverId,
    required this.name,
    required this.mobileNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.profileImage,
    required this.carName,
    required this.carType,
    required this.rating,
    required this.distance,
    this.price = 250.0,
  });

  DriverEntity copyWith({
    String? driverId,
    String? name,
    String? mobileNumber,
    String? address,
    double? latitude,
    double? longitude,
    String? profileImage,
    String? carName,
    String? carType,
    double? rating,
    double? distance,
    double? price,
  }) {
    return DriverEntity(
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      profileImage: profileImage ?? this.profileImage,
      carName: carName ?? this.carName,
      carType: carType ?? this.carType,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [
        driverId,
        name,
        mobileNumber,
        address,
        latitude,
        longitude,
        profileImage,
        carName,
        carType,
        rating,
        distance,
        price,
      ];
}
