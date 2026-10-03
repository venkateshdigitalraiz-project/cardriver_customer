import 'package:cardriver_customer/features/booking/domain/usecases/submit_booking_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_flow_event.dart';
import 'booking_flow_state.dart';

class BookingFlowBloc extends Bloc<BookingFlowEvent, BookingFlowState> {
  // We have 4 steps (0 to 3) in the wizard
  static const int _maxSteps = 3;

  final SubmitBookingUseCase submitBookingUseCase;

  BookingFlowBloc({required this.submitBookingUseCase})
    : super(const BookingFlowState()) {
    on<NextStepEvent>(_onNextStep);
    on<PreviousStepEvent>(_onPreviousStep);
    on<UpdateLocationVehicleEvent>(_onUpdateLocationVehicle);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<UpdateDurationEvent>(_onUpdateDuration);
    on<SubmitBookingEvent>(_onSubmitBooking);
    on<UpdateTripTypeEvent>(_onUpdateTripType);
    on<ClearLocationEvent>(_onClearLocation);
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

  void _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<BookingFlowState> emit,
  ) {
    final updatedRequest = state.request.copyWith(
      scheduleDate: event.date,
      scheduleHour: event.hour,
      scheduleMinute: event.minute,
    );
    emit(state.copyWith(request: updatedRequest));
  }

  void _onUpdateDuration(
    UpdateDurationEvent event,
    Emitter<BookingFlowState> emit,
  ) {
    final updatedRequest = state.request.copyWith(
      durationHours: event.durationHours,
    );
    emit(state.copyWith(request: updatedRequest));
  }

  Future<void> _onSubmitBooking(
    SubmitBookingEvent event,
    Emitter<BookingFlowState> emit,
  ) async {
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
    if (request.tripType == 'Outstation') {
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
      final String serviceType = request.isOutstation ? 'outstation' : 'local';
      // Assume round_trip by default or calculate based on drop location
      String tripType = request.tripType.toLowerCase().replaceAll(
        ' ',
        '_',
      );
      if (tripType == 'local') {
        tripType = 'round_trip';
      }

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

      final payload = {
        "serviceType": serviceType,
        "tripType": tripType,
        "scheduledStartTime": date,
        "durationHours": request.durationHours,
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
      emit(state.copyWith(
        status: BookingFlowStatus.success,
        bookingResponse: response,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: BookingFlowStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onUpdateTripType(
    UpdateTripTypeEvent event,
    Emitter<BookingFlowState> emit,
  ) {
    // If we switch to outstation, default duration to 1 day (1), else 4 hours (4)
    final updatedRequest = state.request.copyWith(
      isOutstation: event.isOutstation,
      tripType: event.tripType,
      durationHours: event.isOutstation ? 1 : 4,
    );
    emit(state.copyWith(request: updatedRequest));
  }
}
