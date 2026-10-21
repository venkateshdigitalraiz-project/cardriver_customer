import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../models/booking_rate_config_model.dart';
import '../models/booking_model.dart';
import '../models/booking_detail_model.dart';
import '../models/charges_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingRateConfigModel> fetchRateConfig();
  Future<ChargesModel> fetchCharges();
  Future<Map<String, dynamic>> submitBooking(Map<String, dynamic> payload);
  Future<BookingListResponseModel> getDriverBookings({
    int page = 1,
    int limit = 5,
    String status = '',
    String startDate = '',
    String endDate = '',
    String search = '',
  });
  Future<BookingDetailModel> getBookingDetail(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl({required this.dio});

  /// Helper to extract clean raw JWT without cookies prefixes, Bearer prefixes, or quotes
  static String _extractCleanToken(String? raw) {
    if (raw == null) return '';
    var token = raw.trim();
    if (token.contains('user_token=')) {
      token = token.split('user_token=').last.split(';').first.trim();
    } else if (token.contains('token=')) {
      token = token.split('token=').last.split(';').first.trim();
    } else if (token.contains(';')) {
      token = token.split(';').first.trim();
    }
    if (token.startsWith('Bearer ')) {
      token = token.substring(7).trim();
    }
    if ((token.startsWith('"') && token.endsWith('"')) ||
        (token.startsWith("'") && token.endsWith("'"))) {
      token = token.substring(1, token.length - 1).trim();
    }
    return token;
  }

  /// Checks if a JWT string is expired
  static bool _isTokenExpired(String token) {
    try {
      final clean = _extractCleanToken(token);
      final parts = clean.split('.');
      if (parts.length != 3) return false;
      final payloadBase64 = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(payloadBase64));
      final payload = jsonDecode(payloadJson);
      if (payload is Map && payload.containsKey('exp')) {
        final exp = payload['exp'];
        if (exp is num) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(
            exp.toInt() * 1000,
            isUtc: true,
          );
          return DateTime.now().toUtc().isAfter(expiryDate);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error checking token expiration: $e');
    }
    return false;
  }

  /// Collects the authenticated user token purely from SharedPreferences
  Future<String?> _getTokenFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Try auth_cookie
    final authCookie = prefs.getString('auth_cookie');
    if (authCookie != null && authCookie.trim().isNotEmpty) {
      final candidate = _extractCleanToken(authCookie);
      if (candidate.isNotEmpty && candidate.contains('eyJ')) {
        return candidate;
      }
    }

    // 2. Try raw token key
    final token = prefs.getString('token');
    if (token != null && token.trim().isNotEmpty) {
      final candidate = _extractCleanToken(token);
      if (candidate.isNotEmpty && candidate.contains('eyJ')) {
        return candidate;
      }
    }

    // 3. Try auth_token key
    final authToken = prefs.getString('auth_token');
    if (authToken != null && authToken.trim().isNotEmpty) {
      final candidate = _extractCleanToken(authToken);
      if (candidate.isNotEmpty && candidate.contains('eyJ')) {
        return candidate;
      }
    }

    // 4. Try jwt_token key
    final jwtToken = prefs.getString('jwt_token');
    if (jwtToken != null && jwtToken.trim().isNotEmpty) {
      final candidate = _extractCleanToken(jwtToken);
      if (candidate.isNotEmpty && candidate.contains('eyJ')) {
        return candidate;
      }
    }

    // 5. Try user_data JSON
    final userData = prefs.getString('user_data');
    if (userData != null && userData.trim().isNotEmpty) {
      try {
        final userMap = jsonDecode(userData);
        if (userMap is Map) {
          final raw = userMap['token'] ??
              userMap['accessToken'] ??
              userMap['jwt'] ??
              userMap['authToken'];
          if (raw != null) {
            final candidate = _extractCleanToken(raw.toString());
            if (candidate.isNotEmpty && candidate.contains('eyJ')) {
              return candidate;
            }
          }
        }
      } catch (_) {}
    }

    return null;
  }

  /// Resolves the authenticated headers dynamically from SharedPreferences
  Future<Map<String, String>> _resolveAuthHeaders({bool requireAuth = true}) async {
    final token = await _getTokenFromPreferences();

    if (token == null || token.isEmpty) {
      if (requireAuth) {
        throw const ServerFailure(
          'Authentication required: Please log in to complete your booking.',
        );
      }
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }

    if (_isTokenExpired(token)) {
      if (requireAuth) {
        throw const ServerFailure(
          'Your session has expired. Please log in again to continue.',
        );
      }
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cookie': 'user_token=$token; token=$token',
      'Authorization': 'Bearer $token',
      'token': token,
      'x-auth-token': token,
    };
  }

  @override
  Future<BookingRateConfigModel> fetchRateConfig() async {
    // Simulate remote network fetch delay
    await Future.delayed(const Duration(milliseconds: 300));
    return const BookingRateConfigModel();
  }

  @override
  Future<ChargesModel> fetchCharges() async {
    try {
      debugPrint('🌍 API Request -> GET ${ApiEndpoints.charges}');
      final headers = await _resolveAuthHeaders(requireAuth: false);

      final response = await dio.get(
        ApiEndpoints.charges,
        options: Options(headers: headers),
      );

      debugPrint('🌍 API Charges Response -> ${response.statusCode} ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final rawList = data['data'];
          if (rawList is List && rawList.isNotEmpty) {
            return ChargesModel.fromJson(rawList[0] as Map<String, dynamic>);
          } else if (rawList is Map<String, dynamic>) {
            return ChargesModel.fromJson(rawList);
          } else if (data['local'] != null) {
            return ChargesModel.fromJson(data);
          } else if (data['charges'] != null && data['charges'] is Map<String, dynamic>) {
            return ChargesModel.fromJson(data['charges'] as Map<String, dynamic>);
          }
        } else if (data is List && data.isNotEmpty) {
          return ChargesModel.fromJson(data[0] as Map<String, dynamic>);
        }
      }
      throw const ServerFailure('Failed to load charges: Invalid response format');
    } catch (e) {
      debugPrint('❌ Error fetching charges: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> submitBooking(Map<String, dynamic> payload) async {
    try {
      debugPrint('🌍 API Request -> POST ${ApiEndpoints.driverBooking}');
      debugPrint('🌍 API Payload -> $payload');

      final headers = await _resolveAuthHeaders(requireAuth: true);
      debugPrint('🍪 Cookie header: ${headers['Cookie']}');
      debugPrint('🔑 Authorization: ${headers['Authorization']}');

      final response = await dio.post(
        ApiEndpoints.driverBooking,
        options: Options(headers: headers),
        data: payload,
      );

      debugPrint('✅ API Response -> Status: ${response.statusCode}');
      debugPrint('✅ API Data -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (_) {}
        }
        if (responseData is Map<String, dynamic>) {
          bool isSuccess = true;
          if (responseData['success'] == false || 
              responseData['status'] == false || 
              responseData['status'] == 'failed') {
            isSuccess = false;
          }

          if (!isSuccess) {
            final msg = responseData['message']?.toString() ?? '';
            throw ServerFailure(
              msg.isNotEmpty ? msg : 'Failed to submit booking. Please try again.',
            );
          }
          return responseData;
        }
        throw const ServerFailure('Invalid response format from server.');
      } else {
        throw const ServerFailure('Failed to submit booking. Please try again.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      final statusCode = e.response?.statusCode;
      final responseMap = e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : null;
      final serverMsg = responseMap?['message']?.toString() ??
          (e.response?.data is String ? e.response!.data.toString() : '');

      if (statusCode == 401 || statusCode == 403 || serverMsg.toLowerCase().contains('unauthorized')) {
        throw const ServerFailure('Unauthorized: Please log in again to complete your booking.');
      }

      if (responseMap != null && responseMap.containsKey('message')) {
        throw ServerFailure(responseMap['message'].toString());
      } else if (e.response?.data is String) {
        try {
          final data = jsonDecode(e.response!.data as String);
          if (data is Map<String, dynamic> && data.containsKey('message')) {
            throw ServerFailure(data['message'].toString());
          }
        } catch (_) {}
      }
      throw ServerFailure(
        e.message ?? 'Unable to connect to the server. Please check your internet connection and try again.',
      );
    } catch (e) {
      debugPrint('❌ API Exception -> $e');
      if (e is ServerFailure) rethrow;
      throw ServerFailure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<BookingListResponseModel> getDriverBookings({
    int page = 1,
    int limit = 5,
    String status = '',
    String startDate = '',
    String endDate = '',
    String search = '',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'status': status,
        'startDate': startDate,
        'endDate': endDate,
        'search': search,
      };

      debugPrint('🌍 API Request -> GET ${ApiEndpoints.driverBooking}');
      debugPrint('🌍 API Query Params -> $queryParams');

      final headers = await _resolveAuthHeaders(requireAuth: true);
      debugPrint('🍪 Cookie header -> ${headers['Cookie']}');

      final response = await dio.get(
        ApiEndpoints.driverBooking,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      debugPrint('✅ API Response -> Status: ${response.statusCode}');
      debugPrint('✅ API Data -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = response.data;
        if (responseData is String) {
          try {
            responseData = json.decode(responseData);
          } catch (_) {}
        }

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == false) {
            throw ServerFailure(responseData['message'] ?? 'Failed to fetch bookings.');
          }
          return BookingListResponseModel.fromAny(responseData);
        } else if (responseData is List) {
          return BookingListResponseModel.fromAny(responseData);
        }
        throw const ServerFailure('Invalid response format from server.');
      } else {
        throw const ServerFailure('Failed to fetch bookings.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      final statusCode = e.response?.statusCode;
      final responseMap = e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : null;
      final message = responseMap?['message']?.toString().toLowerCase() ?? '';

      final isUnauthorized = statusCode == 401 ||
          statusCode == 403 ||
          message.contains('unauthorized') ||
          message.contains('invalid or missing token');

      if (isUnauthorized) {
        throw const ServerFailure('Unauthorized: Please log in again to view your bookings.');
      }
      if (responseMap != null && responseMap.containsKey('message')) {
        throw ServerFailure(responseMap['message']);
      }
      throw const ServerFailure('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('❌ API Exception -> $e');
      if (e is ServerFailure) rethrow;
      throw const ServerFailure('An unexpected error occurred. Please try again later.');
    }
  }

  @override
  Future<BookingDetailModel> getBookingDetail(String bookingId) async {
    try {
      final endpoint = '${ApiEndpoints.driverBooking}/$bookingId';
      debugPrint('🌍 API Request -> GET $endpoint');

      final headers = await _resolveAuthHeaders(requireAuth: true);
      debugPrint('🍪 Cookie header -> ${headers['Cookie']}');

      final response = await dio.get(
        endpoint,
        options: Options(headers: headers),
      );

      debugPrint('✅ API Response -> Status: ${response.statusCode}');
      debugPrint('✅ API Data -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (_) {}
        }

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == false) {
            throw ServerFailure(responseData['message'] ?? 'Failed to fetch booking details.');
          }
          return BookingDetailModel.fromJson(responseData);
        }
        throw const ServerFailure('Invalid response format from server.');
      } else {
        throw const ServerFailure('Failed to fetch booking details.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      final statusCode = e.response?.statusCode;
      final responseMap = e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : null;
      final message = responseMap?['message']?.toString().toLowerCase() ?? '';

      final isUnauthorizedOrNotFound = statusCode == 401 ||
          statusCode == 403 ||
          statusCode == 404 ||
          message.contains('unauthorized') ||
          message.contains('not found') ||
          message.contains('invalid or missing token');

      if (isUnauthorizedOrNotFound) {
        throw const ServerFailure('Unauthorized: Please log in again.');
      }
      if (responseMap != null && responseMap.containsKey('message')) {
        throw ServerFailure(responseMap['message']);
      }
      throw const ServerFailure('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('❌ API Exception -> $e');
      if (e is ServerFailure) rethrow;
      throw const ServerFailure('An unexpected error occurred. Please try again later.');
    }
  }
}
