import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/asset_transfer/asset_transfer_bloc.dart';
import '../bloc/asset_transfer/asset_transfer_event.dart';
import '../bloc/asset_transfer/asset_transfer_state.dart';

/// Route target for `/assets/:id`. Kept intentionally simple in this
/// reference scaffold — the interesting architecture is in the Bloc/
/// Repository/Sync wiring, not the widget tree. Real screens would add
/// tabs for assignment history, maintenance log, and attached
/// documents (concept doc §5.1).
class AssetDetailPage extends StatelessWidget {
  const AssetDetailPage({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<AssetTransferBloc>(),
      child: Scaffold(
        appBar: AppBar(title: Text('Asset $assetId')),
        body: BlocConsumer<AssetTransferBloc, AssetTransferState>(
          listener: (context, state) {
            if (state.status == AssetTransferStatus.submitted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transfer queued — will sync automatically')),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Asset ID: $assetId', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Transfer to another department',
                    isLoading: state.status == AssetTransferStatus.submitting,
                    onPressed: () => context.read<AssetTransferBloc>().add(
                          AssetTransferSubmitted(
                            assetId: assetId,
                            toDepartmentId: 'dept-finance',
                            reason: 'Reassigned per project change',
                          ),
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
