import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
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
    } on AuthFailure catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      String msg = 'An unexpected error occurred';
      try {
        final dynamic dyn = e;
        if (dyn.message != null && dyn.message.toString().trim().isNotEmpty) {
          msg = dyn.message.toString().trim();
        } else {
          final s = e.toString().trim();
          if (s.contains('AuthFailure')) {
            msg = 'User not registered';
          } else {
            msg = s.replaceFirst('Exception: ', '');
          }
        }
      } catch (_) {
        final s = e.toString().trim();
        if (s.contains('AuthFailure')) {
          msg = 'User not registered';
        } else {
          msg = s.replaceFirst('Exception: ', '');
        }
      }

      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: msg,
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
    } on AuthFailure catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      String msg = 'An unexpected error occurred';
      try {
        final dynamic dyn = e;
        if (dyn.message != null && dyn.message.toString().trim().isNotEmpty) {
          msg = dyn.message.toString().trim();
        } else {
          final s = e.toString().trim();
          if (s.contains('AuthFailure')) {
            msg = 'User not registered';
          } else {
            msg = s.replaceFirst('Exception: ', '');
          }
        }
      } catch (_) {
        final s = e.toString().trim();
        if (s.contains('AuthFailure')) {
          msg = 'User not registered';
        } else {
          msg = s.replaceFirst('Exception: ', '');
        }
      }

      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: msg,
      ));
    }
  }
}
