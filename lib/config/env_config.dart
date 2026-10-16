class EnvConfig {
  // Supabase Project URL & Anon Key
  // Can be injected via --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=...
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://demo-yemen-real.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo-anon-key',
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

  static bool get isDemoMode =>
      supabaseUrl.contains('demo-yemen-real') ||
      supabaseAnonKey.contains('demo-anon-key');
}
