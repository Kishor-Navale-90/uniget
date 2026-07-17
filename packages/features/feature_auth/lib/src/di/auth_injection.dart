import 'package:injectable/injectable.dart';

/// `@injectable`/`@LazySingleton` annotations on the classes themselves
/// (bloc, repository, datasources, usecases) are enough for
/// `injectable_generator` to work out this feature's dependency graph
/// — but a single `dart run build_runner build` invocation only ever
/// discovers annotations within the CURRENT package, so this feature
/// still needs its own micro-package trigger (like `core`'s
/// `core_injectable_init.dart`) for the app shell to be able to pull
/// its registrations in. Generates `auth_injection.module.dart`'s
/// `FeatureAuthPackageModule`, exported via `feature_auth.dart` and
/// invoked explicitly from the app's `configureDependencies()`.
@InjectableInit.microPackage()
void configureAuthDependencies() {}
