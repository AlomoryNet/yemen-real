import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Material 3 Expressive-informed themes.
///
/// Both themes are built from one palette-driven recipe so every component
/// (buttons, chips, inputs, dialogs, …) stays readable in light and dark mode.
/// Tokens exposed by [AppColors] are brightness-aware for screens that style
/// text directly.
class AppTheme {
  // Building both themes calls GoogleFonts dozens of times. Cache the results
  // so root rebuilds (settings/auth changes) do not recreate every text style.
  static final ThemeData lightTheme = _build(const _Palette.light());
  static final ThemeData darkTheme = _build(const _Palette.dark());
}

class _Palette {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primaryInk;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color error;
  final Color onError;
  final Color shadow;
  final Color snackBarBackground;
  final Color snackBarForeground;
  final double cardElevation;

  const _Palette.light()
      : brightness = Brightness.light,
        background = AppColors.lightBackground,
        surface = AppColors.lightSurface,
        surfaceVariant = AppColors.lightSurfaceVariant,
        divider = AppColors.lightDivider,
        textPrimary = AppColors.lightTextPrimary,
        textSecondary = AppColors.lightTextSecondary,
        textMuted = AppColors.lightTextMuted,
        primary = AppColors.primary,
        onPrimary = AppColors.textLight,
        primaryContainer = AppColors.lightPrimaryMuted,
        onPrimaryContainer = AppColors.primary,
        primaryInk = AppColors.primary,
        secondary = AppColors.accent,
        onSecondary = AppColors.textLight,
        secondaryContainer = AppColors.accentLight,
        onSecondaryContainer = AppColors.accentDark,
        error = AppColors.error,
        onError = AppColors.textLight,
        shadow = const Color(0x1C000000),
        snackBarBackground = AppColors.lightTextPrimary,
        snackBarForeground = AppColors.textLight,
        cardElevation = 1.5;

  const _Palette.dark()
      : brightness = Brightness.dark,
        background = AppColors.darkBackground,
        surface = AppColors.darkSurface,
        surfaceVariant = AppColors.darkSurfaceVariant,
        divider = AppColors.darkBorder,
        textPrimary = AppColors.darkTextPrimary,
        textSecondary = AppColors.darkTextSecondary,
        textMuted = AppColors.darkTextMuted,
        primary = AppColors.primary,
        onPrimary = AppColors.textLight,
        primaryContainer = AppColors.darkPrimaryMuted,
        onPrimaryContainer = AppColors.primaryLight,
        primaryInk = AppColors.primaryLight,
        secondary = AppColors.accent,
        onSecondary = AppColors.textLight,
        secondaryContainer = const Color(0xFF7C2D12),
        onSecondaryContainer = const Color(0xFFFDE68A),
        error = const Color(0xFFF87171),
        onError = AppColors.darkBackground,
        shadow = const Color(0x66000000),
        snackBarBackground = const Color(0xFF334663),
        snackBarForeground = AppColors.darkTextPrimary,
        cardElevation = 0;
}

