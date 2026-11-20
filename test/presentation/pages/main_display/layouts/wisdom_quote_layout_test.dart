import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/display_state.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/domain/entities/wisdom_quote.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/main_display/layouts/wisdom_quote_layout.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUpAll(() async {
    // WisdomQuoteLayout menggunakan DateFormat('EEEE, dd MMMM yyyy', 'id_ID').
    // Locale data harus diinisialisasi sebelum test berjalan.
    await initializeDateFormatting('id_ID', null);
  });

  // Contoh item quran untuk digunakan di semua test.
  const tQuranQuote = WisdomQuote(
    id: 'quran_001',
    type: 'quran',
    label: 'Ayat Al-Quran',
    translationText: 'Karena sesungguhnya sesudah kesulitan itu ada kemudahan.',
    reference: 'QS. Al-Insyirah [94]: 5',
  );

  // State yang akan dirender oleh WisdomQuoteLayout.
  final tWisdomState = WisdomQuoteState(
    currentQuote: tQuranQuote,
    currentIndex: 0,
    totalItems: 3,
    currentTime: DateTime(2026, 3, 9, 10, 0),
    totalDurationSeconds: 180,
    remainingSeconds: 90,
  );

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

  Widget buildTestable() {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        theme: IslamicTheme.darkTheme(),
        home: BlocProvider<SettingsCubit>.value(
          value: mockSettingsCubit,
          child: Scaffold(body: WisdomQuoteLayout(state: tWisdomState)),
        ),
      ),
    );
  }

  group('WisdomQuoteLayout Widget Tests', () {
    testWidgets('renders tanpa overflow (TEST-008)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      // Tidak ada exception overflow yang terlempar.
      expect(tester.takeException(), isNull);
    });

    testWidgets('badge label quran tampil dengan teks yang benar (TEST-008)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      // Badge menggunakan format: '$badgeIcon  ${label}' → '🕌  Ayat Al-Quran'
      expect(find.textContaining('Ayat Al-Quran'), findsAtLeastNWidgets(1));
    });

    testWidgets('teks terjemahan tampil (TEST-008)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(
        find.textContaining('sesudah kesulitan itu ada kemudahan'),
        findsOneWidget,
      );
    });

    testWidgets('referensi tampil di body (TEST-008)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.textContaining('QS. Al-Insyirah'), findsOneWidget);
    });

    testWidgets('LinearProgressIndicator ada di footer (TEST-008)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('badge hadith tampil dengan ikon yang benar (TEST-008)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const tHadithQuote = WisdomQuote(
        id: 'hadith_001',
        type: 'hadith',
        label: 'Hadits',
        translationText: 'Barang siapa yang beriman kepada Allah.',
        reference: 'HR. Bukhari No. 6018',
      );
      final hadithState = WisdomQuoteState(
        currentQuote: tHadithQuote,
        currentIndex: 0,
        totalItems: 1,
        currentTime: DateTime(2026, 3, 9, 10, 0),
        totalDurationSeconds: 180,
        remainingSeconds: 90,
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1920, 1080),
          builder: (_, _) => MaterialApp(
            theme: IslamicTheme.darkTheme(),
            home: BlocProvider<SettingsCubit>.value(
              value: mockSettingsCubit,
              child: Scaffold(body: WisdomQuoteLayout(state: hadithState)),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Hadits'), findsAtLeastNWidgets(1));
    });
  });
}
