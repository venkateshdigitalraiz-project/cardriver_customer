import 'package:equatable/equatable.dart';

/// Base Failure definition for Clean Architecture domain layer.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed. Please check your internet.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
