import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

/// Composition root for the ENTIRE app's dependency graph.
///
/// `@InjectableInit` makes `injectable_generator` scan every package
/// this app depends on (core, design_system, feature_auth,
/// feature_asset_management, feature_gate_pass,
/// feature_visitor_management) for `@injectable` / `@LazySingleton` /
/// `@module` annotated classes and generate `injection.config.dart`
/// with all of them wired up — no feature package needs to be
/// registered here by hand, which is what lets a new feature (screen
/// #101, #102, ...) be added by a different team without touching
/// this file at all.
///
/// Run `dart run build_runner build --delete-conflicting-outputs`
/// after adding/annotating a new injectable class.
@InjectableInit(initializerName: 'init', preferRelativeImports: true, asExtension: true)
Future<void> configureDependencies() async => getIt.init();
