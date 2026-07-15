import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Destination model shared between the mobile bottom-nav and the
/// desktop/web nav-rail — declared once per feature (in its routing
/// registration) and rendered by whichever layout fits the viewport.
class AdaptiveDestination {
  const AdaptiveDestination({required this.icon, required this.label, required this.path});
  final IconData icon;
  final String label;
  final String path;
}

/// The one navigation shell every top-level screen sits inside.
/// Mobile gets a bottom NavigationBar; tablet/desktop/web get a
/// NavigationRail — same destinations, same routes, no per-platform
/// screen forking. This is what lets a security guard's phone and a
/// facility manager's desktop browser share the exact same route
/// tree.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
  });

  final List<AdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);

    if (size == ScreenSize.mobile) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations
              .map((d) => NavigationDestination(icon: Icon(d.icon), label: d.label))
              .toList(),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: size == ScreenSize.desktop,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations
                .map((d) => NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
