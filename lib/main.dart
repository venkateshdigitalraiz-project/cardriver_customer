import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/bloc/register_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/booking/data/datasources/booking_remote_datasource.dart';
import 'features/booking/data/repositories/booking_repository_impl.dart';
import 'features/booking/domain/usecases/submit_booking_usecase.dart';
import 'features/booking/domain/usecases/get_driver_bookings_usecase.dart';
import 'features/booking/domain/usecases/get_booking_detail_usecase.dart';
import 'features/booking/domain/usecases/get_charges_usecase.dart';
import 'features/booking/domain/usecases/calculate_fare_usecase.dart';
import 'features/main_navigation/presentation/pages/main_page.dart';
import 'features/notifications/data/datasources/firebase_notification_service.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/usecases/clear_all_notifications_usecase.dart';
import 'features/notifications/domain/usecases/get_device_token_usecase.dart';
import 'features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'features/notifications/domain/usecases/send_notification_usecase.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'features/profile/domain/usecases/update_user_profile_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getString('auth_cookie')?.isNotEmpty ?? false;

  // Initialize Firebase and local push notification engine safely
  await FirebaseNotificationService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(DriverCustomerApp(isLoggedIn: isLoggedIn));
}

class DriverCustomerApp extends StatefulWidget {
  final bool isLoggedIn;
  const DriverCustomerApp({super.key, this.isLoggedIn = false});

  @override
  State<DriverCustomerApp> createState() => _DriverCustomerAppState();
}

class _DriverCustomerAppState extends State<DriverCustomerApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Setup Clean Architecture dependencies
    final dio = Dio();
    final authRemoteDataSource = AuthRemoteDataSourceImpl(dio: dio);
    final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
    final loginWithEmailUseCase = LoginWithEmailUseCase(authRepository);
    final loginWithPhoneUseCase = LoginWithPhoneUseCase(authRepository);
    final verifyOtpUseCase = VerifyOtpUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    
    final bookingRemoteDataSource = BookingRemoteDataSourceImpl(dio: dio);
    final bookingRepository = BookingRepositoryImpl(remoteDataSource: bookingRemoteDataSource);
    final submitBookingUseCase = SubmitBookingUseCase(bookingRepository);
    final getDriverBookingsUseCase = GetDriverBookingsUseCase(bookingRepository);
    final getBookingDetailUseCase = GetBookingDetailUseCase(bookingRepository);
    final getChargesUseCase = GetChargesUseCase(bookingRepository);
    final calculateFareUseCase = CalculateFareUseCase();

    final profileRemoteDataSource = ProfileRemoteDataSourceImpl(dio: dio);
    final profileRepository = ProfileRepositoryImpl(remoteDataSource: profileRemoteDataSource);
    final getUserProfileUseCase = GetUserProfileUseCase(profileRepository);
    final updateUserProfileUseCase = UpdateUserProfileUseCase(profileRepository);

    // Notification dependencies
    final notificationRepository = NotificationRepositoryImpl();
    final getNotificationsUseCase = GetNotificationsUseCase(notificationRepository);
    final sendNotificationUseCase = SendNotificationUseCase(notificationRepository);
    final markNotificationAsReadUseCase = MarkNotificationAsReadUseCase(notificationRepository);
    final clearAllNotificationsUseCase = ClearAllNotificationsUseCase(notificationRepository);
    final getDeviceTokenUseCase = GetDeviceTokenUseCase(notificationRepository);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: registerUseCase),
        RepositoryProvider.value(value: submitBookingUseCase),
        RepositoryProvider.value(value: getChargesUseCase),
        RepositoryProvider.value(value: calculateFareUseCase),
        RepositoryProvider.value(value: getDriverBookingsUseCase),
        RepositoryProvider.value(value: getBookingDetailUseCase),
        RepositoryProvider.value(value: getUserProfileUseCase),
        RepositoryProvider.value(value: updateUserProfileUseCase),
        RepositoryProvider.value(value: getNotificationsUseCase),
        RepositoryProvider.value(value: sendNotificationUseCase),
        RepositoryProvider.value(value: markNotificationAsReadUseCase),
        RepositoryProvider.value(value: clearAllNotificationsUseCase),
        RepositoryProvider.value(value: getDeviceTokenUseCase),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (_) => LoginBloc(
              loginWithEmailUseCase: loginWithEmailUseCase,
              loginWithPhoneUseCase: loginWithPhoneUseCase,
              verifyOtpUseCase: verifyOtpUseCase,
            ),
          ),
          BlocProvider<RegisterBloc>(
            create: (_) => RegisterBloc(
              registerUseCase: registerUseCase,
            ),
          ),
          BlocProvider<NotificationBloc>(
            create: (_) => NotificationBloc(
              notificationRepository: notificationRepository,
              getNotificationsUseCase: getNotificationsUseCase,
              sendNotificationUseCase: sendNotificationUseCase,
              markNotificationAsReadUseCase: markNotificationAsReadUseCase,
              clearAllNotificationsUseCase: clearAllNotificationsUseCase,
              getDeviceTokenUseCase: getDeviceTokenUseCase,
            )..add(const InitializeNotifications()),
          ),
        ],
        child: MaterialApp(
          title: 'Car Driver Partner',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          home: widget.isLoggedIn 
              ? const MainPage() 
              : LoginPage(
                  onToggleTheme: _toggleTheme,
                  isDarkMode: _themeMode == ThemeMode.dark,
                ),
        ),
      ),
    );
  }
}
