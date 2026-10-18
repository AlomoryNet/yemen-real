import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/env_config.dart';

void main() {
  test('EnvConfig reads environment from --dart-define-from-file properly', () {
    expect(
      EnvConfig.supabaseUrl,
      equals('https://fwpckpzrhvvxltdiiatn.supabase.co'),
    );
    expect(EnvConfig.supabaseAnonKey.isNotEmpty, isTrue);
    expect(EnvConfig.isDemoMode, isFalse);
    expect(EnvConfig.defaultCurrency, equals('YER'));
    expect(EnvConfig.supportPhone, isNotEmpty);
    expect(EnvConfig.supportWhatsApp, isNotEmpty);
  });
}
