import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getUserProfile();
  Future<ProfileEntity> updateUserProfile(ProfileEntity profile);
}
