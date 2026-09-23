import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_fare_result.dart';
import '../../domain/entities/booking_rate_config_entity.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingFareCalculated extends BookingState {
  final BookingFareResult fareResult;
  final BookingRateConfigEntity rateConfig;

  const BookingFareCalculated({
    required this.fareResult,
    required this.rateConfig,
  });

  @override
  List<Object?> get props => [fareResult, rateConfig];
}

class BookingRadiusChecked extends BookingState {
  final double distanceKm;
  final bool isLocalRadius;

  const BookingRadiusChecked({
    required this.distanceKm,
    required this.isLocalRadius,
  });

  @override
  List<Object?> get props => [distanceKm, isLocalRadius];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}
