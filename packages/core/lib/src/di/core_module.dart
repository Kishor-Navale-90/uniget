import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Third-party instances that need manual registration (can't be
/// annotated directly with @injectable since they're not our classes)
/// live in `@module` classes like this one. Feature packages never
/// touch this file — they only ever request `FlutterSecureStorage`,
/// `Dio`, `AppDatabase`, `SupabaseClient`, etc. through constructor
/// injection.
@module
abstract class CoreModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  /// `Supabase.initialize()` runs in `bootstrap()` before
  /// `configureDependencies()`, so `Supabase.instance.client` already
  /// exists by the time this is resolved — never construct a second
  /// `SupabaseClient` directly, everything goes through this instance.
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
