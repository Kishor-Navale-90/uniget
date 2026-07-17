import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';

/// Must be a top-level (or static) function — FCM dispatches background
/// messages to a separate background isolate that shares none of the
/// main isolate's state, so `Firebase.initializeApp()` has to run again
/// here before anything else touches Firebase. Registered once, in
/// `bootstrap.dart`, via `FirebaseMessaging.onBackgroundMessage(...)`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  appLogger.i('Background FCM message received: ${message.messageId}');
}
