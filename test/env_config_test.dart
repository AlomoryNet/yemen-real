import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  test('AppConfig detects demo mode from unset/placeholder credentials', () {
    // Force demo mode to true via the test hook and verify the flag works.
    AppConfig.setForceDemoModeForTesting(true);
    expect(AppConfig.isDemoMode, isTrue);
    AppConfig.setForceDemoModeForTesting(false);
    expect(AppConfig.isDemoMode, isTrue);
  });

  test('SupabaseService initializes (demo mode safe)', () {
    expect(SupabaseService.isInitialized, isFalse);
  });
}

