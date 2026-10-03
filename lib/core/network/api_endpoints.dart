class ApiEndpoints {
  static const String baseUrl = 'http://192.168.0.161:3000/api';

  // User Authentication
  static const String login = '$baseUrl/user/login';
  static const String verifyOtp = '$baseUrl/user/verify-otp';

  // Booking
  static const String driverBooking = '$baseUrl/user/driver-booking';

  // Profile
  static const String profile = '$baseUrl/user/profile';
}
