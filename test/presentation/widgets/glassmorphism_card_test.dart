import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_colors.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/glassmorphism_card.dart';

/// Widget tests untuk [GlassmorphismCard].
///
/// Ref: Plan 04 TASK-021 s.d. TASK-024
void main() {
  /// Helper untuk membungkus widget dalam ScreenUtil + MaterialApp.
  Widget buildTestable(Widget widget) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      child: MaterialApp(home: Scaffold(body: widget)),
    );
  }

  group('GlassmorphismCard', () {
    // TASK-022: TEST — renders child widget correctly
    testWidgets('renders child widget correctly', (tester) async {
      await tester.pumpWidget(
        buildTestable(const GlassmorphismCard(child: Text('Test Child'))),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    // TASK-023: TEST — golden glow shadow when isFocused = true
    testWidgets('displays golden glow shadow when isFocused is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const GlassmorphismCard(isFocused: true, child: Text('Focused Card')),
        ),
      );

      // Cari Container yang memiliki BoxDecoration dengan boxShadow
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool hasFocusedShadow = false;

      for (final container in containers) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration && decoration.boxShadow != null) {
          final shadows = decoration.boxShadow!;
          if (shadows.isNotEmpty) {
            // Verifikasi shadow menggunakan warna goldAmber
            final shadowColor = shadows.first.color;
            // goldAmber dengan alpha 0.3
            expect(
              shadowColor.a,
              closeTo(IslamicColors.goldAmber.withValues(alpha: 0.3).a, 0.01),
            );
            hasFocusedShadow = true;
            break;
          }
        }
      }

      expect(
        hasFocusedShadow,
        isTrue,
        reason: 'GlassmorphismCard harus memiliki golden glow saat focused',
      );
    });

    // TASK-024: TEST — no shadow when isFocused = false (default)
    testWidgets('does not display shadow when isFocused is false (default)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(const GlassmorphismCard(child: Text('Unfocused Card'))),
      );

      // Cari Container dengan BoxDecoration yang memiliki boxShadow non-null
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool hasNonNullShadow = false;

      for (final container in containers) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration && decoration.boxShadow != null) {
          hasNonNullShadow = true;
          break;
        }
      }

      expect(
        hasNonNullShadow,
        isFalse,
        reason:
            'GlassmorphismCard tidak boleh memiliki shadow saat tidak focused',
      );
    });

    // TASK-024 (lanjutan): TEST — default values digunakan ketika tidak dispesifikasi
    testWidgets(
      'uses default blur intensity and border radius when not specified',
      (tester) async {
        const card = GlassmorphismCard(child: Text('Default Card'));

        // Verifikasi default values via constructor
        expect(card.blurIntensity, equals(15));
        expect(card.borderRadius, equals(16));
        expect(card.backgroundColor, equals(IslamicColors.glassWhite));
        expect(card.borderColor, equals(IslamicColors.glassBorder));
        expect(card.isFocused, isFalse);
      },
    );

    testWidgets('renders BackdropFilter widget', (tester) async {
      await tester.pumpWidget(
        buildTestable(const GlassmorphismCard(child: Text('Blur Test'))),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('renders ClipRRect widget for border radius', (tester) async {
      await tester.pumpWidget(
        buildTestable(const GlassmorphismCard(child: Text('ClipRRect Test'))),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
