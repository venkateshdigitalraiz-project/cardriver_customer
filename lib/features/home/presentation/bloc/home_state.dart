import 'package:equatable/equatable.dart';
import '../../domain/entities/home_banner_item.dart';
import '../../domain/entities/valet_event_booking_response.dart';

abstract class HomeState extends Equatable {
  final int currentBannerIndex;
  final bool isSubmittingValet;
  final bool valetSubmitSuccess;
  final String? valetErrorMessage;
  final ValetEventBookingResponse? valetBookingResponse;

  // Dynamic Home Banners from /api/user/home
  final List<HomeBannerItem> heroBanners;
  final List<HomeBannerItem> middleBanners;
  final bool isLoadingHomeData;
  final String? homeDataErrorMessage;

  const HomeState({
    required this.currentBannerIndex,
    this.isSubmittingValet = false,
    this.valetSubmitSuccess = false,
    this.valetErrorMessage,
    this.valetBookingResponse,
    this.heroBanners = const [],
    this.middleBanners = const [],
    this.isLoadingHomeData = false,
    this.homeDataErrorMessage,
  });

  HomeState copyWith({
    int? currentBannerIndex,
    bool? isSubmittingValet,
    bool? valetSubmitSuccess,
    String? valetErrorMessage,
    ValetEventBookingResponse? valetBookingResponse,
    List<HomeBannerItem>? heroBanners,
    List<HomeBannerItem>? middleBanners,
    bool? isLoadingHomeData,
    String? homeDataErrorMessage,
    bool clearError = false,
    bool clearResponse = false,
    bool clearHomeError = false,
  });

  @override
  List<Object?> get props => [
        currentBannerIndex,
        isSubmittingValet,
        valetSubmitSuccess,
        valetErrorMessage,
        valetBookingResponse,
        heroBanners,
        middleBanners,
        isLoadingHomeData,
        homeDataErrorMessage,
      ];
}

class HomeInitial extends HomeState {
  const HomeInitial({
    required super.currentBannerIndex,
    super.isSubmittingValet = false,
    super.valetSubmitSuccess = false,
    super.valetErrorMessage,
    super.valetBookingResponse,
    super.heroBanners = const [],
    super.middleBanners = const [],
    super.isLoadingHomeData = false,
    super.homeDataErrorMessage,
  });

  @override
  HomeInitial copyWith({
    int? currentBannerIndex,
    bool? isSubmittingValet,
    bool? valetSubmitSuccess,
    String? valetErrorMessage,
    ValetEventBookingResponse? valetBookingResponse,
    List<HomeBannerItem>? heroBanners,
    List<HomeBannerItem>? middleBanners,
    bool? isLoadingHomeData,
    String? homeDataErrorMessage,
    bool clearError = false,
    bool clearResponse = false,
    bool clearHomeError = false,
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
      heroBanners: heroBanners ?? this.heroBanners,
      middleBanners: middleBanners ?? this.middleBanners,
      isLoadingHomeData: isLoadingHomeData ?? this.isLoadingHomeData,
      homeDataErrorMessage: clearHomeError
          ? null
          : (homeDataErrorMessage ?? this.homeDataErrorMessage),
    );
  }
}
