import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:miqotul_khoir_tv/core/theme/islamic_colors.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';

/// Unit tests untuk [IslamicTheme] — validasi ThemeData configuration.
///
/// Menggunakan testWidgets agar ScreenUtil dapat diinisialisasi
/// melalui ScreenUtilInit widget sebelum darkTheme() dipanggil.
///
/// Ref: Plan 03 TASK-039 s.d. TASK-041
void main() {
  setUpAll(() {
    // Disable Google Fonts HTTP requests dalam test environment
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Helper: build widget tree dengan ScreenUtilInit dan expose ThemeData
  Widget buildTestApp(Widget Function(ThemeData theme) builder) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      builder: (context, _) {
        final theme = IslamicTheme.darkTheme();
        return MaterialApp(
          theme: theme,
          home: Scaffold(body: Builder(builder: (_) => builder(theme))),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TEST: Material3 dan Brightness
  // ---------------------------------------------------------------------------

  group('IslamicTheme.darkTheme() — Material3 & Brightness', () {
    testWidgets('useMaterial3 is true', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.useMaterial3, isTrue);
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('brightness is dark', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.brightness, equals(Brightness.dark));
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('scaffoldBackgroundColor is darkBackground', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(
            theme.scaffoldBackgroundColor,
            equals(IslamicColors.darkBackground),
          );
          return const SizedBox.shrink();
        }),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // TEST: ColorScheme mapping
  // ---------------------------------------------------------------------------

  group('IslamicTheme.darkTheme() — ColorScheme', () {
    testWidgets('primary is primaryTeal', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.colorScheme.primary, equals(IslamicColors.primaryTeal));
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('secondary is goldAmber', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.colorScheme.secondary, equals(IslamicColors.goldAmber));
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('surface is surfaceDark', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.colorScheme.surface, equals(IslamicColors.surfaceDark));
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('error is IslamicColors.error', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.colorScheme.error, equals(IslamicColors.error));
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('onPrimary is textPrimary', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(
            theme.colorScheme.onPrimary,
            equals(IslamicColors.textPrimary),
          );
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('onSecondary is darkBackground', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(
            theme.colorScheme.onSecondary,
            equals(IslamicColors.darkBackground),
          );
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('onSurface is textPrimary', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(
            theme.colorScheme.onSurface,
            equals(IslamicColors.textPrimary),
          );
          return const SizedBox.shrink();
        }),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // TEST: TextTheme mapping
  // ---------------------------------------------------------------------------

  group('IslamicTheme.darkTheme() — TextTheme mapping', () {
    testWidgets('all 7 TextTheme slots are non-null', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.textTheme.displayLarge, isNotNull);
          expect(theme.textTheme.headlineLarge, isNotNull);
          expect(theme.textTheme.titleLarge, isNotNull);
          expect(theme.textTheme.titleMedium, isNotNull);
          expect(theme.textTheme.bodyLarge, isNotNull);
          expect(theme.textTheme.bodySmall, isNotNull);
          expect(theme.textTheme.labelSmall, isNotNull);
          return const SizedBox.shrink();
        }),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // TEST: AppBarTheme
  // ---------------------------------------------------------------------------

  group('IslamicTheme.darkTheme() — AppBarTheme', () {
    testWidgets('AppBar backgroundColor is transparent', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.appBarTheme.backgroundColor, equals(Colors.transparent));
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('AppBar elevation is 0', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.appBarTheme.elevation, equals(0));
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('AppBar foregroundColor is textPrimary', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(
            theme.appBarTheme.foregroundColor,
            equals(IslamicColors.textPrimary),
          );
          return const SizedBox.shrink();
        }),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // TEST: CardTheme
  // ---------------------------------------------------------------------------

  group('IslamicTheme.darkTheme() — CardTheme', () {
    testWidgets('Card color is surfaceDark', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.cardTheme.color, equals(IslamicColors.surfaceDark));
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('Card elevation is 0', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.cardTheme.elevation, equals(0));
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('Card shape is RoundedRectangleBorder', (tester) async {
      await tester.pumpWidget(
        buildTestApp((theme) {
          expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
          return const SizedBox.shrink();
        }),
      );
    });
  });
}
