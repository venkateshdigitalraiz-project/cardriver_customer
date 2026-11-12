import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cache/charges_cache.dart';
import '../../../booking/domain/usecases/get_charges_usecase.dart';
import '../../domain/usecases/post_user_job_usecase.dart';
import 'post_job_event.dart';
import 'post_job_state.dart';

class PostJobBloc extends Bloc<PostJobEvent, PostJobState> {
  final PostUserJobUseCase postUserJobUseCase;
  final GetChargesUseCase? getChargesUseCase;

  PostJobBloc({required this.postUserJobUseCase, this.getChargesUseCase})
    : super(
        PostJobState(
          permanentJobs:
              ChargesCache.instance.charges?.permanentJobs ?? const [],
        ),
      ) {
    on<LoadJobChargesEvent>(_onLoadJobCharges);
    on<SubmitJobPostEvent>(_onSubmitJobPost);
    on<ResetJobPostEvent>(_onResetJobPost);
  }

  Future<void> _onLoadJobCharges(
    LoadJobChargesEvent event,
    Emitter<PostJobState> emit,
  ) async {
    if (getChargesUseCase == null) return;
    emit(state.copyWith(isLoadingCharges: true));
    try {
      final charges = await getChargesUseCase!();
      emit(
        state.copyWith(
          isLoadingCharges: false,
          permanentJobs: charges.permanentJobs,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingCharges: false, permanentJobs: const []));
    }
  }

  Future<void> _onSubmitJobPost(
    SubmitJobPostEvent event,
    Emitter<PostJobState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PostJobStatus.loading,
        clearError: true,
        clearResponse: true,
      ),
    );

    try {
      final response = await postUserJobUseCase(event.request);
      if (response.success) {
        emit(state.copyWith(status: PostJobStatus.success, response: response));
      } else {
        emit(
          state.copyWith(
            status: PostJobStatus.failure,
            errorMessage: response.message.isNotEmpty
                ? response.message
                : 'Failed to post job. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PostJobStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onResetJobPost(ResetJobPostEvent event, Emitter<PostJobState> emit) {
    emit(const PostJobState());
  }
}
