import 'package:equatable/equatable.dart';
import '../../domain/entities/create_job_request_entity.dart';

abstract class PostJobEvent extends Equatable {
  const PostJobEvent();

  @override
  List<Object?> get props => [];
}

class SubmitJobPostEvent extends PostJobEvent {
  final CreateJobRequestEntity request;

  const SubmitJobPostEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ResetJobPostEvent extends PostJobEvent {
  const ResetJobPostEvent();
}

