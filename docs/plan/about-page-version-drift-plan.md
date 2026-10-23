---
goal: "Single-Source-of-Truth Version Display & Display-State Copy Correction"
version: "1.2.0"
date_created: "2026-10-23"
last_updated: "2026-10-23"
status: "Planned"
spec_ref: "docs/spec/about-page-version-drift-spec.md"
clarification_ref: "docs/audit/about-page-version-drift-plan-clarification.md"
tags: ["polya", "plan", "tracer-bullets", "vertical-slicing", "clean-architecture", "about-section", "versioning"]
---
<!-- markdownlint-disable -->

# Implementation Plan: Single-Source-of-Truth Version Display

> [!IMPORTANT]
> **THE PAUSE RULE & VERTICAL SLICING MANDATE:**
> All tasks in this plan are organized into **Vertical Feature Slices (Tracer Bullets)** — each slice runs from the build-manifest constant through the `AppVersion` seam to the rendered About UI and is proven by an executable test in the same slice.
> After each phase is verified, execution MUST halt for explicit user approval before proceeding to the next phase. Functional code MUST NOT be written until this plan is approved.

---

## 1. Overview & High-Level Mental Model

The About screen currently restates the application version as two hand-maintained string literals (`about_section.dart:17-18` → `'1.2.2'` / `'5'`) that diverged from `pubspec.yaml` across six consecutive releases. This plan removes the literals and re-binds the rendered value to the **compile-time build manifest** through a single named seam (`AppVersion` in `lib/core/`), then installs two independent guards — a manifest-parity oracle test and a structural anti-regression scan — so the defect class cannot silently return. In parallel it corrects the About feature copy from "5 mode tampilan otomatis" to the canonical nine-state enumeration defined in `CONTEXT.md`.

The change is **S-sized**: 5 files touched during implementation (**3 created, 2 modified**), plus `CONTEXT.md` which was **already amended during Phase 1** (the `Sholat` glossary term landed at `CONTEXT.md:21-23`) and therefore carries no task in this plan.

| Action | Files | Count |
| :--- | :--- | :---: |
| **CREATE** | `lib/core/app_version.dart`, `test/analysis/app_version_consistency_test.dart`, `test/presentation/pages/settings/sections/about_section_test.dart` | 3 |
| **MODIFY** | `lib/presentation/pages/settings/sections/about_section.dart`, `docs/ARCHITECTURE.md` | 2 |
| **PRE-COMPLETED** | `CONTEXT.md` (Phase 1, `Sholat` term) | 1 |
| **TOTAL change set (Spec §5.4)** | — | **6** |

### Topological Data Flow Diagram

```text
[ pubspec.yaml:19  version: 1.4.4+15 ]        ← SINGLE SOURCE OF TRUTH
              │
              ▼  flutter tool: FLUTTER_BUILD_NAME / FLUTTER_BUILD_NUMBER dart-defines
[ package:flutter/services.dart ]
   appBuildName / appBuildNumber  (const String?, null when absent)
              │
              ▼  one-way, compile-time, no runtime lookup
[ lib/core/app_version.dart  —  AppVersion ]   ← NEW SEAM (TASK-001)
   buildName · buildNumber · displayName · displayBuildNumber · unavailable
              │
              ▼
[ about_section.dart  —  render site ]          ← MODIFIED (TASK-001, TASK-005)
   'Versi <displayName>  ·  Build <displayBuildNumber>  ·  GPL v3'
   feature bullet: '9 status tampilan otomatis: … nine names …'
              │
              ▼
[ Observations ]                                ← NEW TESTS
   test/analysis/app_version_consistency_test.dart          (manifest oracle + structural scan)
   test/presentation/pages/settings/sections/about_section_test.dart  (widget behaviour)
```

### Pre-Completed Input (no task required)

| File | Status | Evidence |
| :--- | :--- | :--- |
| `CONTEXT.md` | ✅ **Already executed** during Phase 1 (spec §2.2) | `Sholat` term present at `CONTEXT.md:21-23` with `_Avoid_: salat, salat prayer`; glossary now defines all nine Display States |

---

## 2. 📏 Task Sizing Matrix

| Size   | Files Impacted | Scope                                           | Example                                                 |
| :----- | :------------: | :---------------------------------------------- | :------------------------------------------------------ |
| **XS** |       1        | Single pure function or config change           | One test case, or one documentation edit                |
| **S**  |      1-2       | Small focused vertical interaction              | Seam + render-site wiring, or a new test file           |
| **M**  |      3-5       | Standard Vertical Feature Slice (Tracer Bullet) | — (not used by this plan)                               |
| **L**  |      5-8       | Multi-component vertical flow                   | — (not used by this plan)                               |
| **XL** |       8+       | **Strictly Prohibited (Too Large)**             | Must be decomposed into smaller vertical slices         |

**Largest task in this plan: `TASK-001` and `TASK-005` at 2 files each (S).**

---

## 3. Phased Implementation Sequence (Vertical Tracer Bullets)

> **EXECUTION DIRECTIVE FOR AI AGENTS (`/to-code` & `/to-code auto`):**
> - **Interactive Mode (`/to-code`):** Execute ticket by ticket. Run `check:task` (from `docs/ARCHITECTURE.md` §8.2) after each slice, then pause for user confirmation at each `APPROVAL` gate.
> - **Autonomous Mode (`/to-code auto`):** Advance automatically through verified green tickets (`check:task` passing) until all phases complete or one of the **4 Circuit Breakers** triggers (*Ambiguous Spec*, *3x Verification Failure*, *Ratchet Regression*, or *Untracked Dependency/Architecture Change*).
> - **TDD order per task:** write or extend the failing assertion first (RED), implement (GREEN), then run the post-green simplification pass before staging. Stage only the files listed in each task row.

