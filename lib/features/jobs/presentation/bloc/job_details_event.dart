import 'package:equatable/equatable.dart';

abstract class JobDetailsEvent extends Equatable {
  const JobDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobDetailsEvent extends JobDetailsEvent {
  final String jobId;
  final bool refresh;

  const LoadJobDetailsEvent({required this.jobId, this.refresh = false});

  @override
  List<Object?> get props => [jobId, refresh];
}

class DeleteJobDetailsEvent extends JobDetailsEvent {
  final String jobId;

  const DeleteJobDetailsEvent(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

