import 'package:equatable/equatable.dart';
import '../../domain/entities/job_post_response_entity.dart';
import '../../../booking/domain/entities/charges_entity.dart';

enum PostJobStatus { initial, loading, success, failure }

class PostJobState extends Equatable {
  final PostJobStatus status;
  final String? errorMessage;
  final JobPostResponseEntity? response;
  final List<PermanentJobChargeEntity> permanentJobs;
  final bool isLoadingCharges;

  const PostJobState({
    this.status = PostJobStatus.initial,
    this.errorMessage,
    this.response,
    this.permanentJobs = const [],
    this.isLoadingCharges = false,
  });

  bool get isLoading => status == PostJobStatus.loading;
  bool get isSuccess => status == PostJobStatus.success;
  bool get isFailure => status == PostJobStatus.failure;

  PostJobState copyWith({
    PostJobStatus? status,
    String? errorMessage,
    JobPostResponseEntity? response,
    List<PermanentJobChargeEntity>? permanentJobs,
    bool? isLoadingCharges,
    bool clearError = false,
    bool clearResponse = false,
  }) {
    return PostJobState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      response: clearResponse ? null : (response ?? this.response),
      permanentJobs: permanentJobs ?? this.permanentJobs,
      isLoadingCharges: isLoadingCharges ?? this.isLoadingCharges,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        response,
        permanentJobs,
        isLoadingCharges,
      ];
}