> [!IMPORTANT]
> **STEP-0 — Baseline Capture (before `TASK-001`, no task, no file change).** Every numeric threshold in this plan was measured on 2026-10-23. Re-measure and compare before touching code:
>
> | Metric | Command | Expected (2026-10-23) | If it differs |
> | :--- | :--- | :--- | :--- |
> | Analyzer (scoped) | `dart analyze lib test` | 0 errors / **0 warnings** / **4 infos** | Re-anchor the gate to the new measured value **and record the deviation**; do not widen to bare `dart analyze`. |
> | Unformatted files | `dart format --output=none --set-exit-if-changed lib test` → count `Changed` lines | **15** files, exit `1` | Re-anchor `TASK-014`'s threshold to the new count; the exit code remains meaningless as a signal. |
> | Test suite | `flutter test --reporter=expanded` | **535 / 535**, 59 files | `AC-010`'s floor stays at the new measured count — it may only ratchet **up**. |
>
> This step exists because a moving baseline is not a quality gate. If any number has moved, the plan is re-anchored **before** a single line of production code changes — never after a gate goes red.

### Implementation Phase 1: Land — Minimal End-to-End Tracer Bullet

*Goal: the About screen renders the manifest version end-to-end (constant → `AppVersion` → UI), with an external-oracle guard test that fails on divergence.*

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| TASK-001 | **Version Seam + Render-Site Binding:** create `lib/core/app_version.dart` (`final class AppVersion` with `buildName`, `buildNumber`, `unavailable = 'tidak tersedia'`, `displayName`, `displayBuildNumber` — exact shape per Spec §4.2); remove `_AppInfo.version` and `_AppInfo.buildNumber`; import the new seam; replace the `about_section.dart:163` template so the two interpolations read `AppVersion.displayName` / `AppVersion.displayBuildNumber`. `_AppInfo.license` and all other static copy stay hand-maintained. | REQ-001, REQ-005, REQ-007 | AC-001, AC-003 | - | 2 (S) | [ ] | |
| TASK-002 | **Manifest-Parity Guard Test + `AC-003` Exhaustive Proof:** create `test/analysis/app_version_consistency_test.dart`. **(a) Manifest oracle:** parse `pubspec.yaml` from disk (`File('pubspec.yaml').readAsLinesSync`, first line starting with `version:`), split on the **first** `+` only, and assert `AppVersion.displayName` / `AppVersion.displayBuildNumber` equal the parsed name / build number. The parser MUST yield a **null** build number without throwing when no `+` is present, and MUST fail loudly (never skip) when the file is unreadable. **(b) Exhaustive two-value proof (`AC-003`):** assert `AppVersion.displayName` ∈ {`AppVersion.buildName`, `AppVersion.unavailable`} and — **independently** — `AppVersion.displayBuildNumber` ∈ {`AppVersion.buildNumber`, `AppVersion.unavailable`}; assert `AppVersion.unavailable` is non-empty; assert it does **not** match `RegExp(r'^\d+(\.\d+)*$')`. Since those are the only two possible values of each display member, the absent-manifest branch is proven **by exhaustion** rather than by instantiating a `null` define — which `bool.hasEnvironment` makes impossible. A re-introduced hardcoded fallback fails the `anyOf` assertion on the first run. Finally assert `AppVersion.buildName` is `null` **or** non-empty — the defence against the empty-string define (`RISK-002`). | REQ-002, REQ-005 | AC-002, AC-003, AC-014 | TASK-001 | 1 (S) | [ ] | |
| TASK-003 | **VERIFY (`check:task`):** `dart analyze lib test` + `flutter test test/analysis/app_version_consistency_test.dart --reporter=expanded`. Pass conditions: **0 errors / 0 warnings / ≤ 4 infos** (scoped measurement — see the gate-semantics note below); parity assertions green; the `AC-003` exhaustion assertions green; the no-`+` case returns a null build number without throwing. | - | AC-002, AC-003, AC-009, AC-014 | TASK-002 | - | [ ] | |
| TASK-004 | **APPROVAL:** 🛑 Stop and wait for explicit user confirmation to proceed to Phase 2 (unless `/to-code auto`). | - | - | TASK-003 | - | [ ] | |

> [!NOTE]
> **Why TASK-002 asserts `AppVersion`, not the widget.** The manifest-parity oracle must stay independent of the widget seam so the two guards (`AC-002` and `AC-005`/`AC-001` rendered) neither duplicate nor mask each other — Spec §6.1 `AC-002` *Procedure*.

> [!IMPORTANT]
> **Gate semantics — every quality gate in this plan is baseline-relative, not exit-code-zero.** Measured on 2026-10-23 against the current tree, *before* any change:
>
> | Command | Errors | Warnings | Infos | Exit |
> | :--- | :---: | :---: | :---: | :---: |
> | `dart analyze` (whole package) | 0 | **1** | 4 | **2** |
> | `dart analyze lib test` (**the bound command**) | 0 | **0** | 4 | 0 |
>
> The single warning lives in `tools/replace_opacity.dart:6:7` (`unused_local_variable`) and is **out of scope** by `CON-009`. Never widen the analysis to the whole package to "see everything" — that turns the gate red on a file this change is forbidden to touch, and the only escapes are Floor-Guard violations. The pass condition is always *"no growth beyond the measured baseline"*, per `docs/ARCHITECTURE.md` §8.3.

