import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/add_valet_event_booking_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AddValetEventBookingUseCase addValetEventBookingUseCase;

  HomeBloc({
    AddValetEventBookingUseCase? addValetEventBookingUseCase,
  })  : addValetEventBookingUseCase = addValetEventBookingUseCase ??
            AddValetEventBookingUseCase(
              HomeRepositoryImpl(
                remoteDataSource: HomeRemoteDataSourceImpl(),
              ),
            ),
        super(const HomeInitial(currentBannerIndex: 0)) {
    on<BannerPageChanged>((event, emit) {
      emit(state.copyWith(currentBannerIndex: event.index));
    });

    on<SubmitValetEventBooking>(_onSubmitValetEventBooking);
    on<ResetValetBookingSubmission>(_onResetValetBookingSubmission);
  }

  Future<void> _onSubmitValetEventBooking(
    SubmitValetEventBooking event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isSubmittingValet: true,
      valetSubmitSuccess: false,
      clearError: true,
    ));

    try {
      final result = await addValetEventBookingUseCase(event.booking);
      emit(state.copyWith(
        isSubmittingValet: false,
        valetSubmitSuccess: true,
        valetBookingResponse: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmittingValet: false,
        valetSubmitSuccess: false,
        valetErrorMessage: e.toString(),
      ));
    }
  }

  void _onResetValetBookingSubmission(
    ResetValetBookingSubmission event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(
      valetSubmitSuccess: false,
      clearError: true,
      clearResponse: true,
    ));
  }
}
