class EnvConfig {
  // Supabase Project URL & Anon Key
  // Can be injected via --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=...
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fwpckpzrhvvxltdiiatn.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3cGNrcHpyaHZ2eGx0ZGlpYXRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIxODAzNTUsImV4cCI6MjEwNzc1NjM1NX0.6m2soM8Rhc2ZuG8VQZUiSnrBzmzeY6pgjLFNb7go8CM',
  );

  static const String defaultCurrency = String.fromEnvironment(
    'DEFAULT_CURRENCY',
    defaultValue: 'YER',
  );

  static const String supportPhone = String.fromEnvironment(
    'SUPPORT_PHONE',
    defaultValue: '+967770000000',
  );

  static const String supportWhatsApp = String.fromEnvironment(
    'SUPPORT_WHATSAPP',
    defaultValue: '967770000000',
  );

  static bool _forceDemoModeForTesting = false;

  static void setForceDemoModeForTesting(bool value) {
    _forceDemoModeForTesting = value;
  }

  static bool get isDemoMode =>
      _forceDemoModeForTesting ||
      supabaseAnonKey.trim().isEmpty ||
      supabaseAnonKey.contains('demo-anon-key') ||
      supabaseAnonKey.contains('your-anon-key');
}
