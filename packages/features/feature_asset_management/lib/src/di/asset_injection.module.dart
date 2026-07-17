//@GeneratedMicroModule;FeatureAssetManagementPackageModule;package:feature_asset_management/src/di/asset_injection.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:core/core.dart' as _i494;
import 'package:dio/dio.dart' as _i361;
import 'package:feature_asset_management/src/data/datasources/asset_local_datasource.dart'
    as _i446;
import 'package:feature_asset_management/src/data/datasources/asset_remote_datasource.dart'
    as _i991;
import 'package:feature_asset_management/src/data/local/asset_local_database.dart'
    as _i434;
import 'package:feature_asset_management/src/data/repositories/asset_repository_impl.dart'
    as _i917;
import 'package:feature_asset_management/src/domain/repositories/asset_repository.dart'
    as _i666;
import 'package:feature_asset_management/src/domain/usecases/get_asset_by_id.dart'
    as _i497;
import 'package:feature_asset_management/src/domain/usecases/get_asset_dashboard_stats.dart'
    as _i560;
import 'package:feature_asset_management/src/domain/usecases/get_assets.dart'
    as _i958;
import 'package:feature_asset_management/src/domain/usecases/transfer_asset.dart'
    as _i949;
import 'package:feature_asset_management/src/presentation/bloc/asset_list/asset_list_bloc.dart'
    as _i909;
import 'package:feature_asset_management/src/presentation/bloc/asset_transfer/asset_transfer_bloc.dart'
    as _i1061;
import 'package:injectable/injectable.dart' as _i526;

class FeatureAssetManagementPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final assetDatabaseModule = _$AssetDatabaseModule();
    gh.lazySingleton<_i434.AssetLocalDatabase>(
        () => assetDatabaseModule.assetLocalDatabase());
    gh.lazySingleton<_i991.AssetRemoteDataSource>(
        () => _i991.AssetRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i446.AssetLocalDataSource>(
        () => _i446.AssetLocalDataSourceImpl(gh<_i434.AssetLocalDatabase>()));
    gh.lazySingleton<_i666.AssetRepository>(() => _i917.AssetRepositoryImpl(
          gh<_i991.AssetRemoteDataSource>(),
          gh<_i446.AssetLocalDataSource>(),
          gh<_i494.NetworkInfo>(),
          gh<_i494.AppDatabase>(),
          gh<_i494.SyncEngine>(),
        ));
    gh.factory<_i949.TransferAsset>(
        () => _i949.TransferAsset(gh<_i666.AssetRepository>()));
    gh.factory<_i560.WatchAssetDashboardStats>(
        () => _i560.WatchAssetDashboardStats(gh<_i666.AssetRepository>()));
    gh.factory<_i958.WatchAssets>(
        () => _i958.WatchAssets(gh<_i666.AssetRepository>()));
    gh.factory<_i497.GetAssetById>(
        () => _i497.GetAssetById(gh<_i666.AssetRepository>()));
    gh.factory<_i909.AssetListBloc>(() => _i909.AssetListBloc(
          gh<_i958.WatchAssets>(),
          gh<_i666.AssetRepository>(),
        ));
    gh.factory<_i1061.AssetTransferBloc>(
        () => _i1061.AssetTransferBloc(gh<_i949.TransferAsset>()));
  }
}

class _$AssetDatabaseModule extends _i434.AssetDatabaseModule {}
