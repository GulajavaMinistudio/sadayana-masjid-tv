// Widget-level behaviour guard for the About section.
//
// Spec: docs/spec/about-page-version-drift-spec.md
//       (REQ-003, REQ-004, REQ-006, REQ-007 — AC-001, AC-005, AC-006)
// Plan: docs/plan/about-page-version-drift-plan.md (TASK-005; harness
// extended by TASK-009 / TASK-010 in Phase 3)
//
// The harness mirrors the project's established settings-section shape
// (see wisdom_quote_section_test.dart): ScreenUtilInit on the 1920×1080 TV
// design size + MaterialApp with the dark Islamic theme + a plain Scaffold,
// with the tester view forced to 1920×1080 at 1.0 density.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miqotul_khoir_tv/core/app_version.dart';
import 'package:miqotul_khoir_tv/core/theme/islamic_theme.dart';
import 'package:miqotul_khoir_tv/core/theme/tv_safe_area.dart';
import 'package:miqotul_khoir_tv/presentation/pages/settings/sections/about_section.dart';

/// The mandated single feature bullet — count nine, all nine canonical
/// Display State names in `display_state_type.dart` declaration order, and
/// "status" (not the rejected "mode", Spec §2.1 / [ASSUMPTION-001]).
const String kNineStateBullet =
    '9 status tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → '
    'Sholat → Slideshow Announcement → Imam Schedule → Wisdom Quote → '
    'Midnight Standby';

/// Every `_Avoid_` synonym named in [TASK-005], scoped to the rendered About
/// copy (REQ-004 / AC-006 — the invariant does not extend to route names or
/// code identifiers elsewhere).
const List<String> kForbiddenSynonyms = <String>[
  'carousel',
  'quote rotation',
  'sleep mode',
  'pre-adhan',
  'Azan',
  'Iqama',
  'salat',
];

/// The rendered version line template — two spaces around the `·`, matching
/// the existing template shape (Spec §6.2 / AC-001).
String expectedVersionLine() =>
    'Versi ${AppVersion.displayName}  ·  '
    'Build ${AppVersion.displayBuildNumber}  ·  GPL v3';

Widget buildTestableAboutSection() {
  return ScreenUtilInit(
    designSize: const Size(1920, 1080),
    minTextAdapt: true,
    builder: (_, _) => MaterialApp(
      theme: IslamicTheme.darkTheme(),
      home: const Scaffold(body: AboutSection()),
    ),
  );
}

Future<void> pumpAtTvBaseline(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(buildTestableAboutSection());
  await tester.pumpAndSettle();
}