### Implementation Phase 2: Core Experience — Display-State Copy Correction

*Goal: the About feature list states the canonical count (nine) and names all nine states, proven by a widget test that also establishes the harness for Phase 3.*

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| TASK-005 | **Nine-State Copy Correction + Widget Harness:** replace `about_section.dart:35` with exactly `9 status tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → Sholat → Slideshow Announcement → Imam Schedule → Wisdom Quote → Midnight Standby` (feature list stays at **7** bullets). Create `test/presentation/pages/settings/sections/about_section_test.dart` using the project's established harness shape (`ScreenUtilInit(designSize: Size(1920, 1080))` + `MaterialApp` + `Scaffold(body: AboutSection())`, `tester.view.physicalSize = Size(1920, 1080)`, `devicePixelRatio = 1.0`). Assert: the exact nine-state bullet renders; the strings `5 mode tampilan otomatis` and `9 mode tampilan otomatis` are absent; no `_Avoid_` synonym (`carousel`, `quote rotation`, `sleep mode`, `pre-adhan`, `Azan`, `Iqama`, `salat`) appears; the rendered version line matches `Versi <AppVersion.displayName>  ·  Build <AppVersion.displayBuildNumber>  ·  GPL v3` (two spaces around `·`, matching the existing template); and the section renders at 1920×1080 with **no `RenderFlex` overflow** (an overflow throws under `testWidgets`). | REQ-003, REQ-004, REQ-007 | AC-001, AC-005, AC-006 | TASK-004 | 2 (S) | [ ] | |
| TASK-006 | **VERIFY (`check:task`):** `dart analyze lib test` + `flutter test test/presentation/pages/settings/sections/about_section_test.dart --reporter=expanded`. Pass conditions: 0 errors / 0 warnings / ≤ 4 infos; copy, terminology, version-line and no-overflow assertions green. | - | AC-005, AC-006, AC-009 | TASK-005 | - | [ ] | |
| TASK-007 | **APPROVAL:** 🛑 Stop and wait for explicit user confirmation to proceed to Phase 3 (unless `/to-code auto`). | - | - | TASK-006 | - | [ ] | |

> [!NOTE]
> **`_Avoid_` synonym check scope.** Assertions target the rendered About feature copy only. The word "salat" may legitimately appear elsewhere in the codebase (e.g. route names); the invariant is scoped to the Display State bullet, per `REQ-004` and `AC-006`.

### Implementation Phase 3: Expand — Edge Cases, Invariants & Anti-Regression

*Goal: close the four remaining criteria that need a non-default verification path — structural regression scan, build-override proof, D-Pad invariance, and absent/partial manifest behaviour.*

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| TASK-008 | **Structural Invariants Scan (AC-011 + CON-006):** add cases to `test/analysis/app_version_consistency_test.dart` implementing the owner-confirmed marker rule (audit §2 Item 2, Option A) in seven steps. (1) Recursively enumerate `lib/presentation/**/*.dart` via `dart:io`. (2) Strip `//`, `///`, and `/* … */` comments before matching — mandatory, because `splash_page.dart:51` holds the unrelated comment *"versi lama"*. (3) Match the remaining **code** against `RegExp(r'Versi ')` **or** `RegExp(r'Build ')` — capitalised, mirroring the rendered template `'Versi ${…}  ·  Build ${…}'`. (4) Every matching file MUST import `core/app_version.dart`. (5) Assert that **no** `static const String version` / `static const String buildNumber` display member exists anywhere under `lib/presentation/**` — covers both halves of the shipped defect (`'1.2.2'` *and* `'5'`) by construction, without a literal-shape regex. (6) Assert the known consumer `about_section.dart` imports `AppVersion`. (7) Assert `lib/core/app_version.dart` imports **only** `package:flutter/services.dart` — no `lib/data`, `lib/domain`, `lib/presentation`, `sqflite`, or `firebase` — turning `CON-006`'s dependency-direction invariant into a mechanical check rather than a claim. Any unreadable directory or file MUST **throw** — never skip (`CON-007`). The closed-set variant (`imports == {about_section.dart}`) is explicitly rejected as brittle; the invariant is two-sided: `marker ⇒ imports AppVersion` **and** `no display literal`. | REQ-001, REQ-002, CON-006 | AC-009, AC-011 | TASK-002 | 1 (XS) | [ ] | |
| TASK-009 | **Build-Override Proof (AC-004):** add a case to `about_section_test.dart` asserting the rendered version line equals `Versi ${appBuildName}  ·  Build ${appBuildNumber}  ·  GPL v3` read from `package:flutter/services.dart`, so the same case passes under the manifest defaults **and** under `--dart-define=FLUTTER_BUILD_NAME=9.9.9 --dart-define=FLUTTER_BUILD_NUMBER=99` where it must render `9.9.9` / `99`. Record the exact invocation in §10 (the copy-paste checklist) — **not** as a `// ignore` directive, a `skip:`, or a comment-only note inside the test file. | REQ-001 | AC-004 | TASK-005 | 1 (XS) | [ ] | |
| TASK-010 | **D-Pad Navigation Invariance (AC-007):** add a case to `about_section_test.dart` that renders the section at 1920×1080 with content exceeding the viewport, dispatches `arrowDown` then `arrowUp` `KeyDownEvent`s, and asserts the scroll offset moves by exactly `120.0` in the respective direction, clamped to `[0, maxScrollExtent]`, with the version line still present and correct afterwards. | REQ-006 | AC-007 | TASK-005 | 1 (XS) | [ ] | |
| TASK-011 | **VERIFY (`check:task`):** `dart analyze lib test` + `flutter test test/analysis test/presentation/pages/settings/sections/about_section_test.dart --reporter=expanded` + the override run `flutter test --dart-define=FLUTTER_BUILD_NAME=9.9.9 --dart-define=FLUTTER_BUILD_NUMBER=99 test/presentation/pages/settings/sections/about_section_test.dart`. Pass conditions: all green in both runs; the override run renders `9.9.9` / `99` (`AC-004`). **Isolation rule (mandatory):** the `--dart-define` override is applied **only** to `about_section_test.dart`, never to `test/analysis` and never to `check:full`. Under an override, `AppVersion` legitimately diverges from `pubspec.yaml`, so the manifest-parity oracle (`TASK-002`) would fail **by design** — that is the oracle working, not a defect. | - | AC-004, AC-007, AC-011, AC-009 | TASK-008, TASK-009, TASK-010 | - | [ ] | |
| TASK-012 | **APPROVAL:** 🛑 Stop and wait for explicit user confirmation to proceed to Phase 4 (unless `/to-code auto`). | - | - | TASK-011 | - | [ ] | |

