class ProfileEntity {
  final String? imagePath;
  final String fullName;
  final String lastName;
  final String mobileNumber;
  final String email;
  final String carType;
  final String carName;
  final String registrationNumber;
  final String vehicleColor;

  ProfileEntity({
    this.imagePath,
    this.fullName = '',
    this.lastName = '',
    this.mobileNumber = '',
    this.email = '',
    this.carType = '',
    this.carName = '',
    this.registrationNumber = '',
    this.vehicleColor = '',
  });

  ProfileEntity copyWith({
    String? imagePath,
    String? fullName,
    String? lastName,
    String? mobileNumber,
    String? email,
    String? carType,
    String? carName,
    String? registrationNumber,
    String? vehicleColor,
  }) {
    return ProfileEntity(
      imagePath: imagePath ?? this.imagePath,
      fullName: fullName ?? this.fullName,
      lastName: lastName ?? this.lastName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      carType: carType ?? this.carType,
      carName: carName ?? this.carName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      vehicleColor: vehicleColor ?? this.vehicleColor,
    );
  }
}
