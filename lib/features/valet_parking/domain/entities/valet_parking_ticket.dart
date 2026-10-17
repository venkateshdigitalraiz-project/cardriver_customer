import 'package:equatable/equatable.dart';

enum ValetTicketStatus {
  active,
  retrievalRequested,
  completed,
  cancelled,
}

class ValetParkingTicket extends Equatable {
  final String ticketId;
  final String locationId;
  final String locationName;
  final String locationAddress;
  final String vehicleNumber;
  final String vehicleModel;
  final String valetAttendantName;
  final String valetPhone;
  final String valetPassOtp;
  final String slotNumber;
  final DateTime parkedAt;
  final ValetTicketStatus status;
  final double ratePerHour;
  final double totalAmount;

  const ValetParkingTicket({
    required this.ticketId,
    required this.locationId,
    required this.locationName,
    required this.locationAddress,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.valetAttendantName,
    required this.valetPhone,
    required this.valetPassOtp,
    required this.slotNumber,
    required this.parkedAt,
    required this.status,
    required this.ratePerHour,
    required this.totalAmount,
  });

  ValetParkingTicket copyWith({
    String? ticketId,
    String? locationId,
    String? locationName,
    String? locationAddress,
    String? vehicleNumber,
    String? vehicleModel,
    String? valetAttendantName,
    String? valetPhone,
    String? valetPassOtp,
    String? slotNumber,
    DateTime? parkedAt,
    ValetTicketStatus? status,
    double? ratePerHour,
    double? totalAmount,
  }) {
    return ValetParkingTicket(
      ticketId: ticketId ?? this.ticketId,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      valetAttendantName: valetAttendantName ?? this.valetAttendantName,
      valetPhone: valetPhone ?? this.valetPhone,
      valetPassOtp: valetPassOtp ?? this.valetPassOtp,
      slotNumber: slotNumber ?? this.slotNumber,
      parkedAt: parkedAt ?? this.parkedAt,
      status: status ?? this.status,
      ratePerHour: ratePerHour ?? this.ratePerHour,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props => [
        ticketId,
        locationId,
        locationName,
        locationAddress,
        vehicleNumber,
        vehicleModel,
        valetAttendantName,
        valetPhone,
        valetPassOtp,
        slotNumber,
        parkedAt,
        status,
        ratePerHour,
        totalAmount,
      ];
}
