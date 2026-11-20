import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/display_state.dart';
import 'package:miqotul_khoir_tv/domain/entities/imam.dart';
import 'package:miqotul_khoir_tv/domain/entities/imam_schedule.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/domain/repositories/imam_repository.dart';
import 'package:miqotul_khoir_tv/domain/repositories/imam_schedule_repository.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/display_state/display_state_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/settings/sections/imam_schedule_section.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/dpad_stepper.dart';

// ---------------------------------------------------------------------------
// Mock classes
// ---------------------------------------------------------------------------

class MockSettingsCubit extends Mock implements SettingsCubit {}

class MockImamRepository extends Mock implements ImamRepository {}

class MockImamScheduleRepository extends Mock
    implements ImamScheduleRepository {}

class MockDisplayStateCubit extends Mock implements DisplayStateCubit {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Default settings dengan imam schedule diaktifkan.
const _enabledSettings = Settings(
  isImamScheduleEnabled: true,
  isImamScheduleLocked: false,
  imamScheduleIntervalMinutes: 15,
  imamScheduleDurationSeconds: 30,
  imamScheduleStartHour: 6,
  imamScheduleStartMinute: 0,
  imamScheduleEndHour: 21,
  imamScheduleEndMinute: 0,
);

/// Default settings dengan imam schedule dimatikan.
const _disabledSettings = Settings(isImamScheduleEnabled: false);

void main() {
  late MockSettingsCubit mockSettingsCubit;
  late MockImamRepository mockImamRepo;
  late MockImamScheduleRepository mockScheduleRepo;
  late MockDisplayStateCubit mockDisplayCubit;

  /// Stub semua interaksi repository yang dipanggil oleh ImamScheduleCubit.loadAll()
  void stubRepositoryDefaults({List<Imam> imams = const []}) {
    when(() => mockImamRepo.getAll()).thenAnswer((_) async => imams);
    for (var day = 1; day <= 7; day++) {
      when(
        () => mockScheduleRepo.getRawScheduleForDay(day),
      ).thenAnswer((_) async => const <ImamSchedule>[]);
    }
  }

  /// Stub SettingsCubit dengan settings tertentu.
  void stubSettingsCubit(Settings settings) {
    when(
      () => mockSettingsCubit.state,
    ).thenReturn(SettingsLoaded(settings: settings));
    when(
      () => mockSettingsCubit.stream,
    ).thenAnswer((_) => Stream.value(SettingsLoaded(settings: settings)));
    when(() => mockSettingsCubit.isPinEnabled).thenReturn(false);
  }

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    mockImamRepo = MockImamRepository();
    mockScheduleRepo = MockImamScheduleRepository();
    mockDisplayCubit = MockDisplayStateCubit();

    // Stub semua update methods pada SettingsCubit
    when(
      () => mockSettingsCubit.updateImamScheduleEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsCubit.updateImamScheduleLocked(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsCubit.updateImamScheduleIntervalMinutes(any()),
    ).thenReturn(null);
    when(
      () => mockSettingsCubit.updateImamScheduleDurationSeconds(any()),
    ).thenReturn(null);
    when(
      () => mockSettingsCubit.updateImamScheduleStartHour(any()),
    ).thenReturn(null);
    when(
      () => mockSettingsCubit.updateImamScheduleStartMinute(any()),
    ).thenReturn(null);
    when(
      () => mockSettingsCubit.updateImamScheduleEndHour(any()),
    ).thenReturn(null);
    when(
      () => mockSettingsCubit.updateImamScheduleEndMinute(any()),
    ).thenReturn(null);

    // DisplayStateCubit — perlu stub state & stream karena ImamScheduleSection
    // mengakses displayStateCubit.stream di dalam builder-nya.
    when(
      () => mockDisplayCubit.state,
    ).thenReturn(StandbyState(currentTime: DateTime(2026, 1, 1)));
    when(
      () => mockDisplayCubit.stream,
    ).thenAnswer((_) => const Stream<DisplayState>.empty());
    when(() => mockDisplayCubit.onSettingsChanged()).thenAnswer((_) async {});

    // Default: repository kosong
    stubRepositoryDefaults();
    stubSettingsCubit(_enabledSettings);
  });

