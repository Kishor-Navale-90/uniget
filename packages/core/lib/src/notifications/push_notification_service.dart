import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

/// Thin wrapper over `FirebaseMessaging` — the "Notification Service"
/// cross-cutting component from the concept doc (push half; SMS/email
/// OTP delivery is a separate server-side concern, not this client
/// service). Every feature that needs to react to a push notification
/// depends on this, never on `firebase_messaging` directly, so the
/// underlying push provider could be swapped without touching feature
/// code.
///
/// `Firebase.initializeApp()` itself (and the background message
/// handler, which must be a top-level function) are wired in the
/// app-shell's `bootstrap.dart` — this service only wraps the runtime
/// API surface a feature actually needs (permission, token,
/// foreground/tapped-notification streams).
@lazySingleton
class PushNotificationService {
  PushNotificationService(this._messaging);
  final FirebaseMessaging _messaging;

  /// Must be called before push notifications can be received on iOS
  /// (and is a no-op returning "granted" on Android <13; Android 13+
  /// also needs the `POST_NOTIFICATIONS` manifest permission declared).
  Future<NotificationSettings> requestPermission() => _messaging.requestPermission();

  Future<String?> getToken() => _messaging.getToken();

  /// Fires when FCM rotates the device token — the caller should send
  /// the new token to the backend (`POST /v1/notifications/token` or
  /// similar) to keep server-side push targeting current.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// A push arrived while the app was in the foreground — FCM does
  /// NOT show a system notification for these automatically; the app
  /// decides whether/how to surface it (e.g. an in-app banner).
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// The user tapped a notification and the app opened/resumed because
  /// of it.
  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;

  /// The notification that cold-started the app from a fully
  /// terminated state, if any — check this once at startup after
  /// [onMessageOpenedApp] is already listening.
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();
}

@module
abstract class NotificationModule {
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
}
