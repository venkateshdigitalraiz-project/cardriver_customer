import '../entities/driver_job_item.dart';
import '../entities/driver_job_response.dart';
import '../repositories/home_repository.dart';

class PostDriverJobUseCase {
  final HomeRepository repository;

  PostDriverJobUseCase(this.repository);

  Future<DriverJobResponse> call(DriverJobItem job) async {
    return await repository.postDriverJob(job);
  }
}

