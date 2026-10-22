// ignore_for_file: invalid_use_of_protected_member
// TASK-001: Lifecycle test untuk ImamScheduleCubit
//
// Tujuan (Phase 1 — sebelum fix):
//   Test ini harus FAIL karena ImamScheduleCubit belum memiliki guard isClosed.
//
// Tujuan (Phase 2 — setelah fix):
//   Test ini harus PASS karena guard isClosed sudah ditambahkan.
//
// Pola yang digunakan:
//   Setiap test menggunakan Completer untuk mengontrol timing agar cubit.close()
//   dipanggil *sebelum* operasi async selesai, mensimulasikan skenario race
//   condition yang terjadi di production (user menekan back saat loadAll() masih
//   berjalan).

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:miqotul_khoir_tv/domain/entities/imam.dart';
import 'package:miqotul_khoir_tv/domain/entities/imam_schedule.dart';
import 'package:miqotul_khoir_tv/domain/repositories/imam_repository.dart';
import 'package:miqotul_khoir_tv/domain/repositories/imam_schedule_repository.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/display_state/display_state_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/imam_schedule/imam_schedule_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/imam_schedule/imam_schedule_state.dart';

// ---------------------------------------------------------------------------
// Mock classes
// ---------------------------------------------------------------------------

class MockImamRepository extends Mock implements ImamRepository {}

class MockImamScheduleRepository extends Mock implements ImamScheduleRepository {}

