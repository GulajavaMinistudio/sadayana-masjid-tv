import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miqotul_khoir_tv/domain/entities/display_state.dart';
import 'package:miqotul_khoir_tv/domain/entities/slideshow_image.dart';
import 'package:miqotul_khoir_tv/presentation/pages/main_display/layouts/slideshow_layout.dart';

/// Widget tests untuk [SlideshowLayout].
///
/// Ref: TASK-053 (Phase 8 — Slideshow Pengumuman)
void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  const kImage = SlideshowImage(
    slotIndex: 1,
    fileName: 'slide_slot_1_1000.jpg',
    storedPath: '/non/existent/slide.jpg', // file tidak ada → errorBuilder
    mimeType: 'image/jpeg',
    width: 1920,
    height: 1080,
    fileSizeBytes: 100000,
  );

  SlideshowAnnouncementState buildState({
    SlideshowImage image = kImage,
    int currentIndex = 0,
    int totalItems = 3,
    int remainingSlotSeconds = 90,
    int remainingImageSeconds = 12,
  }) {
    return SlideshowAnnouncementState(
      currentImage: image,
      currentIndex: currentIndex,
      totalItems: totalItems,
      currentTime: DateTime(2026, 5, 7, 10, 0, 0),
      totalSlotDurationSeconds: 120,
      remainingSlotSeconds: remainingSlotSeconds,
      imageDurationSeconds: 15,
      remainingImageSeconds: remainingImageSeconds,
    );
  }

  Widget buildTestWidget(SlideshowAnnouncementState state) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      builder: (_, _) => MaterialApp(
        home: Scaffold(body: SlideshowLayout(state: state)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('SlideshowLayout', () {
    testWidgets('kanvas SizedBox 1280×720 ditemukan di widget tree', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(buildState()));
      await tester.pumpAndSettle();

      final sizedBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((b) => b.width == 1280 && b.height == 720);
      expect(sizedBoxes, isNotEmpty);
    });

    testWidgets('menampilkan Image.file (meski file tidak ada)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(buildState()));
      await tester.pumpAndSettle();

      // Image.file ada di tree meskipun akan trigger errorBuilder saat render
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets(
      'errorBuilder atau Image ada di widget tree saat storedPath tidak valid',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(buildState()));
        await tester.pumpAndSettle();

        // Setidaknya ada widget Image (errorBuilder atau image itu sendiri)
        final hasImage = tester.any(find.byType(Image));
        final hasErrorIcon = tester.any(
          find.byIcon(Icons.broken_image_outlined),
        );
        expect(hasImage || hasErrorIcon, isTrue);
      },
    );

    testWidgets(
      'footer menampilkan posisi indikator "1 / 3" untuk currentIndex=0, totalItems=3',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(buildState(currentIndex: 0, totalItems: 3)),
        );
        await tester.pumpAndSettle();

        expect(find.text('1 / 3'), findsOneWidget);
      },
    );

    testWidgets('footer menampilkan posisi "2 / 3" untuk currentIndex=1', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(buildState(currentIndex: 1, totalItems: 3)),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('footer menampilkan sisa waktu gambar dalam detik', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(buildState(remainingImageSeconds: 12)),
      );
      await tester.pumpAndSettle();

      expect(find.text('12 dtk'), findsOneWidget);
    });

    testWidgets('Container hitam sebagai canvas background ada di tree', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(buildState()));
      await tester.pumpAndSettle();

      // Ada Container dengan color black di dalam Stack
      final blackContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.color == Colors.black);
      expect(blackContainers, isNotEmpty);
    });
  });
}
