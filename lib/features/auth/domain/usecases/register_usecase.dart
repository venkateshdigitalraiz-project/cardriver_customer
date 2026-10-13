import '../repositories/auth_repository.dart';

/// Customer registration use case.
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<void> call({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
  }) async {
    return await repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
    );
  }
}
