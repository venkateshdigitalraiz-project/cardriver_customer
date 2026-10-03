import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<ProfileEntity> call() async {
    return await repository.getUserProfile();
  }
}
