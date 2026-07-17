import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Retries idempotent GET requests on transient network errors —
/// deliberately does NOT retry POST/PUT/PATCH automatically, since a
/// gate-pass approval or asset transfer must never be double-submitted;
/// those go through the offline sync queue instead (see SyncEngine).
@lazySingleton
class RetryInterceptor extends Interceptor {
  static const _maxRetries = 2;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isGet = err.requestOptions.method == 'GET';
    final isTransient = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    final attempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;

    if (isGet && isTransient && attempt < _maxRetries) {
      err.requestOptions.extra['retry_attempt'] = attempt + 1;
      await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      try {
        final response = await Dio().fetch<dynamic>(err.requestOptions);
        return handler.resolve(response);
      } catch (_) {
        // Fall through to default error handling below.
      }
    }
    handler.next(err);
  }
}
