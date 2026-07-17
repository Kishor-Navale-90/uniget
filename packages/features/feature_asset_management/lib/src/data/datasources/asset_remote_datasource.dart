import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/asset_model.dart';

abstract class AssetRemoteDataSource {
  Future<List<AssetModel>> getAssets({String? departmentId});
  Future<AssetModel> getAssetById(String id);

  /// Fire-and-forget from the caller's point of view: the SyncEngine
  /// (not this datasource) decides when this is actually called,
  /// based on connectivity — see AssetSyncHandler.
  Future<void> transferAsset({
    required String assetId,
    required String toDepartmentId,
    required String reason,
    required String idempotencyKey,
  });
}

@LazySingleton(as: AssetRemoteDataSource)
class AssetRemoteDataSourceImpl implements AssetRemoteDataSource {
  AssetRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<AssetModel>> getAssets({String? departmentId}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/v1/assets',
        queryParameters: {if (departmentId != null) 'departmentId': departmentId},
      );
      return response.data!
          .cast<Map<String, dynamic>>()
          .map(AssetModel.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load assets', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<AssetModel> getAssetById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/assets/$id');
      return AssetModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load asset', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> transferAsset({
    required String assetId,
    required String toDepartmentId,
    required String reason,
    required String idempotencyKey,
  }) async {
    try {
      await _dio.post<void>(
        '/v1/assets/$assetId/transfer',
        data: {'toDepartmentId': toDepartmentId, 'reason': reason},
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ServerException('Asset was already transferred by someone else', statusCode: 409);
      }
      throw ServerException(e.message ?? 'Transfer failed', statusCode: e.response?.statusCode);
    }
  }
}
