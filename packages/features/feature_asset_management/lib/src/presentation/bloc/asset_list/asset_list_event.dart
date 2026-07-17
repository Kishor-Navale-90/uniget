import 'package:equatable/equatable.dart';

import '../../../domain/entities/asset.dart';

sealed class AssetListEvent extends Equatable {
  const AssetListEvent();
  @override
  List<Object?> get props => [];
}

/// Starts the reactive subscription to the local cache — call once
/// when the page mounts.
class AssetListSubscriptionRequested extends AssetListEvent {
  const AssetListSubscriptionRequested({this.departmentId});
  final String? departmentId;
  @override
  List<Object?> get props => [departmentId];
}

/// Fed internally by the repository's stream via `emit.onEach` — not
/// dispatched directly by the UI, but public so bloc_test can assert
/// against it like any other event.
class AssetListUpdated extends AssetListEvent {
  const AssetListUpdated(this.assets);
  final List<Asset> assets;
  @override
  List<Object?> get props => [assets];
}

class AssetListRefreshRequested extends AssetListEvent {
  const AssetListRefreshRequested();
}
