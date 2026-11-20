import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/domain/entities/wisdom_quote.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/wisdom_preview_page.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUpAll(() async {
    // WisdomPreviewPage renders WisdomQuoteLayout which uses DateFormat('EEEE, dd MMMM yyyy', 'id_ID').
    await initializeDateFormatting('id_ID', null);
  });

  final tQuotes = <WisdomQuote>[
    const WisdomQuote(
      id: 'quran_001',
      type: 'quran',
      label: 'Ayat Al-Quran',
      translationText:
          'Karena sesungguhnya sesudah kesulitan itu ada kemudahan.',
      reference: 'QS. Al-Insyirah [94]: 5',
    ),
    const WisdomQuote(
      id: 'hadith_001',
      type: 'hadith',
      label: 'Hadits',
      translationText: 'Barang siapa yang beriman kepada Allah dan hari akhir.',
      reference: 'HR. Bukhari No. 6018',
    ),
  ];

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      SettingsLoaded(settings: const Settings(mosqueName: 'Masjid Test')),
    );
    when(() => mockSettingsCubit.stream).thenAnswer(
      (_) => Stream.value(
        SettingsLoaded(settings: const Settings(mosqueName: 'Masjid Test')),
      ),
    );
    when(() => mockSettingsCubit.isPinEnabled).thenReturn(false);
  });

  /// Membangun widget dalam konteks Navigator sehingga Navigator.pop() berfungsi.
  Widget buildTestable(List<WisdomQuote> quotes) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        theme: IslamicTheme.darkTheme(),
        home: BlocProvider<SettingsCubit>.value(
          value: mockSettingsCubit,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<SettingsCubit>.value(
                      value: mockSettingsCubit,
                      child: WisdomPreviewPage(quotes: quotes),
                    ),
                  ),
                ),
                child: const Text('Buka Preview'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('WisdomPreviewPage Widget Tests (TEST-010)', () {
    testWidgets('render item pertama dari list (TEST-010)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable(tQuotes));

      // Navigasi ke WisdomPreviewPage.
      await tester.tap(find.text('Buka Preview'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Teks terjemahan item pertama harus tampil.
      expect(
        find.textContaining('sesudah kesulitan itu ada kemudahan'),
        findsOneWidget,
      );
    });

    testWidgets('tombol Tutup Preview tampil (TEST-010)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable(tQuotes));

      await tester.tap(find.text('Buka Preview'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text('Tutup Preview'), findsOneWidget);
    });

    testWidgets('tap tombol Tutup Preview memanggil Navigator.pop (TEST-010)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable(tQuotes));

      // Buka preview page.
      await tester.tap(find.text('Buka Preview'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Pastikan berada di halaman WisdomPreviewPage
      expect(find.text('Tutup Preview'), findsOneWidget);

      // Tap tombol tutup.
      await tester.tap(find.text('Tutup Preview'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Setelah pop, halaman WisdomPreviewPage sudah tidak ada.
      expect(find.text('Tutup Preview'), findsNothing);
      // Halaman asal kembali tampil.
      expect(find.text('Buka Preview'), findsOneWidget);
    });

    testWidgets('header overlay PREV/NEXT label tampil (TEST-010)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable(tQuotes));

      await tester.tap(find.text('Buka Preview'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text('PREV'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
    });
  });
}
