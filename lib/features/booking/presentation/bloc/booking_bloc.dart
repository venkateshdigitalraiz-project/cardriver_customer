import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking_rate_config_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/usecases/calculate_fare_usecase.dart';
import '../../domain/usecases/check_booking_radius_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;
  final CalculateFareUseCase calculateFareUseCase;
  final CheckBookingRadiusUseCase checkBookingRadiusUseCase;

  BookingRateConfigEntity _cachedRateConfig = const BookingRateConfigEntity();

  int _selectedHours = 6;
  int _startHour = 7;
  int _startMinute = 0;

  BookingBloc({
    required this.repository,
    required this.calculateFareUseCase,
    required this.checkBookingRadiusUseCase,
  }) : super(const BookingInitial()) {
    on<LoadRateConfigEvent>(_onLoadRateConfig);
    on<LocalBookingSelectedEvent>(_onLocalBookingSelected);
    on<LocalHoursChangedEvent>(_onLocalHoursChanged);
    on<LocalStartTimeChangedEvent>(_onLocalStartTimeChanged);
    on<CalculateLocalBookingFareEvent>(_onCalculateLocalFare);
    on<CalculateOutstationBookingFareEvent>(_onCalculateOutstationFare);
    on<CheckRadiusEvent>(_onCheckRadius);
  }

  Future<void> _onLoadRateConfig(
    LoadRateConfigEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      _cachedRateConfig = await repository.getRateConfig();
      _recalculateLocalFare(emit);
    } catch (_) {
      // Keep cached defaults on error
    }
  }

  void _onLocalBookingSelected(
    LocalBookingSelectedEvent event,
    Emitter<BookingState> emit,
  ) {
    _recalculateLocalFare(emit);
  }

  void _onLocalHoursChanged(
    LocalHoursChangedEvent event,
    Emitter<BookingState> emit,
  ) {
    _selectedHours = event.hours;
    _recalculateLocalFare(emit);
  }

  void _onLocalStartTimeChanged(
    LocalStartTimeChangedEvent event,
    Emitter<BookingState> emit,
  ) {
    _startHour = event.startHour;
    _startMinute = event.startMinute;
    _recalculateLocalFare(emit);
  }

  void _recalculateLocalFare(Emitter<BookingState> emit) {
    try {
      final fareResult = calculateFareUseCase.calculateLocalFare(
        startHour: _startHour,
        startMinute: _startMinute,
        durationHours: _selectedHours,
        rates: _cachedRateConfig,
      );

      emit(BookingFareCalculated(
        fareResult: fareResult,
        rateConfig: _cachedRateConfig,
      ));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  void _onCalculateLocalFare(
    CalculateLocalBookingFareEvent event,
    Emitter<BookingState> emit,
  ) {
    _startHour = event.startHour;
    _startMinute = event.startMinute;
    _selectedHours = event.durationHours;
    _recalculateLocalFare(emit);
  }

  void _onCalculateOutstationFare(
    CalculateOutstationBookingFareEvent event,
    Emitter<BookingState> emit,
  ) {
    try {
      final fareResult = calculateFareUseCase.calculateOutstationFare(
        totalDays: event.totalDays,
        rates: _cachedRateConfig,
      );

      emit(BookingFareCalculated(
        fareResult: fareResult,
        rateConfig: _cachedRateConfig,
      ));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  void _onCheckRadius(
    CheckRadiusEvent event,
    Emitter<BookingState> emit,
  ) {
    try {
      final radiusResult = checkBookingRadiusUseCase(
        pickupLat: event.pickupLat,
        pickupLng: event.pickupLng,
        currentLat: event.currentLat,
        currentLng: event.currentLng,
        radiusKm: _cachedRateConfig.localRadiusKm,
      );

      emit(BookingRadiusChecked(
        distanceKm: radiusResult.distanceKm,
        isLocalRadius: radiusResult.isLocalRadius,
      ));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }
}
