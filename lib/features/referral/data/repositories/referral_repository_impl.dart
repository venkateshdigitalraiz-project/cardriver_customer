import '../../domain/entities/referral_entity.dart';
import '../../domain/repositories/referral_repository.dart';
import '../datasources/referral_remote_datasource.dart';

class ReferralRepositoryImpl implements ReferralRepository {
  final ReferralRemoteDataSource remoteDataSource;

  ReferralRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ReferralEntity> getReferralInfo() async {
    return await remoteDataSource.getReferralInfo();
  }
}

