import '../entities/create_job_request_entity.dart';
import '../entities/job_post_response_entity.dart';
import '../repositories/jobs_repository.dart';

class PostUserJobUseCase {
  final JobsRepository repository;

  PostUserJobUseCase(this.repository);

  Future<JobPostResponseEntity> call(CreateJobRequestEntity request) async {
    return await repository.postJob(request);
  }
}

