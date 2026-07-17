import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/asset_list/asset_list_bloc.dart';
import '../bloc/asset_list/asset_list_event.dart';
import '../bloc/asset_list/asset_list_state.dart';
import '../widgets/asset_card.dart';
import 'asset_detail_page.dart';

/// Route target for `/assets`. Reads `departmentId` from the
/// signed-in user's session (via the app-shell router's extra/query
/// params) so a Department Admin only ever sees their own department's
/// assets by construction, not by a client-side filter the UI could
/// forget to apply.
class AssetListPage extends StatelessWidget {
  const AssetListPage({super.key, this.departmentId});

  final String? departmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<AssetListBloc>()
        ..add(AssetListSubscriptionRequested(departmentId: departmentId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Asset Register')),
        body: BlocBuilder<AssetListBloc, AssetListState>(
          builder: (context, state) {
            if (state.status == AssetListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == AssetListStatus.failure) {
              return EmptyState(message: state.errorMessage ?? 'Something went wrong', icon: Icons.error_outline);
            }
            if (state.assets.isEmpty) {
              return const EmptyState(message: 'No assets registered yet');
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<AssetListBloc>().add(const AssetListRefreshRequested()),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.assets.length,
                itemBuilder: (context, index) {
                  final asset = state.assets[index];
                  return AssetCard(
                    asset: asset,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AssetDetailPage(assetId: asset.id)),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
