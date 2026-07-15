import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';

/// Caches the last-known signed-in user so the app can render a
/// dashboard instantly on cold start (offline-first) while
/// [GetCurrentSession] revalidates against the server in the
/// background.
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clear();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._session);
  final SessionManager _session;

  UserModel? _memoryCache;

  @override
  Future<void> cacheUser(UserModel user) async {
    _memoryCache = user;
    // NOTE: in the full implementation this also persists to a Drift
    // `cached_user` table (via a feature-owned table composed into
    // AppDatabase) so it survives an app restart while fully offline.
  }

  @override
  Future<UserModel?> getCachedUser() async => _memoryCache;

  @override
  Future<void> clear() async {
    _memoryCache = null;
    await _session.forceLogout();
  }
}
