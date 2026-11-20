import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/pin_input_widget.dart';

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

  group('PinInputWidget Tests', () {
    testWidgets('Renders correct number of pin boxes', (tester) async {
      await tester.pumpWidget(
        createTestWidget(PinInputWidget(onCompleted: (_) {})),
      );

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Entering digits calls onCompleted', (tester) async {
      String? completedPin;
      await tester.pumpWidget(
        createTestWidget(
          PinInputWidget(onCompleted: (pin) => completedPin = pin),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit1);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit3);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit4);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit5);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit6);
      await tester.pump();

      expect(completedPin, '123456');
    });

    testWidgets('Backspace removes digit', (tester) async {
      String? completedPin;
      await tester.pumpWidget(
        createTestWidget(
          PinInputWidget(onCompleted: (pin) => completedPin = pin),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit1);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      // Complete with 5 more digits
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit3);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit4);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit5);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit6);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit7);
      await tester.pump();

      expect(completedPin, '134567');
    });
  });
}
