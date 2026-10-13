// ignore_for_file: avoid_print
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/register_usecase.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterBloc({required this.registerUseCase}) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<ResetRegisterState>(_onResetRegisterState);
  }

  void _onResetRegisterState(ResetRegisterState event, Emitter<RegisterState> emit) {
    emit(const RegisterState());
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    print('🔄 [REGISTER BLOC] Received RegisterSubmitted event: firstName="${event.firstName}", lastName="${event.lastName}", email="${event.email}", phone="${event.phone}", address="${event.address}"');
    emit(state.copyWith(status: RegisterStatus.loading, clearError: true));

    try {
      await registerUseCase(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        address: event.address,
      );

      print('🎉 [REGISTER BLOC] Registration succeeded! Emitting RegisterStatus.success');
      emit(state.copyWith(
        status: RegisterStatus.success,
        successMessage: 'Registration successful! Please sign in with your mobile number.',
      ));
    } on AuthFailure catch (e) {
      print('❌ [REGISTER BLOC] AuthFailure: ${e.message}');
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      print('❌ [REGISTER BLOC] Unexpected error: $e');
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'An unexpected error occurred during registration. Please try again.',
      ));
    }
  }
}
