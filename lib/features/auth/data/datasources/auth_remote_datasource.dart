// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver_user_model.dart';
import '../models/intro_banner_model.dart';
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

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
  });

  Future<List<IntroBannerModel>> getIntroBanners();
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

  Map<String, dynamic> _parseResponseMap(dynamic rawData) {
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) return Map<String, dynamic>.from(rawData);
    if (rawData is String && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return {};
  }

  String? _extractErrorMessage(DioException e) {
    final rawData = e.response?.data;
    if (rawData is Map) {
      return rawData['message']?.toString();
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map) {
          return decoded['message']?.toString();
        }
      } catch (_) {}
    }
    return null;
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
        final responseData = _parseResponseMap(response.data);

        final isRegistered = responseData['isRegistered'];
        if (isRegistered == false || isRegistered?.toString().toLowerCase() == 'false') {
          final msg = responseData['message']?.toString();
          final userMsg = (msg != null && msg.trim().isNotEmpty) ? msg.trim() : 'User not registered';
          debugPrint('⚠️ [loginWithPhone] User not registered: $userMsg');
          throw AuthFailure(userMsg);
        }

        final successVal = responseData['success'];
        final statusVal = responseData['status'];
        if (successVal == false || 
            successVal?.toString().toLowerCase() == 'false' || 
            statusVal == false || 
            statusVal?.toString().toLowerCase() == 'false' ||
            statusVal == 'failed') {
          final msg = responseData['message']?.toString();
          throw AuthFailure(
            (msg != null && msg.trim().isNotEmpty) ? msg.trim() : 'Failed to send OTP. Please try again.',
          );
        }

        Map<String, dynamic> userMap = {};
        if (responseData.containsKey('data') && responseData['data'] is Map) {
          userMap = Map<String, dynamic>.from(responseData['data'] as Map);
        } else {
          userMap = responseData;
        }

        return CustomerUserModel.fromJson(userMap);
      } else {
        throw const AuthFailure('Failed to login. Please try again.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      final serverMessage = _extractErrorMessage(e);
      if (serverMessage != null && serverMessage.trim().isNotEmpty) {
        throw AuthFailure(serverMessage.trim());
      }
      throw const AuthFailure('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('❌ API Exception -> ${e is Failure ? e.message : e}');
      if (e is AuthFailure) rethrow;
      if (e is Failure) rethrow;
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
        final responseData = _parseResponseMap(response.data);

        // 1. Check isRegistered first
        final isRegistered = responseData['isRegistered'];
        if (isRegistered == false || isRegistered?.toString().toLowerCase() == 'false') {
          final msg = responseData['message']?.toString();
          final userMsg = (msg != null && msg.trim().isNotEmpty) ? msg.trim() : 'User not registered';
          debugPrint('⚠️ [verifyOtp] User not registered: $userMsg');
          throw AuthFailure(userMsg);
        }

        // 2. Check success / status
        final successVal = responseData['success'];
        final statusVal = responseData['status'];
        bool isSuccess = true;
        if (successVal == false || 
            successVal?.toString().toLowerCase() == 'false' || 
            statusVal == false || 
            statusVal?.toString().toLowerCase() == 'false' ||
            statusVal == 'failed') {
          isSuccess = false;
        }

        if (!isSuccess) {
          final msg = responseData['message']?.toString();
          throw AuthFailure(
            (msg != null && msg.trim().isNotEmpty) ? msg.trim() : 'Invalid OTP entered. Please try again.',
          );
        }

        // --- Extract and save the cookie & token upon successful verification ---
        String tokenCookie = '';
        String rawJwt = '';
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          for (var c in cookies) {
            if (c.contains('user_token=')) {
              tokenCookie = c.split(';').first.trim(); // e.g. user_token=eyJ...
              rawJwt = tokenCookie.replaceFirst('user_token=', '').trim();
              break;
            } else if (c.contains('token=')) {
              final val = c.split(';').first.trim();
              rawJwt = val.replaceFirst('token=', '').trim();
              tokenCookie = 'user_token=$rawJwt';
              break;
            }
          }
        }
        
        // Fallback: If Set-Cookie header is missing, check if token is in the JSON body
        if (rawJwt.isEmpty) {
          String? bodyToken = responseData['token']?.toString() ??
              responseData['accessToken']?.toString() ??
              responseData['jwt']?.toString();
          if (bodyToken == null && responseData['data'] is Map) {
            final dataMap = responseData['data'] as Map;
            bodyToken = dataMap['token']?.toString() ??
                dataMap['accessToken']?.toString() ??
                dataMap['jwt']?.toString();
          }
          if (bodyToken == null && responseData['user'] is Map) {
            final userJson = responseData['user'] as Map;
            bodyToken = userJson['token']?.toString() ??
                userJson['accessToken']?.toString();
          }
          if (bodyToken != null && bodyToken.trim().isNotEmpty) {
            rawJwt = bodyToken.trim();
            if (rawJwt.startsWith('Bearer ')) {
              rawJwt = rawJwt.substring(7).trim();
            }
            tokenCookie = 'user_token=$rawJwt';
          }
        }

        if (tokenCookie.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_cookie', tokenCookie);
          if (rawJwt.isNotEmpty) {
            await prefs.setString('token', rawJwt);
            await prefs.setString('auth_token', rawJwt);
          }
          debugPrint('🔑 Saved Auth Cookie: $tokenCookie');
        }
        // -----------------------------------

        Map<String, dynamic> userMap = {};
        if (responseData.containsKey('user') && responseData['user'] is Map) {
          userMap = Map<String, dynamic>.from(responseData['user'] as Map);
        } else if (responseData.containsKey('data') && responseData['data'] is Map) {
          userMap = Map<String, dynamic>.from(responseData['data'] as Map);
        } else {
          userMap = responseData;
        }

        // Save the user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (userMap.isNotEmpty) {
          await prefs.setString('user_data', jsonEncode(userMap));
          debugPrint('👤 Saved User Data: ${jsonEncode(userMap)}');
        }
            
        return CustomerUserModel.fromJson(userMap);
      } else {
        throw const AuthFailure('Failed to verify OTP. Please try again.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      final serverMessage = _extractErrorMessage(e);
      if (serverMessage != null && serverMessage.trim().isNotEmpty) {
        throw AuthFailure(serverMessage.trim());
      }
      throw const AuthFailure('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('❌ API Exception -> ${e is Failure ? e.message : e}');
      if (e is AuthFailure) rethrow;
      if (e is Failure) rethrow;
      throw const AuthFailure('An unexpected error occurred. Please try again later.');
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
  }) async {
    final payload = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
    };

    final requestLog = '''
==================== 🌍 REGISTER API REQUEST ====================
URL     : ${ApiEndpoints.register}
Method  : POST
Headers : {"Content-Type": "application/json"}
Payload : ${jsonEncode(payload)}
==================================================================''';
    print(requestLog);
    developer.log(requestLog, name: 'RegisterAPI');

    try {
      final response = await dio.post(
        ApiEndpoints.register,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: payload,
      );

      final responseLog = '''
==================== ✅ REGISTER API RESPONSE ====================
Status Code : ${response.statusCode}
Headers     : ${response.headers.map}
Data        : ${response.data is Map || response.data is List ? jsonEncode(response.data) : response.data}
==================================================================''';
      print(responseLog);
      developer.log(responseLog, name: 'RegisterAPI');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _parseResponseMap(response.data);
        if (responseData['success'] == false || responseData['status'] == false) {
          final msg = responseData['message']?.toString() ?? 'Registration failed.';
          print('⚠️ [REGISTER API] Server business error: $msg');
          throw AuthFailure(msg);
        }
        return responseData.isNotEmpty ? responseData : {'message': 'Registration successful'};
      } else {
        throw const AuthFailure('Failed to register. Please try again.');
      }
    } on DioException catch (e) {
      final errorLog = '''
==================== ❌ REGISTER API DIO EXCEPTION ====================
Error Type   : ${e.type}
Error Message: ${e.message}
Status Code  : ${e.response?.statusCode}
Response Data: ${e.response?.data != null ? (e.response!.data is Map || e.response!.data is List ? jsonEncode(e.response!.data) : e.response!.data) : "null"}
======================================================================''';
      print(errorLog);
      developer.log(errorLog, name: 'RegisterAPI');

      final serverMessage = _extractErrorMessage(e);
      if (serverMessage != null && serverMessage.trim().isNotEmpty) {
        throw AuthFailure(serverMessage.trim());
      }
      throw const AuthFailure('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      final generalErrorLog = '''
==================== ❌ REGISTER API EXCEPTION ====================
Exception: $e
====================================================================''';
      print(generalErrorLog);
      developer.log(generalErrorLog, name: 'RegisterAPI');

      if (e is AuthFailure) rethrow;
      throw const AuthFailure('An unexpected error occurred. Please try again later.');
    }
  }

  @override
  Future<List<IntroBannerModel>> getIntroBanners() async {
    try {
      debugPrint('🌍 API Request -> GET ${ApiEndpoints.settings}');
      final response = await dio.get(
        ApiEndpoints.settings,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      debugPrint('🌍 API Response [Settings]: ${response.statusCode}');

      final dataMap = _parseResponseMap(response.data);
      final data = dataMap['data'];
      if (data is Map) {
        final banners = data['banners'];
        if (banners is Map) {
          final introList = banners['intro_screen'];
          if (introList is List) {
            final list = introList
                .whereType<Map>()
                .map((item) => IntroBannerModel.fromJson(Map<String, dynamic>.from(item)))
                .toList();
            list.sort((a, b) => a.order.compareTo(b.order));
            debugPrint('✅ Loaded ${list.length} intro banners');
            return list;
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ Error fetching intro banners: $e');
      return [];
    }
  }
}
