import '../entities/create_job_request_entity.dart';
import '../entities/job_post_response_entity.dart';
import '../entities/user_job_entity.dart';

abstract class JobsRepository {
  Future<JobPostResponseEntity> postJob(CreateJobRequestEntity request);
  Future<UserJobListResponseEntity> getMyJobs({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  });
  Future<bool> deleteJob(String jobId);
  Future<UserJobEntity> getJobDetails(String jobId);
}

