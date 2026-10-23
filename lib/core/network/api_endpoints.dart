class ApiEndpoints {
  // current Live Host  http://194.238.19.189:2200
  static const String _host = 'http://192.168.0.115:3000';
  //static const String _host = 'http://194.238.19.189:2200';
  static const String baseUrl = '$_host/api';

  // User Authentication
  static const String login = '$baseUrl/user/login';
  static const String verifyOtp = '$baseUrl/user/verify-otp';
  static const String register = '$baseUrl/user/register';

  // Booking
  static const String driverBooking = '$baseUrl/user/driver-booking';
  static const String valetBooking = '$baseUrl/user/valet-booking';
  static const String charges = '$baseUrl/common/charges';

  // Profile & Home
  static const String profile = '$baseUrl/user/profile';
  static const String userHome = '$baseUrl/user/home';

  // Settings & Banners
  static const String settings = '$baseUrl/user/settings';
  static const String serverBaseUrl = _host;

  /// Helper to convert relative server paths (like /uploads/xyz.jpg) to full URLs
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$serverBaseUrl$cleanPath';
  }
}
