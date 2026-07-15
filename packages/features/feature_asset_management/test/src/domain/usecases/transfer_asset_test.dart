import 'package:core/core.dart';
import 'package:feature_asset_management/src/domain/repositories/asset_repository.dart';
import 'package:feature_asset_management/src/domain/usecases/transfer_asset.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  late _MockAssetRepository repository;
  late TransferAsset useCase;

  setUp(() {
    repository = _MockAssetRepository();
    useCase = TransferAsset(repository);
  });

  const params = TransferAssetParams(
    assetId: 'asset-1',
    toDepartmentId: 'dept-finance',
    reason: 'Reassigned per project change',
  );

  test('rejects an empty reason without touching the repository', () async {
    final result = await useCase(
      const TransferAssetParams(assetId: 'asset-1', toDepartmentId: 'dept-finance', reason: '  '),
    );

    expect(result, isA<Left<Failure, Unit>>());
    verifyNever(() => repository.transferAsset(
          assetId: any(named: 'assetId'),
          toDepartmentId: any(named: 'toDepartmentId'),
          reason: any(named: 'reason'),
        ));
  });

  test('delegates to the repository when the reason is valid', () async {
    when(() => repository.transferAsset(
          assetId: params.assetId,
          toDepartmentId: params.toDepartmentId,
          reason: params.reason,
        )).thenAnswer((_) async => const Right(unit));

    final result = await useCase(params);

    expect(result, const Right<Failure, Unit>(unit));
    verify(() => repository.transferAsset(
          assetId: params.assetId,
          toDepartmentId: params.toDepartmentId,
          reason: params.reason,
        )).called(1);
  });
}
