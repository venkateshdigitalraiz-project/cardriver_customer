import '../entities/driver_user.dart';

/// Authentication repository contract in Domain layer for Customer App.
abstract class AuthRepository {
  Future<CustomerUser> loginWithEmail({
    required String email,
    required String password,
  });

  Future<CustomerUser> loginWithPhone({
    required String phone,
    required String password,
  });

  Future<void> sendOtp({required String phone});

  Future<CustomerUser> verifyOtp({
    required String phone,
    required String otp,
  });
}
