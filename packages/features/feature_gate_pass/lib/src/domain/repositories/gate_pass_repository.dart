import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/gate_pass.dart';

/// Follows the exact same shape as `AssetRepository` — a reactive
/// `watch*` read path backed by this feature's own local Drift cache,
/// and optimistic-write-plus-sync-queue methods for anything mutating.
abstract class GatePassRepository {
  Stream<Either<Failure, List<GatePass>>> watchGatePasses({String? departmentId});

  Future<Either<Failure, Unit>> createRequest({
    required String assetOrMaterialLabel,
    required String reason,
    required bool isReturnable,
  });

  /// Called by the security/reception app when a guard scans a QR at
  /// the gate — resolves the pass, checks approval status, and (if
  /// approved) logs the release/return.
  Future<Either<Failure, GatePass>> verifyAndReleaseAtGate(String qrPayload);
}
