import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/display_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/main_display/layouts/midnight_standby_layout.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/digital_clock_widget.dart';

void main() {
  // State contoh yang akan dirender pada semua test.
  final tState = MidnightStandbyState(
    currentTime: DateTime(2026, 3, 16, 23, 45),
    subuhTime: DateTime(2026, 3, 17, 4, 30),
    subuhLabel: 'Subuh - 04:30',
  );

  Widget buildTestable() {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        theme: IslamicTheme.darkTheme(),
        home: Scaffold(body: MidnightStandbyLayout(state: tState)),
      ),
    );
  }

  group('MidnightStandbyLayout Widget Tests', () {
    testWidgets('(a) Container hitam fullscreen dirender tanpa overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      // Tidak boleh ada exception overflow.
      expect(tester.takeException(), isNull);

      // Container utama dengan color hitam harus ada.
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.color == Colors.black)
          .toList();
      expect(containers, isNotEmpty);
    });

    testWidgets('(b) DigitalClockWidget ditampilkan', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.byType(DigitalClockWidget), findsOneWidget);
    });

    testWidgets('(c) Info Subuh ditampilkan dengan label yang benar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.text('Subuh - 04:30'), findsOneWidget);
    });

    testWidgets('(d) AnimationController diinisialisasi dan berjalan '
        '— widget tidak error setelah beberapa frame', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      // AnimatedBuilder harus ada (membuktikan animasi dipakai).
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));

      // Maju waktu beberapa detik — controller yang tidak berjalan
      // akan menyebabkan exception atau widget kosong.
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      expect(find.byType(MidnightStandbyLayout), findsOneWidget);

      // Animasi masih berlangsung setelah 2 detik (isAnimating = true).
      expect(tester.hasRunningAnimations, isTrue);
    });
  });
}
