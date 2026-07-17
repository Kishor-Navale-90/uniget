import 'package:drift/drift.dart' show Value;

import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_status.dart';
import '../local/asset_local_database.dart';

/// Maps between three shapes: the remote API's JSON, the local Drift
/// row (`AssetTableData`), and the domain `Asset` entity. Keeping all
/// three conversions in one file means a backend field rename or a
/// local schema migration only ever touches this file.
class AssetModel {
  const AssetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.qrCode,
    required this.status,
    required this.departmentId,
    required this.departmentName,
    this.assignedToUserId,
    this.assignedToUserName,
    this.location,
    this.warrantyExpiry,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        qrCode: json['qrCode'] as String,
        status: AssetStatus.values.byName(json['status'] as String),
        departmentId: json['departmentId'] as String,
        departmentName: json['departmentName'] as String,
        assignedToUserId: json['assignedToUserId'] as String?,
        assignedToUserName: json['assignedToUserName'] as String?,
        location: json['location'] as String?,
        warrantyExpiry: json['warrantyExpiry'] == null
            ? null
            : DateTime.parse(json['warrantyExpiry'] as String),
      );

  factory AssetModel.fromLocalRow(AssetTableData row) => AssetModel(
        id: row.id,
        name: row.name,
        category: row.category,
        qrCode: row.qrCode,
        status: AssetStatus.values.byName(row.status),
        departmentId: row.departmentId,
        departmentName: row.departmentName,
        assignedToUserId: row.assignedToUserId,
        assignedToUserName: row.assignedToUserName,
        location: row.location,
        warrantyExpiry: row.warrantyExpiry,
      );

  final String id;
  final String name;
  final String category;
  final String qrCode;
  final AssetStatus status;
  final String departmentId;
  final String departmentName;
  final String? assignedToUserId;
  final String? assignedToUserName;
  final String? location;
  final DateTime? warrantyExpiry;

  AssetModel copyWith({String? departmentId, String? departmentName, AssetStatus? status}) => AssetModel(
        id: id,
        name: name,
        category: category,
        qrCode: qrCode,
        status: status ?? this.status,
        departmentId: departmentId ?? this.departmentId,
        departmentName: departmentName ?? this.departmentName,
        assignedToUserId: assignedToUserId,
        assignedToUserName: assignedToUserName,
        location: location,
        warrantyExpiry: warrantyExpiry,
      );

  AssetTableCompanion toLocalCompanion({bool hasPendingLocalChanges = false}) => AssetTableCompanion.insert(
        id: id,
        name: name,
        category: category,
        qrCode: qrCode,
        status: status.name,
        departmentId: departmentId,
        departmentName: departmentName,
        assignedToUserId: Value(assignedToUserId),
        assignedToUserName: Value(assignedToUserName),
        location: Value(location),
        warrantyExpiry: Value(warrantyExpiry),
        lastSyncedAt: Value(DateTime.now()),
        hasPendingLocalChanges: Value(hasPendingLocalChanges),
      );

  Asset toEntity({bool hasPendingLocalChanges = false, DateTime? lastSyncedAt}) => Asset(
        id: id,
        name: name,
        category: category,
        qrCode: qrCode,
        status: status,
        departmentId: departmentId,
        departmentName: departmentName,
        assignedToUserId: assignedToUserId,
        assignedToUserName: assignedToUserName,
        location: location,
        warrantyExpiry: warrantyExpiry,
        lastSyncedAt: lastSyncedAt,
        hasPendingLocalChanges: hasPendingLocalChanges,
      );
}
