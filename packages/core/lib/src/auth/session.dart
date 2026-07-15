import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// The single source of truth for "who is signed in, with what role,
/// in what department" — read by the AuthInterceptor (to attach the
/// token), the router's route guards (to allow/deny a screen), and any
/// widget that needs to show/hide UI by role. There is deliberately
/// only one of these in the whole app (see core_module registration).
@lazySingleton
class SessionManager {
  SessionManager(this._secureStorage) {
    unawaited(_restore());
  }

  final FlutterSecureStorage _secureStorage;

  final _stateController = StreamController<AppSession?>.broadcast();
  AppSession? _current;

  Stream<AppSession?> get onSessionChanged => _stateController.stream;
  AppSession? get current => _current;
  String? get currentToken => _current?.token;

  Future<void> setSession(AppSession session) async {
    _current = session;
    await _secureStorage.write(key: _tokenKey, value: session.token);
    await _secureStorage.write(key: _roleKey, value: session.role.name);
    await _secureStorage.write(key: _departmentKey, value: session.departmentId ?? '');
    _stateController.add(_current);
  }

  Future<void> forceLogout() async {
    _current = null;
    await _secureStorage.deleteAll();
    _stateController.add(null);
  }

  Future<void> _restore() async {
    final token = await _secureStorage.read(key: _tokenKey);
    final roleStr = await _secureStorage.read(key: _roleKey);
    final dept = await _secureStorage.read(key: _departmentKey);
    if (token != null && roleStr != null) {
      _current = AppSession(
        token: token,
        role: UserRole.values.byName(roleStr),
        departmentId: (dept?.isEmpty ?? true) ? null : dept,
      );
      _stateController.add(_current);
    }
  }

  static const _tokenKey = 'gateflow_token';
  static const _roleKey = 'gateflow_role';
  static const _departmentKey = 'gateflow_department';
}

/// Mirrors Part I §7.1 of the concept document — kept in `core` because
/// route guards, the API auth header, and every feature's RBAC
/// filtering all need the same enum.
enum UserRole { superAdmin, departmentAdmin, approver, security, visitor }

class AppSession {
  const AppSession({required this.token, required this.role, this.departmentId});

  final String token;
  final UserRole role;

  /// Null for Super Admin (cross-department) and Security/Reception
  /// (org-wide by design — see concept doc §8.2).
  final String? departmentId;

  bool get isScopedToDepartment => departmentId != null;
}
