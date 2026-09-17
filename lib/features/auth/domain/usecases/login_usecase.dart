import '../entities/driver_user.dart';
import '../repositories/auth_repository.dart';

/// Customer login use cases.
class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<CustomerUser> call({
    required String email,
    required String password,
  }) async {
    return await repository.loginWithEmail(
      email: email,
      password: password,
    );
  }
}

class LoginWithPhoneUseCase {
  final AuthRepository repository;

  LoginWithPhoneUseCase(this.repository);

  Future<CustomerUser> call({
    required String phone,
    required String password,
  }) async {
    return await repository.loginWithPhone(
      phone: phone,
      password: password,
    );
  }
}