ThemeData _build(_Palette p) {
  final base = GoogleFonts.cairoTextTheme();

  TextStyle cairo({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double height = 1.25,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? p.textPrimary,
        height: height,
      );

  const radiusMedium = 14.0;
  const radiusLarge = 18.0;

  final textTheme = base.copyWith(
    displaySmall: cairo(fontSize: 34, fontWeight: FontWeight.bold),
    headlineLarge: cairo(fontSize: 27, fontWeight: FontWeight.bold, height: 1.2),
    headlineMedium: cairo(fontSize: 22, fontWeight: FontWeight.bold, height: 1.25),
    headlineSmall: cairo(fontSize: 18, fontWeight: FontWeight.bold),
    titleLarge: cairo(fontSize: 16, fontWeight: FontWeight.bold),
    titleMedium: cairo(fontSize: 14.5, fontWeight: FontWeight.w600),
    titleSmall: cairo(fontSize: 13, fontWeight: FontWeight.w600),
    bodyLarge: cairo(fontSize: 16, color: p.textPrimary),
    bodyMedium: cairo(fontSize: 14, color: p.textSecondary),
    bodySmall: cairo(fontSize: 12, color: p.textSecondary),
    labelLarge: cairo(fontSize: 14, fontWeight: FontWeight.bold),
    labelMedium: cairo(fontSize: 12.5, fontWeight: FontWeight.w600),
    labelSmall: cairo(fontSize: 11, fontWeight: FontWeight.w500),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    primaryColor: p.primary,
    scaffoldBackgroundColor: p.background,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    colorScheme: ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      secondary: p.secondary,
      onSecondary: p.onSecondary,
      secondaryContainer: p.secondaryContainer,
      onSecondaryContainer: p.onSecondaryContainer,
      surface: p.surface,
      onSurface: p.textPrimary,
      surfaceContainerHighest: p.surfaceVariant,
      outline: p.divider,
      outlineVariant: p.divider,
      error: p.error,
      onError: p.onError,
    ),
    textTheme: textTheme,
    primaryTextTheme: textTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: p.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      toolbarHeight: 64,
      iconTheme: IconThemeData(color: p.primaryInk),
      titleTextStyle: cairo(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: p.textPrimary,
      ),
    ),

    cardTheme: CardThemeData(
      color: p.surface,
      elevation: p.cardElevation,
      shadowColor: p.shadow,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceVariant,
      isDense: false,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: cairo(fontSize: 13.5, color: p.textMuted),
      labelStyle: cairo(fontSize: 13.5, color: p.textSecondary),
      prefixIconColor: p.textSecondary,
      suffixIconColor: p.textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: p.primaryInk, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: p.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: p.error, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 0,
        minimumSize: const Size(48, 50),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: cairo(fontSize: 14.5, fontWeight: FontWeight.bold,
            color: p.onPrimary),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 0,
        minimumSize: const Size(48, 50),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: cairo(fontSize: 14.5, fontWeight: FontWeight.bold,
            color: p.onPrimary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.primaryInk,
        side: BorderSide(color: p.primaryInk, width: 1.5),
        minimumSize: const Size(48, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: cairo(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primaryInk,
        minimumSize: const Size(40, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: const StadiumBorder(),
        textStyle: cairo(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: p.primaryInk,
        minimumSize: const Size(44, 44),
        iconSize: 24,
        shape: const CircleBorder(),
      ),
    ),

    chipTheme: ChipThemeData(
      showCheckmark: false,
      elevation: 0,
      pressElevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      selectedColor: p.primary,
      backgroundColor: p.surfaceVariant,
      labelStyle: cairo(fontSize: 13, fontWeight: FontWeight.w600,
          color: p.textSecondary),
      secondaryLabelStyle: cairo(fontSize: 13,
          fontWeight: FontWeight.bold, color: p.onPrimary),
      checkmarkColor: p.onPrimary,
    ),

    dividerTheme: DividerThemeData(
      color: p.divider,
      thickness: 1,
      space: 1,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: p.surface,
      selectedItemColor: p.primaryInk,
      unselectedItemColor: p.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showUnselectedLabels: true,
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: p.surface,
      selectedIconTheme: IconThemeData(color: p.primaryInk),
      unselectedIconTheme: IconThemeData(color: p.textSecondary),
      selectedLabelTextStyle: cairo(fontSize: 12, fontWeight: FontWeight.bold,
          color: p.primaryInk),
      unselectedLabelTextStyle: cairo(fontSize: 12, color: p.textSecondary),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge + 2),
      ),
      titleTextStyle: cairo(fontSize: 18, fontWeight: FontWeight.bold,
          color: p.textPrimary),
      contentTextStyle: cairo(fontSize: 14, color: p.textSecondary),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: p.divider,
      dragHandleSize: const Size(40, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.snackBarBackground,
      contentTextStyle: cairo(fontSize: 13.5, color: p.snackBarForeground),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
  );
}