> [!IMPORTANT]
> **`AC-003` is proven by exhaustion, not by instantiating the `null` branch.** `bool.hasEnvironment('FLUTTER_BUILD_NAME')` is constant-folded at compile time (`app_version.dart:17-19`), so no `flutter test` invocation can express "define absent", and `--dart-define=FLUTTER_BUILD_NAME=` yields the *empty string*, not `null`. Instead of hand-waving, `TASK-002` proves the invariant over **both** branches at once by enumerating the only two values each display member can take:
>
> ```text
> displayName        ∈ { buildName,  unavailable }     (independent assertion)
> displayBuildNumber ∈ { buildNumber, unavailable }    (independent assertion)
> unavailable ≠ ''  ∧  unavailable ∉ RegExp(r'^\d+(\.\d+)*$')
> ```
>
> Because the absent-manifest build is precisely the branch where the first alternative is `null` and the second is taken, the rendered value in that build is **non-numeric and non-empty by construction**. The assertions are falsifiable: a re-introduced `'1.2.2'` fallback fails the `anyOf` immediately, and any numeric placeholder fails the regex. This is a real proof, not a restatement — a self-referential `displayName == displayName` check would not survive the mutation.

> [!NOTE]
> **Spec-locus disclosure (unchanged fact, now closed in-plan).** The Spec's §7 *"Verification loci"* table lists `AC-004`, `AC-014`, `AC-013`, `AC-009`, `AC-012`, and `AC-010` — `AC-003` is absent — while §7's extreme-case table nonetheless states the no-`version:` case is *"(Asserted by `AC-003`.)"*. This plan therefore supplies the missing locus itself (`TASK-002` step (b)), rather than editing Phase-1 authority. **Optional follow-up, not a blocker:** the owner may later add that row to the Spec's §7 table so the two documents agree. Until then, `TASK-002` is the binding procedure and `/to-review` cites it.

> [!TIP]
> **`TASK-008`'s expected match set, pre-verified 2026-10-23.** A case-sensitive scan of `lib/presentation/` for the capitalised markers `Versi ` / `Build ` and for `version` / `buildNumber` declarations returns **exactly three hits, all in `about_section.dart`** — lines 17 (`static const String version = '1.2.2'`), 18 (`static const String buildNumber = '5'`), and 163 (the rendered template). After `TASK-001` removes lines 17–18 and rewires line 163, the scan must return **one** marker-bearing file that imports `AppVersion`. The only other "versi" occurrence under `lib/presentation/` is the lower-case comment at `splash_page.dart:51` (*"versi lama (kosong)…"*), which neither the capitalised marker nor the comment-stripping step can turn into a false positive. **If `/to-code` observes any additional hit, that is a real finding — investigate it, do not widen the pattern.**

### Implementation Phase 4: Polish — Living Architecture Map & Release Gate

