import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_request_entity.dart';

enum BookingFlowStatus { initial, updating, submitting, success, error }

class BookingFlowState extends Equatable {
  final int currentStep;
  final BookingRequestEntity request;
  final BookingFlowStatus status;
  final String? errorMessage;

  const BookingFlowState({
    this.currentStep = 0,
    this.request = const BookingRequestEntity(),
    this.status = BookingFlowStatus.initial,
    this.errorMessage,
  });

  BookingFlowState copyWith({
    int? currentStep,
    BookingRequestEntity? request,
    BookingFlowStatus? status,
    String? errorMessage,
  }) {
    return BookingFlowState(
      currentStep: currentStep ?? this.currentStep,
      request: request ?? this.request,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [currentStep, request, status, errorMessage];
}
