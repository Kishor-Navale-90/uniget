import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Third-party instances that need manual registration (can't be
/// annotated directly with @injectable since they're not our classes)
/// live in `@module` classes like this one. Feature packages never
/// touch this file — they only ever request `FlutterSecureStorage`,
/// `Dio`, `AppDatabase`, etc. through constructor injection.
@module
abstract class CoreModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
