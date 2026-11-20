import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:miqotul_khoir_tv/core/theme/islamic_colors.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_typography.dart';

/// Unit tests untuk [IslamicTypography] — validasi typography scale.
///
/// Menggunakan ScreenUtilInit wrapper agar `.sp` extensions berfungsi
/// dalam test environment.
///
/// Ref: Plan 03 TASK-036 s.d. TASK-038
void main() {
  // ---------------------------------------------------------------------------
  // Setup: ScreenUtil harus diinisialisasi sebelum test typography
  // ---------------------------------------------------------------------------

  setUpAll(() {
    // Disable Google Fonts HTTP requests dalam test environment
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Helper: wrap test dalam ScreenUtilInit agar .sp berfungsi
  Widget buildTestWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
    );
  }

  // ---------------------------------------------------------------------------
  // TEST: Semua 7 typography methods mengembalikan TextStyle valid
  // ---------------------------------------------------------------------------

  group('IslamicTypography — all 7 methods return valid TextStyle', () {
    testWidgets('display() returns TextStyle with Poppins and 72sp', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              final style = IslamicTypography.display();
              expect(style, isA<TextStyle>());
              expect(style.fontFamily, contains('Poppins'));
              expect(style.fontWeight, equals(FontWeight.w700));
              expect(style.color, equals(IslamicColors.textPrimary));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('heading() returns TextStyle with Poppins and 48sp', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              final style = IslamicTypography.heading();
              expect(style, isA<TextStyle>());
              expect(style.fontFamily, contains('Poppins'));
              expect(style.fontWeight, equals(FontWeight.w600));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('title() returns TextStyle with w600', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              final style = IslamicTypography.title();
              expect(style.fontWeight, equals(FontWeight.w600));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('subtitle() returns TextStyle with w500', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              final style = IslamicTypography.subtitle();
              expect(style.fontWeight, equals(FontWeight.w500));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('body() returns TextStyle with w400 and textPrimary', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              final style = IslamicTypography.body();
              expect(style.fontWeight, equals(FontWeight.w400));
              expect(style.color, equals(IslamicColors.textPrimary));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('caption() returns TextStyle with textSecondary color', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              final style = IslamicTypography.caption();
              expect(style.color, equals(IslamicColors.textSecondary));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets(
      'overline() returns TextStyle with letterSpacing and textMuted',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            Builder(
              builder: (context) {
                final style = IslamicTypography.overline();
                expect(style.letterSpacing, isNotNull);
                expect(style.letterSpacing, greaterThan(0));
                expect(style.color, equals(IslamicColors.textMuted));
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // TEST: Optional color dan fontWeight overrides berfungsi
  // ---------------------------------------------------------------------------

  group('IslamicTypography — optional parameter overrides', () {
    testWidgets('display() respects color override', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              const overrideColor = IslamicColors.goldAmber;
              final style = IslamicTypography.display(color: overrideColor);
              expect(style.color, equals(overrideColor));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('heading() respects fontWeight override', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              final style = IslamicTypography.heading(
                fontWeight: FontWeight.w400,
              );
              expect(style.fontWeight, equals(FontWeight.w400));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('body() respects both color and fontWeight overrides', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              final style = IslamicTypography.body(
                color: IslamicColors.goldAmber,
                fontWeight: FontWeight.w700,
              );
              expect(style.color, equals(IslamicColors.goldAmber));
              expect(style.fontWeight, equals(FontWeight.w700));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