*Goal: keep the canonical architecture map truthful, then run the macro checkpoint and the release-gate inspection that carries the spec's accepted residual risk.*

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| TASK-013 | **Living Architecture Map Update (`docs/ARCHITECTURE.md`):** (a) add `lib/core/app_version.dart` to the §6.1 repository topography and the §6.2 directory matrix; (b) record that `pubspec.yaml` is the single source of truth for the in-app version, resolved via `AppVersion`; (c) correct the stale "**19 terms**" count in §1 to **20** (the `Sholat` term landed in Phase 1); (d) correct the stale "app version 1.4.3+14" in §1 to the current manifest-derived value, referencing `AppVersion`/`pubspec.yaml` rather than restating a literal. **Items (c) and (d) are an owner-sanctioned addition to the Spec §8 mandate** (audit §2 Item 3, Option A, 2026-10-23) — `CON-009` remains satisfied because this file is #5 of the Spec §5.4 change set. **The sanction is exact:** any *further* stale statement found in this file is out of scope and must be logged as `NOTICED BUT NOT TOUCHING`. | REQ-001, REQ-004 | AC-006 | TASK-012 | 1 (XS) | [ ] | |
| TASK-014 | **VERIFY (`check:full`) + Release Gate + Ratchet Re-Baseline:** run `dart analyze lib test` (**0 errors / 0 warnings / ≤ 4 infos** — the scoped command, never bare `dart analyze`; see the gate-semantics note in §3 Phase 1), `flutter test --reporter=expanded` (0 failures, passing count ≥ 535), `flutter build apk --debug`. **Formatter gate — count, do not trust the exit code:** run `dart format --output=none --set-exit-if-changed lib test` and count the `Changed <path>` lines. Pass condition = count **≤ 15** (measured 2026-10-23; supersedes the stale `16` in `docs/ARCHITECTURE.md` §8.3) **and** none of the five change-set files appears in that list. The command returns exit `1` at the pre-change baseline (`Formatted 173 files (15 changed)`) — a non-zero exit is therefore *not* a failure signal here; the count and the file list are. Confirm `git diff --stat pubspec.yaml` is **empty** (AC-008) and that no `android/` file changed (CON-009). **Release gate:** `flutter build apk --release --target-platform android-arm64`; assert artifact size ≤ **43,240,043 bytes** (AC-013); then byte-scan the uncompressed AOT library at `build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/arm64-v8a/libapp.so` — the manifest version string (`1.4.4`) must be **present** and the stale `1.2.2` **absent** (mitigation hook for the Spec §1.2 `[!CAUTION]`; if the artifact cannot be located, apply Plan B-3 and record the gate as **INCONCLUSIVE**, never as passed). Finally update `docs/ARCHITECTURE.md` §8.3: ratchet **up** passing-test count and test-file count to the measured values, and tighten the unformatted-file floor from `16` to the measured `15`. | CON-001, CON-002, CON-003, CON-004, CON-008, CON-009 | AC-008, AC-009, AC-010, AC-012, AC-013 | TASK-013 | 1 (XS, docs update only) | [ ] | |
| TASK-015 | **APPROVAL:** 🛑 Stop and wait for explicit user confirmation to declare the plan complete. | - | - | TASK-014 | - | [ ] | |

> [!CAUTION]
> **`TASK-014` is the only task that mutates an artifact outside `lib/`/`test/` — and only to record measured numbers.** Never lower a ratchet to make the gate pass (`docs/ARCHITECTURE.md` §8.1 *Zero Bar-Lowering*). If the release APK exceeds the floor, STOP and treat it as a ratchet regression (Circuit Breaker), not as a reason to edit the floor.

---

## 4. Contingency Plan B (Have Two Strings to Your Bow)

*Pólya Heuristic: prepare for potential failure of the primary strategy.*

### Plan B-1 — Asset decoding blocks the widget harness (`TASK-005`)

- **Risk / Failure Point:** `AboutSection` renders two `Image.asset` widgets (`mktv_icon_large.png`, `gulajavas-scaled.png`) plus `GlassmorphismCard`; if the test asset bundle cannot decode them, `pumpAndSettle` surfaces an exception before the copy assertions run.
- **Primary Strategy (Plan A):** Render the full section inside the existing project harness shape (`ScreenUtilInit` 1920×1080 + `MaterialApp` + `Scaffold`), asserting on rendered `Text` widgets — assets declared in `pubspec.yaml` normally resolve from the test bundle.
- **Contingency Strategy (Plan B):** Pre-decode with `tester.runAsync` before the first `pump`, or hoist the assertion target to the text-bearing subtree by pumping the section and immediately asserting `find.text(...)` without `pumpAndSettle`. No assertion is dropped, no error is suppressed, no `// ignore:` is added.
- **Trigger Condition:** A `FlutterError`/`ImageCodecException` is raised before the assertions execute.

### Plan B-2 — `pubspec.yaml`-relative parsing fails under the test runner (`TASK-002`)

- **Risk / Failure Point:** `File('pubspec.yaml')` depends on the test working directory being the package root. The Spec's feasibility spike verified it (`SPIKE cwd=D:\AndroidProject\LatihanFlutter\sadayana-masjid-tv`), but a different runner invocation (IDE runner with a different CWD) could break it.
- **Primary Strategy (Plan A):** Read `pubspec.yaml` relative to CWD, as verified.
- **Contingency Strategy (Plan B):** Resolve the manifest from `Directory.current` upward while `pubspec.yaml` is absent (bounded walk, fail loudly after N levels). The test still fails — never skips — when the manifest cannot be located.
- **Trigger Condition:** `File('pubspec.yaml').existsSync()` is false in the test run.

### Plan B-3 — Release-gate byte-scan cannot locate `libapp.so` (`TASK-014`)

- **Risk / Failure Point:** The AOT library path is a build-toolchain detail and may shift with an AGP/Gradle bump.
- **Primary Strategy (Plan A):** Byte-scan the uncompressed AOT library at the §1.2 path.
- **Contingency Strategy (Plan B):** Fall back to unzipping the release APK to `lib/arm64-v8a/libapp.so` and scanning that copy. If neither yields a scan artifact, record the release-gate inspection as **INCONCLUSIVE** in the review report — do not mark it passed.
- **Trigger Condition:** The path does not exist after a successful release build.

---

## 5. Symmetry, Invariants & Problem Variation (Pólya, p. 199–214)

- **Symmetric Operations & Round-Trip Invertibility:**
  - `parseVersion(pubspec) ↔ renderVersion(AppVersion)` — the manifest value parsed by the guard test and the value rendered by the UI describe the same build; divergence in either direction fails `TASK-002`.
  - `remove literal ↔ remove literal` — **both** halves of the defect must disappear together (`version` **and** `buildNumber`); removing only the version literal is an asymmetric, incomplete fix and is exactly what `AC-011` is written to catch.
  - `expand (new `AppVersion` seam) ↔ contract (delete `_AppInfo.version`/`.buildNumber`)` — the seam is introduced and the old members are deleted inside the **same** task (`TASK-001`), so no state exists where both sources are live.
