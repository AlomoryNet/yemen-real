import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend service with graceful fallback
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: YemenRealEstateApp()));
}

class YemenRealEstateApp extends StatelessWidget {
  const YemenRealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appNameAr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Routing
      routerConfig: appRouter,

      // RTL Arabic Localization
      locale: const Locale('ar', 'YE'),
      supportedLocales: const [
        Locale('ar', 'YE'),
        Locale('ar', ''),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
