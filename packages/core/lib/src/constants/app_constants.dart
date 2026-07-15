/// Compile-time flavor config. Real values are injected per flavor via
/// `--dart-define` from `apps/gateflow_app/lib/flavors/*.dart` — never
/// commit real API keys/URLs here.
class AppConstants {
  AppConstants._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev.api.gateflow.internal',
  );

  static const enableNetworkLogs = bool.fromEnvironment('ENABLE_NETWORK_LOGS', defaultValue: true);

  static const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// How often the SyncEngine sweeps the queue even without a
  /// connectivity-change event (belt and braces for missed events).
  static const syncSweepInterval = Duration(minutes: 2);
}
