import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class PickProfileImageEvent extends ProfileEvent {
  final bool fromCamera;

  const PickProfileImageEvent({required this.fromCamera});

  @override
  List<Object?> get props => [fromCamera];
}

class UpdateProfileFieldEvent extends ProfileEvent {
  final String? fullName;
  final String? lastName;
  final String? mobileNumber;
  final String? email;
  final String? carType;
  final String? carName;
  final String? registrationNumber;
  final String? vehicleColor;

  const UpdateProfileFieldEvent({
    this.fullName,
    this.lastName,
    this.mobileNumber,
    this.email,
    this.carType,
    this.carName,
    this.registrationNumber,
    this.vehicleColor,
  });

  @override
  List<Object?> get props => [
        fullName,
        lastName,
        mobileNumber,
        email,
        carType,
        carName,
        registrationNumber,
        vehicleColor,
      ];
}

class SubmitProfileEvent extends ProfileEvent {}
