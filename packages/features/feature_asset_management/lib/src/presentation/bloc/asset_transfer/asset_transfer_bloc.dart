import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/transfer_asset.dart';
import 'asset_transfer_event.dart';
import 'asset_transfer_state.dart';

/// Deliberately a SEPARATE Bloc from [AssetListBloc] even though both
/// operate on "assets" — this feature's list screen and its transfer
/// dialog/sheet are different screen-slices with different
/// lifecycles, so they get different Blocs (house rule, see
/// ARCHITECTURE.md "One Bloc per screen-slice").
@injectable
class AssetTransferBloc extends Bloc<AssetTransferEvent, AssetTransferState> {
  AssetTransferBloc(this._transferAsset) : super(const AssetTransferState()) {
    on<AssetTransferSubmitted>(_onSubmitted);
  }

  final TransferAsset _transferAsset;

  Future<void> _onSubmitted(AssetTransferSubmitted event, Emitter<AssetTransferState> emit) async {
    emit(state.copyWith(status: AssetTransferStatus.submitting));
    final result = await _transferAsset(
      TransferAssetParams(
        assetId: event.assetId,
        toDepartmentId: event.toDepartmentId,
        reason: event.reason,
      ),
    );
    result.when(
      failure: (f) => emit(state.copyWith(status: AssetTransferStatus.failure, errorMessage: f.message)),
      // The repository always returns success here once the local
      // write + sync-queue enqueue succeed — whether or not the
      // device is online right now. The UI shows an "unsynced" badge
      // (Asset.hasPendingLocalChanges) rather than blocking on the
      // network round-trip.
      success: (_) => emit(state.copyWith(status: AssetTransferStatus.submitted)),
    );
  }
}