- **Variation of the Problem (Property-Based & Boundary Exploration):**
  - *Build number width:* single digit (`5`), two digits (`15`), three digits (`150`), and a very large value — all rendered verbatim as opaque strings; **no numeric conversion exists anywhere in the implementation** (`grep` for `int.parse` in the new files must return nothing).
  - *Manifest shapes:* `name+build` (`1.4.4+15`), `name` only (`1.4.4` — build number `null`, version unaffected), and no `version:` key at all (both `null`).
  - *Define shapes:* manifest default, `--dart-define` override (`9.9.9` / `99`), and empty-string define (`RISK-002`).
  - *Viewport:* 1920×1080 baseline (INV-008) with content taller than the viewport — D-Pad clamp at both ends.
- **SOLID Checks at Blueprint Stage:**
  - *Single Responsibility:* `AppVersion` owns exactly one reason to change — how the build identity is exposed. `about_section.dart` keeps one reason to change — how the About content is rendered.
  - *Open/Closed:* a future version-displaying surface consumes `AppVersion` without modifying it.
  - *Dependency Inversion:* `lib/core/` depends on the Flutter SDK only; `lib/presentation/` depends on `lib/core/` — dependencies point inward and downward (no `core → presentation`, no `core → domain`).
  - *Interface Segregation:* five `static const` members, no instance surface, private constructor — no consumer is forced to depend on a member it does not use.
  - *Liskov:* not applicable — no inheritance hierarchy is introduced (`final class`, no implements/extend).

---

## 6. Risks & Extracted Assumptions

### Extracted from the upstream Spec's `[ASSUMPTION]` tags

| ID | Assumption | Mitigation in this plan |
| :--- | :--- | :--- |
| `[ASSUMPTION-001]` | The corrected copy enumerates **all nine** Display State names in a single bullet. | The exact mandated string is hard-coded into `TASK-005`; the widget test asserts it verbatim and asserts the feature list stays at 7 bullets. |
| `[ASSUMPTION-002]` | The About section remains the **only** in-app version surface. | `TASK-008` installs the structural scan (`AC-011`) that fails when any other presentation file declares a `version` / `buildNumber` display constant. |
| `[ASSUMPTION-003]` | `appBuildName` / `appBuildNumber` are non-null for this project's toolchain. | **Verified in the SDK source** (`app_version.dart:17-19, 29-31`: nullable, `null` when `bool.hasEnvironment` is false) and empirically in the Spec's spike. `TASK-002` asserts parity against the manifest, so a sudden `null` fails the guard. |
| `[ASSUMPTION-004]` | The Android toolchain upgrade is a **separate** initiative. | `CON-009` fence restated in `TASK-014`'s verification: `git diff --stat` must show no `android/` change. Any toolchain edit is a Circuit Breaker. |
| `[ASSUMPTION-005]` | `landingpage/panduan.html` is out of scope (deferred, Option A decouple). | No task touches it. Recorded here so it is not silently folded in during `/to-code`. |
| `[ASSUMPTION-006]` | `Sholat` is a canonical `CONTEXT.md` term. | **Already executed** in Phase 1 (`CONTEXT.md:21-23`). `TASK-005`'s copy uses the term verbatim; `TASK-013` corrects the dependent term count in `docs/ARCHITECTURE.md`. |

### Additional plan-level risks (discovered during Phase 2 planning, source-verified)

| ID | Risk / Failure Point | Mitigation | Trigger / Owner action |
| :--- | :--- | :--- | :--- |
| `RISK-001` | **`AC-003`'s null branch cannot be *instantiated* at test time.** `bool.hasEnvironment` is constant-folded, so no `flutter test` invocation can express "define absent". | **Proven by exhaustion instead** (`TASK-002` step b): `displayName ∈ {buildName, unavailable}` and `displayBuildNumber ∈ {buildNumber, unavailable}`, asserted independently, plus `unavailable` non-empty and non-numeric. Both branches are covered without instantiating either; a hardcoded fallback fails the assertion. Do **not** simulate the null branch with a mocked `AppVersion` — that would test the mock, not the build. | If a future Flutter release changes the accessor's nullability contract, re-open `REQ-005`. |
| `RISK-002` | **An empty-string define (`--dart-define=FLUTTER_BUILD_NAME=`) defeats the fallback.** `hasEnvironment` is true, so `buildName == ''`, and `?? unavailable` yields `''` — the version line renders blank rather than `tidak tersedia`. | `TASK-002` adds a defensive assertion that `AppVersion.buildName` is either `null` **or** non-empty. Do **not** alter the Spec's `??` contract unilaterally — if the empty case must be handled, it is a Spec change (owner decision), not an implementation improvisation. | Flag in `/to-review` as a documented limitation of `REQ-005`. |
| `RISK-003` | **`docs/ARCHITECTURE.md` carries two pre-existing drifts** relevant to this change: §1 claims "19 terms" (the glossary now has **20** after the `Sholat` amendment) and "app version 1.4.3+14" (the manifest is `1.4.4+15`). | Fixed inside `TASK-013`, which already touches this file under the Living Architecture Map Mandate. Both corrections are traceable to `REQ-001`/`REQ-004`, not scope creep. | If `/to-code` finds further drift in the same file beyond these two, log it as `NOTICED BUT NOT TOUCHING` instead of expanding the task. |
| `RISK-004` | **Release-AOT version parity has no automated evidence** (Spec §1.2 `[!CAUTION]`, owner-accepted). | `TASK-014`'s release gate performs the byte-scan manually and records the result. | A missing/ambiguous scan result ⇒ recorded as INCONCLUSIVE, never as passed. |
| `RISK-005` | **Widget-harness friction from `Image.asset` / `GlassmorphismCard`.** No existing settings-section test mounts images; `AboutSection` mounts two. | Plan B-1 in §4. | Escalate only if Plan B-1's fallback is exhausted. |

