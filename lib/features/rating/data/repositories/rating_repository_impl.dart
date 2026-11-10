import '../../../../core/error/failures.dart';
import '../../domain/entities/rating_entity.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/rating_remote_datasource.dart';
import '../models/rating_model.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource remoteDataSource;

  RatingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> submitRating(RatingEntity rating) async {
    try {
      final model = RatingModel.fromEntity(rating);
      return await remoteDataSource.submitRating(model);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