class MockDisplayStateCubit extends Mock implements DisplayStateCubit {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _tImam = Imam(id: 1, name: 'Ust. Ahmad', isActive: true);
const List<ImamSchedule> _emptyRaw = [];

/// Membuat cubit dengan stub default (semua repo mengembalikan data kosong
/// secara instan), lalu mengganti stub tertentu dengan [overrideRepoSetup]
/// agar bisa disuntik Completer untuk mengontrol timing.
ImamScheduleCubit _buildCubit({
  required MockImamRepository imamRepo,
  required MockImamScheduleRepository scheduleRepo,
  MockDisplayStateCubit? displayCubit,
}) {
  return ImamScheduleCubit(
    imamRepository: imamRepo,
    scheduleRepository: scheduleRepo,
    displayStateCubit: displayCubit,
  );
}

void main() {
  late MockImamRepository mockImamRepo;
  late MockImamScheduleRepository mockScheduleRepo;
  late MockDisplayStateCubit mockDisplayCubit;

  setUpAll(() {
    registerFallbackValue(const Imam(id: 0, name: '', isActive: true));
    registerFallbackValue(
      const ImamSchedule(
        id: 0,
        dayOfWeek: 1,
        prayerName: 'subuh',
        imamId: null,
        khatibId: null,
      ),
    );
  });

  setUp(() {
    mockImamRepo = MockImamRepository();
    mockScheduleRepo = MockImamScheduleRepository();
    mockDisplayCubit = MockDisplayStateCubit();

    // Default stub: semua method async mengembalikan data kosong
    when(() => mockImamRepo.getAll()).thenAnswer((_) async => []);
    when(() => mockImamRepo.insert(any())).thenAnswer((_) async => 1);
    when(() => mockImamRepo.update(any())).thenAnswer((_) async {});
    when(() => mockImamRepo.delete(any())).thenAnswer((_) async {});
    when(
      () => mockDisplayCubit.onSettingsChanged(),
    ).thenAnswer((_) async {});
    for (var day = 1; day <= 7; day++) {
      when(
        () => mockScheduleRepo.getRawScheduleForDay(day),
      ).thenAnswer((_) async => _emptyRaw);
    }
    when(
      () => mockScheduleRepo.setSchedule(
        dayOfWeek: any(named: 'dayOfWeek'),
        prayerName: any(named: 'prayerName'),
        imamId: any(named: 'imamId'),
        khatibId: any(named: 'khatibId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockScheduleRepo.clearScheduleForDay(any()),
    ).thenAnswer((_) async {});
  });

  // ---------------------------------------------------------------------------
  // Lifecycle Safety Tests
  // ---------------------------------------------------------------------------

  group('ImamScheduleCubit — Lifecycle Safety', () {
    // ---
    // TASK-002 item: loadAll() harus aman jika cubit di-close sebelum await selesai
    // ---
    test(
      'loadAll() does NOT throw StateError when cubit is closed during async',
      () async {
        // Arrange: gunakan Completer untuk memblokir imamRepo.getAll()
        final completer = Completer<List<Imam>>();
        when(
          () => mockImamRepo.getAll(),
        ).thenAnswer((_) => completer.future);

        final cubit = _buildCubit(
          imamRepo: mockImamRepo,
          scheduleRepo: mockScheduleRepo,
          displayCubit: mockDisplayCubit,
        );

        // Act: panggil loadAll() lalu segera tutup cubit
        final future = cubit.loadAll();
        await cubit.close();

        // Selesaikan operasi async setelah cubit sudah closed
        completer.complete([_tImam]);

        // Assert: tidak ada StateError yang dilempar
        await expectLater(future, completes);
      },
    );

    // ---
    // TASK-003 item: addImam() harus aman jika cubit di-close sebelum await selesai
    // ---
    test(
      'addImam() does NOT throw StateError when cubit is closed during async',
      () async {
        // Arrange: blokir imamRepo.insert() dengan Completer
        final completer = Completer<int>();
        when(
          () => mockImamRepo.insert(any()),
        ).thenAnswer((_) => completer.future);

        final cubit = _buildCubit(
          imamRepo: mockImamRepo,
          scheduleRepo: mockScheduleRepo,
          displayCubit: mockDisplayCubit,
        );

        // Pastikan state di-set ke Loaded agar loadAll() internal tidak crash
        when(
          () => mockImamRepo.getAll(),
        ).thenAnswer((_) async => []);

        // Act
        final future = cubit.addImam('Ust. Baru');
        await cubit.close();
        completer.complete(2);

        await expectLater(future, completes);
      },
    );

    // ---
    // TASK-004 item: updateImam() harus aman jika cubit di-close sebelum await selesai
    // ---
    test(
      'updateImam() does NOT throw StateError when cubit is closed during async',
      () async {
        // Arrange: blokir imamRepo.update() dengan Completer
        final completer = Completer<void>();
        when(
          () => mockImamRepo.update(any()),
        ).thenAnswer((_) => completer.future);

        final cubit = _buildCubit(
          imamRepo: mockImamRepo,
          scheduleRepo: mockScheduleRepo,
          displayCubit: mockDisplayCubit,
        );

        // Act
        final future = cubit.updateImam(_tImam);
        await cubit.close();
        completer.complete();

        await expectLater(future, completes);
      },
    );

    // ---
    // TASK-005 item: deleteImam() harus aman jika cubit di-close sebelum await selesai
    // ---
    test(
      'deleteImam() does NOT throw StateError when cubit is closed during async',
      () async {
        // Arrange: blokir imamRepo.delete() dengan Completer
        final completer = Completer<void>();
        when(
          () => mockImamRepo.delete(any()),
        ).thenAnswer((_) => completer.future);

        final cubit = _buildCubit(
          imamRepo: mockImamRepo,
          scheduleRepo: mockScheduleRepo,
          displayCubit: mockDisplayCubit,
        );

        // Act
        final future = cubit.deleteImam(1);
        await cubit.close();
        completer.complete();

        await expectLater(future, completes);
      },
    );

    // ---
    // TASK-006 item: setSchedule() harus aman jika cubit di-close sebelum await selesai
    // ---
    test(
      'setSchedule() does NOT throw StateError when cubit is closed during async',
      () async {
        // Arrange: blokir scheduleRepo.setSchedule() dengan Completer
        final completer = Completer<void>();
        when(
          () => mockScheduleRepo.setSchedule(
            dayOfWeek: any(named: 'dayOfWeek'),
            prayerName: any(named: 'prayerName'),
            imamId: any(named: 'imamId'),
            khatibId: any(named: 'khatibId'),
          ),
        ).thenAnswer((_) => completer.future);

        final cubit = _buildCubit(
          imamRepo: mockImamRepo,
          scheduleRepo: mockScheduleRepo,
          displayCubit: mockDisplayCubit,
        );

        // Act
        final future = cubit.setSchedule(
          dayOfWeek: 1,
          prayerName: 'subuh',
          imamId: 1,
        );
        await cubit.close();
        completer.complete();

        await expectLater(future, completes);
      },
    );

    // ---
    // TASK-007 item: clearDay() harus aman jika cubit di-close sebelum await selesai
    // ---
    test(
      'clearDay() does NOT throw StateError when cubit is closed during async',
      () async {
        // Arrange: blokir scheduleRepo.clearScheduleForDay() dengan Completer
        final completer = Completer<void>();
        when(
          () => mockScheduleRepo.clearScheduleForDay(any()),
        ).thenAnswer((_) => completer.future);

        final cubit = _buildCubit(
          imamRepo: mockImamRepo,
          scheduleRepo: mockScheduleRepo,
          displayCubit: mockDisplayCubit,
        );

        // Act
        final future = cubit.clearDay(1);
        await cubit.close();
        completer.complete();

        await expectLater(future, completes);
      },
    );

    // ---
    // TASK-008 item: updateLockState() harus aman jika dipanggil setelah close
    // ---
    test(
      'updateLockState() does NOT throw StateError when cubit is closed',
      () async {
        // Arrange: cubit dalam state Loaded
        when(
          () => mockImamRepo.getAll(),
        ).thenAnswer((_) async => []);

        final cubit = _buildCubit(
          imamRepo: mockImamRepo,
          scheduleRepo: mockScheduleRepo,
          displayCubit: mockDisplayCubit,
        );

        // Paksa state ke ImamScheduleLoaded agar guard bisa diuji
        final loadedState = ImamScheduleLoaded(
          imams: const [],
          weeklySchedule: const {},
          isLocked: false,
        );
        // Gunakan emit protected untuk seed state tanpa async
        cubit.emit(loadedState);

        // Act: close lalu panggil updateLockState
        await cubit.close();

        // Assert: tidak ada exception
        expect(() => cubit.updateLockState(true), returnsNormally);
      },
    );
  });
}
