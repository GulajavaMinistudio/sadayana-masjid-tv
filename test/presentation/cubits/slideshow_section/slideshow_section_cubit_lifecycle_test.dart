// TASK-004: Lifecycle test untuk SlideshowSectionCubit
//
// Tujuan (Phase 1 — sebelum fix):
//   Test ini harus FAIL karena SlideshowSectionCubit belum memiliki guard isClosed
//   di method-method async-nya (loadImages, importIntoSlot, replaceSlot,
//   deleteFromSlot).
//
// Tujuan (Phase 2 — setelah fix):
//   Test ini harus PASS karena guard isClosed sudah ditambahkan.
//
// Method yang diuji (memiliki emit() setelah await):
//   - loadImages()     → emit(isLoading:true) → await getAll() → emit(isLoading:false)
//   - deleteFromSlot() → emit(isBusy:true)    → await getBySlot/delete/reload
//                        → emit(images:..., isBusy:false)

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:miqotul_khoir_tv/domain/entities/slideshow_image.dart';
import 'package:miqotul_khoir_tv/domain/repositories/slideshow_image_repository.dart';
import 'package:miqotul_khoir_tv/domain/services/slideshow_file_storage_service.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/display_state/display_state_cubit.dart';
import 'package:miqotul_khoir_tv/presentation/cubits/slideshow_section/slideshow_section_cubit.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockSlideshowImageRepository extends Mock
    implements SlideshowImageRepository {}

class MockSlideshowFileStorageService extends Mock
    implements SlideshowFileStorageService {}

class MockImagePickerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {}

class MockDisplayStateCubit extends Mock implements DisplayStateCubit {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _kSlot1 = SlideshowImage(
  slotIndex: 1,
  fileName: 'slide_slot_1_100.jpg',
  storedPath: '/internal/slideshow/slide_slot_1_100.jpg',
  mimeType: 'image/jpeg',
  width: 1920,
  height: 1080,
  fileSizeBytes: 150000,
);

void main() {
  late MockSlideshowImageRepository mockRepo;
  late MockSlideshowFileStorageService mockStorage;
  late MockImagePickerPlatform mockPickerPlatform;
  late MockDisplayStateCubit mockDisplayCubit;

  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(const ImagePickerOptions());
    registerFallbackValue(
      const SlideshowImage(
        slotIndex: 0,
        fileName: '_fallback.jpg',
        storedPath: '/fallback.jpg',
        mimeType: 'image/jpeg',
        width: 1,
        height: 1,
        fileSizeBytes: 1,
      ),
    );
  });

  setUp(() {
    mockRepo = MockSlideshowImageRepository();
    mockStorage = MockSlideshowFileStorageService();
    mockPickerPlatform = MockImagePickerPlatform();
    mockDisplayCubit = MockDisplayStateCubit();

    // Pasang mock platform agar ImagePicker tidak memanggil kanal nyata
    ImagePickerPlatform.instance = mockPickerPlatform;

    // Default stubs
    when(() => mockDisplayCubit.onSettingsChanged()).thenAnswer((_) async {});
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    when(() => mockRepo.getBySlot(any())).thenAnswer((_) async => null);
    when(() => mockRepo.deleteBySlot(any())).thenAnswer((_) async {});
    when(() => mockStorage.deleteStoredImage(any())).thenAnswer((_) async {});
  });

  SlideshowSectionCubit buildCubit() => SlideshowSectionCubit(
    imageRepository: mockRepo,
    storageService: mockStorage,
    displayStateCubit: mockDisplayCubit,
    imagePicker: ImagePicker(),
  );

  // ---------------------------------------------------------------------------
  // Lifecycle Safety Tests
  // ---------------------------------------------------------------------------

  group('SlideshowSectionCubit — Lifecycle Safety', () {
    // ---
    // loadImages(): emit(isLoading:true) → await repo.getAll() → emit(isLoading:false)
    // ---
    test(
      'loadImages() does NOT throw StateError when cubit is closed during async',
      () async {
        // Arrange: blokir repo.getAll() dengan Completer
        final completer = Completer<List<SlideshowImage>>();
        when(() => mockRepo.getAll()).thenAnswer((_) => completer.future);

        final cubit = buildCubit();

        // Act
        final future = cubit.loadImages();
        await cubit.close();
        completer.complete([_kSlot1]);

        // Assert
        await expectLater(future, completes);
      },
    );

    // ---
    // deleteFromSlot(): emit(isBusy:true) → await getBySlot → await deleteBySlot
    //                   → await _reloadImages → emit(isBusy:false)
    // ---
    test(
      'deleteFromSlot() does NOT throw StateError when cubit is closed during async',
      () async {
        // Arrange: stub getBySlot agar mengembalikan gambar yang akan dihapus
        when(() => mockRepo.getBySlot(1)).thenAnswer((_) async => _kSlot1);

        // Blokir deleteBySlot() agar cubit bisa di-close sebelum lanjut
        final completer = Completer<void>();
        when(
          () => mockRepo.deleteBySlot(1),
        ).thenAnswer((_) => completer.future);

        final cubit = buildCubit();

        // Act
        final future = cubit.deleteFromSlot(1);
        await cubit.close();
        completer.complete();

        // Assert
        await expectLater(future, completes);
      },
    );
  });
}
