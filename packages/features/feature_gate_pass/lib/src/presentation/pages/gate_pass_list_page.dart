import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Placeholder route target for `/gate-passes`. Wire this up exactly
/// like `AssetListPage` once `GatePassRepositoryImpl` (data layer) and
/// `GatePassListBloc` (presentation layer) are implemented following
/// the feature_asset_management reference.
class GatePassListPage extends StatelessWidget {
  const GatePassListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gate Passes')),
      body: const EmptyState(
        message: 'Gate Pass module scaffolded — implement GatePassRepositoryImpl '
            'and GatePassListBloc following feature_asset_management\'s pattern.',
        icon: Icons.qr_code_scanner,
      ),
    );
  }
}
