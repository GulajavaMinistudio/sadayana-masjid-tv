import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/display_state.dart';
import 'package:miqotul_khoir_tv/domain/entities/imam_schedule_display.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/main_display/layouts/imam_schedule_layout.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/glassmorphism_card.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockSettingsCubit extends Mock implements SettingsCubit {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ImamScheduleDisplay _slot({
  required int dayOfWeek,
  required String prayerName,
  required String prayerLabel,
  String? imamName,
  String? khatibName,
}) {
  return ImamScheduleDisplay(
    dayOfWeek: dayOfWeek,
    prayerName: prayerName,
    prayerLabel: prayerLabel,
    imamId: imamName != null ? 1 : null,
    imamName: imamName,
    khatibId: khatibName != null ? 2 : null,
    khatibName: khatibName,
  );
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

// Jadwal Senin reguler (5 slot: 3 terisi, 2 kosong)
final _mondaySlots = [
  _slot(
    dayOfWeek: 1,
    prayerName: 'subuh',
    prayerLabel: 'Subuh',
    imamName: 'Ust. Ahmad',
  ),
  _slot(
    dayOfWeek: 1,
    prayerName: 'dzuhur',
    prayerLabel: 'Dzuhur',
    imamName: 'Ust. Budi',
  ),
  _slot(dayOfWeek: 1, prayerName: 'ashar', prayerLabel: 'Ashar'), // kosong
  _slot(
    dayOfWeek: 1,
    prayerName: 'maghrib',
    prayerLabel: 'Maghrib',
    imamName: 'Ust. Candra',
  ),
  _slot(dayOfWeek: 1, prayerName: 'isya', prayerLabel: 'Isya'), // kosong
];

// Jadwal Jumat (dengan khatib dan imam)
final _fridaySlots = [
  _slot(
    dayOfWeek: 5,
    prayerName: 'subuh',
    prayerLabel: 'Subuh',
    imamName: 'Ust. Ali',
  ),
  _slot(
    dayOfWeek: 5,
    prayerName: 'jumat',
    prayerLabel: 'Jumat',
    imamName: 'Ust. Zaid',
    khatibName: 'Ust. Mahmud',
  ),
  _slot(
    dayOfWeek: 5,
    prayerName: 'ashar',
    prayerLabel: 'Ashar',
    imamName: 'Ust. Ali',
  ),
  _slot(
    dayOfWeek: 5,
    prayerName: 'maghrib',
    prayerLabel: 'Maghrib',
    imamName: 'Ust. Ali',
  ),
  _slot(dayOfWeek: 5, prayerName: 'isya', prayerLabel: 'Isya'),
];

// State untuk hari Senin (dayOfWeek=1)
final _mondayState = ImamScheduleState(
  dayName: 'SENIN',
  hijriDate: '25 Rajab 1447 H',
  slots: _mondaySlots,
  currentTime: DateTime(2026, 3, 16, 10, 0),
  totalDurationSeconds: 30,
  remainingSeconds: 20,
);

// State untuk hari Jumat (dayOfWeek=5)
final _fridayState = ImamScheduleState(
  dayName: "JUM'AT",
  hijriDate: '28 Rajab 1447 H',
  slots: _fridaySlots,
  currentTime: DateTime(2026, 3, 20, 10, 0),
  totalDurationSeconds: 30,
  remainingSeconds: 15,
);

void main() {
  late MockSettingsCubit mockSettingsCubit;

  void setupSettingsCubit({String mosqueName = 'Masjid Al-Ikhlas'}) {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      SettingsLoaded(
        settings: Settings(
          mosqueName: mosqueName,
          mosqueAddress: 'Jl. Masjid No.1',
        ),
      ),
    );
    when(() => mockSettingsCubit.stream).thenAnswer(
      (_) => Stream.value(
        SettingsLoaded(
          settings: Settings(
            mosqueName: mosqueName,
            mosqueAddress: 'Jl. Masjid No.1',
          ),
        ),
      ),
    );
    when(() => mockSettingsCubit.isPinEnabled).thenReturn(false);
  }

  Widget buildTestable(ImamScheduleState state) {
    setupSettingsCubit();
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        theme: IslamicTheme.darkTheme(),
        home: BlocProvider<SettingsCubit>.value(
          value: mockSettingsCubit,
          child: Scaffold(body: ImamScheduleLayout(state: state)),
        ),
      ),
    );
  }

  // Ukuran layar TV standar
  void setTvSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  setUpAll(() async {
    // Inisialisasi locale data 'id' yang dibutuhkan oleh HeaderWidget (DateFormat)
    await initializeDateFormatting('id');
  });

  group('ImamScheduleLayout Widget Tests', () {
    testWidgets('(a) layout render tanpa overflow pada resolusi 1920x1080', (
      tester,
    ) async {
      setTvSize(tester);
      await tester.pumpWidget(buildTestable(_mondayState));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ImamScheduleLayout), findsOneWidget);
    });

    testWidgets(
      '(b) HeaderWidget ditampilkan tanpa exception (currentTime ada)',
      (tester) async {
        setTvSize(tester);
        await tester.pumpWidget(buildTestable(_mondayState));
        await tester.pumpAndSettle();

        // Header widget sudah dirender — tidak ada exception
        expect(tester.takeException(), isNull);
        expect(find.byType(ImamScheduleLayout), findsOneWidget);
      },
    );

    testWidgets('(c) badge nama hari ditampilkan: SENIN', (tester) async {
      setTvSize(tester);
      await tester.pumpWidget(buildTestable(_mondayState));
      await tester.pumpAndSettle();

      // Badge berisi '══  SENIN  ══'
      expect(find.textContaining('SENIN'), findsOneWidget);
    });

    testWidgets('(d) semua label waktu sholat ditampilkan (5 baris)', (
      tester,
    ) async {
      setTvSize(tester);
      await tester.pumpWidget(buildTestable(_mondayState));
      await tester.pumpAndSettle();

      expect(find.text('Subuh'), findsAtLeastNWidgets(1));
      expect(find.text('Dzuhur'), findsAtLeastNWidgets(1));
      expect(find.text('Ashar'), findsAtLeastNWidgets(1));
      expect(find.text('Maghrib'), findsAtLeastNWidgets(1));
      expect(find.text('Isya'), findsAtLeastNWidgets(1));
    });

    testWidgets('(e) slot kosong menampilkan teks "Imam belum tersedia"', (
      tester,
    ) async {
      setTvSize(tester);
      await tester.pumpWidget(buildTestable(_mondayState));
      await tester.pumpAndSettle();

      // Ada 2 slot kosong (Ashar dan Isya) → 2x teks
      expect(find.text('Imam belum tersedia'), findsNWidgets(2));
    });

    testWidgets('(f) slot terisi menampilkan nama imam', (tester) async {
      setTvSize(tester);
      await tester.pumpWidget(buildTestable(_mondayState));
      await tester.pumpAndSettle();

      expect(find.text('Ust. Ahmad'), findsOneWidget);
      expect(find.text('Ust. Budi'), findsOneWidget);
      expect(find.text('Ust. Candra'), findsOneWidget);
    });

    testWidgets('(g) GlassmorphismCard ditampilkan di body dan footer', (
      tester,
    ) async {
      setTvSize(tester);
      await tester.pumpWidget(buildTestable(_mondayState));
      await tester.pumpAndSettle();

      // Minimal 2 card: 1 body + 1 footer
      expect(find.byType(GlassmorphismCard), findsAtLeastNWidgets(2));
    });

    testWidgets(
      '(h) LinearProgressIndicator ditampilkan di footer dengan nilai yang benar',
      (tester) async {
        setTvSize(tester);
        // remainingSeconds=20, totalDurationSeconds=30
        // progress = 1 - 20/30 = 1/3 ≈ 0.333
        await tester.pumpWidget(buildTestable(_mondayState));
        await tester.pumpAndSettle();

        final progressIndicators = tester
            .widgetList<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .toList();
        expect(progressIndicators, isNotEmpty);

        final progress = progressIndicators.first.value;
        expect(progress, closeTo(1.0 / 3.0, 0.01));
      },
    );

    // -------------------------------------------------------------------------
    // Skenario Jumat: khatib + imam
    // -------------------------------------------------------------------------

    testWidgets('(i) Jumat: badge menampilkan nama hari JUM\'AT', (
      tester,
    ) async {
      setTvSize(tester);
      await tester.pumpWidget(buildTestable(_fridayState));
      await tester.pumpAndSettle();

      expect(find.textContaining("JUM'AT"), findsOneWidget);
    });

    testWidgets('(j) Jumat: slot jumat menampilkan Khatib dan Imam', (
      tester,
    ) async {
      setTvSize(tester);
      await tester.pumpWidget(buildTestable(_fridayState));
      await tester.pumpAndSettle();

      // Label baris
      expect(find.text('Khatib:'), findsOneWidget);
      expect(find.text('Imam:'), findsOneWidget);

      // Nama-nama
      expect(find.text('Ust. Mahmud'), findsOneWidget); // khatib
      expect(find.text('Ust. Zaid'), findsOneWidget); // imam
    });

    testWidgets(
      '(k) Jumat slot kosong imam menampilkan "Imam belum tersedia"',
      (tester) async {
        setTvSize(tester);

        // Buat state Jumat dengan slot jumat yang imam-nya kosong
        final emptyFridaySlots = [
          _slot(dayOfWeek: 5, prayerName: 'subuh', prayerLabel: 'Subuh'),
          _slot(
            dayOfWeek: 5,
            prayerName: 'jumat',
            prayerLabel: 'Jumat',
            khatibName: 'Ust. Mahmud', // khatib ada, imam kosong
          ),
          _slot(dayOfWeek: 5, prayerName: 'ashar', prayerLabel: 'Ashar'),
          _slot(dayOfWeek: 5, prayerName: 'maghrib', prayerLabel: 'Maghrib'),
          _slot(dayOfWeek: 5, prayerName: 'isya', prayerLabel: 'Isya'),
        ];

        final emptyFridayState = ImamScheduleState(
          dayName: "JUM'AT",
          hijriDate: '28 Rajab 1447 H',
          slots: emptyFridaySlots,
          currentTime: DateTime(2026, 3, 20, 10, 0),
          totalDurationSeconds: 30,
          remainingSeconds: 10,
        );

        await tester.pumpWidget(buildTestable(emptyFridayState));
        await tester.pumpAndSettle();

        expect(find.text('Imam belum tersedia'), findsAtLeastNWidgets(1));
        expect(find.text('Ust. Mahmud'), findsOneWidget);
      },
    );

    testWidgets('(l) nama masjid ditampilkan dari SettingsCubit', (
      tester,
    ) async {
      setTvSize(tester);
      // mosqueName = 'Masjid Al-Ikhlas' (sudah di-setup di buildTestable)
      await tester.pumpWidget(buildTestable(_mondayState));
      await tester.pumpAndSettle();

      expect(find.text('Masjid Al-Ikhlas'), findsWidgets);
    });
  });
}
