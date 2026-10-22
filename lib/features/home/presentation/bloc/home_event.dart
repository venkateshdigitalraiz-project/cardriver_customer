import '../../domain/entities/valet_event_booking_item.dart';

abstract class HomeEvent {}

class BannerPageChanged extends HomeEvent {
  final int index;
  BannerPageChanged(this.index);
}

class SubmitValetEventBooking extends HomeEvent {
  final ValetEventBookingItem booking;
  SubmitValetEventBooking(this.booking);
}

class ResetValetBookingSubmission extends HomeEvent {}

class LoadHomeDataRequested extends HomeEvent {}
