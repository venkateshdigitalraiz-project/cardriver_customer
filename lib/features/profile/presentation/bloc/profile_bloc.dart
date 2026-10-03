// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ImagePicker _picker = ImagePicker();
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  
  ProfileEntity _currentProfile = ProfileEntity();

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<PickProfileImageEvent>(_onPickProfileImage);
    on<UpdateProfileFieldEvent>(_onUpdateProfileField);
    on<SubmitProfileEvent>(_onSubmitProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading(_currentProfile));
    try {
      final profile = await getUserProfileUseCase();
      _currentProfile = profile;
      emit(ProfileLoaded(profile: _currentProfile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e', _currentProfile));
    }
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
      address: event.address,
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
      final updatedProfile = await updateUserProfileUseCase(_currentProfile);
      _currentProfile = updatedProfile;
      emit(ProfileSubmitSuccess(_currentProfile));
      emit(ProfileLoaded(profile: _currentProfile));
    } catch (e) {
      emit(ProfileError('Failed to save profile: $e', _currentProfile));
      emit(ProfileLoaded(profile: _currentProfile));
    }
  }
}
