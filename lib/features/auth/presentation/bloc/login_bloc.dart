import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LoginWithPhoneUseCase loginWithPhoneUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  LoginBloc({
    required this.loginWithEmailUseCase,
    required this.loginWithPhoneUseCase,
    required this.verifyOtpUseCase,
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
    emit(state.copyWith(status: LoginStatus.initial, clearError: true, isOtpSent: false));
  }

  Future<void> _onSendOtpRequested(SendOtpRequested event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading, clearError: true));
    
    try {
      if (state.mode == LoginMode.phone) {
        // We use the full phone number (dial code + phone) if needed, but here event.contact has it.
        await loginWithPhoneUseCase(phone: event.contact);
        
        emit(state.copyWith(
          status: LoginStatus.initial, // Show OTP field
          isOtpSent: true,
        ));
      } else {
        // email flow if any
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(
          status: LoginStatus.initial,
          isOtpSent: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onVerifyOtpSubmitted(VerifyOtpSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading, clearError: true));

    try {
      await verifyOtpUseCase(phone: event.contact, otp: event.otp);
      
      emit(state.copyWith(
        status: LoginStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
