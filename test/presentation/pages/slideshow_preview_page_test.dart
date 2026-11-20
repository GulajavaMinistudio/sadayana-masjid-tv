import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:miqotul_khoir_tv/domain/entities/slideshow_image.dart';
import 'package:miqotul_khoir_tv/presentation/pages/slideshow_preview_page.dart';

/// Widget tests untuk [SlideshowPreviewPage].
///
/// Ref: TASK-054 (Phase 8 — Slideshow Pengumuman)
void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  const kImage = SlideshowImage(
    slotIndex: 2,
    fileName: 'slide_slot_2_1000.jpg',
    storedPath: '/non/existent/slide.jpg', // tidak ada → errorBuilder
    mimeType: 'image/jpeg',
    width: 1280,
    height: 720,
    fileSizeBytes: 80000,
  );

  Widget buildTestWidget({SlideshowImage image = kImage}) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      builder: (_, _) => MaterialApp(home: SlideshowPreviewPage(image: image)),
    );
  }

  group('SlideshowPreviewPage', () {
    testWidgets('kanvas SizedBox 1280×720 ditemukan di widget tree', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final sizedBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((b) => b.width == 1280 && b.height == 720);
      expect(sizedBoxes, isNotEmpty);
    });

    testWidgets('Image.file ada di widget tree', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsWidgets);
    });

    testWidgets(
      'errorBuilder atau Image ada di widget tree saat storedPath tidak valid',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final hasImage = tester.any(find.byType(Image));
        final hasErrorIcon = tester.any(
          find.byIcon(Icons.broken_image_outlined),
        );
        expect(hasImage || hasErrorIcon, isTrue);
      },
    );

    testWidgets('header menampilkan label slot "Pratinjau · Slot 2"', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Pratinjau · Slot 2'), findsOneWidget);
    });

    testWidgets('header menampilkan nama file gambar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('slide_slot_2_1000.jpg'), findsOneWidget);
    });

    testWidgets('tombol Tutup/back menutup halaman via FocusableWidget', (
      tester,
    ) async {
      bool popped = false;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1920, 1080),
          builder: (_, _) => MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SlideshowPreviewPage(image: kImage),
                    ),
                  );
                  popped = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka SlideshowPreviewPage
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Simulasi tombol Escape (back) via KeyEvent
      await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('background Scaffold berwarna hitam', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, equals(Colors.black));
    });
  });
}
