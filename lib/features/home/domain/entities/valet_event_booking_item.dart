import 'package:equatable/equatable.dart';

class ValetEventBookingItem extends Equatable {
  final String eventName;
  final String eventType;
  final String eventDate;
  final String startTime;
  final String endTime;
  final int hours;
  final int person;
  final String venueName;
  final List<double> coordinates;
  final String locationAddress;
  final String address;
  final String specialInstructions;
  final String paymentMethod;

  const ValetEventBookingItem({
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.hours,
    required this.person,
    required this.venueName,
    required this.coordinates,
    required this.locationAddress,
    required this.address,
    required this.specialInstructions,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'eventType': eventType,
      'eventDate': eventDate,
      'startTime': startTime,
      'endTime': endTime,
      'hours': hours,
      'person': person,
      'venueName': venueName,
      'location': {
        'type': 'Point',
        'coordinates': coordinates,
        'address': locationAddress,
      },
      'address': address,
      'specialInstructions': specialInstructions,
      'paymentMethod': paymentMethod,
    };
  }

  factory ValetEventBookingItem.fromJson(Map<String, dynamic> json) {
    List<double> coords = [77.6483, 12.9606];
    String locAddress = '';
    if (json['location'] is Map<String, dynamic>) {
      final loc = json['location'] as Map<String, dynamic>;
      if (loc['coordinates'] is List) {
        coords = (loc['coordinates'] as List)
            .map((c) => (c as num).toDouble())
            .toList();
      }
      locAddress = loc['address']?.toString() ?? '';
    }

    return ValetEventBookingItem(
      eventName: json['eventName']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      eventDate: json['eventDate']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      hours: (json['hours'] as num?)?.toInt() ?? 0,
      person: (json['person'] as num?)?.toInt() ?? 0,
      venueName: json['venueName']?.toString() ?? '',
      coordinates: coords,
      locationAddress: locAddress.isNotEmpty
          ? locAddress
          : (json['address']?.toString() ?? ''),
      address: json['address']?.toString() ?? '',
      specialInstructions: json['specialInstructions']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'online',
    );
  }

  ValetEventBookingItem copyWith({
    String? eventName,
    String? eventType,
    String? eventDate,
    String? startTime,
    String? endTime,
    int? hours,
    int? person,
    String? venueName,
    List<double>? coordinates,
    String? locationAddress,
    String? address,
    String? specialInstructions,
    String? paymentMethod,
  }) {
    return ValetEventBookingItem(
      eventName: eventName ?? this.eventName,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hours: hours ?? this.hours,
      person: person ?? this.person,
      venueName: venueName ?? this.venueName,
      coordinates: coordinates ?? this.coordinates,
      locationAddress: locationAddress ?? this.locationAddress,
      address: address ?? this.address,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  List<Object?> get props => [
        eventName,
        eventType,
        eventDate,
        startTime,
        endTime,
        hours,
        person,
        venueName,
        coordinates,
        locationAddress,
        address,
        specialInstructions,
        paymentMethod,
      ];
}
