import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Placeholder route target for `/visitors/checkin` — the reception
/// kiosk entry point. Wire this up like `AssetListPage` once
/// `VisitorRepositoryImpl` and a `VisitorCheckinBloc` are implemented
/// following the feature_asset_management reference. Offline-first
/// matters especially here: a kiosk must keep accepting walk-ins even
/// if the reception desk's connectivity drops.
class VisitorCheckinPage extends StatelessWidget {
  const VisitorCheckinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitor Check-In')),
      body: const EmptyState(
        message: 'Visitor Management module scaffolded — implement VisitorRepositoryImpl '
            'and VisitorCheckinBloc following feature_asset_management\'s pattern.',
        icon: Icons.badge_outlined,
      ),
    );
  }
}
