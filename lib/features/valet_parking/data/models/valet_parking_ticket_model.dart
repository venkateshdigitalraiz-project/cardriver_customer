import '../../domain/entities/valet_parking_ticket.dart';

class ValetParkingTicketModel extends ValetParkingTicket {
  const ValetParkingTicketModel({
    required super.ticketId,
    required super.locationId,
    required super.locationName,
    required super.locationAddress,
    required super.vehicleNumber,
    required super.vehicleModel,
    required super.valetAttendantName,
    required super.valetPhone,
    required super.valetPassOtp,
    required super.slotNumber,
    required super.parkedAt,
    required super.status,
    required super.ratePerHour,
    required super.totalAmount,
  });

  factory ValetParkingTicketModel.fromJson(Map<String, dynamic> json) {
    ValetTicketStatus status = ValetTicketStatus.active;
    final statusStr = (json['status'] as String? ?? '').toLowerCase();
    if (statusStr == 'retrieval_requested' || statusStr == 'retrievalrequested') {
      status = ValetTicketStatus.retrievalRequested;
    } else if (statusStr == 'completed') {
      status = ValetTicketStatus.completed;
    } else if (statusStr == 'cancelled') {
      status = ValetTicketStatus.cancelled;
    }

    return ValetParkingTicketModel(
      ticketId: json['ticket_id'] as String? ?? '',
      locationId: json['location_id'] as String? ?? '',
      locationName: json['location_name'] as String? ?? '',
      locationAddress: json['location_address'] as String? ?? '',
      vehicleNumber: json['vehicle_number'] as String? ?? '',
      vehicleModel: json['vehicle_model'] as String? ?? '',
      valetAttendantName: json['valet_attendant_name'] as String? ?? '',
      valetPhone: json['valet_phone'] as String? ?? '',
      valetPassOtp: json['valet_pass_otp'] as String? ?? '',
      slotNumber: json['slot_number'] as String? ?? '',
      parkedAt: json['parked_at'] != null
          ? DateTime.tryParse(json['parked_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: status,
      ratePerHour: (json['rate_per_hour'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'location_id': locationId,
      'location_name': locationName,
      'location_address': locationAddress,
      'vehicle_number': vehicleNumber,
      'vehicle_model': vehicleModel,
      'valet_attendant_name': valetAttendantName,
      'valet_phone': valetPhone,
      'valet_pass_otp': valetPassOtp,
      'slot_number': slotNumber,
      'parked_at': parkedAt.toIso8601String(),
      'status': status.name,
      'rate_per_hour': ratePerHour,
      'total_amount': totalAmount,
    };
  }
}
