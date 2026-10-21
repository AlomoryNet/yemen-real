import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/env_config.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/yemen_map_screen.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  setUp(() async {
    EnvConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() {
    EnvConfig.setForceDemoModeForTesting(false);
  });

  testWidgets('YemenMapScreen renders map controls, chips and header',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: YemenMapScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify presence of title badge and governorate chips
    expect(find.text('خريطة اليمن'), findsWidgets);
    expect(find.text('خريطة اليمن 🇾🇪'), findsOneWidget);
    expect(find.text('كافة المحافظات 🇾🇪'), findsOneWidget);
    expect(find.text('صنعاء'), findsOneWidget);
    expect(find.text('عرض القائمة'), findsOneWidget);
  });
}
