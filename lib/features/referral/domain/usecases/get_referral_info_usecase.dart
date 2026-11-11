import '../entities/referral_entity.dart';
import '../repositories/referral_repository.dart';

class GetReferralInfoUseCase {
  final ReferralRepository repository;

  GetReferralInfoUseCase(this.repository);

  Future<ReferralEntity> call() async {
    return await repository.getReferralInfo();
  }
}

