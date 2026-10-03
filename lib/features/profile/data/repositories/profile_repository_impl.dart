import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity> getUserProfile() async {
    return await remoteDataSource.getUserProfile();
  }

  @override
  Future<ProfileEntity> updateUserProfile(ProfileEntity profile) async {
    final profileModel = ProfileModel(
      imagePath: profile.imagePath,
      fullName: profile.fullName,
      lastName: profile.lastName,
      mobileNumber: profile.mobileNumber,
      email: profile.email,
      address: profile.address,
      carType: profile.carType,
      carName: profile.carName,
      registrationNumber: profile.registrationNumber,
      vehicleColor: profile.vehicleColor,
    );
    return await remoteDataSource.updateUserProfile(profileModel);
  }
}
