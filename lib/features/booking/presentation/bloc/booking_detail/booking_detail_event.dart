import 'package:equatable/equatable.dart';

abstract class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchBookingDetail extends BookingDetailEvent {
  final String bookingId;

  const FetchBookingDetail(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class RefreshBookingDetail extends BookingDetailEvent {
  final String bookingId;

  const RefreshBookingDetail(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
