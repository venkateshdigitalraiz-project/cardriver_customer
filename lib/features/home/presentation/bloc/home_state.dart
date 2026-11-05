import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_job_response.dart';
import '../../domain/entities/home_banner_item.dart';
import '../../domain/entities/valet_event_booking_response.dart';

abstract class HomeState extends Equatable {
  final int currentBannerIndex;
  final bool isSubmittingValet;
  final bool valetSubmitSuccess;
  final String? valetErrorMessage;
  final ValetEventBookingResponse? valetBookingResponse;

  // Post for Driver Job
  final bool isSubmittingDriverJob;
  final bool driverJobSubmitSuccess;
  final String? driverJobErrorMessage;
  final DriverJobResponse? driverJobResponse;

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
    this.isSubmittingDriverJob = false,
    this.driverJobSubmitSuccess = false,
    this.driverJobErrorMessage,
    this.driverJobResponse,
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
    bool? isSubmittingDriverJob,
    bool? driverJobSubmitSuccess,
    String? driverJobErrorMessage,
    DriverJobResponse? driverJobResponse,
    List<HomeBannerItem>? heroBanners,
    List<HomeBannerItem>? middleBanners,
    bool? isLoadingHomeData,
    String? homeDataErrorMessage,
    bool clearError = false,
    bool clearResponse = false,
    bool clearDriverJobError = false,
    bool clearDriverJobResponse = false,
    bool clearHomeError = false,
  });

  @override
  List<Object?> get props => [
        currentBannerIndex,
        isSubmittingValet,
        valetSubmitSuccess,
        valetErrorMessage,
        valetBookingResponse,
        isSubmittingDriverJob,
        driverJobSubmitSuccess,
        driverJobErrorMessage,
        driverJobResponse,
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
    super.isSubmittingDriverJob = false,
    super.driverJobSubmitSuccess = false,
    super.driverJobErrorMessage,
    super.driverJobResponse,
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
    bool? isSubmittingDriverJob,
    bool? driverJobSubmitSuccess,
    String? driverJobErrorMessage,
    DriverJobResponse? driverJobResponse,
    List<HomeBannerItem>? heroBanners,
    List<HomeBannerItem>? middleBanners,
    bool? isLoadingHomeData,
    String? homeDataErrorMessage,
    bool clearError = false,
    bool clearResponse = false,
    bool clearDriverJobError = false,
    bool clearDriverJobResponse = false,
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
      isSubmittingDriverJob:
          isSubmittingDriverJob ?? this.isSubmittingDriverJob,
      driverJobSubmitSuccess:
          driverJobSubmitSuccess ?? this.driverJobSubmitSuccess,
      driverJobErrorMessage: clearDriverJobError
          ? null
          : (driverJobErrorMessage ?? this.driverJobErrorMessage),
      driverJobResponse: clearDriverJobResponse
          ? null
          : (driverJobResponse ?? this.driverJobResponse),
      heroBanners: heroBanners ?? this.heroBanners,
      middleBanners: middleBanners ?? this.middleBanners,
      isLoadingHomeData: isLoadingHomeData ?? this.isLoadingHomeData,
      homeDataErrorMessage: clearHomeError
          ? null
          : (homeDataErrorMessage ?? this.homeDataErrorMessage),
    );
  }
}

