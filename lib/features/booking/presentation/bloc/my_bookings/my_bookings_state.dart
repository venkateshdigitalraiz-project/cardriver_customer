import 'package:cardriver_customer/features/booking/domain/entities/booking_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MyBookingsState extends Equatable {
  const MyBookingsState();

  @override
  List<Object?> get props => [];
}

class MyBookingsInitial extends MyBookingsState {}

class MyBookingsLoading extends MyBookingsState {}

class MyBookingsLoaded extends MyBookingsState {
  final List<BookingEntity> bookings;

  const MyBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class MyBookingsError extends MyBookingsState {
  final String message;

  const MyBookingsError(this.message);

  @override
  List<Object?> get props => [message];
}
