import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_user.dart';
import 'login_event.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final LoginMode mode;
  final bool obscurePassword;
  final bool rememberMe;
  final String dialCode;
  final String flag;
  final CustomerUser? user;
  final String? errorMessage;
  final bool isOtpSent;

  const LoginState({
    this.status = LoginStatus.initial,
    this.mode = LoginMode.phone,
    this.obscurePassword = true,
    this.rememberMe = true,
    this.dialCode = '+1',
    this.flag = '🇺🇸',
    this.user,
    this.errorMessage,
    this.isOtpSent = false,
  });

  LoginState copyWith({
    LoginStatus? status,
    LoginMode? mode,
    bool? obscurePassword,
    bool? rememberMe,
    String? dialCode,
    String? flag,
    CustomerUser? user,
    String? errorMessage,
    bool clearError = false,
    bool? isOtpSent,
  }) {
    return LoginState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      dialCode: dialCode ?? this.dialCode,
      flag: flag ?? this.flag,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOtpSent: isOtpSent ?? this.isOtpSent,
    );
  }

  @override
  List<Object?> get props => [
        status,
        mode,
        obscurePassword,
        rememberMe,
        dialCode,
        flag,
        user,
        errorMessage,
        isOtpSent,
      ];
}
