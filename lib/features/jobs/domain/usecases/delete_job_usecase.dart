import '../repositories/jobs_repository.dart';

class DeleteJobUseCase {
  final JobsRepository repository;

  DeleteJobUseCase(this.repository);

  Future<bool> call(String jobId) async {
    return await repository.deleteJob(jobId);
  }
}

