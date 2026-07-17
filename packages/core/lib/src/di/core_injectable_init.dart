import 'package:injectable/injectable.dart';

/// `injectable`'s micro-package trigger — each package that has its own
/// `@injectable`/`@LazySingleton`/`@module` classes needs one of these,
/// because a single `dart run build_runner build` invocation only ever
/// discovers annotations within the CURRENT package; the app-shell's
/// own `@InjectableInit` (see `apps/uniget_app/lib/di/injection.dart`)
/// cannot see across package boundaries on its own.
///
/// Generates `core_injectable_init.module.dart`'s `CorePackageModule`
/// (a `MicroPackageModule` with an `init(GetItHelper)` covering every
/// annotated class in this package) — exported via `core.dart` and
/// invoked explicitly from the app's `configureDependencies()`.
@InjectableInit.microPackage()
void configureCoreDependencies() {}
