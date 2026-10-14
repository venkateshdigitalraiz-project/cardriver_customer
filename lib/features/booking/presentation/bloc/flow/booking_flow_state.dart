import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_request_entity.dart';
import '../../../domain/entities/charges_entity.dart';

enum BookingFlowStatus { initial, updating, submitting, success, error }

class BookingFlowState extends Equatable {
  final int currentStep;
  final BookingRequestEntity request;
  final BookingFlowStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? bookingResponse;
  final ChargesEntity? charges;
  final bool isLoadingCharges;
  final double? driverEarnings;

  const BookingFlowState({
    this.currentStep = 0,
    this.request = const BookingRequestEntity(),
    this.status = BookingFlowStatus.initial,
    this.errorMessage,
    this.bookingResponse,
    this.charges,
    this.isLoadingCharges = false,
    this.driverEarnings,
  });

  BookingFlowState copyWith({
    int? currentStep,
    BookingRequestEntity? request,
    BookingFlowStatus? status,
    String? errorMessage,
    Map<String, dynamic>? bookingResponse,
    ChargesEntity? charges,
    bool? isLoadingCharges,
    double? driverEarnings,
  }) {
    return BookingFlowState(
      currentStep: currentStep ?? this.currentStep,
      request: request ?? this.request,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      bookingResponse: bookingResponse ?? this.bookingResponse,
      charges: charges ?? this.charges,
      isLoadingCharges: isLoadingCharges ?? this.isLoadingCharges,
      driverEarnings: driverEarnings ?? this.driverEarnings,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        request,
        status,
        errorMessage,
        bookingResponse,
        charges,
        isLoadingCharges,
        driverEarnings,
      ];
}
