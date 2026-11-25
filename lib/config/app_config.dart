/// Minimal runtime configuration that cannot live in a `.env` file.
///
/// All environment *values* (Supabase URL/key, currency, support contacts)
/// are read directly via `String.fromEnvironment(...)` at their call sites,
/// sourced from `--dart-define-from-file=.env`.
class AppConfig {
  static bool _forceDemoModeForTesting = false;

  static void setForceDemoModeForTesting(bool value) {
    _forceDemoModeForTesting = value;
  }

  static bool get isDemoMode {
    if (_forceDemoModeForTesting) return true;
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    return anonKey.trim().isEmpty ||
        anonKey.contains('demo-anon-key') ||
        anonKey.contains('your-anon-key');
  }
}