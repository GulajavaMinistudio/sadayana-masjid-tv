import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'islamic_colors.dart';
import 'islamic_typography.dart';

/// Material3 ThemeData untuk Miqotul Khoir TV.
///
/// Mengintegrasikan [IslamicColors] dan [IslamicTypography] ke dalam
/// Flutter ThemeData. Selalu gunakan dark theme — sesuai dengan
/// digital signage masjid (ALT-004).
///
/// Ref: Plan 03 TASK-021 s.d. TASK-026
class IslamicTheme {
  // ---------------------------------------------------------------------------
  // Private constructor — prevent instantiation
  // ---------------------------------------------------------------------------
  const IslamicTheme._();

  // ---------------------------------------------------------------------------
  // Dark Theme — satu-satunya theme yang digunakan
  // ---------------------------------------------------------------------------

  /// Mengembalikan Material3 ThemeData dengan Islamic Glassmorphism palette.
  ///
  /// Gunakan di `MaterialApp(theme: IslamicTheme.darkTheme())`.
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: IslamicColors.darkBackground,

      // -----------------------------------------------------------------------
      // ColorScheme — mapping Islamic palette ke Material3 roles
      // -----------------------------------------------------------------------
      colorScheme: const ColorScheme.dark(
        primary: IslamicColors.primaryTeal,
        onPrimary: IslamicColors.textPrimary,
        secondary: IslamicColors.goldAmber,
        onSecondary: IslamicColors.darkBackground,
        surface: IslamicColors.surfaceDark,
        onSurface: IslamicColors.textPrimary,
        error: IslamicColors.error,
        onError: IslamicColors.textPrimary,
        // Extended roles
        primaryContainer: IslamicColors.deepTeal,
        onPrimaryContainer: IslamicColors.textPrimary,
        secondaryContainer: IslamicColors.iqomahColor,
        onSecondaryContainer: IslamicColors.textPrimary,
        surfaceContainerHighest: IslamicColors.surfaceLight,
        outline: IslamicColors.glassBorder,
        outlineVariant: IslamicColors.glassWhite,
      ),

      // -----------------------------------------------------------------------
      // TextTheme — mapping typography scale ke Material text roles
      // -----------------------------------------------------------------------
      textTheme: TextTheme(
        displayLarge: IslamicTypography.display(),
        headlineLarge: IslamicTypography.heading(),
        titleLarge: IslamicTypography.title(),
        titleMedium: IslamicTypography.subtitle(),
        bodyLarge: IslamicTypography.body(),
        bodySmall: IslamicTypography.caption(),
        labelSmall: IslamicTypography.overline(),
      ),

      // -----------------------------------------------------------------------
      // AppBarTheme — transparent, no elevation
      // -----------------------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: IslamicColors.textPrimary,
        centerTitle: false,
      ),

      // -----------------------------------------------------------------------
      // CardTheme — glassmorphism surface, rounded corners
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: IslamicColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: IslamicColors.glassBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // -----------------------------------------------------------------------
      // Misc — consistent with dark Islamic theme
      // -----------------------------------------------------------------------
      dividerColor: IslamicColors.glassBorder,
      focusColor: IslamicColors.goldAmber.withValues(alpha: 0.3),
      highlightColor: IslamicColors.glassWhite,
      splashColor: IslamicColors.glassWhite,
    );
  }
}
