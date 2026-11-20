import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/focusable_widget.dart';

/// Widget tests untuk [FocusableWidget].
///
/// Ref: Plan 04 TASK-025 s.d. TASK-028
void main() {
  /// Helper untuk membungkus widget dalam ScreenUtil + MaterialApp.
  Widget buildTestable(Widget widget) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      child: MaterialApp(home: Scaffold(body: widget)),
    );
  }

  group('FocusableWidget', () {
    // TASK-026: TEST — builder(false) saat tidak focused, builder(true) saat focused
    testWidgets('calls builder(false) when not focused initially', (
      tester,
    ) async {
      bool? receivedFocusState;

      await tester.pumpWidget(
        buildTestable(
          FocusableWidget(
            builder: (isFocused) {
              receivedFocusState = isFocused;
              return Text(isFocused ? 'Focused' : 'Not Focused');
            },
          ),
        ),
      );

      expect(receivedFocusState, isFalse);
      expect(find.text('Not Focused'), findsOneWidget);
    });

    testWidgets('calls builder(true) when widget receives focus', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          FocusableWidget(
            autofocus: true,
            builder: (isFocused) {
              return Text(isFocused ? 'Focused' : 'Not Focused');
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Focused'), findsOneWidget);
    });

    // TASK-027: TEST — onSelect dipanggil saat Enter key ditekan
    testWidgets('calls onSelect when Enter key is pressed while focused', (
      tester,
    ) async {
      bool selectCalled = false;

      await tester.pumpWidget(
        buildTestable(
          FocusableWidget(
            autofocus: true,
            onSelect: () {
              selectCalled = true;
            },
            builder: (isFocused) => const Text('Press Enter'),
          ),
        ),
      );

      await tester.pump();

      // Simulasi Enter key press
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(
        selectCalled,
        isTrue,
        reason: 'onSelect harus dipanggil saat Enter key ditekan',
      );
    });

    testWidgets('calls onSelect when Select key is pressed while focused', (
      tester,
    ) async {
      bool selectCalled = false;

      await tester.pumpWidget(
        buildTestable(
          FocusableWidget(
            autofocus: true,
            onSelect: () {
              selectCalled = true;
            },
            builder: (isFocused) => const Text('Press Select'),
          ),
        ),
      );

      await tester.pump();

      // Simulasi D-Pad Select key press
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pump();

      expect(
        selectCalled,
        isTrue,
        reason: 'onSelect harus dipanggil saat D-Pad Select key ditekan',
      );
    });

    // TASK-028: TEST — internal FocusNode di-dispose dengan benar
    testWidgets('disposes internal FocusNode correctly', (tester) async {
      final key = GlobalKey<State<FocusableWidget>>();

      await tester.pumpWidget(
        buildTestable(
          FocusableWidget(
            key: key,
            builder: (isFocused) => const Text('Dispose Test'),
          ),
        ),
      );

      // Widget berhasil dibuat
      expect(find.text('Dispose Test'), findsOneWidget);

      // Remove widget dari tree — dispose() harus dipanggil tanpa error
      await tester.pumpWidget(buildTestable(const SizedBox.shrink()));

      // Jika dispose() berhasil, tidak ada exception yang dilempar
      expect(find.text('Dispose Test'), findsNothing);
    });

    testWidgets('uses external FocusNode when provided', (tester) async {
      final externalFocusNode = FocusNode();
      addTearDown(externalFocusNode.dispose);

      await tester.pumpWidget(
        buildTestable(
          FocusableWidget(
            focusNode: externalFocusNode,
            builder: (isFocused) => Text(isFocused ? 'Focused' : 'Not Focused'),
          ),
        ),
      );

      // Request focus via external node
      externalFocusNode.requestFocus();
      await tester.pump();

      expect(find.text('Focused'), findsOneWidget);
    });

    testWidgets('has minimum size constraint of 48x48', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          FocusableWidget(
            builder: (isFocused) => const SizedBox(width: 10, height: 10),
          ),
        ),
      );

      // Cari ConstrainedBox yang merupakan child langsung FocusableWidget
      // (bukan ConstrainedBox dari Scaffold/MaterialApp)
      final constrainedBox = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .firstWhere(
            (cb) =>
                cb.constraints.minWidth == 48 && cb.constraints.minHeight == 48,
          );

      expect(constrainedBox.constraints.minWidth, equals(48));
      expect(constrainedBox.constraints.minHeight, equals(48));
    });

    testWidgets('renders AnimatedScale widget', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          FocusableWidget(builder: (isFocused) => const Text('Scale Test')),
        ),
      );

      expect(find.byType(AnimatedScale), findsOneWidget);
    });
  });
}
