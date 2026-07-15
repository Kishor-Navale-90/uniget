import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:feature_asset_management/src/domain/usecases/transfer_asset.dart';
import 'package:feature_asset_management/src/presentation/bloc/asset_transfer/asset_transfer_bloc.dart';
import 'package:feature_asset_management/src/presentation/bloc/asset_transfer/asset_transfer_event.dart';
import 'package:feature_asset_management/src/presentation/bloc/asset_transfer/asset_transfer_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransferAsset extends Mock implements TransferAsset {}

void main() {
  late _MockTransferAsset transferAsset;

  setUpAll(() {
    registerFallbackValue(
      const TransferAssetParams(assetId: '', toDepartmentId: '', reason: ''),
    );
  });

  setUp(() => transferAsset = _MockTransferAsset());

  const event = AssetTransferSubmitted(
    assetId: 'asset-1',
    toDepartmentId: 'dept-finance',
    reason: 'Reassigned per project change',
  );

  blocTest<AssetTransferBloc, AssetTransferState>(
    'emits [submitting, submitted] on success — even while offline, since '
    'the repository resolves as soon as the local write + sync-queue enqueue succeed',
    setUp: () {
      when(() => transferAsset(any())).thenAnswer((_) async => const Right(unit));
    },
    build: () => AssetTransferBloc(transferAsset),
    act: (bloc) => bloc.add(event),
    expect: () => [
      const AssetTransferState(status: AssetTransferStatus.submitting),
      const AssetTransferState(status: AssetTransferStatus.submitted),
    ],
  );

  blocTest<AssetTransferBloc, AssetTransferState>(
    'emits [submitting, failure] when the use case rejects the request',
    setUp: () {
      when(() => transferAsset(any()))
          .thenAnswer((_) async => const Left(ValidationFailure('A transfer reason is required')));
    },
    build: () => AssetTransferBloc(transferAsset),
    act: (bloc) => bloc.add(
      const AssetTransferSubmitted(assetId: 'asset-1', toDepartmentId: 'dept-finance', reason: ''),
    ),
    expect: () => [
      const AssetTransferState(status: AssetTransferStatus.submitting),
      const AssetTransferState(
        status: AssetTransferStatus.failure,
        errorMessage: 'A transfer reason is required',
      ),
    ],
  );
}
