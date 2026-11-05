import '../entities/user_job_entity.dart';
import '../repositories/jobs_repository.dart';

class GetJobDetailsUseCase {
  final JobsRepository repository;

  GetJobDetailsUseCase(this.repository);

  Future<UserJobEntity> call(String jobId) async {
    return await repository.getJobDetails(jobId);
  }
}

