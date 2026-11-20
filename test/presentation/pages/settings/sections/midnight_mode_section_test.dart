import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/settings/sections/midnight_mode_section.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/dpad_stepper.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockSettingsCubit mockSettingsCubit;

  void setupCubit(Settings settings) {
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
    when(
      () => mockSettingsCubit.updateMidnightModeEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsCubit.updateMidnightStartHour(any()),
    ).thenReturn(null);
    when(
      () => mockSettingsCubit.updateMidnightStartMinute(any()),
    ).thenReturn(null);
    when(() => mockSettingsCubit.updateMidnightEndHour(any())).thenReturn(null);
    when(
      () => mockSettingsCubit.updateMidnightEndMinute(any()),
    ).thenReturn(null);
  });

  Widget buildTestable(Settings settings) {
    setupCubit(settings);
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        theme: IslamicTheme.darkTheme(),
        home: BlocProvider<SettingsCubit>.value(
          value: mockSettingsCubit,
          child: const Scaffold(body: MidnightModeSection()),
        ),
      ),
    );
  }

  group('MidnightModeSection Widget Tests (TASK-028)', () {
    testWidgets(
      '(a) tap toggle saat OFF → updateMidnightModeEnabled(true) dipanggil (TASK-028)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // isMidnightModeEnabled = false (default), tap toggle → should call true
        await tester.pumpWidget(
          buildTestable(const Settings(isMidnightModeEnabled: false)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Aktifkan Mode Hemat Daya'));
        await tester.pump();

        verify(
          () => mockSettingsCubit.updateMidnightModeEnabled(true),
        ).called(1);
      },
    );

    testWidgets(
      '(a) tap toggle saat ON → updateMidnightModeEnabled(false) dipanggil (TASK-028)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // isMidnightModeEnabled = true, tap toggle → should call false
        await tester.pumpWidget(
          buildTestable(const Settings(isMidnightModeEnabled: true)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Aktifkan Mode Hemat Daya'));
        await tester.pump();

        verify(
          () => mockSettingsCubit.updateMidnightModeEnabled(false),
        ).called(1);
      },
    );

    testWidgets('(b) 4 DPadStepper tampil saat toggle ON (TASK-028)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestable(const Settings(isMidnightModeEnabled: true)),
      );
      await tester.pumpAndSettle();

      // Jam Mulai, Menit Mulai, Jam Berakhir, Menit Berakhir
      expect(find.byType(DPadStepper), findsNWidgets(4));
    });

    testWidgets('(b) info bar menampilkan rentang waktu default (TASK-028)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Default: start 23:00 – end 03:30
      await tester.pumpWidget(
        buildTestable(
          const Settings(
            isMidnightModeEnabled: true,
            midnightStartHour: 23,
            midnightStartMinute: 0,
            midnightEndHour: 3,
            midnightEndMinute: 30,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('23:00 – 03:30'), findsOneWidget);
    });

    testWidgets(
      '(c) toggle OFF → ExcludeFocus(excluding: true) ada di widget tree (TASK-028)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestable(const Settings(isMidnightModeEnabled: false)),
        );
        await tester.pumpAndSettle();

        final excludingWidgets = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((w) => w.excluding)
            .toList();
        expect(excludingWidgets, isNotEmpty);
      },
    );

    testWidgets(
      '(c) toggle ON → tidak ada ExcludeFocus(excluding: true) di config area (TASK-028)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestable(const Settings(isMidnightModeEnabled: true)),
        );
        await tester.pumpAndSettle();

        final excludingWidgets = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((w) => w.excluding)
            .toList();
        expect(excludingWidgets, isEmpty);
      },
    );
  });
}
