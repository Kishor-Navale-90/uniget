import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The one navigation chrome for every top-level, authenticated
/// screen. Wraps `AdaptiveScaffold` (design_system) so the same three
/// destinations render as a bottom bar on mobile and a nav rail on
/// desktop/web — see design_system's ADR comment for why this exists
/// as a single shared widget instead of per-platform screens.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _destinations = [
    AdaptiveDestination(icon: Icons.inventory_2_outlined, label: 'Assets', path: '/assets'),
    AdaptiveDestination(icon: Icons.qr_code_scanner, label: 'Gate Passes', path: '/gate-passes'),
    AdaptiveDestination(icon: Icons.badge_outlined, label: 'Visitors', path: '/visitors'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _destinations.indexWhere((d) => location.startsWith(d.path)).clamp(0, _destinations.length - 1);

    return AdaptiveScaffold(
      destinations: _destinations,
      selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
      onDestinationSelected: (index) => context.go(_destinations[index].path),
      body: child,
    );
  }
}
