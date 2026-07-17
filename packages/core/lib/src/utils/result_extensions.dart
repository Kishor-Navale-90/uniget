import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// Small ergonomic helpers on top of fpdart's Either so Bloc event
/// handlers read as a single fluent chain instead of nested
/// `fold(...)` calls repeated in every one of the 100+ screens' worth
/// of blocs.
extension EitherFailureX<T> on Either<Failure, T> {
  R when<R>({
    required R Function(Failure failure) failure,
    required R Function(T value) success,
  }) =>
      fold(failure, success);
}
