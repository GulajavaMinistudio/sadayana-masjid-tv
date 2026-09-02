// TASK-005: Lifecycle test untuk DisplayStateCubit
//
// Tujuan (Phase 1 — sebelum fix):
//   Test ini harus FAIL karena DisplayStateCubit.init() / _loadConfig() /
//   _tick() belum memiliki guard isClosed sebelum memanggil emit().
//
// Tujuan (Phase 2 — setelah fix):
//   Test ini harus PASS karena guard isClosed sudah ditambahkan.
//
// Method yang diuji:
//   - init() → _loadConfig() (await getSettings, getByIds, getAll, getScheduleForDay)
//             → _startTickTimer() → _tick() → emit(StandbyState/dll)
//   - onSettingsChanged() → _loadConfig() → _tick() → emit()
//
// Catatan arsitektural:
//   DisplayStateCubit paling kompleks karena `init()` dipanggil dari konstruktor
//   dan memulai Timer periodic. Guard harus memastikan bahwa saat cubit di-close
//   sebelum init() selesai, tidak ada StateError.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:miqotul_khoir_tv/domain/entities/daily_prayer_times.dart';
import 'package:miqotul_khoir_tv/domain/entities/display_state.dart';
import 'package:miqotul_khoir_tv/domain/entities/prayer_time.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/domain/entities/transition_config.dart';
import 'package:miqotul_khoir_tv/domain/repositories/imam_schedule_repository.dart';
import 'package:miqotul_khoir_tv/domain/repositories/settings_repository.dart';
import 'package:miqotul_khoir_tv/domain/repositories/slideshow_image_repository.dart';
import 'package:miqotul_khoir_tv/domain/repositories/wisdom_quote_repository.dart';
import 'package:miqotul_khoir_tv/domain/services/audio_alert_service.dart';
import 'package:miqotul_khoir_tv/domain/usecases/evaluate_display_state_use_case.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/display_state/display_state_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/prayer_time/prayer_time.dart';

// ---------------------------------------------------------------------------
// Mock classes
// ---------------------------------------------------------------------------

class MockEvaluateDisplayStateUseCase extends Mock
    implements EvaluateDisplayStateUseCase {}

