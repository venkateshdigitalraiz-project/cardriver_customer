import 'package:equatable/equatable.dart';

class ValetParkingLocation extends Equatable {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final double rating;
  final int totalReviews;
  final double ratePerHour;
  final bool isOpen;
  final int availableSlots;
  final int totalSlots;
  final String operatingHours;
  final List<String> features;

  const ValetParkingLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.totalReviews,
    required this.ratePerHour,
    required this.isOpen,
    required this.availableSlots,
    required this.totalSlots,
    required this.operatingHours,
    required this.features,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        distanceKm,
        rating,
        totalReviews,
        ratePerHour,
        isOpen,
        availableSlots,
        totalSlots,
        operatingHours,
        features,
      ];
}
