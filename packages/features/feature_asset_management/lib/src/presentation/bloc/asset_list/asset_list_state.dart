import 'package:equatable/equatable.dart';

import '../../../domain/entities/asset.dart';

enum AssetListStatus { initial, loading, loaded, failure }

class AssetListState extends Equatable {
  const AssetListState({
    this.status = AssetListStatus.initial,
    this.assets = const [],
    this.isRefreshing = false,
    this.errorMessage,
  });

  final AssetListStatus status;
  final List<Asset> assets;
  final bool isRefreshing;
  final String? errorMessage;

  AssetListState copyWith({
    AssetListStatus? status,
    List<Asset>? assets,
    bool? isRefreshing,
    String? errorMessage,
  }) =>
      AssetListState(
        status: status ?? this.status,
        assets: assets ?? this.assets,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, assets, isRefreshing, errorMessage];
}