class MockPrayerTimeCubit extends Mock implements PrayerTimeCubit {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockWisdomQuoteRepository extends Mock implements WisdomQuoteRepository {}

class MockSlideshowImageRepository extends Mock
    implements SlideshowImageRepository {}

class MockImamScheduleRepository extends Mock
    implements ImamScheduleRepository {}

class MockAudioAlertService extends Mock implements AudioAlertService {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Membangun dummy DailyPrayerTimes untuk registerFallbackValue
DailyPrayerTimes _dummyDPT() {
  final now = DateTime.now();
  final pt = PrayerTime(
    name: 'Subuh',
    time: now,
    originalTime: now,
    ihtiyatMinutes: 0,
  );
  return DailyPrayerTimes(
    date: now,
    hijriDate: '',
    subuh: pt,
    syuruq: pt,
    dhuha: pt,
    dzuhur: pt,
    ashar: pt,
    maghrib: pt,
    isya: pt,
  );
}

void main() {
  late MockEvaluateDisplayStateUseCase mockEvaluate;
  late MockPrayerTimeCubit mockPrayerCubit;
  late MockSettingsRepository mockSettingsRepo;
  late MockWisdomQuoteRepository mockWisdomRepo;
  late MockSlideshowImageRepository mockSlideshowRepo;
  late MockImamScheduleRepository mockImamScheduleRepo;
  late MockAudioAlertService mockAudioService;
  late StreamController<PrayerTimeState> prayerStreamCtrl;

  setUpAll(() {
    registerFallbackValue(StandbyState(currentTime: DateTime.now()));
    registerFallbackValue(
      const TransitionConfig(
        preAdzanMinutes: 10,
        adzanDurationSeconds: 180,
        sholatDurationMinutes: 15,
        iqomahMinutes: {},
      ),
    );
    registerFallbackValue(_dummyDPT());
    registerFallbackValue(PrayerTimeInitial());
  });

  setUp(() {
    mockEvaluate = MockEvaluateDisplayStateUseCase();
    mockPrayerCubit = MockPrayerTimeCubit();
    mockSettingsRepo = MockSettingsRepository();
    mockWisdomRepo = MockWisdomQuoteRepository();
    mockSlideshowRepo = MockSlideshowImageRepository();
    mockImamScheduleRepo = MockImamScheduleRepository();
    mockAudioService = MockAudioAlertService();
    prayerStreamCtrl = StreamController<PrayerTimeState>();

    // Stub semua AudioAlertService methods yang dipanggil saat close()
    when(() => mockAudioService.playAlert()).thenAnswer((_) async {});
    when(() => mockAudioService.stopAlert()).thenAnswer((_) async {});
    when(() => mockAudioService.dispose()).thenAnswer((_) async {});

    // Default stubs untuk init() → _loadConfig()
    when(
      () => mockSettingsRepo.getSettings(),
    ).thenAnswer((_) async => const Settings());
    when(() => mockWisdomRepo.getByIds(any())).thenAnswer((_) async => []);
    when(() => mockSlideshowRepo.getAll()).thenAnswer((_) async => []);
    when(
      () => mockImamScheduleRepo.getScheduleForDay(any()),
    ).thenAnswer((_) async => []);

    // Stream dan state mock untuk PrayerTimeCubit
    when(
      () => mockPrayerCubit.stream,
    ).thenAnswer((_) => prayerStreamCtrl.stream);
    when(() => mockPrayerCubit.state).thenReturn(PrayerTimeInitial());

    // Default evaluate: kembalikan StandbyState
    when(
      () => mockEvaluate.evaluate(
        now: any(named: 'now'),
        dailyPrayerTimes: any(named: 'dailyPrayerTimes'),
        config: any(named: 'config'),
        hijriDate: any(named: 'hijriDate'),
        activeQuotes: any(named: 'activeQuotes'),
        slideshowImages: any(named: 'slideshowImages'),
        todayImamSchedule: any(named: 'todayImamSchedule'),
      ),
    ).thenReturn(StandbyState(currentTime: DateTime.now()));
  });

  tearDown(() {
    prayerStreamCtrl.close();
  });

  /// Helper untuk membangun cubit dengan semua dependency
  DisplayStateCubit buildCubit() => DisplayStateCubit(
    evaluateUseCase: mockEvaluate,
    prayerTimeCubit: mockPrayerCubit,
    settingsRepository: mockSettingsRepo,
    wisdomQuoteRepository: mockWisdomRepo,
    slideshowImageRepository: mockSlideshowRepo,
    imamScheduleRepository: mockImamScheduleRepo,
    audioAlertService: mockAudioService,
  );

  // ---------------------------------------------------------------------------
  // Lifecycle Safety Tests
  // ---------------------------------------------------------------------------

  group('DisplayStateCubit — Lifecycle Safety', () {
    // ---
    // Skenario paling kritis: cubit di-close saat init() masih memproses
    // _loadConfig() — yaitu saat getSettings() masih menunggu.
    // ---
    test(
      'init() does NOT throw StateError when cubit is closed during _loadConfig()',
      () async {
        // Arrange: blokir getSettings() agar init() tergantung sebelum selesai
        final completer = Completer<Settings>();
        when(
          () => mockSettingsRepo.getSettings(),
        ).thenAnswer((_) => completer.future);

        // Buat cubit — ini otomatis memanggil init() di constructor
        final cubit = buildCubit();

        // Act: segera close sebelum init() selesai
        await cubit.close();
        completer.complete(const Settings());

        // Assert: tidak ada StateError — cukup menunggu semua microtask selesai
        await expectLater(Future.microtask(() {}), completes);
      },
    );

    // ---
    // onSettingsChanged() memanggil _loadConfig() lalu _tick() → emit()
    // ---
    test(
      'onSettingsChanged() does NOT throw StateError when cubit is closed during async',
      () async {
        // Arrange: buat cubit dan tunggu init() selesai
        final cubit = buildCubit();
        await Future.delayed(const Duration(milliseconds: 50));

        // Blokir getSettings() untuk panggilan berikutnya dari onSettingsChanged
        final completer = Completer<Settings>();
        when(
          () => mockSettingsRepo.getSettings(),
        ).thenAnswer((_) => completer.future);

        // Act
        final future = cubit.onSettingsChanged();
        await cubit.close();
        completer.complete(const Settings());

        // Assert
        await expectLater(future, completes);
      },
    );
  });
}
