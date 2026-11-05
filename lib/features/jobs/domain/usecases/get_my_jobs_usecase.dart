import '../entities/user_job_entity.dart';
import '../repositories/jobs_repository.dart';

class GetMyJobsUseCase {
  final JobsRepository repository;

  GetMyJobsUseCase(this.repository);

  Future<UserJobListResponseEntity> call({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    return await repository.getMyJobs(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
  }
}

