import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LoginWithPhoneUseCase loginWithPhoneUseCase;

  LoginBloc({
    required this.loginWithEmailUseCase,
    required this.loginWithPhoneUseCase,
  }) : super(const LoginState()) {
    on<LoginModeChanged>(_onLoginModeChanged);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ToggleRememberMe>(_onToggleRememberMe);
    on<CountryCodeChanged>(_onCountryCodeChanged);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<ResetLoginState>(_onResetLoginState);
  }

  void _onLoginModeChanged(LoginModeChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      mode: event.mode,
      status: LoginStatus.initial,
      clearError: true,
    ));
  }

  void _onTogglePasswordVisibility(TogglePasswordVisibility event, Emitter<LoginState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onToggleRememberMe(ToggleRememberMe event, Emitter<LoginState> emit) {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  void _onCountryCodeChanged(CountryCodeChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(dialCode: event.dialCode, flag: event.flag));
  }

  void _onResetLoginState(ResetLoginState event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: LoginStatus.initial, clearError: true));
  }

  Future<void> _onSendOtpRequested(SendOtpRequested event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading, clearError: true));
    
    try {
      // Simulate API call to send OTP
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(
        status: LoginStatus.initial, // Reset status so form is usable again
        isOtpSent: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Failed to send OTP. Please try again.',
      ));
    }
  }

  Future<void> _onVerifyOtpSubmitted(VerifyOtpSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading, clearError: true));

    try {
      // For now, mock the use case or bypass it since we don't have an OTP use case defined yet
      // Simulate verification delay
      await Future.delayed(const Duration(seconds: 1));
      
      if (event.otp == '1234') {
        // Mock successful login
        emit(state.copyWith(
          status: LoginStatus.success,
          // user: mockUser,
        ));
      } else {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Invalid OTP. Please enter 1234.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }
}
