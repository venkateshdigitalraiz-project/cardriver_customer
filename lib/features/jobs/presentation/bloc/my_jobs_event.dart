import 'package:equatable/equatable.dart';

abstract class MyJobsEvent extends Equatable {
  const MyJobsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyJobsEvent extends MyJobsEvent {
  final bool refresh;
  final int page;
  final int limit;

  const LoadMyJobsEvent({
    this.refresh = false,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [refresh, page, limit];
}

class FilterMyJobsByStatusEvent extends MyJobsEvent {
  final String status;

  const FilterMyJobsByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchMyJobsEvent extends MyJobsEvent {
  final String query;

  const SearchMyJobsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteMyJobEvent extends MyJobsEvent {
  final String jobId;

  const DeleteMyJobEvent(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

