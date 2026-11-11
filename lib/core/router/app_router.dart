import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/location_picker_map_screen.dart';
import '../../features/auth/presentation/pages/customer_dashboard_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/booking/domain/entities/booking_request_entity.dart';
import '../../features/booking/presentation/pages/booking_confirmed_screen.dart';
import '../../features/booking/presentation/pages/booking_details_page.dart';
import '../../features/booking/presentation/pages/booking_wizard_screen.dart';
import '../../features/booking/presentation/pages/my_bookings_page.dart';
import '../../features/drivers/domain/entities/driver_search_type.dart';
import '../../features/drivers/presentation/pages/driver_list_screen.dart';
import '../../features/jobs/domain/entities/user_job_entity.dart';
import '../../features/jobs/presentation/pages/job_post_details_screen.dart';
import '../../features/jobs/presentation/pages/my_job_posts_screen.dart';
import '../../features/jobs/presentation/pages/post_driver_job_screen.dart';
import '../../features/legal/presentation/pages/legal_page.dart';
import '../../features/locations/presentation/bloc/location_bloc.dart';
import '../../features/locations/presentation/bloc/location_event.dart';
import '../../features/locations/presentation/pages/saved_locations_page.dart';
import '../../features/main_navigation/presentation/pages/main_page.dart';
import '../../features/notifications/presentation/pages/firebase_setup_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/open_whatsapp_helpline_usecase.dart';
import '../../features/profile/domain/usecases/update_user_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_event.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/rates/presentation/pages/rates_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/tickets/presentation/pages/tickets_page.dart';
import '../../features/valet_parking/presentation/pages/valet_parking_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/rating/domain/usecases/submit_rating_usecase.dart';
import '../../features/rating/presentation/bloc/rating_bloc.dart';
import '../../features/rating/presentation/pages/rating_page.dart';
import '../../features/referral/domain/usecases/get_referral_info_usecase.dart';
import '../../features/referral/presentation/bloc/referral_bloc.dart';
import '../../features/referral/presentation/pages/refer_and_earn_page.dart';

/// Centralized route paths for the customer application
class AppRoutes {
  static const String main = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String customerDashboard = '/customer-dashboard';
  static const String driverList = '/driver-list';
  static const String bookingWizard = '/booking-wizard';
  static const String bookingConfirmed = '/booking-confirmed';
  static const String bookingDetails = '/booking-details';
  static const String bookingDetailsWithParam = '/booking-details/:bookingId';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String savedLocations = '/saved-locations';
  static const String addLocation = '/saved-locations/add';
  static const String rates = '/rates';
  static const String tickets = '/tickets';
  static const String support = '/support';
  static const String legal = '/legal';
  static const String notifications = '/notifications';
  static const String firebaseSetup = '/firebase-setup';
  static const String valetParking = '/valet-parking';
  static const String locationPickerMap = '/location-picker-map';
  static const String wallet = '/wallet';
  static const String myBookings = '/my-bookings';
  static const String postJob = '/post-job';
  static const String myJobPosts = '/my-job-posts';
  static const String jobDetails = '/job-details';
  static const String jobDetailsWithParam = '/job-details/:jobId';
  static const String rateTrip = '/rate-trip';
  static const String referAndEarn = '/refer-and-earn';
}

/// Centralized route names for named navigation
class AppRouteNames {
  static const String main = 'main';
  static const String login = 'login';
  static const String register = 'register';
  static const String customerDashboard = 'customerDashboard';
  static const String driverList = 'driverList';
  static const String bookingWizard = 'bookingWizard';
  static const String bookingConfirmed = 'bookingConfirmed';
  static const String bookingDetails = 'bookingDetails';
  static const String rateTrip = 'rateTrip';
  static const String referAndEarn = 'referAndEarn';
  static const String profile = 'profile';
  static const String editProfile = 'editProfile';
  static const String savedLocations = 'savedLocations';
  static const String addLocation = 'addLocation';
  static const String rates = 'rates';
  static const String tickets = 'tickets';
  static const String support = 'support';
  static const String legal = 'legal';
  static const String notifications = 'notifications';
  static const String firebaseSetup = 'firebaseSetup';
  static const String valetParking = 'valetParking';
  static const String locationPickerMap = 'locationPickerMap';
  static const String wallet = 'wallet';
  static const String myBookings = 'myBookings';
  static const String postJob = 'postJob';
  static const String myJobPosts = 'myJobPosts';
  static const String jobDetails = 'jobDetails';
}

