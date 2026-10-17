import 'package:equatable/equatable.dart';
import '../../domain/entities/valet_event_booking_response.dart';

abstract class HomeState extends Equatable {
  final int currentBannerIndex;
  final bool isSubmittingValet;
  final bool valetSubmitSuccess;
  final String? valetErrorMessage;
  final ValetEventBookingResponse? valetBookingResponse;

  const HomeState({
    required this.currentBannerIndex,
    this.isSubmittingValet = false,
    this.valetSubmitSuccess = false,
    this.valetErrorMessage,
    this.valetBookingResponse,
  });

  HomeState copyWith({
    int? currentBannerIndex,
    bool? isSubmittingValet,
    bool? valetSubmitSuccess,
    String? valetErrorMessage,
    ValetEventBookingResponse? valetBookingResponse,
    bool clearError = false,
    bool clearResponse = false,
  });

  @override
  List<Object?> get props => [
        currentBannerIndex,
        isSubmittingValet,
        valetSubmitSuccess,
        valetErrorMessage,
        valetBookingResponse,
      ];
}

class HomeInitial extends HomeState {
  const HomeInitial({
    required super.currentBannerIndex,
    super.isSubmittingValet = false,
    super.valetSubmitSuccess = false,
    super.valetErrorMessage,
    super.valetBookingResponse,
  });

  @override
  HomeInitial copyWith({
    int? currentBannerIndex,
    bool? isSubmittingValet,
    bool? valetSubmitSuccess,
    String? valetErrorMessage,
    ValetEventBookingResponse? valetBookingResponse,
    bool clearError = false,
    bool clearResponse = false,
  }) {
    return HomeInitial(
      currentBannerIndex: currentBannerIndex ?? this.currentBannerIndex,
      isSubmittingValet: isSubmittingValet ?? this.isSubmittingValet,
      valetSubmitSuccess: valetSubmitSuccess ?? this.valetSubmitSuccess,
      valetErrorMessage:
          clearError ? null : (valetErrorMessage ?? this.valetErrorMessage),
      valetBookingResponse: clearResponse
          ? null
          : (valetBookingResponse ?? this.valetBookingResponse),
    );
  }
}
