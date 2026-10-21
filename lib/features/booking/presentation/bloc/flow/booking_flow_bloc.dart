import 'package:cardriver_customer/features/booking/domain/usecases/submit_booking_usecase.dart';
import 'package:cardriver_customer/features/booking/domain/usecases/get_charges_usecase.dart';
import 'package:cardriver_customer/features/booking/domain/usecases/calculate_fare_usecase.dart';
import 'package:cardriver_customer/features/booking/domain/entities/booking_fare_result.dart';
import 'package:cardriver_customer/features/booking/domain/entities/booking_request_entity.dart';
import 'package:cardriver_customer/features/booking/domain/entities/charges_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_flow_event.dart';
import 'booking_flow_state.dart';

class BookingFlowBloc extends Bloc<BookingFlowEvent, BookingFlowState> {
  // We have 4 steps (0 to 3) in the wizard
  static const int _maxSteps = 3;

  final SubmitBookingUseCase submitBookingUseCase;
  final GetChargesUseCase getChargesUseCase;
  final CalculateFareUseCase calculateFareUseCase;

  BookingFlowBloc({
    required this.submitBookingUseCase,
    required this.getChargesUseCase,
    required this.calculateFareUseCase,
  }) : super(const BookingFlowState()) {
    on<NextStepEvent>(_onNextStep);
    on<PreviousStepEvent>(_onPreviousStep);
    on<UpdateLocationVehicleEvent>(_onUpdateLocationVehicle);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<UpdateDurationEvent>(_onUpdateDuration);
    on<FetchChargesEvent>(_onFetchCharges);
    on<SubmitBookingEvent>(_onSubmitBooking);
    on<UpdateTripTypeEvent>(_onUpdateTripType);
    on<ClearLocationEvent>(_onClearLocation);
  }

  BookingFareResult _calculateFare({
    required BookingRequestEntity request,
    required ChargesEntity? charges,
  }) {
    final effectiveCharges = charges ?? const ChargesEntity();
    final now = DateTime.now();
    return calculateFareUseCase.calculateDynamicFare(
      charges: effectiveCharges,
      isOutstation: request.isOutstation,
      tripType: request.tripType,
      durationHours: request.durationHours,
      startDate: request.scheduleDate,
      startHour: request.scheduleHour ?? now.hour,
      startMinute: request.scheduleMinute ?? now.minute,
    );
  }

  void _onClearLocation(
    ClearLocationEvent event,
    Emitter<BookingFlowState> emit,
  ) {
    emit(state.copyWith(request: state.request.clearLocations()));
  }

