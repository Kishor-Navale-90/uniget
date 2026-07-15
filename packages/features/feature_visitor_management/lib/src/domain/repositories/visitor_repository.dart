import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/visitor.dart';

abstract class VisitorRepository {
  /// Backs the real-time on-site headcount view (concept doc §5.3) —
  /// reactive for the same offline-first reasons as every other
  /// feature's `watch*` method.
  Stream<Either<Failure, List<Visitor>>> watchOnSiteVisitors();

  Future<Either<Failure, Visitor>> checkIn({
    required String name,
    required String hostId,
    required String category,
  });

  Future<Either<Failure, Unit>> checkOut(String visitorId);
}
