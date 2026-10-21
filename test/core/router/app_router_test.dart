import 'package:cardriver_customer/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter Route Definition Tests', () {
    test('AppRoutes defines valid route paths', () {
      expect(AppRoutes.main, equals('/'));
      expect(AppRoutes.login, equals('/login'));
      expect(AppRoutes.register, equals('/register'));
      expect(AppRoutes.customerDashboard, equals('/customer-dashboard'));
      expect(AppRoutes.driverList, equals('/driver-list'));
      expect(AppRoutes.bookingWizard, equals('/booking-wizard'));
      expect(AppRoutes.bookingConfirmed, equals('/booking-confirmed'));
      expect(AppRoutes.bookingDetails, equals('/booking-details'));
      expect(AppRoutes.bookingDetailsWithParam, equals('/booking-details/:bookingId'));
      expect(AppRoutes.profile, equals('/profile'));
      expect(AppRoutes.editProfile, equals('/edit-profile'));
      expect(AppRoutes.savedLocations, equals('/saved-locations'));
      expect(AppRoutes.addLocation, equals('/saved-locations/add'));
      expect(AppRoutes.rates, equals('/rates'));
      expect(AppRoutes.tickets, equals('/tickets'));
      expect(AppRoutes.support, equals('/support'));
      expect(AppRoutes.legal, equals('/legal'));
      expect(AppRoutes.notifications, equals('/notifications'));
      expect(AppRoutes.firebaseSetup, equals('/firebase-setup'));
      expect(AppRoutes.valetParking, equals('/valet-parking'));
      expect(AppRoutes.locationPickerMap, equals('/location-picker-map'));
    });

    test('AppRouteNames defines unique route names', () {
      final names = [
        AppRouteNames.main,
        AppRouteNames.login,
        AppRouteNames.register,
        AppRouteNames.customerDashboard,
        AppRouteNames.driverList,
        AppRouteNames.bookingWizard,
        AppRouteNames.bookingConfirmed,
        AppRouteNames.bookingDetails,
        AppRouteNames.profile,
        AppRouteNames.editProfile,
        AppRouteNames.savedLocations,
        AppRouteNames.addLocation,
        AppRouteNames.rates,
        AppRouteNames.tickets,
        AppRouteNames.support,
        AppRouteNames.legal,
        AppRouteNames.notifications,
        AppRouteNames.firebaseSetup,
        AppRouteNames.valetParking,
        AppRouteNames.locationPickerMap,
      ];

      expect(names.toSet().length, equals(names.length));
    });

    test('AppRouter creates valid router configurations', () {
      final routerLoggedIn = AppRouter.createRouter(isLoggedIn: true);
      expect(routerLoggedIn, isNotNull);

      final routerLoggedOut = AppRouter.createRouter(isLoggedIn: false);
      expect(routerLoggedOut, isNotNull);
    });
  });
}
