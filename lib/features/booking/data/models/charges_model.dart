import '../../domain/entities/charges_entity.dart';

class ChargesModel extends ChargesEntity {
  const ChargesModel({super.id, super.local, super.outstation});

  factory ChargesModel.fromJson(Map<String, dynamic> json) {
    return ChargesModel(
      id: json['_id']?.toString() ?? '',
      local: json['local'] != null && json['local'] is Map<String, dynamic>
          ? LocalChargesModel.fromJson(json['local'] as Map<String, dynamic>)
          : const LocalChargesEntity(),
      outstation:
          json['outstation'] != null &&
              json['outstation'] is Map<String, dynamic>
          ? OutstationChargesModel.fromJson(
              json['outstation'] as Map<String, dynamic>,
            )
          : const OutstationChargesEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id};
  }
}

class LocalChargesModel extends LocalChargesEntity {
  const LocalChargesModel({super.oneWay, super.roundTrip});

  factory LocalChargesModel.fromJson(Map<String, dynamic> json) {
    final oneWayData = json['one_way'] ?? json['oneWay'];
    final roundTripData = json['round_trip'] ?? json['roundTrip'];

    return LocalChargesModel(
      oneWay: oneWayData != null && oneWayData is Map<String, dynamic>
          ? LocalTripChargesModel.fromJson(oneWayData)
          : const LocalTripChargesEntity(),
      roundTrip: roundTripData != null && roundTripData is Map<String, dynamic>
          ? LocalTripChargesModel.fromJson(roundTripData)
          : const LocalTripChargesEntity(),
    );
  }
}

class LocalTripChargesModel extends LocalTripChargesEntity {
  const LocalTripChargesModel({super.morningHours, super.nightHours});

  factory LocalTripChargesModel.fromJson(Map<String, dynamic> json) {
    final morningData = json['morningHours'] ??
        json['morning_hours'] ??
        json['dayHours'] ??
        json['day_hours'];
    final nightData = json['nightHours'] ?? json['night_hours'];

    return LocalTripChargesModel(
      morningHours: morningData != null && morningData is Map<String, dynamic>
          ? TimeSlotChargeModel.fromJson(morningData)
          : const TimeSlotChargeEntity(),
      nightHours: nightData != null && nightData is Map<String, dynamic>
          ? TimeSlotChargeModel.fromJson(nightData)
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
      timeRange: (json['timeRange'] ?? json['time_range'])?.toString() ?? '',
      customerPrice:
          ((json['customerPrice'] ?? json['customer_price'] ?? json['price'])
                  as num?)
              ?.toDouble() ??
          0.0,
      driverPrice:
          ((json['driverPrice'] ?? json['driver_price']) as num?)?.toDouble() ??
          0.0,
    );
  }
}

class OutstationChargesModel extends OutstationChargesEntity {
  const OutstationChargesModel({super.oneWay, super.roundTrip});

  factory OutstationChargesModel.fromJson(Map<String, dynamic> json) {
    final oneWayData = json['one_way'] ?? json['oneWay'];
    final roundTripData = json['round_trip'] ?? json['roundTrip'];

    return OutstationChargesModel(
      oneWay: oneWayData != null && oneWayData is Map<String, dynamic>
          ? OutstationTripChargeModel.fromJson(oneWayData)
          : const OutstationTripChargeEntity(),
      roundTrip: roundTripData != null && roundTripData is Map<String, dynamic>
          ? OutstationTripChargeModel.fromJson(roundTripData)
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
      customerPrice:
          ((json['customerPrice'] ?? json['customer_price'] ?? json['price'])
                  as num?)
              ?.toDouble() ??
          0.0,
      driverPrice:
          ((json['driverPrice'] ?? json['driver_price']) as num?)?.toDouble() ??
          0.0,
    );
  }
}
