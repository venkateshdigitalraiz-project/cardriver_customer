import '../entities/home_data.dart';
import '../repositories/home_repository.dart';

/// Use case to fetch home page banners (hero and middle/suggestions) from /api/user/home.
class GetHomeDataUseCase {
  final HomeRepository repository;

  const GetHomeDataUseCase(this.repository);

  Future<HomeData> call() async {
    return await repository.getHomeData();
  }
}
