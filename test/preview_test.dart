import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miqotul_khoir_tv/domain/entities/slideshow_image.dart';
import 'package:miqotul_khoir_tv/presentation/pages/slideshow_preview_page.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  testWidgets('Test button tap', (WidgetTester tester) async {
    bool didPop = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        child: MaterialApp(
          home: Navigator(
            onPopPage: (route, result) {
              didPop = true;
              return route.didPop(result);
            },
            pages: [
              MaterialPage(child: Scaffold(body: Text('Home'))),
              MaterialPage(
                child: SlideshowPreviewPage(
                  image: SlideshowImage(
                    slotIndex: 1,
                    fileName: 'test.jpg',
                    storedPath: 'test.jpg',
                    mimeType: 'image/jpeg',
                    width: 1920,
                    height: 1080,
                    fileSizeBytes: 100,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check if the button is there
    final btn = find.text('Tutup Preview');
    expect(btn, findsOneWidget);

    // Tap the button
    await tester.tap(btn);
    await tester.pumpAndSettle();

    print('Did pop? $didPop');
  });
}
