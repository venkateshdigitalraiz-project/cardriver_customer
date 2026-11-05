import 'package:equatable/equatable.dart';
import '../../domain/entities/user_job_entity.dart';

enum JobDetailsStatus { initial, loading, loaded, failure, deleted }

class JobDetailsState extends Equatable {
  final JobDetailsStatus status;
  final UserJobEntity? job;
  final String? errorMessage;
  final bool isRefreshing;
  final bool isDeleting;

  const JobDetailsState({
    this.status = JobDetailsStatus.initial,
    this.job,
    this.errorMessage,
    this.isRefreshing = false,
    this.isDeleting = false,
  });

  bool get isLoading => status == JobDetailsStatus.loading && !isRefreshing;
  bool get isLoaded => status == JobDetailsStatus.loaded;
  bool get isFailure => status == JobDetailsStatus.failure;
  bool get isDeleted => status == JobDetailsStatus.deleted;

  JobDetailsState copyWith({
    JobDetailsStatus? status,
    UserJobEntity? job,
    String? errorMessage,
    bool? isRefreshing,
    bool? isDeleting,
    bool clearError = false,
  }) {
    return JobDetailsState(
      status: status ?? this.status,
      job: job ?? this.job,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
        status,
        job,
        errorMessage,
        isRefreshing,
        isDeleting,
      ];
}

