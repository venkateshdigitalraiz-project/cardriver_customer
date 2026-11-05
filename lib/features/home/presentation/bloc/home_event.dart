import '../../domain/entities/driver_job_item.dart';
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

class SubmitDriverJobEvent extends HomeEvent {
  final DriverJobItem job;
  SubmitDriverJobEvent(this.job);
}

class ResetDriverJobSubmissionEvent extends HomeEvent {}

class LoadHomeDataRequested extends HomeEvent {}

/// Dispatched when the customer taps the WhatsApp support icon in the HomePage AppBar.
class OpenWhatsAppSupportEvent extends HomeEvent {
  final String? message;
  OpenWhatsAppSupportEvent({this.message});
}
