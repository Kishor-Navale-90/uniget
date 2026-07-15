import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Single configured Dio instance for the whole app. Every remote
/// datasource takes this via constructor injection — never creates
/// its own Dio — so auth headers, retry policy, and logging are
/// consistent everywhere and swappable in tests.
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    RetryInterceptor retryInterceptor,
    LoggingInterceptor loggingInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.addAll([authInterceptor, retryInterceptor, loggingInterceptor]);
    return dio;
  }
}
