import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/settings.dart';
import 'package:miqotul_khoir_tv/domain/entities/wisdom_quote.dart';
import 'package:miqotul_khoir_tv/domain/repositories/wisdom_quote_repository.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/settings/settings_state.dart';
import 'package:miqotul_khoir_tv/presentation/pages/settings/sections/wisdom_quote_section.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/checklist_item_widget.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

class MockWisdomQuoteRepository extends Mock implements WisdomQuoteRepository {}

/// Daftar 11 wisdom quotes yang mencerminkan data riil dari aset JSON.
final tAllQuotes = <WisdomQuote>[
  const WisdomQuote(
    id: 'quran_001',
    type: 'quran',
    label: 'Ayat Al-Quran',
    translationText: 'Sesungguhnya sesudah kesulitan ada kemudahan.',
    reference: 'QS. Al-Insyirah [94]: 5',
  ),
  const WisdomQuote(
    id: 'quran_002',
    type: 'quran',
    label: 'Ayat Al-Quran',
    translationText: 'Dan hanya kepada Tuhanmulah hendaknya kamu berharap.',
    reference: 'QS. Al-Insyirah [94]: 8',
  ),
  const WisdomQuote(
    id: 'quran_003',
    type: 'quran',
    label: 'Ayat Al-Quran',
    translationText:
        'Allah tidak membebani seseorang melainkan sesuai kesanggupannya.',
    reference: 'QS. Al-Baqarah [2]: 286',
  ),
  const WisdomQuote(
    id: 'quran_004',
    type: 'quran',
    label: 'Ayat Al-Quran',
    translationText:
        'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
    reference: 'QS. Ar-Ra\'d [13]: 28',
  ),
  const WisdomQuote(
    id: 'quran_005',
    type: 'quran',
    label: 'Ayat Al-Quran',
    translationText: 'Sesungguhnya Allah bersama orang-orang yang sabar.',
    reference: 'QS. Al-Baqarah [2]: 153',
  ),
  const WisdomQuote(
    id: 'hadith_001',
    type: 'hadith',
    label: 'Hadits',
    translationText: 'Barang siapa beriman kepada Allah dan hari akhir.',
    reference: 'HR. Bukhari No. 6018',
  ),
  const WisdomQuote(
    id: 'hadith_002',
    type: 'hadith',
    label: 'Hadits',
    translationText: 'Senyummu kepada saudaramu adalah sedekah.',
    reference: 'HR. Tirmidzi No. 1956',
  ),
  const WisdomQuote(
    id: 'hadith_003',
    type: 'hadith',
    label: 'Hadits',
    translationText: 'Sesungguhnya amal itu tergantung niatnya.',
    reference: 'HR. Bukhari No. 1',
  ),
  const WisdomQuote(
    id: 'hadith_004',
    type: 'hadith',
    label: 'Hadits',
    translationText: 'Muslim yang satu adalah saudara Muslim yang lain.',
    reference: 'HR. Muslim No. 2564',
  ),
  const WisdomQuote(
    id: 'hadith_005',
    type: 'hadith',
    label: 'Hadits',
    translationText: 'Orang yang kuat bukanlah yang menang dalam gulat.',
    reference: 'HR. Bukhari No. 6114',
  ),
  const WisdomQuote(
    id: 'hadith_006',
    type: 'hadith',
    label: 'Hadits',
    translationText:
        'Sebaik-baik manusia adalah yang paling bermanfaat bagi orang lain.',
    reference: 'HR. Ahmad, Al-Mu\u2019jam Al-Awsath No. 5787',
  ),
];

void main() {
  late MockSettingsCubit mockSettingsCubit;
  late MockWisdomQuoteRepository mockWisdomRepo;

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
    mockWisdomRepo = MockWisdomQuoteRepository();
    when(() => mockWisdomRepo.getAll()).thenAnswer((_) async => tAllQuotes);
    when(
      () => mockWisdomRepo.getByIds(any()),
    ).thenAnswer((_) async => const []);
  });

  Widget buildTestable(Settings settings) {
    setupCubit(settings);
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        theme: IslamicTheme.darkTheme(),
        home: RepositoryProvider<WisdomQuoteRepository>.value(
          value: mockWisdomRepo,
          child: BlocProvider<SettingsCubit>.value(
            value: mockSettingsCubit,
            child: const Scaffold(body: WisdomQuoteSection()),
          ),
        ),
      ),
    );
  }

  group('WisdomQuoteSection Widget Tests (TEST-011)', () {
    testWidgets(
      'semua 11 item checklist tampil setelah future selesai (TEST-011)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestable(const Settings(isWisdomEnabled: true)),
        );
        // Tunggu future getAll() selesai dan setState dipanggil.
        await tester.pumpAndSettle();

        expect(find.byType(ChecklistItemWidget), findsNWidgets(11));
      },
    );

    testWidgets(
      'toggle disabled → ExcludeFocus(excluding: true) ada di widget tree (TEST-011)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestable(const Settings(isWisdomEnabled: false)),
        );
        await tester.pumpAndSettle();

        // Ketika isWisdomEnabled = false, config area dibungkus ExcludeFocus(excluding: true).
        final excludingWidgets = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((w) => w.excluding)
            .toList();
        expect(excludingWidgets, isNotEmpty);
      },
    );

    testWidgets(
      'toggle enabled → ExcludeFocus(excluding: false) di config area (TEST-011)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestable(const Settings(isWisdomEnabled: true)),
        );
        await tester.pumpAndSettle();

        // Ketika isWisdomEnabled = true, config area tidak di-exclude dari focus.
        final excludingWidgets = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((w) => w.excluding)
            .toList();
        expect(excludingWidgets, isEmpty);
      },
    );

    testWidgets(
      'tombol Preview memiliki Opacity 0.4 saat selectedCount == 0 (TEST-011)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestable(
            const Settings(isWisdomEnabled: true, wisdomSelectedIds: []),
          ),
        );
        await tester.pumpAndSettle();

        // Tombol preview dibungkus Opacity(opacity: 0.4) saat tidak ada item dipilih.
        final opacityWidgets = tester
            .widgetList<Opacity>(find.byType(Opacity))
            .where((w) => w.opacity == 0.4)
            .toList();
        expect(opacityWidgets, isNotEmpty);
      },
    );

    testWidgets('tombol Preview Opacity 1.0 saat ada item dipilih (TEST-011)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestable(
          const Settings(
            isWisdomEnabled: true,
            wisdomSelectedIds: ['quran_001'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ketika ada item terpilih, tidak ada Opacity(opacity: 0.4) di tree.
      final opacityAtPointFour = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .where((w) => w.opacity == 0.4)
          .toList();
      expect(opacityAtPointFour, isEmpty);
    });

    testWidgets('CircularProgressIndicator tampil saat loading (TEST-011)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Mock dengan delay agar future belum selesai saat pump pertama.
      when(() => mockWisdomRepo.getAll()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return tAllQuotes;
      });

      await tester.pumpWidget(
        buildTestable(const Settings(isWisdomEnabled: true)),
      );
      // Pump sekali untuk render awal — future belum selesai → loading indicator muncul.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Selesaikan semua future agar timer tidak leak.
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });
}
