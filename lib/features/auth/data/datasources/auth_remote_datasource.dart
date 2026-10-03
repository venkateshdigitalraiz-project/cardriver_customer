import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver_user_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<CustomerUserModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<CustomerUserModel> loginWithPhone({
    required String phone,
  });

  Future<void> sendOtp({required String phone});

  Future<CustomerUserModel> verifyOtp({
    required String phone,
    required String otp,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<CustomerUserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (password.length < 6) {
      throw const AuthFailure('Password must be at least 6 characters');
    }

    return CustomerUserModel(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      name: 'David Sterling',
      email: email,
      phone: '+1 (555) 839-2019',
      memberTier: 'Elite Gold Customer',
      totalRidesTaken: 28,
      savedCarsCount: 2,
    );
  }

  @override
  Future<CustomerUserModel> loginWithPhone({
    required String phone,
  }) async {
    try {
      debugPrint('🌍 API Request -> POST ${ApiEndpoints.login}');
      debugPrint('🌍 API Payload -> {"phone": "$phone"}');
      
      final response = await dio.post(
        ApiEndpoints.login,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'phone': phone},
      );

      debugPrint('✅ API Response -> Status: ${response.statusCode}');
      debugPrint('✅ API Data -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData['isRegistered'] == false) {
            throw AuthFailure(responseData['message'] ?? 'Mobile number is not registered. Please sign up.');
          }
          if (responseData['success'] == false || responseData['status'] == false) {
             throw AuthFailure(responseData['message'] ?? 'Failed to login.');
          }
        }

        // Assuming the API returns user data in 'data' field or directly
        final userData = (responseData is Map<String, dynamic> && responseData.containsKey('data')) 
            ? responseData['data'] 
            : responseData;
        return CustomerUserModel.fromJson(userData ?? {});
      } else {
        throw const AuthFailure('Failed to login. Please try again.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          throw AuthFailure(data['message']);
        }
      }
      throw const AuthFailure('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('❌ API Exception -> $e');
      if (e is AuthFailure) rethrow;
      throw const AuthFailure('An unexpected error occurred. Please try again later.');
    }
  }

  @override
  Future<void> sendOtp({required String phone}) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<CustomerUserModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      debugPrint('🌍 API Request -> POST ${ApiEndpoints.verifyOtp}');
      debugPrint('🌍 API Payload -> {"phone": "$phone", "otp": "$otp"}');
      
      final response = await dio.post(
        ApiEndpoints.verifyOtp,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'phone': phone, 'otp': otp},
      );

      debugPrint('✅ API Response -> Status: ${response.statusCode}');
      debugPrint('✅ API Data -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // --- Extract and save the cookie ---
        String tokenCookie = '';
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          for (var c in cookies) {
            if (c.contains('user_token=')) {
              tokenCookie = c.split(';').first; // e.g. user_token=eyJ...
              break;
            }
          }
        }
        
        final responseData = response.data;
        
        // Fallback: If Set-Cookie header is missing, check if token is in the JSON body
        if (tokenCookie.isEmpty && responseData is Map<String, dynamic>) {
          String? bodyToken = responseData['token'];
          if (bodyToken == null && responseData['data'] is Map<String, dynamic>) {
            bodyToken = responseData['data']['token'];
          }
          if (bodyToken != null && bodyToken.isNotEmpty) {
            tokenCookie = 'user_token=$bodyToken';
          }
        }

        if (tokenCookie.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_cookie', tokenCookie);
          debugPrint('🔑 Saved Auth Cookie: $tokenCookie');
        }
        // -----------------------------------
        
        // Ensure the API explicitly returned success if it follows standard envelope format
        if (responseData is Map<String, dynamic>) {
          if (responseData['isRegistered'] == false) {
            throw AuthFailure(responseData['message'] ?? 'User not registered. Please sign up.');
          }

          bool isSuccess = true;
          if (responseData['success'] == false || 
              responseData['status'] == false || 
              responseData['status'] == 'failed') {
            isSuccess = false;
          }

          if (!isSuccess) {
            throw AuthFailure(responseData['message'] ?? 'Invalid OTP entered. Please try again.');
          }
        }

        // Assuming the API returns user data in 'data' field or directly, or 'user' field
        final userData = (responseData is Map<String, dynamic> && responseData.containsKey('user'))
            ? responseData['user']
            : (responseData is Map<String, dynamic> && responseData.containsKey('data')) 
                ? responseData['data'] 
                : responseData;

        // Save the user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (userData != null && userData is Map<String, dynamic>) {
           await prefs.setString('user_data', jsonEncode(userData));
           debugPrint('👤 Saved User Data: ${jsonEncode(userData)}');
        }
            
        return CustomerUserModel.fromJson(userData ?? {});
      } else {
        throw const AuthFailure('Failed to verify OTP. Please try again.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          throw AuthFailure(data['message']);
        }
      }
      throw const AuthFailure('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('❌ API Exception -> $e');
      if (e is AuthFailure) rethrow;
      throw const AuthFailure('An unexpected error occurred. Please try again later.');
    }
  }
}
