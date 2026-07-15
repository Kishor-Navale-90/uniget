import 'package:injectable/injectable.dart';

import '../local/asset_local_database.dart';
import '../models/asset_model.dart';

/// Thin wrapper translating between [AssetLocalDatabase]'s Drift rows
/// and [AssetModel] — the repository never imports Drift types
/// directly, only this datasource does.
abstract class AssetLocalDataSource {
  Stream<List<AssetModel>> watchAssets({String? departmentId});
  Future<AssetModel?> getAssetById(String id);
  Future<void> upsertFromRemote(List<AssetModel> assets);
  Future<void> applyOptimisticTransfer(String assetId, String toDepartmentId, String toDepartmentName);
}

@LazySingleton(as: AssetLocalDataSource)
class AssetLocalDataSourceImpl implements AssetLocalDataSource {
  AssetLocalDataSourceImpl(this._db);
  final AssetLocalDatabase _db;

  @override
  Stream<List<AssetModel>> watchAssets({String? departmentId}) => _db
      .watchAll(departmentId: departmentId)
      .map((rows) => rows.map(AssetModel.fromLocalRow).toList(growable: false));

  @override
  Future<AssetModel?> getAssetById(String id) async {
    final row = await _db.getById(id);
    return row == null ? null : AssetModel.fromLocalRow(row);
  }

  @override
  Future<void> upsertFromRemote(List<AssetModel> assets) =>
      _db.upsertAll(assets.map((a) => a.toLocalCompanion()).toList(growable: false));

  @override
  Future<void> applyOptimisticTransfer(
    String assetId,
    String toDepartmentId,
    String toDepartmentName,
  ) async {
    final existingRow = await _db.getById(assetId);
    if (existingRow == null) return;
    final updatedModel = AssetModel.fromLocalRow(existingRow)
        .copyWith(departmentId: toDepartmentId, departmentName: toDepartmentName);
    await _db.upsertOne(updatedModel.toLocalCompanion(hasPendingLocalChanges: true));
  }
}
