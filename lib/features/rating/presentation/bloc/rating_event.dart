import 'package:equatable/equatable.dart';

abstract class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object?> get props => [];
}

class ChangeRatingScoreEvent extends RatingEvent {
  final double rating;
  const ChangeRatingScoreEvent(this.rating);

  @override
  List<Object?> get props => [rating];
}

class ToggleRatingTagEvent extends RatingEvent {
  final String tag;
  const ToggleRatingTagEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}

class ChangeCommentEvent extends RatingEvent {
  final String comment;
  const ChangeCommentEvent(this.comment);

  @override
  List<Object?> get props => [comment];
}

class SelectTipAmountEvent extends RatingEvent {
  final double tipAmount;
  const SelectTipAmountEvent(this.tipAmount);

  @override
  List<Object?> get props => [tipAmount];
}

class SubmitRatingEvent extends RatingEvent {
  final String bookingId;
  final String? driverId;
  final String? driverName;

  const SubmitRatingEvent({
    required this.bookingId,
    this.driverId,
    this.driverName,
  });

  @override
  List<Object?> get props => [bookingId, driverId, driverName];
}