/// Replicates the production mount of [AboutSection] inside the Settings
/// right-hand panel (settings_menu_page.dart:62-69 → `TVSafeArea` → `Row` →
/// fixed `400.w` left column + `Expanded`(`Padding` 32.w)) so the D-Pad
/// scroll contract is exercised against the SAME bounded geometry that the
/// production layout imposes, within the same 1920×1080 tester view.
///
/// The full-bleed mount (`buildTestableAboutSection`) gives the section the
/// whole viewport, where its content happens to fit (`maxScrollExtent == 0`)
/// and the D-Pad contract is not exercisable — measured empirically in the
/// TASK-010 red run on 2026-10-23.
Widget buildProductionPanelLayout() {
  return ScreenUtilInit(
    designSize: const Size(1920, 1080),
    minTextAdapt: true,
    builder: (_, _) => MaterialApp(
      theme: IslamicTheme.darkTheme(),
      home: Scaffold(
        body: TVSafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left menu column — fixed width, settings_menu_page.dart:82.
              SizedBox(width: 400.w),
              Expanded(
                child: Padding(
                  // Center panel padding, settings_menu_page.dart:203.
                  padding: EdgeInsets.all(32.w),
                  child: const AboutSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> pumpAtProductionPanel(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(buildProductionPanelLayout());
  await tester.pumpAndSettle();
}

void main() {
  group('AboutSection Display State copy (AC-005, REQ-003)', () {
    testWidgets('renders the canonical nine-state bullet exactly', (
      tester,
    ) async {
      await pumpAtTvBaseline(tester);

      expect(tester.takeException(), isNull);
      expect(find.text(kNineStateBullet), findsOneWidget);
    });

    testWidgets('renders neither the stale under-count nor a wrong count', (
      tester,
    ) async {
      await pumpAtTvBaseline(tester);

      expect(find.textContaining('5 mode tampilan otomatis'), findsNothing);
      expect(find.textContaining('9 mode tampilan otomatis'), findsNothing);
    });

    testWidgets('keeps the feature list at exactly 7 bullets', (tester) async {
      // [ASSUMPTION-001]: only the ONE existing bullet changes; the list
      // must not gain a second Display State bullet.
      await pumpAtTvBaseline(tester);

      expect(find.byIcon(Icons.check_circle_outline_rounded), findsNWidgets(7));
    });
  });

  group('AboutSection terminology conformance (AC-006, REQ-004)', () {
    testWidgets('renders no _Avoid_ synonym anywhere in the copy', (
      tester,
    ) async {
      await pumpAtTvBaseline(tester);

      for (final synonym in kForbiddenSynonyms) {
        expect(
          find.textContaining(synonym),
          findsNothing,
          reason: '"$synonym" is an _Avoid_ synonym per CONTEXT.md',
        );
      }
    });
  });

  group('AboutSection version line (AC-001, REQ-001, REQ-007)', () {
    testWidgets('renders the manifest-sourced version line verbatim', (
      tester,
    ) async {
      await pumpAtTvBaseline(tester);

      expect(find.text(expectedVersionLine()), findsOneWidget);
    });
  });

  group('AboutSection layout bound (Spec §4.3 measurable bound)', () {
    testWidgets('renders at 1920x1080 with no layout overflow', (tester) async {
      // A RenderFlex (or any) overflow is thrown as an exception under
      // testWidgets — this test IS the overflow assertion.
      await pumpAtTvBaseline(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group(
    'AboutSection define-to-rendered proof (AC-004, REQ-001 — amended)',
    () {
      testWidgets('renders the compiled define values, not a restatement', (
        tester,
      ) async {
        // AC-004, owner-amended 2026-10-23 (Option A): the historic
        // --dart-define override invocation is impossible on Flutter 3.47.6 —
        // the FLUTTER_BUILD_NAME / FLUTTER_BUILD_NUMBER keys are framework-
        // reserved and `flutter test` refuses them. The define → rendered-UI
        // path is therefore proven at TWO loci: (1) this sentinel, asserting
        // the rendered line equals the raw SDK accessor read from
        // package:flutter/services.dart — a re-introduced hardcoded literal
        // fails it immediately; (2) the TASK-014 release-gate byte-scan of
        // libapp.so, proving the manifest values materialize in the AOT
        // artifact. Spec §6.1 AC-004 / §7 record the amendment.
        await pumpAtTvBaseline(tester);

        final compiledVersionLine =
            'Versi $appBuildName  ·  Build $appBuildNumber  ·  GPL v3';
        expect(find.text(compiledVersionLine), findsOneWidget);
      });
    },
  );

  group('AboutSection D-Pad navigation invariance (AC-007, REQ-006)', () {
    testWidgets(
      'scrolls exactly one step per arrow key and clamps at both ends',
      (tester) async {
        await pumpAtProductionPanel(tester);
        expect(tester.takeException(), isNull);

        final scrollable = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
        );
        final controller = scrollable.controller!;
        expect(controller.positions.length, 1);

        // Task precondition (Plan TASK-010): content must exceed the viewport
        // of its production panel — otherwise the D-Pad contract is dead code
        // and the scroll criterion must be re-derived via /to-spec, not hacked.
        final maxScroll = controller.position.maxScrollExtent;
        expect(
          maxScroll,
          greaterThan(0.0),
          reason:
              'About content must exceed its production panel viewport at '
              '1920x1080; if this grows false, re-derive the scroll contract '
              'with /to-spec',
        );

        const double scrollStep = 120.0; // about_section.dart `_scrollStep`

        // Top clamp: arrowUp at offset 0 must not produce a negative offset.
        expect(controller.offset, 0.0);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(controller.offset, 0.0);

        // One step down = exactly _scrollStep, clamped to [0, maxScrollExtent].
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(controller.offset, scrollStep.clamp(0.0, maxScroll));

        // Bottom clamp: arrowDown at maxScrollExtent stays at maxScrollExtent.
        controller.jumpTo(maxScroll);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(controller.offset, maxScroll);

        // One step up from the bottom clamp recovers exactly one step.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(
          controller.offset,
          (maxScroll - scrollStep).clamp(0.0, maxScroll),
        );

        // REQ-006 invariance: after all scrolling, both guarded surfaces are
        // still rendered and correct.
        expect(find.text(expectedVersionLine()), findsOneWidget);
        expect(find.text(kNineStateBullet), findsOneWidget);
      },
    );
  });
}
