import '../../domain/entities/charges_entity.dart';

class ChargesModel extends ChargesEntity {
  const ChargesModel({
    super.id,
    super.local,
    super.outstation,
  });

  factory ChargesModel.fromJson(Map<String, dynamic> json) {
    return ChargesModel(
      id: json['_id']?.toString() ?? '',
      local: json['local'] != null && json['local'] is Map<String, dynamic>
          ? LocalChargesModel.fromJson(json['local'] as Map<String, dynamic>)
          : const LocalChargesEntity(),
      outstation: json['outstation'] != null && json['outstation'] is Map<String, dynamic>
          ? OutstationChargesModel.fromJson(json['outstation'] as Map<String, dynamic>)
          : const OutstationChargesEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
    };
  }
}

class LocalChargesModel extends LocalChargesEntity {
  const LocalChargesModel({
    super.oneWay,
    super.roundTrip,
  });

  factory LocalChargesModel.fromJson(Map<String, dynamic> json) {
    return LocalChargesModel(
      oneWay: json['one_way'] != null && json['one_way'] is Map<String, dynamic>
          ? LocalTripChargesModel.fromJson(json['one_way'] as Map<String, dynamic>)
          : const LocalTripChargesEntity(),
      roundTrip: json['round_trip'] != null && json['round_trip'] is Map<String, dynamic>
          ? LocalTripChargesModel.fromJson(json['round_trip'] as Map<String, dynamic>)
          : const LocalTripChargesEntity(),
    );
  }
}

class LocalTripChargesModel extends LocalTripChargesEntity {
  const LocalTripChargesModel({
    super.morningHours,
    super.nightHours,
  });

  factory LocalTripChargesModel.fromJson(Map<String, dynamic> json) {
    return LocalTripChargesModel(
      morningHours: json['morningHours'] != null && json['morningHours'] is Map<String, dynamic>
          ? TimeSlotChargeModel.fromJson(json['morningHours'] as Map<String, dynamic>)
          : const TimeSlotChargeEntity(),
      nightHours: json['nightHours'] != null && json['nightHours'] is Map<String, dynamic>
          ? TimeSlotChargeModel.fromJson(json['nightHours'] as Map<String, dynamic>)
          : const TimeSlotChargeEntity(),
    );
  }
}

class TimeSlotChargeModel extends TimeSlotChargeEntity {
  const TimeSlotChargeModel({
    super.hours,
    super.timeRange,
    super.customerPrice,
    super.driverPrice,
  });

  factory TimeSlotChargeModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotChargeModel(
      hours: (json['hours'] as num?)?.toInt() ?? 4,
      timeRange: json['timeRange']?.toString() ?? '',
      customerPrice: (json['customerPrice'] as num?)?.toDouble() ?? 0.0,
      driverPrice: (json['driverPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OutstationChargesModel extends OutstationChargesEntity {
  const OutstationChargesModel({
    super.oneWay,
    super.roundTrip,
  });

  factory OutstationChargesModel.fromJson(Map<String, dynamic> json) {
    return OutstationChargesModel(
      oneWay: json['one_way'] != null && json['one_way'] is Map<String, dynamic>
          ? OutstationTripChargeModel.fromJson(json['one_way'] as Map<String, dynamic>)
          : const OutstationTripChargeEntity(),
      roundTrip: json['round_trip'] != null && json['round_trip'] is Map<String, dynamic>
          ? OutstationTripChargeModel.fromJson(json['round_trip'] as Map<String, dynamic>)
          : const OutstationTripChargeEntity(),
    );
  }
}

class OutstationTripChargeModel extends OutstationTripChargeEntity {
  const OutstationTripChargeModel({
    super.day,
    super.customerPrice,
    super.driverPrice,
  });

  factory OutstationTripChargeModel.fromJson(Map<String, dynamic> json) {
    return OutstationTripChargeModel(
      day: (json['day'] as num?)?.toInt() ?? 1,
      customerPrice: (json['customerPrice'] as num?)?.toDouble() ?? 0.0,
      driverPrice: (json['driverPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
