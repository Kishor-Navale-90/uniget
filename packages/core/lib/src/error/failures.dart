import 'package:equatable/equatable.dart';

/// Base class for every domain-level failure. Repositories return
/// `Either<Failure, T>` (see [core/usecase/usecase.dart]) instead of
/// throwing, so the presentation layer never has to wrap calls in
/// try/catch — it just pattern-matches on the Either.
abstract class Failure extends Equatable {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Server/API responded with an error (4xx/5xx).
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// No local network connectivity — the offline-first repository should
/// have already served cached data before this ever reaches the UI;
/// this failure is for actions that genuinely cannot be queued (e.g.
/// a security-sensitive approval that must round-trip immediately).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Local database (Drift) read/write error.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Request rejected by the API gateway's role/department RBAC check.
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have permission to perform this action']);
}

/// Input failed client-side validation before it was ever sent.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// A queued offline mutation conflicted with a newer server-side change
/// on sync (see SyncEngine's conflict resolution policy).
class SyncConflictFailure extends Failure {
  const SyncConflictFailure(super.message, {this.serverVersion});

  final Map<String, dynamic>? serverVersion;

  @override
  List<Object?> get props => [message, code, serverVersion];
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
