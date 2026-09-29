class BookingEntity {
  final String id;
  final String status; // 'Upcoming', 'Completed', 'Cancelled'
  final String tripType; // 'Local', 'Outstation'
  final String pickupAddress;
  final String? dropAddress;
  final DateTime scheduleDate;
  final int duration; // in hours or days
  final double fare;
  final String driverName;
  final String driverMobile;
  final String driverVehicle;

  const BookingEntity({
    required this.id,
    required this.status,
    required this.tripType,
    required this.pickupAddress,
    this.dropAddress,
    required this.scheduleDate,
    required this.duration,
    required this.fare,
    required this.driverName,
    required this.driverMobile,
    required this.driverVehicle,
  });
}
