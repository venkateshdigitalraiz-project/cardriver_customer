import 'package:equatable/equatable.dart';
import '../../domain/entities/job_post_response_entity.dart';

enum PostJobStatus { initial, loading, success, failure }

class PostJobState extends Equatable {
  final PostJobStatus status;
  final String? errorMessage;
  final JobPostResponseEntity? response;

  const PostJobState({
    this.status = PostJobStatus.initial,
    this.errorMessage,
    this.response,
  });

  bool get isLoading => status == PostJobStatus.loading;
  bool get isSuccess => status == PostJobStatus.success;
  bool get isFailure => status == PostJobStatus.failure;

  PostJobState copyWith({
    PostJobStatus? status,
    String? errorMessage,
    JobPostResponseEntity? response,
    bool clearError = false,
    bool clearResponse = false,
  }) {
    return PostJobState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      response: clearResponse ? null : (response ?? this.response),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, response];
}

