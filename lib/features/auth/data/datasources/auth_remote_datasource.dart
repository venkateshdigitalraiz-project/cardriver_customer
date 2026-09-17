import '../models/driver_user_model.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRemoteDataSource {
  Future<CustomerUserModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<CustomerUserModel> loginWithPhone({
    required String phone,
    required String password,
  });

  Future<void> sendOtp({required String phone});

  Future<CustomerUserModel> verifyOtp({
    required String phone,
    required String otp,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<CustomerUserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (password.length < 6) {
      throw const AuthFailure('Password must be at least 6 characters');
    }

    return CustomerUserModel(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      name: 'David Sterling',
      email: email,
      phone: '+1 (555) 839-2019',
      memberTier: 'Elite Gold Customer',
      totalRidesTaken: 28,
      savedCarsCount: 2,
    );
  }

  @override
  Future<CustomerUserModel> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (password.length < 6) {
      throw const AuthFailure('Invalid credentials. Password too short.');
    }

    return CustomerUserModel(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      name: 'David Sterling',
      email: 'david.sterling@example.com',
      phone: phone,
      memberTier: 'Elite Gold Customer',
      totalRidesTaken: 28,
      savedCarsCount: 2,
    );
  }

  @override
  Future<void> sendOtp({required String phone}) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<CustomerUserModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (otp != '1234' && otp != '123456') {
      throw const AuthFailure('Invalid OTP entered. Try 1234');
    }
    return CustomerUserModel(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      name: 'David Sterling',
      email: 'david.sterling@example.com',
      phone: phone,
      memberTier: 'Elite Gold Customer',
      totalRidesTaken: 28,
      savedCarsCount: 2,
    );
  }
}
