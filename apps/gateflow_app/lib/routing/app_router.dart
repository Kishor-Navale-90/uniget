import 'package:core/core.dart';
import 'package:feature_asset_management/feature_asset_management.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_gate_pass/feature_gate_pass.dart';
import 'package:feature_visitor_management/feature_visitor_management.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import 'main_shell.dart';

/// The single route tree for the whole app — the same tree renders on
/// a phone, a desktop window, and a browser tab; `MainShell` (via
/// design_system's `AdaptiveScaffold`) is what changes the chrome
/// around it per platform, not the routes themselves.
///
/// Route guards (see `core/routing/route_guard.dart`) are declared
/// per-route via `redirect`, not as ad-hoc checks inside each page
/// widget — this is what keeps screen #101 from shipping without an
/// RBAC check.
GoRouter buildAppRouter() {
  final session = getIt<SessionManager>();

  return GoRouter(
    initialLocation: '/assets',
    refreshListenable: _SessionRefreshStream(session),
    redirect: (context, state) {
      final loggedIn = session.current != null;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/assets';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/assets',
            builder: (context, state) => AssetListPage(departmentId: session.current?.departmentId),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => AssetDetailPage(assetId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/gate-passes',
            builder: (context, state) => const GatePassListPage(),
          ),
          GoRoute(
            path: '/visitors',
            redirect: (context, state) {
              // Example role guard: only Security/Reception and above
              // manage visitors from the main shell; a Visitor's own
              // guest-session check-in is a separate, unauthenticated
              // route (`/kiosk`), not shown here.
              const guard = RoleGuard({
                UserRole.superAdmin,
                UserRole.departmentAdmin,
                UserRole.security,
              });
              return guard.canActivate(session.current) ? null : guard.redirectPath;
            },
            builder: (context, state) => const VisitorCheckinPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('You do not have permission to view this page')),
        ),
      ),
    ],
  );
}

/// Bridges [SessionManager]'s stream to a `Listenable` so GoRouter
/// re-evaluates `redirect` the instant login/logout happens, instead
/// of only on navigation.
class _SessionRefreshStream extends ChangeNotifier {
  _SessionRefreshStream(SessionManager session) {
    _sub = session.onSessionChanged.listen((_) => notifyListeners());
  }
  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
