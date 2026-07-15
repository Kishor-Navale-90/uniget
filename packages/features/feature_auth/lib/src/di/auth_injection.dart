/// Nothing to hand-write here in the normal case — `@injectable` /
/// `@LazySingleton` annotations on the classes themselves (bloc,
/// repository, datasources, usecases) are enough for
/// `injectable_generator` to wire this feature's dependency graph
/// automatically into the shared `GetIt` instance.
///
/// This file exists as the one place to add anything that genuinely
/// needs manual/conditional registration for this feature (e.g. a
/// feature flag deciding between a real and a demo AuthRemoteDataSource).
/// The app shell calls `configureDependencies()` (generated in
/// `injection.config.dart` at the app level) which sweeps every
/// package's annotated classes, this one included — no feature package
/// needs to be registered by hand in the app shell.
library feature_auth_di;
