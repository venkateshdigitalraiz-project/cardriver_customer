import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    super.imagePath,
    super.fullName,
    super.lastName,
    super.mobileNumber,
    super.email,
    super.address,
    super.carType,
    super.carName,
    super.registrationNumber,
    super.vehicleColor,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      imagePath: json['imagePath'],
      fullName: json['firstName'] ?? json['fullName'] ?? '',
      lastName: json['lastName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      carType: json['carType'] ?? '',
      carName: json['carName'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      vehicleColor: json['vehicleColor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': fullName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'email': email,
      'address': address,
      'carType': carType,
      'carName': carName,
      'registrationNumber': registrationNumber,
      'vehicleColor': vehicleColor,
    };
  }
}
