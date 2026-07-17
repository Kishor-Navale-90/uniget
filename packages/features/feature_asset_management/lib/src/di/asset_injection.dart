import 'package:injectable/injectable.dart';

/// Same micro-package trigger pattern as `core`'s
/// `core_injectable_init.dart` — see that file's doc comment for why
/// this is needed even though every class here is already
/// `@injectable`/`@LazySingleton` annotated. Generates
/// `asset_injection.module.dart`'s `FeatureAssetManagementPackageModule`,
/// exported via `feature_asset_management.dart` and invoked explicitly
/// from the app's `configureDependencies()`.
///
/// One thing worth calling out explicitly: [AssetRepositoryImpl]'s
/// constructor registers this feature's `SyncHandler` with the shared
/// `SyncEngine` the moment DI creates it (a `@LazySingleton`, so this
/// happens exactly once, on first use) — that's the entire integration
/// point between this feature and core's offline-sync machinery.
@InjectableInit.microPackage()
void configureAssetManagementDependencies() {}
