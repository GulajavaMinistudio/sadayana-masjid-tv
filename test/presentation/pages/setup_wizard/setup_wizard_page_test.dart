import 'package:bloc_test/bloc_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/domain/entities/city.dart';
import 'package:miqotul_khoir_tv/domain/entities/setup_wizard_data.dart';
import 'package:miqotul_khoir_tv/domain/repositories/city_repository.dart';
import 'package:miqotul_khoir_tv/domain/repositories/settings_repository.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/setup_wizard/setup_wizard.dart';
import 'package:miqotul_khoir_tv/presentation/pages/setup_wizard/setup_wizard_page.dart';
import 'package:miqotul_khoir_tv/presentation/pages/setup_wizard/steps/identity_step.dart';
import 'package:miqotul_khoir_tv/presentation/pages/setup_wizard/steps/location_step.dart';
import 'package:miqotul_khoir_tv/presentation/pages/setup_wizard/steps/preview_step.dart';
import 'package:miqotul_khoir_tv/presentation/pages/setup_wizard/steps/welcome_step.dart';
import 'package:miqotul_khoir_tv/domain/repositories/slideshow_image_repository.dart';
import 'package:miqotul_khoir_tv/domain/services/slideshow_file_storage_service.dart';

import 'package:google_fonts/google_fonts.dart';

// Mocks
class MockSetupWizardCubit extends MockCubit<SetupWizardState>
    implements SetupWizardCubit {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockCityRepository extends Mock implements CityRepository {}

class MockSlideshowImageRepository extends Mock
    implements SlideshowImageRepository {}

class MockSlideshowFileStorageService extends Mock
    implements SlideshowFileStorageService {}

void main() {
  late MockSetupWizardCubit mockCubit;
  late MockSettingsRepository mockSettingsRepo;
  late MockCityRepository mockCityRepo;
  late MockSlideshowImageRepository mockSlideshowRepo;
  late MockSlideshowFileStorageService mockSlideshowStorage;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const SetupWizardData());
    registerFallbackValue(
      const City(
        id: 1,
        provinceName: 'Jawa Barat',
        cityName: 'Bandung',
        latitude: -6.9175,
        longitude: 107.6191,
      ),
    );
  });

  setUp(() {
    mockCubit = MockSetupWizardCubit();
    mockSettingsRepo = MockSettingsRepository();
    mockCityRepo = MockCityRepository();
    mockSlideshowRepo = MockSlideshowImageRepository();
    mockSlideshowStorage = MockSlideshowFileStorageService();
    when(() => mockSlideshowRepo.getAll()).thenAnswer((_) async => const []);
  });

  Widget createViewUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: false,
      builder: (context, child) {
        return MaterialApp(
          theme: IslamicTheme.darkTheme(),
          home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<SettingsRepository>.value(
                value: mockSettingsRepo,
              ),
              RepositoryProvider<CityRepository>.value(value: mockCityRepo),
              RepositoryProvider<SlideshowImageRepository>.value(
                value: mockSlideshowRepo,
              ),
              RepositoryProvider<SlideshowFileStorageService>.value(
                value: mockSlideshowStorage,
              ),
            ],
            child: BlocProvider<SetupWizardCubit>.value(
              value: mockCubit,
              child: const SetupWizardView(),
            ),
          ),
        );
      },
    );
  }

  group('SetupWizardPage Widget Tests', () {
    testWidgets('Renders WelcomeStep initially (step 0)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockCubit.state).thenReturn(
        const SetupWizardInProgress(currentStep: 0, data: SetupWizardData()),
      );

      await tester.pumpWidget(createViewUnderTest());

      expect(find.byType(WelcomeStep), findsOneWidget);
      expect(find.byType(IdentityStep), findsNothing);
      expect(find.text('Miqotul Khoir TV'), findsOneWidget);
    });

    testWidgets('Renders IdentityStep at step 1', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockCubit.state).thenReturn(
        const SetupWizardInProgress(currentStep: 1, data: SetupWizardData()),
      );

      await tester.pumpWidget(createViewUnderTest());

      expect(find.byType(IdentityStep), findsOneWidget);
      expect(find.text('Identitas Masjid'), findsOneWidget);
    });

    testWidgets('Renders LocationStep at step 2', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockCubit.state).thenReturn(
        const SetupWizardInProgress(currentStep: 2, data: SetupWizardData()),
      );
      when(
        () => mockCityRepo.getProvinces(),
      ).thenAnswer((_) async => ['Jawa Barat', 'DKI Jakarta']);

      await tester.pumpWidget(createViewUnderTest());

      expect(find.byType(LocationStep), findsOneWidget);
      expect(find.text('Lokasi Masjid'), findsOneWidget);
    });

    testWidgets('Renders PreviewStep at step 3', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockCubit.state).thenReturn(
        const SetupWizardInProgress(
          currentStep: 3,
          data: SetupWizardData(
            mosqueName: 'Masjid Raya',
            mosqueAddress: 'Jl. Asia Afrika',
            cityName: 'Bandung',
            provinceName: 'Jawa Barat',
            latitude: -6.9175,
            longitude: 107.6191,
          ),
        ),
      );

      await tester.pumpWidget(createViewUnderTest());

      expect(find.byType(PreviewStep), findsOneWidget);
      expect(find.text('Konfirmasi Pengaturan'), findsOneWidget);
      expect(find.text('Masjid Raya'), findsOneWidget); // Verify binding
    });

    testWidgets('Step 0: "Mulai Setup" button interactions', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockCubit.state).thenReturn(
        const SetupWizardInProgress(currentStep: 0, data: SetupWizardData()),
      );

      await tester.pumpWidget(createViewUnderTest());

      final button = find.text('Mulai Setup');
      expect(button, findsOneWidget);

      await tester.tap(button);
      verify(() => mockCubit.goToNextStep()).called(1);
    });
  });
}
