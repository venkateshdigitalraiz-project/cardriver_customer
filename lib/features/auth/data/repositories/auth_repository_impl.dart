import '../../domain/entities/driver_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CustomerUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.loginWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<CustomerUser> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    return await remoteDataSource.loginWithPhone(
      phone: phone,
      password: password,
    );
  }

  @override
  Future<void> sendOtp({required String phone}) async {
    return await remoteDataSource.sendOtp(phone: phone);
  }

  @override
  Future<CustomerUser> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return await remoteDataSource.verifyOtp(phone: phone, otp: otp);
  }
}
