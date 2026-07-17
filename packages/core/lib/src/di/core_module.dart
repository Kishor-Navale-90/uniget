import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Third-party instances that need manual registration (can't be
/// annotated directly with @injectable since they're not our classes)
/// live in `@module` classes like this one. Feature packages never
/// touch this file — they only ever request `FlutterSecureStorage`,
/// `Dio`, `AppDatabase`, etc. through constructor injection.
@module
abstract class CoreModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  // Requires `Supabase.initialize()` to have already run in
  // `bootstrap()` before `configureDependencies()` — this just hands
  // out the singleton client it creates.
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
