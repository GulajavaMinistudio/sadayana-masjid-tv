import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/settings/sections/treasury_section.dart';

/// Widget tests untuk [TreasurySection].
///
/// Memvalidasi:
/// - Render komponen (switch toggle, 3 input fields)
/// - Input groups disabled saat toggle OFF
/// - Pemanggilan cubit saat toggle berubah
///
/// Ref: Plan feature-treasury-info-1.md Phase 9 TASK-036
class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockSettingsCubit mockCubit;

  /// Helper: settings dengan isTreasuryEnabled = false (default)
  Settings settingsOff() => const Settings();

  /// Helper: settings dengan isTreasuryEnabled = true
  Settings settingsOn() => const Settings(
    isTreasuryEnabled: true,
    treasuryBalance: 5000000,
    treasuryIncome: 2500000,
    treasuryExpense: 750000,
  );

  setUp(() {
    mockCubit = MockSettingsCubit();
  });

  Widget buildTestable(Settings settings) {
    when(() => mockCubit.state).thenReturn(SettingsLoaded(settings: settings));
    when(
      () => mockCubit.stream,
    ).thenAnswer((_) => Stream.value(SettingsLoaded(settings: settings)));

    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (context, _) {
        return MaterialApp(
          home: Scaffold(
            body: BlocProvider<SettingsCubit>.value(
              value: mockCubit,
              child: const TreasurySection(),
            ),
          ),
        );
      },
    );
  }

  group('TreasurySection', () {
    testWidgets('menampilkan header "Informasi Kas Masjid"', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestable(settingsOff()));
      await tester.pump();

      expect(find.text('Informasi Kas Masjid'), findsOneWidget);
    });

    testWidgets('menampilkan Switch toggle untuk aktifkan/nonaktifkan kas', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestable(settingsOff()));
      await tester.pump();

      expect(find.text('Tampilkan Info Kas di Layar Utama'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('Switch OFF saat isTreasuryEnabled = false', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestable(settingsOff()));
      await tester.pump();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('Switch ON saat isTreasuryEnabled = true', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestable(settingsOn()));
      await tester.pump();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets(
      'menampilkan label 3 input group (Saldo, Pemasukan, Pengeluaran)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestable(settingsOn()));
        await tester.pump();

        expect(find.text('Saldo Kas (Rp)'), findsOneWidget);
        expect(find.text('Pemasukan Periode Ini (Rp)'), findsOneWidget);
        expect(find.text('Pengeluaran Periode Ini (Rp)'), findsOneWidget);
      },
    );

    testWidgets(
      'input groups wrapped dalam IgnorePointer saat isTreasuryEnabled = false',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestable(settingsOff()));
        await tester.pump();

        // IgnorePointer dengan ignoring=true harus ada di tree saat toggle OFF
        final ignorePointers = tester.widgetList<IgnorePointer>(
          find.byType(IgnorePointer),
        );
        final hasIgnoringPointer = ignorePointers.any((w) => w.ignoring);
        expect(hasIgnoringPointer, isTrue);
      },
    );

    testWidgets(
      'input groups tidak di-ignore (IgnorePointer false) saat isTreasuryEnabled = true',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestable(settingsOn()));
        await tester.pump();

        // IgnorePointer dengan ignoring=true tidak boleh ada saat toggle ON
        final ignorePointers = tester.widgetList<IgnorePointer>(
          find.byType(IgnorePointer),
        );
        final hasIgnoringPointer = ignorePointers.any((w) => w.ignoring);
        expect(hasIgnoringPointer, isFalse);
      },
    );

    testWidgets('memanggil updateTreasuryEnabled saat Switch di-tap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(
        () => mockCubit.updateTreasuryEnabled(any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestable(settingsOff()));
      await tester.pump();

      await tester.tap(find.byType(Switch));
      await tester.pump();

      verify(() => mockCubit.updateTreasuryEnabled(true)).called(1);
    });
  });
}
