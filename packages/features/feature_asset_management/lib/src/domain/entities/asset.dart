import 'package:equatable/equatable.dart';

import 'asset_status.dart';

/// Plain domain entity — no JSON, no Drift annotations. Both the
/// remote API shape (`AssetModel` in data/models) and the local Drift
/// row (`AssetTableData`, generated) map onto this one type, so the
/// presentation layer never has to know or care which source the data
/// came from.
class Asset extends Equatable {
  const Asset({
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
    this.lastSyncedAt,
    this.hasPendingLocalChanges = false,
  });

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
  final DateTime? lastSyncedAt;

  /// True when this row was created/modified locally and is still
  /// sitting in the sync queue — the Asset Management Dashboard and
  /// list screens use this to render an "unsynced" indicator instead
  /// of silently pretending everything is already on the server.
  final bool hasPendingLocalChanges;

  Asset copyWith({
    AssetStatus? status,
    String? assignedToUserId,
    String? assignedToUserName,
    String? departmentId,
    String? departmentName,
    String? location,
    bool? hasPendingLocalChanges,
  }) {
    return Asset(
      id: id,
      name: name,
      category: category,
      qrCode: qrCode,
      status: status ?? this.status,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToUserName: assignedToUserName ?? this.assignedToUserName,
      location: location ?? this.location,
      warrantyExpiry: warrantyExpiry,
      lastSyncedAt: lastSyncedAt,
      hasPendingLocalChanges: hasPendingLocalChanges ?? this.hasPendingLocalChanges,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        qrCode,
        status,
        departmentId,
        assignedToUserId,
        location,
        hasPendingLocalChanges,
      ];
}
