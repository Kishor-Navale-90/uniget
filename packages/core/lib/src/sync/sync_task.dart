import 'package:equatable/equatable.dart';

/// A dequeued row from [SyncQueue], deserialized and ready to be
/// replayed against the remote API by whichever feature registers a
/// handler for its `entityType`.
class SyncTask extends Equatable {
  const SyncTask({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    required this.retryCount,
  });

  final int id;
  final String entityType;
  final String operation;
  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final int retryCount;

  @override
  List<Object?> get props => [id, entityType, operation, payload, idempotencyKey, retryCount];
}

/// Each feature package (Asset, Gate Pass, Visitor) implements this
/// and registers itself with the [SyncEngine] at startup — the engine
/// itself has zero knowledge of what an "asset transfer" is.
abstract class SyncHandler {
  /// The `entityType` this handler replays, e.g. "asset".
  String get entityType;

  /// Replay one queued mutation against the remote API. Throwing
  /// surfaces as a retry (network hiccup) or a conflict (409 from the
  /// server, meaning someone else changed the record first).
  Future<void> replay(SyncTask task);
}
