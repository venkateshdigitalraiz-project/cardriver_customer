import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getUserProfile();
  Future<ProfileModel> updateUserProfile(ProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  Future<String?> _getAuthCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_cookie');
  }

  @override
  Future<ProfileModel> getUserProfile() async {
    try {
      debugPrint('🌍 API Request -> GET ${ApiEndpoints.profile}');
      
      final authCookie = await _getAuthCookie();
      
      final response = await dio.get(
        ApiEndpoints.profile,
        options: Options(headers: {
          'Content-Type': 'application/json',
          if (authCookie != null && authCookie.isNotEmpty) 'Cookie': authCookie,
          // Add dummy Bearer token if API specifically requires it, but usually cookie is enough
          // if not handled properly by backend. If the backend needs Bearer token, we extract it.
          if (authCookie != null && authCookie.contains('user_token='))
            'Authorization': 'Bearer ${authCookie.split('user_token=').last.split(';').first}',
        }),
      );

      debugPrint('✅ API Response -> Status: ${response.statusCode}');
      debugPrint('✅ API Data -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final userData = (responseData is Map<String, dynamic> && responseData.containsKey('data')) 
            ? responseData['data'] 
            : (responseData is Map<String, dynamic> && responseData.containsKey('user'))
                ? responseData['user']
                : responseData;
                
        return ProfileModel.fromJson(userData ?? {});
      } else {
        throw const ServerFailure('Failed to fetch profile.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      if (e.response?.data is Map<String, dynamic>) {
         final data = e.response!.data as Map<String, dynamic>;
         if (data.containsKey('message')) {
           throw ServerFailure(data['message']);
         }
      }
      throw const ServerFailure('Unable to connect to the server.');
    } catch (e) {
      debugPrint('❌ API Exception -> $e');
      if (e is ServerFailure) rethrow;
      throw const ServerFailure('An unexpected error occurred.');
    }
  }

  @override
  Future<ProfileModel> updateUserProfile(ProfileModel profile) async {
    try {
      debugPrint('🌍 API Request -> PUT ${ApiEndpoints.profile}');
      
      final authCookie = await _getAuthCookie();
      final payload = profile.toJson();
      
      final response = await dio.put(
        ApiEndpoints.profile,
        options: Options(headers: {
          'Content-Type': 'application/json',
          if (authCookie != null && authCookie.isNotEmpty) 'Cookie': authCookie,
          if (authCookie != null && authCookie.contains('user_token='))
            'Authorization': 'Bearer ${authCookie.split('user_token=').last.split(';').first}',
        }),
        data: payload,
      );

      debugPrint('✅ API Response -> Status: ${response.statusCode}');
      debugPrint('✅ API Data -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final userData = (responseData is Map<String, dynamic> && responseData.containsKey('data')) 
            ? responseData['data'] 
            : (responseData is Map<String, dynamic> && responseData.containsKey('user'))
                ? responseData['user']
                : responseData;
                
        return ProfileModel.fromJson(userData ?? {});
      } else {
        throw const ServerFailure('Failed to update profile.');
      }
    } on DioException catch (e) {
      debugPrint('❌ API DioException -> ${e.message}, Response: ${e.response?.data}');
      if (e.response?.data is Map<String, dynamic>) {
         final data = e.response!.data as Map<String, dynamic>;
         if (data.containsKey('message')) {
           throw ServerFailure(data['message']);
         }
      }
      throw const ServerFailure('Unable to connect to the server.');
    } catch (e) {
      debugPrint('❌ API Exception -> $e');
      if (e is ServerFailure) rethrow;
      throw const ServerFailure('An unexpected error occurred.');
    }
  }
}
