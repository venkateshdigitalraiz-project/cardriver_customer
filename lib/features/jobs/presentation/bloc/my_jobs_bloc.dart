import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_jobs_usecase.dart';
import '../../domain/usecases/delete_job_usecase.dart';
import 'my_jobs_event.dart';
import 'my_jobs_state.dart';

class MyJobsBloc extends Bloc<MyJobsEvent, MyJobsState> {
  final GetMyJobsUseCase getMyJobsUseCase;
  final DeleteJobUseCase deleteJobUseCase;

  MyJobsBloc({
    required this.getMyJobsUseCase,
    required this.deleteJobUseCase,
  }) : super(const MyJobsState()) {
    on<LoadMyJobsEvent>(_onLoadMyJobs);
    on<SearchMyJobsEvent>(_onSearchMyJobs);
    on<FilterMyJobsByStatusEvent>(_onFilterMyJobsByStatus);
    on<DeleteMyJobEvent>(_onDeleteMyJob);
  }

  Future<void> _onLoadMyJobs(
    LoadMyJobsEvent event,
    Emitter<MyJobsState> emit,
  ) async {
    if (event.refresh) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else {
      emit(state.copyWith(status: MyJobsStatus.loading, clearError: true));
    }

    try {
      final response = await getMyJobsUseCase(
        page: event.page,
        limit: event.limit,
        search: state.searchQuery,
        status: state.selectedStatus,
      );

      emit(state.copyWith(
        status: MyJobsStatus.loaded,
        jobs: response.jobs,
        total: response.total,
        page: response.page,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MyJobsStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isRefreshing: false,
      ));
    }
  }

  Future<void> _onSearchMyJobs(
    SearchMyJobsEvent event,
    Emitter<MyJobsState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));

    try {
      final response = await getMyJobsUseCase(
        page: 1,
        limit: 10,
        search: event.query,
        status: state.selectedStatus,
      );

      emit(state.copyWith(
        jobs: response.jobs,
        total: response.total,
        page: response.page,
      ));
    } catch (e) {
      debugPrint('⚠️ [MyJobsBloc] Error searching jobs from API: $e');
    }
  }

  Future<void> _onFilterMyJobsByStatus(
    FilterMyJobsByStatusEvent event,
    Emitter<MyJobsState> emit,
  ) async {
    emit(state.copyWith(selectedStatus: event.status));

    try {
      final response = await getMyJobsUseCase(
        page: 1,
        limit: 10,
        search: state.searchQuery,
        status: event.status,
      );

      emit(state.copyWith(
        jobs: response.jobs,
        total: response.total,
        page: response.page,
      ));
    } catch (e) {
      debugPrint('⚠️ [MyJobsBloc] Error filtering jobs from API: $e');
    }
  }

  Future<void> _onDeleteMyJob(
    DeleteMyJobEvent event,
    Emitter<MyJobsState> emit,
  ) async {
    emit(state.copyWith(
      deletingJobId: event.jobId,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final success = await deleteJobUseCase(event.jobId);
      if (success) {
        final updatedJobs = state.jobs
            .where((j) => j.jobId != event.jobId && j.id != event.jobId)
            .toList();
        final newTotal = (state.total - 1).clamp(0, 999999);
        emit(state.copyWith(
          jobs: updatedJobs,
          total: newTotal,
          clearDeleting: true,
          successMessage: 'Job post deleted successfully',
        ));
      } else {
        emit(state.copyWith(
          clearDeleting: true,
          errorMessage: 'Failed to delete job post. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        clearDeleting: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}


