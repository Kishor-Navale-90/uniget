/// As with feature_auth, `@injectable`/`@LazySingleton` annotations on
/// the classes themselves are enough for `injectable_generator` to
/// wire this feature's whole graph — repository, both datasources,
/// both Blocs, every UseCase, and the local Drift database — into the
/// shared `GetIt` instance without the app shell listing any of them
/// by hand.
///
/// The one thing worth calling out explicitly: [AssetRepositoryImpl]'s
/// constructor registers this feature's [SyncHandler] with the shared
/// [SyncEngine] the moment DI creates it (a `@LazySingleton`, so this
/// happens exactly once, on first use). That's the entire integration
/// point between this feature and core's offline-sync machinery.
library feature_asset_management_di;
