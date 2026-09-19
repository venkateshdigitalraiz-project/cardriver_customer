// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:cardriver_customer/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ImagePicker _picker = ImagePicker();
  ProfileEntity _currentProfile = ProfileEntity();

  ProfileBloc() : super(ProfileInitial()) {
    on<PickProfileImageEvent>(_onPickProfileImage);
    on<UpdateProfileFieldEvent>(_onUpdateProfileField);
    on<SubmitProfileEvent>(_onSubmitProfile);

    // Emit initial loaded state
    emit(ProfileLoaded(profile: _currentProfile));
  }

  Future<void> _onPickProfileImage(
    PickProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _currentProfile = _currentProfile.copyWith(imagePath: image.path);
        emit(ProfileLoaded(profile: _currentProfile));
      }
    } catch (e) {
      emit(ProfileError('Failed to pick image: $e', _currentProfile));
      // Revert to loaded state after showing error
      emit(ProfileLoaded(profile: _currentProfile));
    }
  }

  void _onUpdateProfileField(
    UpdateProfileFieldEvent event,
    Emitter<ProfileState> emit,
  ) {
    _currentProfile = _currentProfile.copyWith(
      fullName: event.fullName,
      lastName: event.lastName,
      mobileNumber: event.mobileNumber,
      email: event.email,
      carType: event.carType,
      carName: event.carName,
      registrationNumber: event.registrationNumber,
      vehicleColor: event.vehicleColor,
    );
    emit(ProfileLoaded(profile: _currentProfile));
  }

  Future<void> _onSubmitProfile(
    SubmitProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading(_currentProfile));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Here you would typically call a repository to save the profile data

      emit(ProfileSubmitSuccess(_currentProfile));
      // Reset back to loaded state so user can continue editing if they want
      emit(ProfileLoaded(profile: _currentProfile));
    } catch (e) {
      emit(ProfileError('Failed to save profile', _currentProfile));
      emit(ProfileLoaded(profile: _currentProfile));
    }
  }
}
