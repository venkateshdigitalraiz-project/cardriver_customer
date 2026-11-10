import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/app_auth_storage.dart';
import '../models/rating_model.dart';

abstract class RatingRemoteDataSource {
  Future<bool> submitRating(RatingModel ratingModel);
}

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  final Dio dio;

  RatingRemoteDataSourceImpl({required this.dio});

  Future<Map<String, String>> _resolveAuthHeaders() async {
    final token = await AppAuthStorage.getOrCollectToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Cookie': 'user_token=$token',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<bool> submitRating(RatingModel ratingModel) async {
    try {
      final headers = await _resolveAuthHeaders();
      final body = ratingModel.toJson();

      // Primary endpoint: POST /api/user/driver-booking/rate
      final endpoint = '${ApiEndpoints.driverBooking}/rate';
      debugPrint('⭐ Rating API Request -> POST $endpoint with body: $body');

      try {
        final response = await dio.post(
          endpoint,
          data: body,
          options: Options(headers: headers),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('⭐ Rating submitted successfully');
          return true;
        }
      } on DioException catch (dioErr) {
        // If 404, fallback to /api/user/driver-booking/:id/rate
        if (dioErr.response?.statusCode == 404 && ratingModel.bookingId.isNotEmpty) {
          final fallbackEndpoint = '${ApiEndpoints.driverBooking}/${ratingModel.bookingId}/rate';
          debugPrint('⭐ Falling back to endpoint: POST $fallbackEndpoint');
          final fallbackResponse = await dio.post(
            fallbackEndpoint,
            data: body,
            options: Options(headers: headers),
          );
          if (fallbackResponse.statusCode == 200 || fallbackResponse.statusCode == 201) {
            return true;
          }
        } else {
          final message = dioErr.response?.data?['message']?.toString() ??
              dioErr.message ??
              'Failed to submit rating';
          throw ServerFailure(message);
        }
      }

      return true;
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Rating submission error: $e');
      throw ServerFailure(e.toString());
    }
  }
}

