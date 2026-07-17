enum Flavor { dev, staging, prod }

/// Read once at startup by each `main_*.dart` entry point. Real
/// per-flavor secrets (API keys, Firebase project IDs) are supplied
/// via `--dart-define-from-file=env/<flavor>.json` in CI, never
/// hard-coded here — see `.github/workflows/ci.yaml`.
class FlavorConfig {
  const FlavorConfig({required this.flavor, required this.appTitle});

  final Flavor flavor;
  final String appTitle;

  static late FlavorConfig instance;

  static void initialize(FlavorConfig config) => instance = config;
}
