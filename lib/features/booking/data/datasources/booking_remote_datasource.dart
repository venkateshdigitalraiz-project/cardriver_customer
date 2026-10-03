import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../models/booking_rate_config_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingRateConfigModel> fetchRateConfig();
  Future<Map<String, dynamic>> submitBooking(Map<String, dynamic> payload);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl({required this.dio});

  @override
  Future<BookingRateConfigModel> fetchRateConfig() async {
    // Simulate remote network fetch delay
    await Future.delayed(const Duration(milliseconds: 300));
    return const BookingRateConfigModel();
  }

  @override
  Future<Map<String, dynamic>> submitBooking(Map<String, dynamic> payload) async {
    try {
      debugPrint('🌍 API Request -> POST ${ApiEndpoints.driverBooking}');
      debugPrint('🌍 API Payload -> $payload');
      
      final prefs = await SharedPreferences.getInstance();
      final authCookie = prefs.getString('auth_cookie') ?? '';
      
      debugPrint('🍪 Sending Cookie: $authCookie');
      if (authCookie.isEmpty) {
        debugPrint('⚠️ WARNING: No auth_cookie found in SharedPreferences!');
      }

      final response = await dio.post(
        ApiEndpoints.driverBooking,
        options: Options(headers: {
          'Content-Type': 'application/json',
          if (authCookie.isNotEmpty) 'Cookie': authCookie,
        }),
        data: payload,
      );

      debugPrint('✅ API Response -> Status: ${response.statusCode}');
      debugPrint('✅ API Data -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          bool isSuccess = true;
          if (responseData['success'] == false || 
              responseData['status'] == false || 
              responseData['status'] == 'failed') {
            isSuccess = false;
          }

          if (!isSuccess) {
            throw ServerFailure(responseData['message'] ?? 'Failed to submit booking. Please try again.');
          }
          return responseData;
        }
        throw const ServerFailure('Invalid response format from server.');
      } else {
        throw const ServerFailure('Failed to submit booking. Please try again.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          throw ServerFailure(data['message']);
        }
      }
      throw const ServerFailure('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('❌ API Exception -> $e');
      if (e is ServerFailure) rethrow;
      throw const ServerFailure('An unexpected error occurred. Please try again later.');
    }
  }
}
