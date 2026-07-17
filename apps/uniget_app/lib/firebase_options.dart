import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase project configuration, hand-authored from the
/// `google-services.json` (Android) and `GoogleService-Info.plist`
/// (iOS) the org's Firebase admin exported for project
/// `unigate-dba17` — matches what `flutterfire configure` would have
/// generated. Only Android and iOS are registered in that Firebase
/// project so far; add a `web`/`macos`/`windows` case here (and a
/// matching app registration in the Firebase console) if push
/// notifications are ever needed on those platforms.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — '
        'no web app is registered in the unigate-dba17 Firebase project yet.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for $defaultTargetPlatform — '
          'only android and ios are registered in the unigate-dba17 Firebase project.',
        );
    }
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyDO3UFgMtiOuZEGSx-XSTYYtMcxlv9TwXc',
    appId: '1:689386121335:android:7ef863460bf13098a6fe72',
    messagingSenderId: '689386121335',
    projectId: 'unigate-dba17',
    storageBucket: 'unigate-dba17.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyDiW0dYl3JfkE3e9Op-n98Zpmbxj21BU5U',
    appId: '1:689386121335:ios:00f4bad07471e113a6fe72',
    messagingSenderId: '689386121335',
    projectId: 'unigate-dba17',
    storageBucket: 'unigate-dba17.firebasestorage.app',
    iosBundleId: 'com.softdel.unigate',
  );
}
