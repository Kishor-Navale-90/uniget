import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// Every business action in the app (one per class — Single
/// Responsibility) implements this. `Type` is the success value,
/// `Params` is the input. Bloc event handlers call exactly one
/// UseCase and never talk to a Repository directly — that boundary
/// is what keeps 100+ screens testable in isolation.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// For use cases that stream, rather than one-shot resolve (e.g. a
/// live "assets currently out" count on a dashboard backed by Drift's
/// reactive queries).
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// For the (few) use cases that take no parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