/// Centralized Router Configuration using go_router
class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

  static GoRouter createRouter({
    required bool isLoggedIn,
    VoidCallback? onToggleTheme,
    bool isDarkMode = true,
  }) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: isLoggedIn ? AppRoutes.main : AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.main,
          name: AppRouteNames.main,
          builder: (context, state) => const MainPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRouteNames.login,
          builder: (context, state) => LoginPage(
            onToggleTheme: onToggleTheme,
            isDarkMode: isDarkMode,
          ),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: AppRouteNames.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.customerDashboard,
          name: AppRouteNames.customerDashboard,
          builder: (context, state) {
            final searchType =
                state.extra as DriverSearchType? ?? DriverSearchType.local;
            return CustomerDashboardPage(searchType: searchType);
          },
        ),
        GoRoute(
          path: AppRoutes.driverList,
          name: AppRouteNames.driverList,
          builder: (context, state) {
            final searchType =
                state.extra as DriverSearchType? ?? DriverSearchType.local;
            return DriverListScreen(searchType: searchType);
          },
        ),
        GoRoute(
          path: AppRoutes.bookingWizard,
          name: AppRouteNames.bookingWizard,
          builder: (context, state) {
            final initialTripType = state.extra as String? ??
                state.uri.queryParameters['tripType'] ??
                'Local';
            return BookingWizardScreen(initialTripType: initialTripType);
          },
        ),
        GoRoute(
          path: AppRoutes.bookingConfirmed,
          name: AppRouteNames.bookingConfirmed,
          builder: (context, state) {
            BookingRequestEntity? request;
            String? bookingId;
            if (state.extra is Map<String, dynamic>) {
              final map = state.extra as Map<String, dynamic>;
              request = map['request'] as BookingRequestEntity?;
              bookingId = map['bookingId']?.toString();
            } else if (state.extra is BookingRequestEntity) {
              request = state.extra as BookingRequestEntity;
            }
            bookingId ??= state.uri.queryParameters['bookingId'];

            final fallbackRequest = request ??
                const BookingRequestEntity(
                  isOutstation: false,
                  tripType: 'One Way',
                  pickupAddress: 'Pickup Location',
                  dropAddress: 'Drop Location',
                );

            return BookingConfirmedScreen(
              request: fallbackRequest,
              bookingId: bookingId,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.bookingDetailsWithParam,
          name: AppRouteNames.bookingDetails,
          builder: (context, state) {
            final bookingId = state.pathParameters['bookingId'] ??
                state.uri.queryParameters['id'] ??
                '';
            return BookingDetailsPage(bookingId: bookingId);
          },
        ),
        GoRoute(
          path: AppRoutes.rateTrip,
          name: AppRouteNames.rateTrip,
          builder: (context, state) {
            RatingPageArgs? args;
            if (state.extra is RatingPageArgs) {
              args = state.extra as RatingPageArgs;
            } else if (state.extra is Map) {
              final map = state.extra as Map;
              args = RatingPageArgs(
                bookingId: map['bookingId']?.toString() ?? '',
                driverName: map['driverName']?.toString(),
                driverPhoto: map['driverPhoto']?.toString(),
                vehicleInfo: map['vehicleInfo']?.toString(),
                tripInfo: map['tripInfo']?.toString(),
              );
            } else {
              args = RatingPageArgs(
                bookingId: state.uri.queryParameters['bookingId'] ?? '',
              );
            }

            return BlocProvider<RatingBloc>(
              create: (context) => RatingBloc(
                submitRatingUseCase: context.read<SubmitRatingUseCase>(),
              ),
              child: CustomerRatingPage(args: args),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.referAndEarn,
          name: AppRouteNames.referAndEarn,
          builder: (context, state) {
            return BlocProvider<ReferralBloc>(
              create: (context) => ReferralBloc(
                getReferralInfoUseCase: context.read<GetReferralInfoUseCase>(),
              ),
              child: const ReferAndEarnPage(),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: AppRouteNames.profile,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.myBookings,
          name: AppRouteNames.myBookings,
          builder: (context, state) => const MyBookingsPage(),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          name: AppRouteNames.editProfile,
          builder: (context, state) {
            final profileBloc = state.extra as ProfileBloc? ??
                ProfileBloc(
                  getUserProfileUseCase: context.read<GetUserProfileUseCase>(),
                  updateUserProfileUseCase:
                      context.read<UpdateUserProfileUseCase>(),
                  openWhatsAppHelplineUseCase:
                      context.read<OpenWhatsAppHelplineUseCase>(),
                )..add(LoadProfileEvent());
            return EditProfilePage(profileBloc: profileBloc);
          },
        ),
        GoRoute(
          path: AppRoutes.savedLocations,
          name: AppRouteNames.savedLocations,
          builder: (context, state) => BlocProvider(
            create: (context) => LocationBloc()..add(LoadLocations()),
            child: const SavedLocationsPage(),
          ),
          routes: [
            GoRoute(
              path: 'add',
              name: AppRouteNames.addLocation,
              builder: (context, state) {
                final parentCtx = state.extra as BuildContext? ?? context;
                return AddLocationScreen(parentCtx: parentCtx);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.rates,
          name: AppRouteNames.rates,
          builder: (context, state) => const RatesPage(),
        ),
        GoRoute(
          path: AppRoutes.tickets,
          name: AppRouteNames.tickets,
          builder: (context, state) => const TicketsPage(),
        ),
        GoRoute(
          path: AppRoutes.support,
          name: AppRouteNames.support,
          builder: (context, state) => const SupportPage(),
        ),
        GoRoute(
          path: AppRoutes.legal,
          name: AppRouteNames.legal,
          builder: (context, state) {
            LegalPageType pageType = LegalPageType.terms;
            if (state.extra is LegalPageType) {
              pageType = state.extra as LegalPageType;
            } else {
              final typeParam = state.uri.queryParameters['type'];
              if (typeParam == 'privacy') {
                pageType = LegalPageType.privacy;
              }
            }
            return LegalPage(pageType: pageType);
          },
        ),
        GoRoute(
          path: AppRoutes.notifications,
          name: AppRouteNames.notifications,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.firebaseSetup,
          name: AppRouteNames.firebaseSetup,
          builder: (context, state) => const FirebaseSetupPage(),
        ),
        GoRoute(
          path: AppRoutes.valetParking,
          name: AppRouteNames.valetParking,
          builder: (context, state) => const ValetParkingPage(),
        ),
        GoRoute(
          path: AppRoutes.locationPickerMap,
          name: AppRouteNames.locationPickerMap,
          builder: (context, state) {
            double? initialLat;
            double? initialLng;
            String? title;
            bool? isPickup;
            String? initialAddress;
            if (state.extra is Map) {
              final map = state.extra as Map;
              initialLat = (map['initialLat'] as num?)?.toDouble();
              initialLng = (map['initialLng'] as num?)?.toDouble();
              title = map['title'] as String?;
              isPickup = map['isPickup'] as bool?;
              initialAddress = map['initialAddress'] as String?;
            }
            return LocationPickerMapScreen(
              initialLat: initialLat,
              initialLng: initialLng,
              title: title,
              isPickup: isPickup,
              initialAddress: initialAddress,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.wallet,
          name: AppRouteNames.wallet,
          builder: (context, state) => const WalletPage(),
        ),
        GoRoute(
          path: AppRoutes.postJob,
          name: AppRouteNames.postJob,
          builder: (context, state) => const PostDriverJobScreen(),
        ),
        GoRoute(
          path: AppRoutes.myJobPosts,
          name: AppRouteNames.myJobPosts,
          builder: (context, state) => const MyJobPostsScreen(),
        ),
        GoRoute(
          path: AppRoutes.jobDetailsWithParam,
          name: AppRouteNames.jobDetails,
          builder: (context, state) {
            final jobId = state.pathParameters['jobId'] ?? '';
            final initialJob = state.extra is UserJobEntity
                ? state.extra as UserJobEntity
                : null;
            return JobPostDetailsScreen(
              jobId: jobId,
              initialJob: initialJob,
            );
          },
        ),
      ],
    );
  }
}
