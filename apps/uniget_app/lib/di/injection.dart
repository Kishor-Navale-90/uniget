import 'package:core/core.dart';
import 'package:feature_asset_management/feature_asset_management.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_gate_pass/feature_gate_pass.dart';
import 'package:feature_visitor_management/feature_visitor_management.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

/// Composition root for the ENTIRE app's dependency graph.
///
/// `@InjectableInit` only ever discovers `@injectable`/`@LazySingleton`/
/// `@module` classes within THIS package (`apps/uniget_app` has none of
/// its own) — a single `dart run build_runner build` invocation cannot
/// see across package boundaries, no matter how many packages this app
/// depends on. Every package with annotated classes (`core`,
/// `feature_auth`, `feature_asset_management`, `feature_gate_pass`,
/// `feature_visitor_management`) therefore has its own micro-package
/// trigger (see `core`'s `core_injectable_init.dart` for the full
/// explanation) generating a `<Package>PackageModule`, which this
/// function registers into the SAME shared [getIt] instance, in
/// dependency order — `core` first, since every feature's module
/// resolves types like `Dio`/`SessionManager`/`NetworkInfo` that only
/// `core`'s module provides.
///
/// Run `melos run build_runner` after adding/annotating a new
/// injectable class in ANY package — this file's registration order
/// only needs to change if a NEW package with cross-feature
/// dependencies is added, not for ordinary new classes within an
/// existing package.
@InjectableInit(initializerName: 'init', preferRelativeImports: true, asExtension: true)
Future<void> configureDependencies() async {
  await getIt.init();
  final gh = GetItHelper(getIt);
  await CorePackageModule().init(gh);
  await FeatureAuthPackageModule().init(gh);
  await FeatureAssetManagementPackageModule().init(gh);
  await FeatureGatePassPackageModule().init(gh);
  await FeatureVisitorManagementPackageModule().init(gh);
}
