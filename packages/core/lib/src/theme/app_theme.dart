import 'package:flutter/material.dart';

/// One ThemeData for the whole app, shared by every feature package's
/// screens — colors/typography live here, never hard-coded per screen,
/// so 100+ screens stay visually consistent by construction.
class AppTheme {
  AppTheme._();

  static const _navy = Color(0xFF1F3864);
  static const _accent = Color(0xFF2E74B5);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _accent, primary: _accent, secondary: _navy),
        appBarTheme: const AppBarTheme(backgroundColor: _navy, foregroundColor: Colors.white),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accent,
          brightness: Brightness.dark,
        ),
      );
}
