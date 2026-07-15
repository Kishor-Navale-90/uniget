import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<(UserModel, String token)> loginWithSso(String ssoIdToken);
  Future<void> requestOtp(String email);
  Future<(UserModel, String token)> verifyOtp({required String email, required String otp});
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<(UserModel, String token)> loginWithSso(String ssoIdToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/sso',
        data: {'idToken': ssoIdToken},
      );
      final data = response.data!;
      return (UserModel.fromJson(data['user'] as Map<String, dynamic>), data['token'] as String);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'SSO login failed', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> requestOtp(String email) async {
    try {
      await _dio.post<void>('/v1/auth/otp/request', data: {'email': email});
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Could not send OTP', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<(UserModel, String token)> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/otp/verify',
        data: {'email': email, 'otp': otp},
      );
      final data = response.data!;
      return (UserModel.fromJson(data['user'] as Map<String, dynamic>), data['token'] as String);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Invalid OTP', statusCode: e.response?.statusCode);
    }
  }
}
