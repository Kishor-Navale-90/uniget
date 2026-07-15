import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'di/injection.dart';

/// Single bootstrap path for every flavor (`main_dev.dart`,
/// `main_staging.dart`, `main_prod.dart` all call this) so DI setup,
/// error handling, and the widget tree only need to be right in one
/// place.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await configureDependencies();
      runApp(const GateFlowApp());
    },
    (error, stackTrace) {
      appLogger.e('Uncaught zone error', error: error, stackTrace: stackTrace);
      // Wire a crash-reporting sink (e.g. Firebase Crashlytics) here —
      // deliberately not hard-wired in this scaffold to keep it
      // backend-agnostic.
    },
  );
}
