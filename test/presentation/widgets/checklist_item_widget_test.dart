import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/checklist_item_widget.dart';

void main() {
  Widget buildTestable({
    required String id,
    required String type,
    required String label,
    required String translationText,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  }) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        theme: IslamicTheme.darkTheme(),
        home: Scaffold(
          body: ChecklistItemWidget(
            id: id,
            type: type,
            label: label,
            translationText: translationText,
            isChecked: isChecked,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  group('ChecklistItemWidget Tests (TEST-009)', () {
    testWidgets(
      'isChecked: true menampilkan ikon centang (check_circle_outline)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestable(
            id: 'quran_001',
            type: 'quran',
            label: 'Ayat Al-Quran',
            translationText:
                'Karena sesungguhnya sesudah kesulitan ada kemudahan.',
            isChecked: true,
            onChanged: (_) {},
          ),
        );
        await tester.pump();

        // Ikon check_circle saat isChecked = true
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      },
    );

    testWidgets('isChecked: false menampilkan ikon circle (tidak ter-check)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestable(
          id: 'quran_001',
          type: 'quran',
          label: 'Ayat Al-Quran',
          translationText:
              'Karena sesungguhnya sesudah kesulitan ada kemudahan.',
          isChecked: false,
          onChanged: (_) {},
        ),
      );
      await tester.pump();

      // Ikon circle_outlined saat isChecked = false
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('tap memanggil onChanged dengan nilai toggle (!isChecked)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool? callbackResult;

      await tester.pumpWidget(
        buildTestable(
          id: 'quran_001',
          type: 'quran',
          label: 'Ayat Al-Quran',
          translationText:
              'Karena sesungguhnya sesudah kesulitan ada kemudahan.',
          isChecked: false,
          onChanged: (value) => callbackResult = value,
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(ChecklistItemWidget));
      await tester.pump();

      // FocusableWidget.onSelect dipanggil → onChanged(!isChecked) = onChanged(true)
      expect(callbackResult, isTrue);
    });

    testWidgets('tap pada isChecked: true memanggil onChanged(false)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool? callbackResult;

      await tester.pumpWidget(
        buildTestable(
          id: 'hadith_001',
          type: 'hadith',
          label: 'Hadits',
          translationText: 'Barang siapa yang beriman kepada Allah.',
          isChecked: true,
          onChanged: (value) => callbackResult = value,
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(ChecklistItemWidget));
      await tester.pump();

      // onChanged(!true) = onChanged(false)
      expect(callbackResult, isFalse);
    });

    testWidgets('badge label quran tampil (TEST-009)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestable(
          id: 'quran_001',
          type: 'quran',
          label: 'Ayat Al-Quran',
          translationText:
              'Karena sesungguhnya sesudah kesulitan ada kemudahan.',
          isChecked: false,
          onChanged: (_) {},
        ),
      );
      await tester.pump();

      // Badge menampilkan '🕌  Ayat Al-Quran'
      expect(find.textContaining('Ayat Al-Quran'), findsOneWidget);
    });

    testWidgets('badge label hadith tampil (TEST-009)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestable(
          id: 'hadith_003',
          type: 'hadith',
          label: 'Hadits',
          translationText: 'Barang siapa yang beriman kepada Allah.',
          isChecked: false,
          onChanged: (_) {},
        ),
      );
      await tester.pump();

      // Badge menampilkan '📖  Hadits'
      expect(find.textContaining('Hadits'), findsOneWidget);
    });

    testWidgets('translationText tampil sebagai preview (TEST-009)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestable(
          id: 'quran_001',
          type: 'quran',
          label: 'Ayat Al-Quran',
          translationText: 'Teks preview terjemahan untuk test',
          isChecked: false,
          onChanged: (_) {},
        ),
      );
      await tester.pump();

      expect(find.textContaining('Teks preview terjemahan'), findsOneWidget);
    });
  });
}