---

## 7. Rollback & Recovery Strategy

This change has **no database migration, no schema change, and no persisted state** — rollback is purely source-level.

1. **Full revert (before commit):** the change set is **3 created + 2 modified + 1 already-committed-by-design** entry (`CONTEXT.md`). Nothing else is touched.

   | Action | File |
   | :--- | :--- |
   | **DELETE (created by this plan)** | `lib/core/app_version.dart` |
   | **DELETE (created by this plan)** | `test/analysis/app_version_consistency_test.dart` |
   | **DELETE (created by this plan)** | `test/presentation/pages/settings/sections/about_section_test.dart` |
   | **RESTORE (modified)** | `lib/presentation/pages/settings/sections/about_section.dart` |
   | **RESTORE (modified)** | `docs/ARCHITECTURE.md` |
   | **KEEP** | `CONTEXT.md` — the `Sholat` amendment was authorised in Phase 1 and is a legitimate glossary improvement independent of this change |

   - Command: `git restore lib/presentation/pages/settings/sections/about_section.dart docs/ARCHITECTURE.md`, then delete the three untracked new files.
2. **Revert after commit:** `git revert <commit-sha>` — one atomic commit per phase is recommended so a partial revert is possible.
3. **Post-rollback verification:** `dart analyze lib test` + `flutter test --reporter=expanded` must return to the pre-change baseline (535/535 across 59 files, `dart analyze lib test` = 0 warnings / 4 infos).
4. **No cache invalidation, no environment restoration, and no data repair are required** — the feature is a compile-time constant display.

---

## 8. 🚩 Pre-Flight Self-Correction Checklist (Anti-Patterns)

- [x] **No Horizontal Slicing:** No task is "build the seam, then build all the tests". Each slice delivers an executable end-to-end behaviour: seam + render site (`TASK-001`), oracle guard (`TASK-002`), copy + widget proof (`TASK-005`), then edge-case proofs that extend already-green slices.
- [x] **No Bloated Tasks (XL):** Maximum 2 files / Size S (`TASK-001`, `TASK-005`). No task touches ≥ 8 files or spans unrelated subsystems.
- [x] **Strict Traceability:** every functional task carries a `Ref ID` (`REQ-*`/`CON-*`) and an `AC Ref` (`AC-*`) from the Spec. Zero orphaned tasks — see §9.
- [x] **Deterministic Dependencies:** every `Dep` points strictly to a previously scheduled task; no inverted downstream consumer.
- [x] **Mandatory Verification & Approval:** every phase ends with a `VERIFY` (`TASK-003`, `TASK-006`, `TASK-011`, `TASK-014`) and an `APPROVAL` gate (`TASK-004`, `TASK-007`, `TASK-012`, `TASK-015`).
- [x] **No Vague Acceptance Verbs:** every pass condition is a boolean assertion with a named command and a numeric threshold.
- [x] **No Requirement Drift:** the plan touches exactly the Spec §5.4 change set (5 files remaining + `CONTEXT.md` pre-completed). The two `docs/ARCHITECTURE.md` drift corrections in `TASK-013` are recorded as `RISK-003`, traced to `REQ-001`/`REQ-004`, and **owner-sanctioned** (audit §2 Item 3, Option A) — not silent scope creep.
- [x] **Gates are executable:** every pass condition was measured against the live tree on 2026-10-23 before being written (`dart analyze lib test` = 0 warnings / 4 infos; formatter = 15 changed). No gate is red by construction, so no Floor-Guard pressure exists.
- [x] **Every criterion is falsifiable:** each of the 14 acceptance criteria names a command and an assertion that breaks under a deliberate mutation — including `AC-003`, proven by two-branch exhaustion rather than by an unimplementable `null` instantiation, and `CON-006`, proven by an import scan rather than by a claim.
- [x] **No Floor-Guard Violation planned:** zero `// ignore:` directives, zero `skip:`, zero `TODO`, zero lowered ratchets. `TASK-014` ratchets **up** only.

---

## 9. Spec → Plan Traceability Bridge

