import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/post_user_job_usecase.dart';
import 'post_job_event.dart';
import 'post_job_state.dart';

class PostJobBloc extends Bloc<PostJobEvent, PostJobState> {
  final PostUserJobUseCase postUserJobUseCase;

  PostJobBloc({required this.postUserJobUseCase})
      : super(const PostJobState()) {
    on<SubmitJobPostEvent>(_onSubmitJobPost);
    on<ResetJobPostEvent>(_onResetJobPost);
  }

  Future<void> _onSubmitJobPost(
    SubmitJobPostEvent event,
    Emitter<PostJobState> emit,
  ) async {
    emit(state.copyWith(
      status: PostJobStatus.loading,
      clearError: true,
      clearResponse: true,
    ));

    try {
      final response = await postUserJobUseCase(event.request);
      if (response.success) {
        emit(state.copyWith(
          status: PostJobStatus.success,
          response: response,
        ));
      } else {
        emit(state.copyWith(
          status: PostJobStatus.failure,
          errorMessage: response.message.isNotEmpty
              ? response.message
              : 'Failed to post job. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PostJobStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onResetJobPost(
    ResetJobPostEvent event,
    Emitter<PostJobState> emit,
  ) {
    emit(const PostJobState());
  }
}

