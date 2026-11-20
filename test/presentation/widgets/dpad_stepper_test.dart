import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/dpad_stepper.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      builder: (context, _) {
        return MaterialApp(home: Scaffold(body: child));
      },
    );
  }

  group('DPadStepper Widget Tests', () {
    testWidgets('Renders label, value, and suffix correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          DPadStepper(
            label: 'Test Label',
            value: 10,
            minValue: 0,
            maxValue: 20,
            suffix: 'menit',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('10 menit'), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('Increments value when right arrow is pressed', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DPadStepper(
              value: 10,
              minValue: 0,
              maxValue: 20,
              onChanged: (val) => changedValue = val,
              autofocus: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(changedValue, 11);
    });

    testWidgets('Decrements value when left arrow is pressed', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DPadStepper(
              value: 10,
              minValue: 0,
              maxValue: 20,
              onChanged: (val) => changedValue = val,
              autofocus: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      expect(changedValue, 9);
    });

    testWidgets('Does not increment beyond maxValue', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DPadStepper(
              value: 20,
              minValue: 0,
              maxValue: 20,
              onChanged: (val) => changedValue = val,
              autofocus: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(changedValue, null); // Shouldn't call onChanged
    });

    testWidgets('Does not decrement below minValue', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DPadStepper(
              value: 0,
              minValue: 0,
              maxValue: 20,
              onChanged: (val) => changedValue = val,
              autofocus: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      expect(changedValue, null); // Shouldn't call onChanged
    });
  });
}
