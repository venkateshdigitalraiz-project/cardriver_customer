import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/app_auth_storage.dart';
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

  /// Resolves the authenticated headers dynamically from SharedPreferences and static cache
  Future<Map<String, String>> _resolveAuthHeaders({bool requireAuth = true}) async {
    final token = await AppAuthStorage.getOrCollectToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Cookie': 'user_token=$token',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
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
        dynamic data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          final rawList = mapData['data'];
          if (rawList is List && rawList.isNotEmpty) {
            final first = rawList[0];
            if (first is Map) {
              return ChargesModel.fromJson(Map<String, dynamic>.from(first));
            }
          } else if (rawList is Map) {
            return ChargesModel.fromJson(Map<String, dynamic>.from(rawList));
          } else if (mapData['local'] != null) {
            return ChargesModel.fromJson(mapData);
          } else if (mapData['charges'] != null && mapData['charges'] is Map) {
            return ChargesModel.fromJson(
              Map<String, dynamic>.from(mapData['charges'] as Map),
            );
          }
        } else if (data is List && data.isNotEmpty) {
          final first = data[0];
          if (first is Map) {
            return ChargesModel.fromJson(Map<String, dynamic>.from(first));
          }
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
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status.trim().isNotEmpty) queryParams['status'] = status.trim();
    if (startDate.trim().isNotEmpty) queryParams['startDate'] = startDate.trim();
    if (endDate.trim().isNotEmpty) queryParams['endDate'] = endDate.trim();
    if (search.trim().isNotEmpty) queryParams['search'] = search.trim();

    try {
      debugPrint('🌍 API Request -> GET ${ApiEndpoints.driverBooking}');
      debugPrint('🌍 API Query Params -> $queryParams');

      final headers = await _resolveAuthHeaders(requireAuth: true);
      debugPrint('🍪 Cookie header -> ${headers['Cookie']}');
      debugPrint('🔑 Authorization -> ${headers['Authorization']}');

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
