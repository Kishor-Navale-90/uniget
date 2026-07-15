import 'package:flutter/widgets.dart';

/// Breakpoints shared by every feature's pages and by
/// `design_system`'s AdaptiveScaffold — a screen is written once and
/// adapts its layout (bottom nav on mobile vs. nav rail on
/// desktop/web) rather than being forked per platform.
enum ScreenSize { mobile, tablet, desktop }

class Breakpoints {
  Breakpoints._();
  static const double tablet = 700;
  static const double desktop = 1100;
}

ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= Breakpoints.desktop) return ScreenSize.desktop;
  if (width >= Breakpoints.tablet) return ScreenSize.tablet;
  return ScreenSize.mobile;
}
