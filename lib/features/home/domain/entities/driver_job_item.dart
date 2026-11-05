import 'package:equatable/equatable.dart';

class DriverJobItem extends Equatable {
  final String jobTitle;
  final String jobType; // Full-Time, Part-Time, Monthly, On-Demand
  final String vehicleType; // Sedan, SUV, Hatchback, Luxury, Any
  final String transmission; // Manual, Automatic, Any
  final String salary; // e.g. ₹20,000 / month
  final String workingHours; // e.g. 9 AM - 6 PM (9 Hours)
  final String dutyDays; // e.g. 6 Days / Week, Monday to Saturday
  final String locationAddress;
  final String city;
  final List<double> coordinates;
  final String startDate;
  final String experienceRequired;
  final String contactPerson;
  final String contactPhone;
  final String description;

  const DriverJobItem({
    required this.jobTitle,
    required this.jobType,
    required this.vehicleType,
    required this.transmission,
    required this.salary,
    required this.workingHours,
    required this.dutyDays,
    required this.locationAddress,
    required this.city,
    required this.coordinates,
    required this.startDate,
    required this.experienceRequired,
    required this.contactPerson,
    required this.contactPhone,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'jobType': jobType,
      'vehicleType': vehicleType,
      'transmission': transmission,
      'salary': salary,
      'workingHours': workingHours,
      'dutyDays': dutyDays,
      'location': {
        'type': 'Point',
        'coordinates': coordinates,
        'address': locationAddress,
        'city': city,
      },
      'locationAddress': locationAddress,
      'startDate': startDate,
      'experienceRequired': experienceRequired,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'description': description,
    };
  }

  factory DriverJobItem.fromJson(Map<String, dynamic> json) {
    List<double> coords = [77.6483, 12.9606];
    String locAddress = '';
    String cityName = '';
    if (json['location'] is Map<String, dynamic>) {
      final loc = json['location'] as Map<String, dynamic>;
      if (loc['coordinates'] is List) {
        coords = (loc['coordinates'] as List)
            .map((c) => (c as num).toDouble())
            .toList();
      }
      locAddress = loc['address']?.toString() ?? '';
      cityName = loc['city']?.toString() ?? '';
    }

    return DriverJobItem(
      jobTitle: json['jobTitle']?.toString() ?? '',
      jobType: json['jobType']?.toString() ?? 'Full-Time',
      vehicleType: json['vehicleType']?.toString() ?? 'Sedan',
      transmission: json['transmission']?.toString() ?? 'Manual',
      salary: json['salary']?.toString() ?? '',
      workingHours: json['workingHours']?.toString() ?? '9 AM - 6 PM',
      dutyDays: json['dutyDays']?.toString() ?? '6 Days/Week',
      locationAddress: locAddress.isNotEmpty
          ? locAddress
          : (json['locationAddress']?.toString() ?? json['address']?.toString() ?? ''),
      city: cityName,
      coordinates: coords,
      startDate: json['startDate']?.toString() ?? '',
      experienceRequired: json['experienceRequired']?.toString() ?? '2+ Years',
      contactPerson: json['contactPerson']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        jobTitle,
        jobType,
        vehicleType,
        transmission,
        salary,
        workingHours,
        dutyDays,
        locationAddress,
        city,
        coordinates,
        startDate,
        experienceRequired,
        contactPerson,
        contactPhone,
        description,
      ];
}

