import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/display_state.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/domain/repositories/wisdom_quote_repository.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/display_state/display_state_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/main_display/layouts/midnight_standby_layout.dart';
import 'package:miqotul_khoir_tv/presentation/pages/main_display_page.dart';
import 'package:miqotul_khoir_tv/presentation/pages/settings/pin_gate_page.dart';

class MockDisplayStateCubit extends Mock implements DisplayStateCubit {}

class MockSettingsCubit extends Mock implements SettingsCubit {}

class MockWisdomQuoteRepository extends Mock implements WisdomQuoteRepository {}

void main() {
  late MockDisplayStateCubit mockDisplayStateCubit;
  late MockSettingsCubit mockSettingsCubit;
  late MockWisdomQuoteRepository mockWisdomRepo;

  // State midnight yang digunakan pada semua test.
  final tMidnightState = MidnightStandbyState(
    currentTime: DateTime(2026, 3, 16, 23, 45),
    subuhTime: DateTime(2026, 3, 17, 4, 30),
    subuhLabel: 'Subuh - 04:30',
  );

  setUp(() {
    mockDisplayStateCubit = MockDisplayStateCubit();
    mockSettingsCubit = MockSettingsCubit();
    mockWisdomRepo = MockWisdomQuoteRepository();

    // DisplayStateCubit — state awal MidnightStandbyState.
    // onAppResumed() dipanggil di initState MainDisplayPage, harus di-stub.
    when(() => mockDisplayStateCubit.state).thenReturn(tMidnightState);
    when(
      () => mockDisplayStateCubit.stream,
    ).thenAnswer((_) => Stream.value(tMidnightState));
    when(() => mockDisplayStateCubit.onAppResumed()).thenAnswer((_) {});

    // SettingsCubit — dibutuhkan oleh PinGatePage saat navigation test (b).
    // isPinEnabled = true agar PinGatePage menampilkan UI PIN input (tidak auto-push ke SettingsMenuPage),
    // sehingga test (b) hanya perlu memverifikasi PinGatePage tampil tanpa perlu stub lebih dalam.
    when(
      () => mockSettingsCubit.state,
    ).thenReturn(SettingsLoaded(settings: const Settings()));
    when(() => mockSettingsCubit.stream).thenAnswer(
      (_) => Stream.value(SettingsLoaded(settings: const Settings())),
    );
    when(() => mockSettingsCubit.isPinEnabled).thenReturn(true);

    // WisdomQuoteRepository — dibutuhkan oleh widget tree PinGatePage.
    when(() => mockWisdomRepo.getAll()).thenAnswer((_) async => const []);
    when(
      () => mockWisdomRepo.getByIds(any()),
    ).thenAnswer((_) async => const []);
  });

  Widget buildTestable() {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (_, _) => RepositoryProvider<WisdomQuoteRepository>.value(
        value: mockWisdomRepo,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<DisplayStateCubit>.value(value: mockDisplayStateCubit),
            BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
          ],
          child: MaterialApp(
            theme: IslamicTheme.darkTheme(),
            home: const MainDisplayPage(),
          ),
        ),
      ),
    );
  }

  group('MainDisplayPage — Phase 5 Integration', () {
    testWidgets(
      '(a) MidnightStandbyLayout dirender ketika cubit emit MidnightStandbyState',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestable());
        await tester.pump();

        // MidnightStandbyLayout harus tampil — bukan layout lain.
        expect(find.byType(MidnightStandbyLayout), findsOneWidget);
        // Tidak ada exception overflow atau error rendering.
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('(b) onKeyEvent handler tetap aktif saat MidnightStandbyState — '
        'tekan OK (select) → PinGatePage terbuka', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      // Pastikan midnight layout yang aktif.
      expect(find.byType(MidnightStandbyLayout), findsOneWidget);

      // Simulasi tekan tombol OK (Android TV remote center / D-Pad select).
      // Focus widget level parent men-capture event ini dan memanggil _openSettings().
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      // PinGatePage harus di-push — onKeyEvent handler berhasil memanggil
      // Navigator.push() meski layout yang aktif adalah MidnightStandbyLayout.
      expect(find.byType(PinGatePage), findsOneWidget);
    });
  });
}
