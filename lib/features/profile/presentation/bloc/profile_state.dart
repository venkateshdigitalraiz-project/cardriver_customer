import 'package:cardriver_customer/features/profile/domain/entities/profile_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {
  final ProfileEntity currentProfile;

  const ProfileLoading(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;
  final ProfileEntity currentProfile;

  const ProfileError(this.message, this.currentProfile);

  @override
  List<Object?> get props => [message, currentProfile];
}

class ProfileSubmitSuccess extends ProfileState {
  final ProfileEntity profile;

  const ProfileSubmitSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}
