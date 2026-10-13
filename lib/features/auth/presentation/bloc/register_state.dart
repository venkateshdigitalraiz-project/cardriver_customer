import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? errorMessage;
  final String? successMessage;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}
