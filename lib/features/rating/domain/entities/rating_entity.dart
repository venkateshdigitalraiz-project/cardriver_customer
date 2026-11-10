import 'package:equatable/equatable.dart';

/// Clean Architecture Entity representing a rating submission from Customer to Driver
class RatingEntity extends Equatable {
  final String bookingId;
  final num rating;
  final String comment;
  final List<String> tags;
  final double tipAmount;
  final String? driverId;
  final String? driverName;

  const RatingEntity({
    required this.bookingId,
    required this.rating,
    this.comment = '',
    this.tags = const [],
    this.tipAmount = 0.0,
    this.driverId,
    this.driverName,
  });

  @override
  List<Object?> get props => [
        bookingId,
        rating,
        comment,
        tags,
        tipAmount,
        driverId,
        driverName,
      ];
}
