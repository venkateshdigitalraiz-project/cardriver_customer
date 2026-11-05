import 'package:equatable/equatable.dart';
import '../../domain/entities/user_job_entity.dart';

enum MyJobsStatus { initial, loading, loaded, failure }

class MyJobsState extends Equatable {
  final MyJobsStatus status;
  final List<UserJobEntity> jobs;
  final String selectedStatus; // 'all', 'active', 'pending', 'closed'
  final String searchQuery;
  final int total;
  final int page;
  final String? errorMessage;
  final String? successMessage;
  final String? deletingJobId;
  final bool isRefreshing;

  const MyJobsState({
    this.status = MyJobsStatus.initial,
    this.jobs = const [],
    this.selectedStatus = 'all',
    this.searchQuery = '',
    this.total = 0,
    this.page = 1,
    this.errorMessage,
    this.successMessage,
    this.deletingJobId,
    this.isRefreshing = false,
  });

  bool get isLoading => status == MyJobsStatus.loading && !isRefreshing;
  bool get isLoaded => status == MyJobsStatus.loaded;
  bool get isFailure => status == MyJobsStatus.failure;

  List<UserJobEntity> get filteredJobs {
    var list = jobs;
    if (selectedStatus != 'all') {
      list = list.where((job) {
        return job.status.toLowerCase() == selectedStatus.toLowerCase();
      }).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((job) {
        final title = job.title.toLowerCase();
        final loc = job.location.toLowerCase();
        final jId = job.jobId.toLowerCase();
        final desc = job.description.toLowerCase();
        return title.contains(q) ||
            loc.contains(q) ||
            jId.contains(q) ||
            desc.contains(q);
      }).toList();
    }
    return list;
  }

  int get activeJobsCount {
    return jobs
        .where((j) =>
            j.status.toLowerCase() == 'active' ||
            j.status.toLowerCase() == 'open')
        .length;
  }

  bool isJobDeleting(String jobId) => deletingJobId == jobId;

  MyJobsState copyWith({
    MyJobsStatus? status,
    List<UserJobEntity>? jobs,
    String? selectedStatus,
    String? searchQuery,
    int? total,
    int? page,
    String? errorMessage,
    String? successMessage,
    String? deletingJobId,
    bool? isRefreshing,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearDeleting = false,
  }) {
    return MyJobsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      total: total ?? this.total,
      page: page ?? this.page,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      deletingJobId: clearDeleting ? null : (deletingJobId ?? this.deletingJobId),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        jobs,
        selectedStatus,
        searchQuery,
        total,
        page,
        errorMessage,
        successMessage,
        deletingJobId,
        isRefreshing,
      ];
}

