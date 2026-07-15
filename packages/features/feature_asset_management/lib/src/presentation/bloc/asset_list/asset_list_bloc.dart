import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repositories/asset_repository.dart';
import '../../../domain/usecases/get_assets.dart';
import 'asset_list_event.dart';
import 'asset_list_state.dart';

/// One Bloc per screen-slice (the house rule for all 100+ screens —
/// see ARCHITECTURE.md). This Bloc's only job is: subscribe to the
/// offline-first stream from [WatchAssets], translate Failure/List
/// into [AssetListState], and expose a manual refresh action. No
/// business logic lives here — that's entirely in the UseCase/Repository.
@injectable
class AssetListBloc extends Bloc<AssetListEvent, AssetListState> {
  AssetListBloc(this._watchAssets, this._assetRepository) : super(const AssetListState()) {
    on<AssetListSubscriptionRequested>(_onSubscriptionRequested);
    on<AssetListUpdated>(_onAssetsUpdated);
    on<AssetListRefreshRequested>(_onRefreshRequested);
  }

  final WatchAssets _watchAssets;
  final AssetRepository _assetRepository;
  StreamSubscription<dynamic>? _subscription;

  Future<void> _onSubscriptionRequested(
    AssetListSubscriptionRequested event,
    Emitter<AssetListState> emit,
  ) async {
    emit(state.copyWith(status: AssetListStatus.loading));
    await _subscription?.cancel();

    // Bridge the repository's Stream<Either<Failure, List<Asset>>>
    // into Bloc events rather than emitting directly from the stream
    // callback — keeps every state transition going through `on<>`
    // handlers, which is what bloc_test asserts against.
    _subscription = _watchAssets(WatchAssetsParams(departmentId: event.departmentId)).listen(
      (result) => result.when(
        failure: (f) => emit(state.copyWith(status: AssetListStatus.failure, errorMessage: f.message)),
        success: (assets) => add(AssetListUpdated(assets)),
      ),
    );

    // Kick a background refresh so the cache doesn't go stale purely
    // because the app is currently online but hasn't recently pulled.
    unawaited(_assetRepository.refreshFromRemote());
  }

  void _onAssetsUpdated(AssetListUpdated event, Emitter<AssetListState> emit) {
    emit(state.copyWith(status: AssetListStatus.loaded, assets: event.assets));
  }

  Future<void> _onRefreshRequested(
    AssetListRefreshRequested event,
    Emitter<AssetListState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    final result = await _assetRepository.refreshFromRemote();
    result.when(
      failure: (f) => emit(state.copyWith(isRefreshing: false, errorMessage: f.message)),
      success: (_) => emit(state.copyWith(isRefreshing: false)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