| Spec ID | Covered by task(s) | Notes |
| :--- | :--- | :--- |
| `REQ-001` Single-Source Version Display | `TASK-001`, `TASK-009`, `TASK-013` | Literals removed, seam introduced, living docs record the source of truth |
| `REQ-002` Manifest-Parity Invariant | `TASK-002`, `TASK-008` | External oracle + structural scan |
| `REQ-003` Display-State Copy Correction | `TASK-005` | Exact mandated bullet string |
| `REQ-004` Terminology Conformance | `TASK-005`, `TASK-013` | `_Avoid_` assertions + glossary term-count drift fix |
| `REQ-005` Graceful Degradation | `TASK-001` (`??` fallback), `TASK-002` (`RISK-002` assertion) | Null branch structurally proven — see `RISK-001` |
| `REQ-006` D-Pad Navigation Invariance | `TASK-010` | Offset ±120.0, clamped |
| `REQ-007` Static Artifact Concession | `TASK-001`, `TASK-005` | `_AppInfo` retained; only `version` / `buildNumber` members removed |
| `CON-001` Zero New Runtime Dependency | `TASK-014` | `git diff --stat pubspec.yaml` empty |
| `CON-002` APK Size Ratchet | `TASK-014` | Release build ≤ 43,240,043 bytes |
| `CON-003` Analyzer Ratchet | `TASK-003`, `TASK-006`, `TASK-011`, `TASK-014` | `dart analyze lib test` at every gate — 0 errors / 0 warnings / ≤ 4 infos |
| `CON-004` Test Count Ratchet | `TASK-014` | ≥ 535, then ratcheted **up** to the measured value |
| `CON-005` Offline-First | `TASK-001`, `TASK-005` | No I/O, no network in the slice |
| `CON-006` Domain Purity | `TASK-001`, `TASK-008` | New file lives in `lib/core/`; `TASK-008` step 7 mechanically asserts it imports only `package:flutter/services.dart` |
| `CON-007` Floor-Guard | all tasks | Zero suppressions / skips / stubs / lowered floors |
| `CON-008` Formatting | `TASK-014` | `dart format --output=none --set-exit-if-changed lib test` — **count** `Changed` lines ≤ 15 and no change-set file listed; exit `1` at baseline is expected |
| `CON-009` Surgical Edit | `TASK-014` | No `android/` diff; file set confined to §5.4 |

### Acceptance-Criterion Coverage (all 14)

| AC | Verification task | Verification kind |
| :--- | :--- | :--- |
| `AC-001` rendered version line | `TASK-005`, `TASK-006` | widget test |
| `AC-002` manifest parity | `TASK-002`, `TASK-003` | analysis test (external oracle) |
| `AC-003` absent manifest | `TASK-002`, `TASK-003` | exhaustion proof over both branches — falsifiable `anyOf` + non-numeric regex (§3 Phase 3) |
| `AC-004` build override | `TASK-009`, `TASK-011` | widget test under `--dart-define` |
| `AC-005` nine-state copy | `TASK-005`, `TASK-006` | widget test |
| `AC-006` terminology | `TASK-005`, `TASK-013` | widget test + docs |
| `AC-007` D-Pad invariance | `TASK-010`, `TASK-011` | widget test |
| `AC-008` no new dependency | `TASK-014` | git diff assertion |
| `AC-009` analyzer ratchet | `TASK-003`, `TASK-006`, `TASK-011`, `TASK-014` | `dart analyze lib test` (scoped) |
| `AC-010` test-suite ratchet | `TASK-014` | `flutter test` |
| `AC-011` structural anti-regression | `TASK-008`, `TASK-011` | analysis test (marker scan, seven steps — audit §2 Item 2) |
| `AC-012` formatting | `TASK-014` | `dart format` — `Changed` line count ≤ 15, change-set files absent |
| `AC-013` APK size + release gate | `TASK-014` | release build + byte-scan |
| `AC-014` partial manifest | `TASK-002`, `TASK-003` | analysis test (parser without `+`) |

**No orphaned tasks. No uncovered acceptance criteria. No criterion rests on an unprovable claim.** `AC-003` is covered by an exhaustion proof over both manifest branches rather than by a runtime instantiation (`RISK-001`), and one documented limitation (`RISK-002` empty-string define) is carried into `/to-review` explicitly.

---

## 10. Execution Checklists (Copy-Paste)

```text
# Phase 1 — check:task
dart analyze lib test
flutter test test/analysis/app_version_consistency_test.dart --reporter=expanded

# Phase 2 — check:task
dart analyze lib test
flutter test test/presentation/pages/settings/sections/about_section_test.dart --reporter=expanded

# Phase 3 — check:task (default run proves AC-007 / AC-011)
dart analyze lib test
flutter test test/analysis test/presentation/pages/settings/sections/about_section_test.dart --reporter=expanded

# Phase 3 — AC-004 override run. SCOPE MATTERS: this file only.
# Never add --dart-define to `test/analysis` or to `check:full`; it would break
# the AC-002 manifest-parity oracle by design.
flutter test --dart-define=FLUTTER_BUILD_NAME=9.9.9 --dart-define=FLUTTER_BUILD_NUMBER=99 test/presentation/pages/settings/sections/about_section_test.dart

# Phase 4 — check:full
dart analyze lib test
flutter test --reporter=expanded
flutter build apk --debug

# Phase 4 — formatter gate: PASS CONDITION IS THE COUNT, NOT THE EXIT CODE.
# Baseline 2026-10-23: exit 1, "Formatted 173 files (15 changed)".
# Pass  = count <= 15 AND none of the 5 change-set files appears in the list.
dart format --output=none --set-exit-if-changed lib test

# Phase 4 — scope fences (both must print nothing)
git diff --stat pubspec.yaml
git diff --stat android/

# Phase 4 — release gate (AC-013) + AOT version byte-scan
flutter build apk --release --target-platform android-arm64
# then scan: build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/arm64-v8a/libapp.so
# expected: "1.4.4" present, "1.2.2" absent. If the artifact is missing -> Plan B-3, record INCONCLUSIVE.
```

> [!NOTE]
> Always scope `dart format` to `lib test`. `dart format .` at the repository root crashes with `PathNotFoundException` while walking `build/` (`docs/ARCHITECTURE.md` §8.2; Knowledge Base Dead-End #2).
