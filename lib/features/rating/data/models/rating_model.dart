import '../../domain/entities/rating_entity.dart';

class RatingModel extends RatingEntity {
  const RatingModel({
    required super.bookingId,
    required super.rating,
    super.tags = const [],
    super.comment = '',
    super.tipAmount = 0.0,
    super.driverId,
    super.driverName,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'rating': rating,
      'tags': tags,
      'feedback': comment,
      'review': comment,
      'comment': comment,
      if (tipAmount > 0) 'tipAmount': tipAmount,
      if (driverId != null && driverId!.isNotEmpty) 'driverId': driverId,
    };
  }

  factory RatingModel.fromEntity(RatingEntity entity) {
    return RatingModel(
      bookingId: entity.bookingId,
      rating: entity.rating,
      tags: entity.tags,
      comment: entity.comment,
      tipAmount: entity.tipAmount,
      driverId: entity.driverId,
      driverName: entity.driverName,
    );
  }
}

