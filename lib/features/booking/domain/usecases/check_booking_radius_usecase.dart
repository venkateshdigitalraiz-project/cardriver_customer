import 'package:geolocator/geolocator.dart';

class CheckBookingRadiusResult {
  final double distanceKm;
  final bool isLocalRadius;

  const CheckBookingRadiusResult({
    required this.distanceKm,
    required this.isLocalRadius,
  });
}

class CheckBookingRadiusUseCase {
  CheckBookingRadiusResult call({
    required double pickupLat,
    required double pickupLng,
    required double currentLat,
    required double currentLng,
    double radiusKm = 100.0,
  }) {
    final distInMeters = Geolocator.distanceBetween(
      pickupLat,
      pickupLng,
      currentLat,
      currentLng,
    );

    final distanceKm = double.parse((distInMeters / 1000.0).toStringAsFixed(1));
    final bool isLocalRadius = distanceKm <= radiusKm;

    return CheckBookingRadiusResult(
      distanceKm: distanceKm,
      isLocalRadius: isLocalRadius,
    );
  }
}
