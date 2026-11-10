import '../entities/rating_entity.dart';
import '../repositories/rating_repository.dart';

class SubmitRatingUseCase {
  final RatingRepository repository;

  SubmitRatingUseCase(this.repository);

  Future<bool> call(RatingEntity rating) async {
    return await repository.submitRating(rating);
  }

  Future<bool> execute({required RatingEntity rating}) async {
    return await repository.submitRating(rating);
  }
}