  void _onNextStep(NextStepEvent event, Emitter<BookingFlowState> emit) {
    if (state.currentStep < _maxSteps) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPreviousStep(
    PreviousStepEvent event,
    Emitter<BookingFlowState> emit,
  ) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void _onUpdateLocationVehicle(
    UpdateLocationVehicleEvent event,
    Emitter<BookingFlowState> emit,
  ) {
    final updatedRequest = state.request.copyWith(
      pickupAddress: event.pickupAddress,
      pickupLat: event.pickupLat,
      pickupLng: event.pickupLng,
      dropAddress: event.dropAddress,
      dropLat: event.dropLat,
      dropLng: event.dropLng,
      carType: event.carType,
      transmission: event.transmission,
      vehicleCategory: event.vehicleCategory,
    );
    emit(state.copyWith(request: updatedRequest));
  }

  Future<void> _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<BookingFlowState> emit,
  ) async {
    var updatedRequest = state.request.copyWith(
      scheduleDate: event.date,
      scheduleHour: event.hour,
      scheduleMinute: event.minute,
    );
    final fareResult = _calculateFare(
      request: updatedRequest,
      charges: state.charges,
    );
    updatedRequest = updatedRequest.copyWith(
      estimatedFare: fareResult.customerFare,
    );
    emit(
      state.copyWith(
        request: updatedRequest,
        driverEarnings: fareResult.driverEarnings,
      ),
    );

    if (state.charges == null) {
      try {
        final charges = await getChargesUseCase();
        final updatedFare = _calculateFare(
          request: updatedRequest,
          charges: charges,
        );
        emit(
          state.copyWith(
            request: updatedRequest.copyWith(
              estimatedFare: updatedFare.customerFare,
            ),
            driverEarnings: updatedFare.driverEarnings,
            charges: charges,
            isLoadingCharges: false,
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> _onUpdateDuration(
    UpdateDurationEvent event,
    Emitter<BookingFlowState> emit,
  ) async {
    var updatedRequest = state.request.copyWith(
      durationHours: event.durationHours,
    );
    final currentFare = _calculateFare(
      request: updatedRequest,
      charges: state.charges,
    );
    updatedRequest = updatedRequest.copyWith(
      estimatedFare: currentFare.customerFare,
    );

    emit(
      state.copyWith(
        request: updatedRequest,
        driverEarnings: currentFare.driverEarnings,
        isLoadingCharges: state.charges == null,
      ),
    );

    if (state.charges == null) {
      try {
        final charges = await getChargesUseCase();
        final fareResult = _calculateFare(
          request: updatedRequest,
          charges: charges,
        );
        emit(
          state.copyWith(
            request: updatedRequest.copyWith(
              estimatedFare: fareResult.customerFare,
            ),
            driverEarnings: fareResult.driverEarnings,
            charges: charges,
            isLoadingCharges: false,
          ),
        );
      } catch (_) {
        emit(state.copyWith(isLoadingCharges: false));
      }
    }
  }

  Future<void> _onFetchCharges(
    FetchChargesEvent event,
    Emitter<BookingFlowState> emit,
  ) async {
    emit(state.copyWith(isLoadingCharges: true));
    try {
      final charges = await getChargesUseCase();
      final fareResult = _calculateFare(
        request: state.request,
        charges: charges,
      );
      emit(
        state.copyWith(
          request: state.request.copyWith(
            estimatedFare: fareResult.customerFare,
          ),
          driverEarnings: fareResult.driverEarnings,
          charges: charges,
          isLoadingCharges: false,
        ),
      );
    } catch (_) {
      final fallbackCharges = state.charges ?? const ChargesEntity();
      final fareResult = _calculateFare(
        request: state.request,
        charges: fallbackCharges,
      );
      emit(
        state.copyWith(
          request: state.request.copyWith(
            estimatedFare: fareResult.customerFare,
          ),
          driverEarnings: fareResult.driverEarnings,
          charges: fallbackCharges,
          isLoadingCharges: false,
        ),
      );
    }
  }

  Future<void> _onSubmitBooking(
    SubmitBookingEvent event,
    Emitter<BookingFlowState> emit,
  ) async {
    // Prevent duplicate processing if already submitting
    if (state.status == BookingFlowStatus.submitting) {
      return;
    }

    final request = state.request;

    // Validation
    if (request.pickupAddress == null || request.pickupAddress!.isEmpty) {
      emit(
        state.copyWith(
          status: BookingFlowStatus.error,
          errorMessage: 'Pickup location is required.',
        ),
      );
      return;
    }
    if (request.scheduleDate == null ||
        request.scheduleHour == null ||
        request.scheduleMinute == null) {
      emit(
        state.copyWith(
          status: BookingFlowStatus.error,
          errorMessage: 'Pickup date and time are required.',
        ),
      );
      return;
    }
    if (request.isOutstation) {
      if (request.dropAddress == null || request.dropAddress!.isEmpty) {
        emit(
          state.copyWith(
            status: BookingFlowStatus.error,
            errorMessage: 'Destination is required for Outstation.',
          ),
        );
        return;
      }
    }

    emit(
      state.copyWith(status: BookingFlowStatus.submitting, errorMessage: null),
    );

    try {
      // Build the payload mapping
      final bool isOutstation = request.isOutstation;
      // Always enforce lowercase serviceType to match API enum schema ('local' | 'outstation')
      final String serviceType = isOutstation ? 'outstation' : 'local';
      final String tripType = request.tripType.toLowerCase().contains('round')
          ? 'round_trip'
          : 'one_way';

      // Construct ISO timestamp string
      // Example: 2026-09-26T10:00:00.000Z
      final dt = request.scheduleDate!;
      final date = DateTime(
        dt.year,
        dt.month,
        dt.day,
        request.scheduleHour ?? 0,
        request.scheduleMinute ?? 0,
      ).toUtc().toIso8601String();

      final int duration = request.durationHours > 0 ? request.durationHours : 1;

      final Map<String, dynamic> payload = {
        "serviceType": serviceType,
        "tripType": tripType,
        "scheduledStartTime": date,
        if (isOutstation) ...{
          "durationDays": duration,
          "durationHours": duration * 24,
          if (tripType == 'round_trip')
            "returnDate": DateTime(
              dt.year,
              dt.month,
              dt.day + duration,
              request.scheduleHour ?? 0,
              request.scheduleMinute ?? 0,
            ).toUtc().toIso8601String(),
        } else ...{
          "durationHours": duration,
        },
        "pickupLocation": {
          "address": request.pickupAddress,
          "location": {
            "type": "Point",
            "coordinates": [
              request.pickupLng ?? 77.209,
              request.pickupLat ?? 28.6139,
            ],
          },
        },
        if (request.dropAddress != null && request.dropAddress!.isNotEmpty)
          "dropLocation": {
            "address": request.dropAddress,
            "location": {
              "type": "Point",
              "coordinates": [
                request.dropLng ?? 77.219,
                request.dropLat ?? 28.6239,
              ],
            },
          },
        "vehicleType": request.vehicleCategory.toLowerCase(),
      };

      final response = await submitBookingUseCase(payload);

      // Extract booking details if returned to update estimated fare
      double? finalFare = request.estimatedFare;
      final bookingData = response['booking'] ?? response['data'];
      if (bookingData is Map<String, dynamic>) {
        if (bookingData['totalAmount'] is num) {
          finalFare = (bookingData['totalAmount'] as num).toDouble();
        } else if (bookingData['baseAmount'] is num) {
          finalFare = (bookingData['baseAmount'] as num).toDouble();
        }
      }

      emit(
        state.copyWith(
          status: BookingFlowStatus.success,
          bookingResponse: response,
          request: request.copyWith(estimatedFare: finalFare),
        ),
      );
    } catch (e) {
      final msg = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ServerFailure: ', '')
          .replaceFirst('Failure: ', '');
      emit(
        state.copyWith(
          status: BookingFlowStatus.error,
          errorMessage: msg,
        ),
      );
    }
  }

  Future<void> _onUpdateTripType(
    UpdateTripTypeEvent event,
    Emitter<BookingFlowState> emit,
  ) async {
    final bool isSwitchingService =
        event.isOutstation != state.request.isOutstation;
    final bool isSwitchingJourney = event.tripType != state.request.tripType;

    int newDuration = state.request.durationHours;
    if (isSwitchingService) {
      if (event.isOutstation) {
        newDuration = 1; // 1 Day default for outstation
      } else {
        newDuration = event.tripType.toLowerCase().contains('round') ? 8 : 4;
      }
    } else if (isSwitchingJourney && !event.isOutstation) {
      // Switching between One Way and Round Trip within Local
      if (event.tripType.toLowerCase().contains('round') && newDuration < 8) {
        newDuration = 8;
      } else if (!event.tripType.toLowerCase().contains('round')) {
        newDuration = 4;
      }
    }

    var updatedRequest = state.request.copyWith(
      isOutstation: event.isOutstation,
      tripType: event.tripType,
      durationHours: newDuration,
    );

    final fareResult = _calculateFare(
      request: updatedRequest,
      charges: state.charges,
    );
    updatedRequest = updatedRequest.copyWith(
      estimatedFare: fareResult.customerFare,
    );

    emit(
      state.copyWith(
        request: updatedRequest,
        driverEarnings: fareResult.driverEarnings,
      ),
    );

    if (state.charges == null) {
      try {
        final charges = await getChargesUseCase();
        final updatedFare = _calculateFare(
          request: updatedRequest,
          charges: charges,
        );
        emit(
          state.copyWith(
            request: updatedRequest.copyWith(
              estimatedFare: updatedFare.customerFare,
            ),
            driverEarnings: updatedFare.driverEarnings,
            charges: charges,
            isLoadingCharges: false,
          ),
        );
      } catch (_) {}
    }
  }
}
