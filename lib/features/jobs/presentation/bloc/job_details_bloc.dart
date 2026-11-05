import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_job_entity.dart';
import '../../domain/usecases/delete_job_usecase.dart';
import '../../domain/usecases/get_job_details_usecase.dart';
import 'job_details_event.dart';
import 'job_details_state.dart';

class JobDetailsBloc extends Bloc<JobDetailsEvent, JobDetailsState> {
  final GetJobDetailsUseCase getJobDetailsUseCase;
  final DeleteJobUseCase deleteJobUseCase;

  JobDetailsBloc({
    required this.getJobDetailsUseCase,
    required this.deleteJobUseCase,
    UserJobEntity? initialJob,
  }) : super(JobDetailsState(
          job: initialJob,
          status: initialJob != null ? JobDetailsStatus.loaded : JobDetailsStatus.initial,
        )) {
    on<LoadJobDetailsEvent>(_onLoadJobDetails);
    on<DeleteJobDetailsEvent>(_onDeleteJobDetails);
  }

  Future<void> _onLoadJobDetails(
    LoadJobDetailsEvent event,
    Emitter<JobDetailsState> emit,
  ) async {
    if (event.refresh) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else {
      if (state.job == null) {
        emit(state.copyWith(status: JobDetailsStatus.loading, clearError: true));
      }
    }

    try {
      final job = await getJobDetailsUseCase(event.jobId);
      emit(state.copyWith(
        status: JobDetailsStatus.loaded,
        job: job,
        isRefreshing: false,
      ));
    } catch (e) {
      if (state.job == null) {
        emit(state.copyWith(
          status: JobDetailsStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isRefreshing: false,
        ));
      } else {
        emit(state.copyWith(isRefreshing: false));
      }
    }
  }

  Future<void> _onDeleteJobDetails(
    DeleteJobDetailsEvent event,
    Emitter<JobDetailsState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, clearError: true));

    try {
      final success = await deleteJobUseCase(event.jobId);
      if (success) {
        emit(state.copyWith(
          status: JobDetailsStatus.deleted,
          isDeleting: false,
        ));
      } else {
        emit(state.copyWith(
          isDeleting: false,
          errorMessage: 'Failed to delete job post. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

