import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_status.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({super.key, required this.asset, required this.onTap});

  final Asset asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.qr_code_2),
        title: Text(asset.name),
        subtitle: Text('${asset.category} · ${asset.departmentName}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _statusChip(asset.status),
            if (asset.hasPendingLocalChanges)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Unsynced', style: TextStyle(fontSize: 10, color: AppColors.warning)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(AssetStatus status) => switch (status) {
        AssetStatus.inUse => StatusChip.neutral('In Use'),
        AssetStatus.inStorage => StatusChip.success('In Storage'),
        AssetStatus.underMaintenance => StatusChip.warning('Maintenance'),
        AssetStatus.inTransit => StatusChip.warning('In Transit'),
        AssetStatus.retired => StatusChip.danger('Retired'),
      };
}
