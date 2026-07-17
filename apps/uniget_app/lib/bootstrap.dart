import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'di/injection.dart';
import 'firebase_options.dart';
import 'notifications/firebase_messaging_background_handler.dart';

/// Single bootstrap path for every flavor (`main_dev.dart`,
/// `main_staging.dart`, `main_prod.dart` all call this) so DI setup,
/// error handling, and the widget tree only need to be right in one
/// place.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _initializeFirebaseIfSupported();
      await configureDependencies();
      runApp(const UnigetApp());
    },
    (error, stackTrace) {
      appLogger.e('Uncaught zone error', error: error, stackTrace: stackTrace);
      // Wire a crash-reporting sink (e.g. Firebase Crashlytics) here —
      // deliberately not hard-wired in this scaffold to keep it
      // backend-agnostic.
    },
  );
}

/// Only Android and iOS have a registered Firebase app
/// (`firebase_options.dart`) — macOS/Windows/web desktop dev builds
/// skip push notifications entirely rather than crash on
/// `DefaultFirebaseOptions.currentPlatform`'s `UnsupportedError`.
Future<void> _initializeFirebaseIfSupported() async {
  final supported = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  if (!supported) {
    appLogger.i('Skipping Firebase init on $defaultTargetPlatform — no app registered for this platform yet.');
    return;
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Registered once, before configureDependencies() so it's in place
  // no matter how quickly a push arrives after launch.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
