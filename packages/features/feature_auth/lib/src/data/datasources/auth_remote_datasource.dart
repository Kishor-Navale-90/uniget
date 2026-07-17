import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> checkRegistrationEmail(String email);
  Future<void> requestRegistrationOtp(String email);
  Future<String> verifyRegistrationOtp({required String email, required String otp});
  Future<(UserModel, String token)> setPassword({
    required String registrationToken,
    required String password,
  });
  Future<(UserModel, String token)> loginWithPassword({required String email, required String password});
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<void> checkRegistrationEmail(String email) async {
    try {
      await _dio.post<void>('/v1/auth/register/check-email', data: {'email': email});
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'This email is not eligible for registration',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> requestRegistrationOtp(String email) async {
    try {
      await _dio.post<void>('/v1/auth/register/otp/request', data: {'email': email});
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Could not send OTP', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<String> verifyRegistrationOtp({required String email, required String otp}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/register/otp/verify',
        data: {'email': email, 'otp': otp},
      );
      return response.data!['registrationToken'] as String;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Invalid OTP', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<(UserModel, String token)> setPassword({
    required String registrationToken,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/register/set-password',
        data: {'registrationToken': registrationToken, 'password': password},
      );
      final data = response.data!;
      return (UserModel.fromJson(data['user'] as Map<String, dynamic>), data['token'] as String);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Could not set password', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<(UserModel, String token)> loginWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data!;
      return (UserModel.fromJson(data['user'] as Map<String, dynamic>), data['token'] as String);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Invalid email or password', statusCode: e.response?.statusCode);
    }
  }
}
