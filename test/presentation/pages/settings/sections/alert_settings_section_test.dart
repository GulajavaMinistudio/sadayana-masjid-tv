import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/settings/sections/alert_settings_section.dart';
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
      () => mockSettingsCubit.updatePreAdzanAlertEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsCubit.updatePreIqomahAlertEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsCubit.updatePreAdzanAlertSeconds(any()),
    ).thenReturn(null);
    when(
      () => mockSettingsCubit.updatePreIqomahAlertSeconds(any()),
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
          child: const Scaffold(body: AlertSettingsSection()),
        ),
      ),
    );
  }

  group('AlertSettingsSection Widget Tests (TASK-023)', () {
    testWidgets(
      '(a) kedua toggle OFF secara default — Switch menampilkan value false (TASK-023)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Default: isPreAdzanAlertEnabled = false, isPreIqomahAlertEnabled = false
        await tester.pumpWidget(buildTestable(const Settings()));
        await tester.pumpAndSettle();

        // Kedua teks toggle tampil
        expect(find.text('Aktifkan Alarm Sebelum Adzan'), findsOneWidget);
        expect(find.text('Aktifkan Alarm Sebelum Iqomah'), findsOneWidget);

        // Kedua Switch dalam state false
        final switches = tester.widgetList<Switch>(find.byType(Switch));
        expect(switches.every((s) => s.value == false), isTrue);
      },
    );

    testWidgets(
      '(b) tap toggle Pre-Adzan saat OFF → updatePreAdzanAlertEnabled(true) dipanggil (TASK-023)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestable(
            const Settings(
              isPreAdzanAlertEnabled: false,
              isPreIqomahAlertEnabled: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Aktifkan Alarm Sebelum Adzan'));
        await tester.pump();

        verify(
          () => mockSettingsCubit.updatePreAdzanAlertEnabled(true),
        ).called(1);
      },
    );

    testWidgets(
      '(c) tap toggle Pre-Iqomah saat OFF → updatePreIqomahAlertEnabled(true) dipanggil (TASK-023)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestable(
            const Settings(
              isPreAdzanAlertEnabled: false,
              isPreIqomahAlertEnabled: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Aktifkan Alarm Sebelum Iqomah'));
        await tester.pump();

        verify(
          () => mockSettingsCubit.updatePreIqomahAlertEnabled(true),
        ).called(1);
      },
    );

    testWidgets(
      '(d) toggle OFF → ExcludeFocus(excluding: true) ada di widget tree (TASK-023)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Kedua toggle OFF → kedua DPadStepper harus di-exclude dari fokus
        await tester.pumpWidget(
          buildTestable(
            const Settings(
              isPreAdzanAlertEnabled: false,
              isPreIqomahAlertEnabled: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final excludingWidgets = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((w) => w.excluding)
            .toList();
        expect(excludingWidgets.length, equals(2));
      },
    );

    testWidgets(
      '(e) kedua toggle ON → tidak ada ExcludeFocus(excluding: true) di widget tree (TASK-023)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Kedua toggle ON → kedua DPadStepper harus aktif penuh
        await tester.pumpWidget(
          buildTestable(
            const Settings(
              isPreAdzanAlertEnabled: true,
              isPreIqomahAlertEnabled: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final excludingWidgets = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((w) => w.excluding)
            .toList();
        expect(excludingWidgets, isEmpty);

        // Kedua DPadStepper tampil
        expect(find.byType(DPadStepper), findsNWidgets(2));
      },
    );

    testWidgets(
      '(f) DPadStepper increment memanggil updatePreAdzanAlertSeconds (TASK-023)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Pre-Adzan ON, Pre-Iqomah OFF → hanya 1 add button yang aktif
        await tester.pumpWidget(
          buildTestable(
            const Settings(
              isPreAdzanAlertEnabled: true,
              isPreIqomahAlertEnabled: false,
              preAdzanAlertSeconds: 10,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap add button (icons.add_circle_outline) pada stepper Pre-Adzan
        // IgnorePointer pada stepper Pre-Iqomah memblokir tap-nya,
        // sehingga hanya stepper Pre-Adzan yang merespons.
        final addButtons = find.byIcon(Icons.add_circle_outline);
        await tester.tap(addButtons.first);
        await tester.pump();

        // 10 + 1 = 11
        verify(
          () => mockSettingsCubit.updatePreAdzanAlertSeconds(11),
        ).called(1);
      },
    );
  });
}
