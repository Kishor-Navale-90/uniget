import '../auth/session.dart';

/// Every protected route in the app-shell router (see
/// `apps/uniget_app/lib/routing/app_router.dart`) declares a guard
/// like this instead of ad-hoc `if` checks scattered across widgets —
/// so adding screen #101 can't accidentally forget an RBAC check.
abstract class RouteGuard {
  bool canActivate(AppSession? session);

  /// Where to redirect if [canActivate] returns false.
  String get redirectPath;
}

/// Any authenticated user, regardless of role.
class AuthenticatedGuard implements RouteGuard {
  const AuthenticatedGuard();
  @override
  bool canActivate(AppSession? session) => session != null;
  @override
  String get redirectPath => '/login';
}

/// Restricts a route to a specific set of roles, e.g. asset disposal
/// approval is `RoleGuard({UserRole.itAdmin, UserRole.superAdmin})`.
class RoleGuard implements RouteGuard {
  const RoleGuard(this.allowedRoles);
  final Set<UserRole> allowedRoles;

  @override
  bool canActivate(AppSession? session) =>
      session != null && allowedRoles.contains(session.role);

  @override
  String get redirectPath => '/unauthorized';
}
