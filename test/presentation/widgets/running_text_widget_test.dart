import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marquee/marquee.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/glassmorphism_card.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/running_text_widget.dart';

/// Widget tests untuk [RunningTextWidget].
///
/// Ref: Plan 04 TASK-029 s.d. TASK-031
void main() {
  /// Helper untuk membungkus widget dalam ScreenUtil + MaterialApp.
  Widget buildTestable(Widget widget) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      child: MaterialApp(
        home: Scaffold(body: SizedBox(width: 800, height: 200, child: widget)),
      ),
    );
  }

  group('RunningTextWidget', () {
    // TASK-030: TEST — renders Marquee when text is not empty
    testWidgets('renders Marquee widget when text is not empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const RunningTextWidget(text: 'Selamat datang di Masjid Al-Ikhlas'),
        ),
      );

      // Pump beberapa frame untuk memberi Marquee waktu inisialisasi
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Marquee), findsOneWidget);
    });

    // TASK-031: TEST — renders SizedBox.shrink() when text is empty
    testWidgets('renders SizedBox.shrink() when text is empty', (tester) async {
      await tester.pumpWidget(buildTestable(const RunningTextWidget(text: '')));

      // Tidak ada Marquee yang dirender
      expect(find.byType(Marquee), findsNothing);

      // Tidak ada GlassmorphismCard yang dirender
      expect(find.byType(GlassmorphismCard), findsNothing);

      // SizedBox.shrink() ada di widget tree — cari yang paling kecil (0×0)
      final allSizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final shrinkBox = allSizedBoxes.firstWhere(
        (sb) => sb.width == 0.0 && sb.height == 0.0,
        orElse: () => throw TestFailure(
          'SizedBox.shrink() (width=0, height=0) tidak ditemukan di widget tree',
        ),
      );
      expect(shrinkBox.width, equals(0.0));
      expect(shrinkBox.height, equals(0.0));
    });

    testWidgets(
      'renders GlassmorphismCard when showBackground is true (default)',
      (tester) async {
        await tester.pumpWidget(
          buildTestable(const RunningTextWidget(text: 'Test running text')),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(GlassmorphismCard), findsOneWidget);
      },
    );

    testWidgets(
      'does not render GlassmorphismCard when showBackground is false',
      (tester) async {
        await tester.pumpWidget(
          buildTestable(
            const RunningTextWidget(
              text: 'Test running text',
              showBackground: false,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(GlassmorphismCard), findsNothing);
        expect(find.byType(Marquee), findsOneWidget);
      },
    );

    testWidgets('uses default scrollSpeed of 30.0', (tester) async {
      const widget = RunningTextWidget(text: 'Test');
      expect(widget.scrollSpeed, equals(30.0));
    });

    testWidgets('uses default pauseDuration of Duration.zero', (tester) async {
      const widget = RunningTextWidget(text: 'Test');
      expect(widget.pauseDuration, equals(Duration.zero));
    });
  });
}
