import 'package:equatable/equatable.dart';

enum LoginMode { phone, email }

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginModeChanged extends LoginEvent {
  final LoginMode mode;
  const LoginModeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}

class TogglePasswordVisibility extends LoginEvent {
  const TogglePasswordVisibility();
}

class ToggleRememberMe extends LoginEvent {
  const ToggleRememberMe();
}

class CountryCodeChanged extends LoginEvent {
  final String dialCode;
  final String flag;

  const CountryCodeChanged({required this.dialCode, required this.flag});

  @override
  List<Object?> get props => [dialCode, flag];
}

class SendOtpRequested extends LoginEvent {
  final String contact; // email or phone
  
  const SendOtpRequested({required this.contact});

  @override
  List<Object?> get props => [contact];
}

class VerifyOtpSubmitted extends LoginEvent {
  final String contact;
  final String otp;

  const VerifyOtpSubmitted({required this.contact, required this.otp});

  @override
  List<Object?> get props => [contact, otp];
}

class ResetLoginState extends LoginEvent {
  const ResetLoginState();
}
