/// Compile-time flavor config. Real values are injected per flavor via
/// `--dart-define` from `apps/uniget_app/lib/flavors/*.dart` — never
/// commit real API keys/URLs here.
class AppConstants {
  AppConstants._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev.api.uniget.internal',
  );

  /// Supabase project URL/anon key backing `feature_auth` (see
  /// `supabase/README.md` for the schema/functions this talks to).
  /// The anon/publishable key is safe to ship in the client — it's
  /// subject to RLS, never the service-role key — so defaulting it to
  /// the real `uniget-dev` project here (rather than a fake host) is
  /// fine; staging/prod still override both via `--dart-define`.
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wzjlekgijefwqcvkxovt.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_PmtB6U3tBRH72OFYe4qOog_bFJcuJ92',
  );

  static const enableNetworkLogs = bool.fromEnvironment('ENABLE_NETWORK_LOGS', defaultValue: true);

  static const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// How often the SyncEngine sweeps the queue even without a
  /// connectivity-change event (belt and braces for missed events).
  static const syncSweepInterval = Duration(minutes: 2);
}
