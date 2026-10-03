import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfileUseCase {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<ProfileEntity> call(ProfileEntity profile) async {
    return await repository.updateUserProfile(profile);
  }
}