  /// Membangun widget tree dengan semua dependency yang dibutuhkan.
  ///
  /// [ImamScheduleSection] membuat [BlocProvider<ImamScheduleCubit>] secara
  /// lokal dan membaca [ImamRepository], [ImamScheduleRepository], dan
  /// [DisplayStateCubit] dari ancestor context.
  Widget buildTestable() {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        theme: IslamicTheme.darkTheme(),
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ImamRepository>.value(value: mockImamRepo),
            RepositoryProvider<ImamScheduleRepository>.value(
              value: mockScheduleRepo,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
              BlocProvider<DisplayStateCubit>.value(value: mockDisplayCubit),
            ],
            child: const Scaffold(body: ImamScheduleSection()),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('ImamScheduleSection Widget Tests', () {
    testWidgets(
      '(a) render tanpa overflow — header "Jadwal Imam Sholat" tampil',
      (tester) async {
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Jadwal Imam Sholat'), findsOneWidget);
      },
    );

    testWidgets(
      '(b) toggle "Aktifkan Jadwal Imam" tampil dengan nilai sesuai settings',
      (tester) async {
        stubSettingsCubit(_enabledSettings);
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        expect(find.text('Aktifkan Jadwal Imam'), findsOneWidget);

        final switches = tester
            .widgetList<Switch>(find.byType(Switch))
            .toList();
        // Switch pertama = toggle enabled
        expect(switches.first.value, isTrue);
      },
    );

    testWidgets(
      '(c) toggle OFF — updateImamScheduleEnabled(false) dipanggil saat tap',
      (tester) async {
        stubSettingsCubit(_enabledSettings);
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Aktifkan Jadwal Imam'));
        await tester.pump();

        verify(
          () => mockSettingsCubit.updateImamScheduleEnabled(false),
        ).called(1);
      },
    );

    testWidgets(
      '(d) toggle enabled=false → ExcludeFocus(excluding:true) ada di tree',
      (tester) async {
        stubSettingsCubit(_disabledSettings);
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        final excludingWidgets = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((w) => w.excluding)
            .toList();
        expect(excludingWidgets, isNotEmpty);
      },
    );

    testWidgets(
      '(e) toggle enabled=true → 6 DPadStepper tampil (interval, durasi, 4 jam)',
      (tester) async {
        stubSettingsCubit(_enabledSettings);
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        // 6 DPadStepper: interval, durasi, startHour, startMinute, endHour, endMinute
        expect(find.byType(DPadStepper), findsNWidgets(6));
      },
    );

    testWidgets('(f) toggle "Kunci Jadwal" tampil ketika enabled=true', (
      tester,
    ) async {
      stubSettingsCubit(_enabledSettings);
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Kunci Jadwal'), findsOneWidget);
    });

    testWidgets(
      '(g) tap "Kunci Jadwal" dengan imam terdaftar → updateImamScheduleLocked(true) dipanggil',
      (tester) async {
        stubSettingsCubit(_enabledSettings);
        // Toggle kunci hanya aktif jika ada imam terdaftar (canLock = hasImams)
        stubRepositoryDefaults(
          imams: [const Imam(id: 1, name: 'Ahmad Fauzi', isActive: true)],
        );
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kunci Jadwal'));
        await tester.pump();

        verify(
          () => mockSettingsCubit.updateImamScheduleLocked(true),
        ).called(1);
      },
    );

    testWidgets(
      '(g2) tap "Kunci Jadwal" tanpa imam terdaftar → toggle nonaktif, updateImamScheduleLocked tidak dipanggil',
      (tester) async {
        stubSettingsCubit(_enabledSettings);
        stubRepositoryDefaults(imams: []); // tidak ada imam → canLock=false
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kunci Jadwal'));
        await tester.pump();

        verifyNever(() => mockSettingsCubit.updateImamScheduleLocked(any()));
        // Hint text muncul saat toggle dinonaktifkan
        expect(
          find.text('Tambah imam terlebih dahulu untuk mengunci'),
          findsOneWidget,
        );
      },
    );

    testWidgets('(h) info bar jam aktif tampil dengan format HH:MM – HH:MM', (
      tester,
    ) async {
      // startHour=6, startMinute=0, endHour=21, endMinute=0
      stubSettingsCubit(_enabledSettings);
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      // Info bar: 'Aktif 06:00 – 21:00'
      expect(find.textContaining('06:00'), findsAtLeastNWidgets(1));
      expect(find.textContaining('21:00'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      '(i) daftar imam kosong → tampil pesan "Belum ada imam terdaftar"',
      (tester) async {
        stubSettingsCubit(_enabledSettings);
        stubRepositoryDefaults(imams: []);
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        expect(find.textContaining('Belum ada imam terdaftar'), findsOneWidget);
      },
    );

    testWidgets('(j) daftar imam terisi → nama imam tampil di list', (
      tester,
    ) async {
      stubSettingsCubit(_enabledSettings);
      stubRepositoryDefaults(
        imams: const [
          Imam(id: 1, name: 'Ust. Ahmad Fauzi', isActive: true),
          Imam(id: 2, name: 'Ust. Budi Santoso', isActive: true),
        ],
      );
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Ust. Ahmad Fauzi'), findsOneWidget);
      expect(find.text('Ust. Budi Santoso'), findsOneWidget);
    });

    testWidgets('(k) counter imam/10 tampil di header daftar imam', (
      tester,
    ) async {
      stubSettingsCubit(_enabledSettings);
      stubRepositoryDefaults(
        imams: const [Imam(id: 1, name: 'Ust. Ahmad', isActive: true)],
      );
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('1/10'), findsOneWidget);
    });

    testWidgets('(l) 7 tab hari tampil di grid jadwal mingguan', (
      tester,
    ) async {
      stubSettingsCubit(_enabledSettings);
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      // 7 nama hari: Senin, Selasa, Rabu, Kamis, Jum'at, Sabtu, Minggu
      expect(find.text('Senin'), findsOneWidget);
      expect(find.text('Selasa'), findsOneWidget);
      expect(find.text('Rabu'), findsOneWidget);
      expect(find.text('Kamis'), findsOneWidget);
      expect(find.textContaining("Jum'at"), findsOneWidget);
      expect(find.text('Sabtu'), findsOneWidget);
      expect(find.text('Minggu'), findsOneWidget);
    });
  });
}
