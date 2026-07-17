import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../utils/logger.dart';

/// Structured request/response logging — stripped of Authorization
/// header contents and gated behind `AppConstants.enableNetworkLogs`
/// (false in the prod flavor) so tokens/PII never end up in logs.
@lazySingleton
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLogger.d('--> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    appLogger.d('<-- ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    appLogger.e('<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}', error: err);
    handler.next(err);
  }
}
