import '../../domain/entities/create_job_request_entity.dart';
import '../../domain/entities/job_post_response_entity.dart';
import '../../domain/entities/user_job_entity.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../datasources/jobs_remote_datasource.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource remoteDataSource;

  JobsRepositoryImpl({JobsRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? JobsRemoteDataSourceImpl();

  @override
  Future<JobPostResponseEntity> postJob(CreateJobRequestEntity request) async {
    return await remoteDataSource.postJob(request);
  }

  @override
  Future<UserJobListResponseEntity> getMyJobs({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    return await remoteDataSource.getMyJobs(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
  }

  @override
  Future<bool> deleteJob(String jobId) async {
    return await remoteDataSource.deleteJob(jobId);
  }

  @override
  Future<UserJobEntity> getJobDetails(String jobId) async {
    return await remoteDataSource.getJobDetails(jobId);
  }
}


