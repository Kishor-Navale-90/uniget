import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';

class _AddOneUseCase implements UseCase<int, int> {
  @override
  Future<Either<Failure, int>> call(int params) async => Right(params + 1);
}

void main() {
  test('UseCase returns Right on success', () async {
    final useCase = _AddOneUseCase();
    final result = await useCase(1);
    expect(result, const Right<Failure, int>(2));
  });
}
