import 'package:equatable/equatable.dart';

enum RatingSubmissionStatus { initial, loading, success, failure }

class RatingState extends Equatable {
  final double rating;
  final List<String> selectedTags;
  final String comment;
  final double tipAmount;
  final RatingSubmissionStatus status;
  final String? errorMessage;

  const RatingState({
    this.rating = 5.0,
    this.selectedTags = const [],
    this.comment = '',
    this.tipAmount = 0.0,
    this.status = RatingSubmissionStatus.initial,
    this.errorMessage,
  });

  RatingState copyWith({
    double? rating,
    List<String>? selectedTags,
    String? comment,
    double? tipAmount,
    RatingSubmissionStatus? status,
    String? errorMessage,
  }) {
    return RatingState(
      rating: rating ?? this.rating,
      selectedTags: selectedTags ?? this.selectedTags,
      comment: comment ?? this.comment,
      tipAmount: tipAmount ?? this.tipAmount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        rating,
        selectedTags,
        comment,
        tipAmount,
        status,
        errorMessage,
      ];
}

