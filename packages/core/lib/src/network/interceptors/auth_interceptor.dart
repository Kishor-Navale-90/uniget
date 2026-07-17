import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../auth/session.dart';

/// Attaches the current session token + role/department claims to
/// every outgoing request, and forces a logout on 401 so a stale
/// token can never silently keep hitting department-scoped endpoints.
@lazySingleton
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._session);
  final SessionManager _session;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _session.currentToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _session.forceLogout();
    }
    handler.next(err);
  }
}
