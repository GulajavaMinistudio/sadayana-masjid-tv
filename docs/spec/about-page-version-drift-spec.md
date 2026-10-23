---
title: "Single-Source-of-Truth Version Display & Display-State Copy Correction"
version: "1.2.0"
date_created: "2026-10-22"
last_updated: "2026-10-23"
status: "Revised"
discovery_ref: "docs/discovery/about-page-version-drift-discovery.md"
tags: ["polya", "spec", "clean-architecture", "about-section", "versioning"]
---
<!-- markdownlint-disable-->

# Technical Specification: Single-Source-of-Truth Version Display

## 1. Pólya Phase 1: Understanding the Problem

### 1.1 The Unknown (Goal & Desired State)

**What exactly are we trying to render?**

The "Tentang Aplikasi" section of the Settings menu must render the application's version and build number such that the displayed value is **structurally incapable of diverging** from the value that was compiled into the running binary. Today the value is a hand-maintained string literal in a private constant class; it has silently diverged across **six consecutive releases**.

**What constitutes a successful and complete solution?**

1. The version string rendered on the About screen equals the `version:` field of `pubspec.yaml` at build time — **without any human editing a version literal**.
2. A machine-checkable invariant exists so that a future regression (a re-introduced hardcoded literal, or a mismatch between the rendered value and the manifest) **fails a test** rather than shipping silently to Google Play.
3. The About screen's feature copy accurately describes the application's Display State model, matching the canonical term in `CONTEXT.md`.

**Explicit Non-Goals (Out of Scope):**

| Non-Goal | Rationale |
| :--- | :--- |
| **Android toolchain upgrade** (AGP 8.11.1 → 9.1.0, Gradle 8.14 → 9.3.1, Kotlin 2.2.20 → 2.4.0) | Pre-existing debt surfaced by the feasibility spike; a materially larger initiative. Bundling it would convert an XS change into an XL one and violate the Surgical Edit Mandate. Recorded as `[ASSUMPTION-004]` in the Discovery Draft. |
| **Reconciling the pending `compileSdk`/`targetSdk` 37 bump** | In-flight release work unrelated to version display. It does **not** block this specification — the feasibility spike proved the build succeeds and that the Flutter-native accessor requires no toolchain change. |
| **Introducing `package_info_plus` or any new runtime dependency** | The Flutter-native accessor (`package:flutter/services.dart`) satisfies the requirement at zero cost. Adding a plugin would force an AGP upgrade (§Out of Scope above). |
| **Rewriting `landingpage/panduan.html` version literal** | A static marketing artifact, not the in-app surface. It cannot read the build manifest, so no structural fix is available. Handling is deferred to a separate decision — see `[ASSUMPTION-005]`. |
| **Adding a version badge to the splash screen or header** | Not requested. If added later, it **must** consume the same accessor established here (see `[ASSUMPTION-002]`). |
| **Introducing a new architectural layer (domain entity / use case / port) for the version value** | The value is a compile-time constant of the build, not domain business logic. Full Clean Architecture layering here would be ceremony without benefit. Justified by the Architectural Pragmatism Check in §5. |

### 1.2 The Data (Inputs, State & Source-Grounded Context)

**The value chain (fully source-grounded):**

```text
pubspec.yaml:19                    version: 1.4.4+15          ← SINGLE SOURCE OF TRUTH
        │
        │  flutter_tools parses the manifest
        ▼
flutter_tools/lib/src/runner/flutter_command.dart:1506-1514
        │  dartDefines.add('FLUTTER_BUILD_NAME=$buildName')
        │  dartDefines.add('FLUTTER_BUILD_NUMBER=$buildNumber')
        │  where buildName/buildNumber default to project.manifest.buildName/buildNumber
        ▼
flutter_tools/lib/src/build_info.dart:364
        │  dart-defines are encoded and passed to the Dart compiler
        ▼
flutter/packages/flutter/lib/src/services/app_version.dart:17-31
        │  const String? appBuildName    = String.fromEnvironment('FLUTTER_BUILD_NAME')
        │  const String? appBuildNumber  = String.fromEnvironment('FLUTTER_BUILD_NUMBER')
        ▼
lib/presentation/pages/settings/sections/about_section.dart   ← RENDER SITE (the fix)
```

**Verified facts:**

| Fact | Evidence |
| :--- | :--- |
| `pubspec.yaml` declares `version: 1.4.4+15` | `[VERIFIED: pubspec.yaml:19]` |
| The manifest version is injected as a dart-define by **every** Flutter build/run command | `[VERIFIED: D:/Aplikasi/flutter_windows_stable/flutter/packages/flutter_tools/lib/src/runner/flutter_command.dart:1506-1514]` |
| The dart-define is baked into the compiled binary (compile-time, not runtime lookup) | `[VERIFIED: D:/Aplikasi/flutter_windows_stable/flutter/packages/flutter/lib/src/services/app_version.dart:10-13]` — *"this constant is embedded in the compiled application itself, so it always describes the code that is actually running."* |
| The accessor is exported from the public `package:flutter/services.dart` | `[VERIFIED: D:/Aplikasi/flutter_windows_stable/flutter/packages/flutter/lib/services.dart:13]` → `export 'src/services/app_version.dart';` |
| `appBuildName` / `appBuildNumber` are **nullable** `String?` | `[VERIFIED: app_version.dart:17,29]` — `const String? appBuildName` |
| `flutter test` also injects the define | `[VERIFIED: flutter_tools/lib/src/commands/test.dart:433]` — calls the same `getBuildInfo` |
| The About page currently hardcodes the version | `[VERIFIED: lib/presentation/pages/settings/sections/about_section.dart:17-18]` — `static const String version = '1.2.2';` / `static const String buildNumber = '5';` |
| The hardcoded values are rendered as one string | `[VERIFIED: about_section.dart:163]` — `'Versi ${_AppInfo.version}  ·  Build ${_AppInfo.buildNumber}  ·  ${_AppInfo.license}'` |
| The About screen is the **only** in-app surface displaying a version | `[VERIFIED: grep 'versi\|version' across lib/presentation/ → only about_section.dart matches]` |
| The About section is mounted as one of the settings categories | `[VERIFIED: lib/presentation/pages/settings/settings_menu_page.dart:69]` — `AboutSection(),` |
| The Display State model has **nine** states | `[VERIFIED: lib/domain/entities/display_state_type.dart:2-29]` — 9 enum values; `[VERIFIED: lib/domain/entities/display_state.dart:22,54,88,120,154,188,240,283,328]` — 9 concrete classes |
| The canonical domain term is "nine automatic screen modes" | `[VERIFIED: CONTEXT.md:55-57]` — **Display State**: *"One of the nine automatic screen modes the signage can show at any moment."* |
| The About page's feature copy claims only five | `[VERIFIED: about_section.dart:35]` — `'5 mode tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → Sholat'` |
| The `DisplayState` priority chain (5 core prayer states + 4 informational + Standby fallback) | `[VERIFIED: lib/domain/usecases/evaluate_display_state_use_case.dart:56-161]` — Pre-Adzan → Adzan → Iqomah → Sholat (per-prayer loop) → Midnight Standby → Slideshow Announcement → Imam Schedule → Wisdom Quote → Standby (fallback) |
| The four additional states are **reachable in production**, not dead enum members | `[VERIFIED: lib/presentation/pages/main_display_page.dart:153,160,166,172]` — each is rendered by a dedicated layout; each is gated by a user-facing settings toggle (`isSlideshowEnabled` `slideshow_section.dart:202`, `isImamScheduleEnabled` `imam_schedule_section.dart:244`, `isWisdomEnabled` `wisdom_quote_section.dart:121`, `isMidnightModeEnabled` `midnight_mode_section.dart:93`) |
| The dart-define injection is **build-mode-agnostic** — the define list is computed before mode-specific compilation and shared by debug, profile, and release | `[VERIFIED: flutter_tools/lib/src/runner/flutter_command.dart:1506-1514]` — `getBuildInfo` populates `kAppBuildName` / `kAppBuildNumber` for every build command |
| `appBuildName` / `appBuildNumber` resolve to `1.4.4` / `15` under `flutter test` | `[VERIFIED: feasibility spike, §5 Technical Unknown 1]` — output: `SPIKE appBuildName=[1.4.4] appBuildNumber=[15]` |
| A **release AOT** build's version parity has **not** been empirically verified | The feasibility spike ran `flutter build apk --debug` — a **JIT** build; the AOT path was never separately observed. *Read-only audit probe, 2026-10-23:* the existing release artifact `build/app/outputs/flutter-apk/app-release.apk` → `lib/arm64-v8a/libapp.so` contains `"1.2.2"` and does **not** contain `"1.4.4"` — i.e. the shipped AOT artifact carries the stale literal, confirming the defect on the AOT path as well. |
| `pubspec.yaml` is readable from a test's working directory | `[VERIFIED: feasibility spike] — `SPIKE cwd=D:\AndroidProject\LatihanFlutter\sadayana-masjid-tv`, `version line=[version: 1.4.4+15]`` |
| The About section is a `StatefulWidget` with a `ScrollController` + D-Pad key handling | `[VERIFIED: about_section.dart:53-98]` |

> [!CAUTION]
> **Residual risk — the AOT / release path carries no empirical version-parity evidence.** Owner decision, 2026-10-23 (`/to-grill-me` Iteration 2, Item 1): `AC-004`'s sole verification procedure is `flutter test --dart-define=…`; the release-artifact byte-scan was declined. Consequently, the guarantee that a **release** build carries the manifest version rests on *source reasoning* — the dart-define injection at `flutter_command.dart:1506-1514` is build-mode-agnostic — and **not** on direct observation of a release artifact.
>
> **Mitigation hook:** `AC-013`'s release build (`flutter build apk --release --target-platform android-arm64`) already runs in `check:full`. At that point the artifact's version MUST be re-confirmed by inspection — `lib/arm64-v8a/libapp.so` contains the manifest version string and does **not** contain the previous one — as a manual **release-gate** step. This is a release checkpoint, not an automated test; it is recorded here so that the residual risk is owned and revisited rather than forgotten.
>
> Recorded in `docs/audit/about-page-version-drift-spec-clarification.md` Iteration 2, Finding I2-1, and in `docs/audit/about-page-version-drift-spec-decisions.md` §Key Decisions Settled (5).

**State machine / session context:** the About section is a **read-only, stateless presentation surface**. It owns no Cubit, performs no I/O, and holds no domain state. Its only mutable state is a `ScrollController` and an implicit `FocusNode` for D-Pad navigation.

### 1.3 The Condition (Requirements, Constraints & Invariants)

- **REQ-001 (Single-Source Version Display):** The About section MUST render the application version and build number from the compile-time build manifest (`appBuildName` / `appBuildNumber`) and MUST NOT contain any hardcoded version or build-number literal.

- **REQ-002 (Manifest-Parity Invariant):** The rendered version MUST equal the `version:` field of `pubspec.yaml` for the build under test. This SHALL be enforced by an automated test that fails on divergence.

- **REQ-003 (Display-State Copy Correction):** The About section's feature list MUST describe the Display State model using the canonical count from `CONTEXT.md` (nine), replacing the current "5 mode" claim, and MUST NOT enumerate a state that does not exist.

- **REQ-004 (Terminology Conformance):** Any Display State named in About-section copy MUST use the canonical term from `CONTEXT.md` and MUST NOT use a term listed under that term's `_Avoid_` list.

- **REQ-005 (Graceful Degradation on Absent Manifest Version or Build Number):** When the build manifest provides no version (`appBuildName == null`) **or no build number** (`appBuildNumber == null`), the affected field of the About section MUST render a deterministic, non-empty fallback and MUST NOT render a misleading value. The fallback MUST NOT be a numeric version literal, so that the absence is visible rather than silently wrong. The two fields degrade **independently**: a manifest that declares a version without a build number MUST still render the version.

- **REQ-006 (D-Pad Navigation Invariance):** The version-source change MUST NOT alter the D-Pad scroll behaviour of the About section (`arrowUp` / `arrowDown` handling over the `ScrollController`).

- **REQ-007 (Static Artifact Concession):** The About section's static copy — application name, description, license, developer credit — remains hand-maintained and is OUT of the scope of REQ-001/REQ-002. Only the version and build-number fields are bound to the build manifest.

- **CON-001 (Zero New Runtime Dependency):** The solution MUST NOT add any new entry to `dependencies:` in `pubspec.yaml`. `package:flutter/services.dart` is already part of the Flutter SDK. *Rationale: the APK-size ratchet floor is 41.24 MB (§8.3) and every new plugin is a potential regression against it.*

- **CON-002 (APK Size Ratchet):** Release APK size MUST NOT **grow beyond** **41.24 MB (43,240,043 bytes)**, arm64 unminified baseline `[VERIFIED: docs/ARCHITECTURE.md:282]`. This matches the ratchet's own wording (*"Must not grow"*, `docs/ARCHITECTURE.md:282`). Since CON-001 forbids new dependencies and the change is a constant substitution, the expected delta is **≈ 0 bytes** — it is deliberately **not** asserted to be *exactly* 0, because inlining a dart-define shifts the Dart snapshot's const pool and string table, and the measurement cannot resolve a single byte. `AC-013` carries the executable form of this constraint.

- **CON-003 (Analyzer Ratchet):** Analyzer findings MUST NOT grow — Errors `0`, Warnings `≤ 1`, Infos `≤ 4` `[VERIFIED: docs/ARCHITECTURE.md:273-275]`. Baseline measured 2026-10-22: **0 errors, 0 warnings, 4 infos**.

- **CON-004 (Test Count Ratchet):** Passing tests MUST NOT drop below **535 / 535** across 59 test files `[VERIFIED: docs/ARCHITECTURE.md:276]`. This specification ADDS tests; the ratchet therefore ratchets **up**.

- **CON-005 (Offline-First — No Network):** The About section MUST NOT perform any network request. The version source is a compile-time constant; no I/O of any kind is introduced.

- **CON-006 (Domain Purity):** The change MUST NOT introduce any import of Flutter, SQLite, or Firebase into `lib/domain/` — that layer's invariant is **0** violations `[VERIFIED: docs/ARCHITECTURE.md:214, 279]`.

- **CON-007 (Floor-Guard — Zero Suppressions):** The implementation MUST NOT introduce `@ts-ignore`-equivalent suppressions (`// ignore:`, `// ignore_for_file:`), skipped tests (`skip:`), weakened assertions, `TODO`/`FIXME` placeholders, or a lowered ratchet floor.

- **CON-008 (Formatting):** `dart format --output=none --set-exit-if-changed lib test` MUST remain clean (ratchet floor: ≤ 16 unformatted files) `[VERIFIED: docs/ARCHITECTURE.md:277]`.

- **CON-009 (Surgical Edit):** The implementation MUST modify only the files enumerated in §5.4 and MUST NOT touch the Android toolchain (`android/settings.gradle.kts`, `android/gradle/wrapper/gradle-wrapper.properties`, `android/build.gradle.kts`).

### 1.4 Condition Sanity Check & Completeness Audit (Pólya, p. 7, 33)

**Is the condition sufficient to determine the unknown?** — **Yes.** REQ-001 fixes the source (`appBuildName`/`appBuildNumber`), REQ-002 fixes the verification mechanism (test against `pubspec.yaml`), REQ-003/REQ-004 fix the copy defect, REQ-005 fixes the null case, REQ-006 protects existing behaviour, and REQ-007 fences the boundary. No further input is needed.

**Is it insufficient?** — One gap was identified and closed by REQ-005: `appBuildName` is nullable, so the specification must define the absent-manifest behaviour rather than assume non-null.

**Is it redundant or contradictory?** — Checked for conflict between REQ-001 (no hardcoded literal) and REQ-005 (a fallback value). **Resolution:** REQ-005's fallback is explicitly constrained to be **non-numeric** so it cannot become a de-facto hardcoded version. This makes the two requirements compatible, not contradictory.

**Did you use ALL the data?** — Every input in the version chain (§1.2) is mapped: `pubspec.yaml` → manifest parse → dart-define → compile-time constant → render site. The `flutter build --build-name/--build-number` override path is covered by REQ-001's "compile-time build manifest" wording and by AC-004. The `android/local.properties` corroboration (`flutter.versionName=1.4.4`, `flutter.versionCode=15`) `[VERIFIED: android/local.properties]` is treated as **verification evidence**, not as a runtime source — it is git-ignored and therefore not a durable contract.

**Did you use the WHOLE condition?** — Every constraint from the Discovery Draft is mapped: offline-only (CON-005), APK-size ratchet (CON-002), D-Pad navigation (REQ-006), Floor-Guard (CON-007), formatting (CON-008), zero-dependency (CON-001), toolchain exclusion (CON-009), and the scope fence on the toolchain upgrade (§1.1 Non-Goals).

### 1.5 Indirect Proof & Negative Invariant Analysis (Pólya, p. 162–171)

**Negative Hypothesis H1 (assume the invariant is violated):** *Assume the About screen shows a version different from the compiled binary.*

- **Contradiction:** A mosque operator reports "the app says version X" while Play Store and the binary report version Y. Support triage becomes impossible to resolve; the operator cannot determine which build is installed. This is not hypothetical — it is the exact state the application shipped in for six releases (§1.2, and the Discovery Draft §3.3 drift timeline).
- **Safe rejection:** REQ-002 converts this from a shipping defect into a **test failure**. The guard test compares the value the UI renders against the manifest parsed from `pubspec.yaml` at test time. A divergence fails `flutter test` and therefore blocks the release.

**Negative Hypothesis H2 (assume the manifest version is absent):** *Assume `appBuildName` is `null` — the pubspec has no `version:` field, or the build was invoked with a toolchain that does not inject the define.*

- **Contradiction:** Rendering an empty string produces a broken-looking line ("Versi  ·  Build  ·  GPL v3"). Worse, rendering a *hardcoded* fallback would reintroduce exactly the defect this specification exists to eliminate — a plausible-looking but silently wrong version.
- **Safe rejection:** REQ-005 mandates a deterministic, **non-numeric** fallback that is visually distinct from a real version, so the absence is diagnosable rather than misleading. Covered by AC-003.

**Negative Hypothesis H3 (assume the define injection regresses in a future Flutter upgrade):** *Assume a future Flutter release stops injecting `FLUTTER_BUILD_NAME`.*

- **Contradiction:** `appBuildName` becomes `null` on every build. If the About section silently fell back to a literal, the defect returns invisibly.
- **Safe rejection:** The guard test asserts against `pubspec.yaml` (the manifest), **not** against `appBuildName`. If the define stops being injected, the test fails because the rendered fallback does not equal the manifest value — even though both sides of the app-internal comparison would still "agree" with each other. This is precisely why the guard test parses the manifest rather than comparing two app-internal constants.

**Negative Hypothesis H4 (assume the About section's copy is used to justify the Display State model):** *Assume the "5 mode" claim is left uncorrected.*

- **Contradiction:** A reader of the About screen concludes the signage has five screen modes, while the application ships nine. The claim contradicts `CONTEXT.md:55-57` — the canonical glossary that every other artifact defers to — and `docs/ARCHITECTURE.md:20`, which documents the "9-state automatic display machine". Critically, the four additional states are **not** dead enum members: each is rendered by a dedicated layout in `main_display_page.dart:153,160,166,172` and gated by a user-facing settings toggle, so a DKM administrator can enable all nine. The About page becomes a fifth divergent copy of the model, exactly the failure pattern this specification eliminates for the version.
- **Safe rejection:** REQ-003 mandates the canonical count; REQ-004 mandates canonical terminology for every named state; AC-005 asserts the corrected copy renders and the stale "5 mode" string does not.

---

## 2. Ubiquitous Language & Domain Glossary (`CONTEXT.md`)

*This specification introduces **one new domain term** — **Sholat** — and reuses the remaining canonical vocabulary verbatim. The full set of terms this specification relies on is reproduced below; the single glossary amendment is recorded in §2.2.*

- **Display State:**
  One of the nine automatic screen modes the signage can show at any moment.
  _Avoid_: screen mode, layout

  *Used in REQ-003/REQ-004. The canonical count — nine — is the correction target for the About page's "5 mode" claim. The nine states, per `lib/domain/entities/display_state_type.dart:2-29`: Standby, Pre-Adzan, Adzan, Iqomah, Sholat, Slideshow Announcement, Imam Schedule, Wisdom Quote, Midnight Standby.*

- **Standby:**
  The default resting screen: clock, dates, prayer schedule, Treasury summary, and Running Text.
  _Avoid_: idle screen

- **Slideshow Announcement:**
  The periodic full-screen rotation of announcement images from up to three configured slots.
  _Avoid_: carousel, banner rotation

- **Imam Schedule:**
  The weekly rota assigning an imam — and on Jum'at a khatib — to each congregational prayer.
  _Avoid_: imam board

- **Wisdom Quote:**
  A Quran verse or hadith shown as a periodic full-screen reflection.
  _Avoid_: quote rotation

- **Midnight Standby:**
  The scheduled night power-saving screen with a dimmed clock and anti burn-in drift.
  _Avoid_: sleep mode, night mode

- **Pre-Adzan:**
  The countdown window shortly before a prayer time, used to highlight the upcoming prayer.
  _Avoid_: pre-adhan

- **Adzan:**
  The call to prayer marking the start of a prayer time; the signage dedicates a full-screen phase to it.
  _Avoid_: Azan, Adhan

- **Iqomah:**
  The countdown interval between the Adzan and the start of the congregational prayer.
  _Avoid_: Iqamah, Iqama

- **Sholat:**
  The congregational prayer phase the signage commits to, shown as a darkened silent screen.
  _Avoid_: salat, salat prayer

  *Added to `CONTEXT.md` by this specification (§2.2). Used in REQ-003/REQ-004 as the fifth state of the prayer cycle.*

> [!NOTE]
> **Terms deliberately NOT introduced.** "Application Version", "Build Number", and "Version String" are generic technical terms, not business-domain concepts; `CONTEXT.md` is reserved for Prayer Schedule / Display Features / Mosque Administration vocabulary. Adding them would dilute the glossary. **No further `CONTEXT.md` change is required by this specification** — the single `Sholat` amendment above is the only one.

> [!NOTE]
> **"Sholat" is now a canonical glossary term.** Before this revision, `CONTEXT.md` defined the nine Display States collectively via "Display State" and named **eight of the nine** individually — "Sholat" was the sole omission, even though it is an enum member (`display_state_type.dart:16`) and already appeared in the About copy. The glossary's own claim that "Display State" means *"One of the nine automatic screen modes"* (`CONTEXT.md:55-57`) is now consistent with the terms it names. See `[ASSUMPTION-006]`.

### 2.1 Canonical Display State Enumeration (normative for REQ-003 / REQ-004)

*The nine states, in the declaration order of `lib/domain/entities/display_state_type.dart:2-29`, with the Indonesian user-facing rendering mandated for the About-section feature bullet.*

| # | Enum member `[VERIFIED: display_state_type.dart]` | Class `[VERIFIED: display_state.dart]` | About-copy name (canonical) | `CONTEXT.md` status |
| :---: | :--- | :--- | :--- | :--- |
| 1 | `standby` | `StandbyState` (`:22`) | **Standby** | Defined (`:59-61`), `_Avoid_: idle screen` |
| 2 | `preAdzan` | `PreAdzanState` (`:54`) | **Pre-Adzan** | Defined (`:17-20`), `_Avoid_: pre-adhan` |
| 3 | `adzan` | `AdzanState` (`:88`) | **Adzan** | Defined (`:9-12`), `_Avoid_: Azan, Adhan` |
| 4 | `iqomah` | `IqomahState` (`:120`) | **Iqomah** | Defined (`:13-16`), `_Avoid_: Iqamah, Iqama` |
| 5 | `sholat` | `SholatState` (`:154`) | **Sholat** | Defined (`:21-23`), `_Avoid_: salat, salat prayer` — *added by this specification (§2.2)* |
| 6 | `slideshowAnnouncement` | `SlideshowAnnouncementState` (`:188`) | **Slideshow Announcement** | Defined (`:63-66`), `_Avoid_: carousel, banner rotation` |
| 7 | `imamSchedule` | `ImamScheduleState` (`:240`) | **Imam Schedule** | Defined (`:67-70`), `_Avoid_: imam board` |
| 8 | `wisdomQuote` | `WisdomQuoteState` (`:283`) | **Wisdom Quote** | Defined (`:71-74`), `_Avoid_: quote rotation` |
| 9 | `midnightStandby` | `MidnightStandbyState` (`:328`) | **Midnight Standby** | Defined (`:75-78`), `_Avoid_: sleep mode, night mode` |

**Mandated bullet shape (per `[ASSUMPTION-001]`):** a single feature bullet stating the count **nine** and naming all nine states in the order above, separated by `→` (preserving the current bullet's arrow convention) — e.g. `9 status tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → Sholat → Slideshow Announcement → Imam Schedule → Wisdom Quote → Midnight Standby`.

> [!NOTE]
> **The arrow is retained for continuity with the existing copy, but it denotes the canonical enumeration order, not a temporal sequence.** The actual runtime priority chain is documented separately in `evaluate_display_state_use_case.dart:56-161` and is: prayer-cycle states (per prayer) → Midnight Standby → Slideshow Announcement → Imam Schedule → Wisdom Quote → Standby (fallback). The About bullet is a *capability summary*, not a scheduling description — it must not be read as a claim that the signage advances through the nine modes in that order.

> [!NOTE]
> **The bullet uses "status", not "mode".** `CONTEXT.md` defines **Display State** with `_Avoid_: screen mode, layout`, and *"mode tampilan otomatis"* is the direct Indonesian rendering of the rejected synonym *"screen mode"*. The mandated wording therefore uses **"status tampilan otomatis"**, which is the vocabulary the domain layer already uses for this concept — `display_state_type.dart:1` (*"Jenis status tampilan layar…"*), `display_state.dart:10` (*"Base class untuk status tampilan layar."*), `transition_config.dart:4` (*"…antar status tampilan."*), `evaluate_display_state_use_case.dart:11` (*"…status tampilan saat ini."*). A repository-wide search confirms *"mode tampilan"* occurred in exactly one place before this revision — the About copy itself, `about_section.dart:35`. No `_Avoid_` entry is added to `CONTEXT.md`, and `REQ-004` requires no carve-out. Decision recorded in `docs/audit/about-page-version-drift-spec-clarification.md` §2 Item 3.

### 2.2 Glossary Amendment — `Sholat` (owner-confirmed 2026-10-23)

| Field | Value |
| :--- | :--- |
| **Term added** | `Sholat` |
| **Group** | Prayer Schedule (adjacent to `Adzan`, `Iqomah`, `Pre-Adzan` — the three sibling prayer-cycle phases) |
| **Definition** | *"The congregational prayer phase the signage commits to, shown as a darkened silent screen."* |
| **Rejected synonyms** | `salat`, `salat prayer` |
| **Rationale** | `CONTEXT.md` defined eight of the nine Display States by name while `DisplayStateType.sholat` (`display_state_type.dart:16`) is a first-class enum member — a one-term gap that made `REQ-004` (every named state must be a `CONTEXT.md` term) contradict `AC-005` (all nine states must be named). Closing the gap makes both requirements literally satisfiable, and makes the glossary's own *"nine automatic screen modes"* claim (`CONTEXT.md:55-57`) consistent with the terms it names. |
| **Decision** | ✅ Owner-confirmed — **Option A** (add the term). Recorded in `docs/audit/about-page-version-drift-spec-clarification.md` §2 Item 1. |
| **Executed** | `CONTEXT.md` amended 2026-10-23; the term sits at `CONTEXT.md:21-23`. |

---

## 3. Assumptions & Open Clarifications

> [!WARNING] [ASSUMPTION-001]: The corrected feature copy will enumerate **all nine** Display State names rather than restating only the five prayer-cycle states.
> *Risk / Trade-off:* Listing nine names lengthens a single feature bullet in a TV-facing card at 1920×1080, which is a readability cost. The alternative — describing the five prayer-cycle states and summarising the four informational modes generically — is shorter but reintroduces an under-count that contradicts `CONTEXT.md:55-57`.
> *Proposed Verification:* ✅ **Owner-confirmed 2026-10-23 — Option A.** A single bullet enumerating all nine names was selected over a two-bullet split (five prayer-cycle states + four informational modes), because the split preserves the "five prayer-cycle" framing this specification exists to correct, and the `→` arrow's sequence ambiguity is already disarmed by the §2.1 note. The feature list therefore remains at **7 bullets**; only the single existing bullet at `about_section.dart:35` changes. **Default boundary (now binding):** enumerate all nine, using canonical names in canonical order (Standby → Pre-Adzan → Adzan → Iqomah → Sholat → Slideshow Announcement → Imam Schedule → Wisdom Quote → Midnight Standby), matching the enum declaration order in `display_state_type.dart:2-29`.

> [!WARNING] [ASSUMPTION-002]: The About section remains the **only** in-app surface that displays the version.
> *Risk / Trade-off:* If a splash-screen or header version badge is added later, a developer may reach for a literal — reintroducing the defect. *Verified:* a `grep` for `versi|version` across `lib/presentation/` returns matches only in `about_section.dart`; the other hits are unrelated (`masehiDate`, a `TASK-010` comment, and an unrelated "versi lama" comment in `splash_page.dart:51`).
> *Proposed Verification:* A repository-wide **structural** invariant test enforces this at test time — no file under `lib/presentation/` may declare a `version` or `buildNumber` string constant for display, and every version-displaying surface must import `AppVersion` (`AC-011`). *Why a structural assertion rather than a literal-shape scan:* the original defect shipped two coupled literals (`'1.2.2'` **and** `'5'`), and a `<digits>.<digits>.<digits>` pattern cannot match a bare build number such as `'15'` — so a regex would have missed the second half of the defect it exists to prevent.
> *Default boundary:* Any future version-displaying surface MUST consume `appBuildName`/`appBuildNumber`.

> [!WARNING] [ASSUMPTION-003]: `appBuildName` and `appBuildNumber` are **non-null** for every build produced by this project's toolchain.
> *Risk / Trade-off:* Both are nullable by contract (`app_version.dart:17,29`); they are `null` only when the manifest has no `version:` field **and** no `--build-name` was supplied. This project's `pubspec.yaml:19` always declares a version, so the null branch is unreachable in practice — but it is reachable in principle, and Dart's null-safety makes the compiler enforce handling.
> *Proposed Verification:* **Already verified empirically** — the feasibility spike produced `appBuildName=[1.4.4]`, `appBuildNumber=[15]` under both `flutter test` and `flutter build apk --debug`. REQ-005 specifies the fallback for the theoretical branch; AC-003 covers it.
> *Default boundary:* The fallback renders a non-numeric placeholder (§4.3), never a numeric version.

> [!WARNING] [ASSUMPTION-004]: The Android toolchain upgrade (AGP 8.11.1 → 9.1.0, Gradle 8.14 → 9.3.1, Kotlin 2.2.20 → 2.4.0) and the pending `compileSdk`/`targetSdk` 37 bump are **separate initiatives** and are **not** prerequisites for this specification.
> *Risk / Trade-off:* `compileSdk 37` is not officially supported by AGP 8.11.1 (max API 36); a future Flutter or AGP validation could hard-fail the build. Bundling the toolchain upgrade here would inflate this change from XS to XL and mix two unrelated concerns — a direct violation of the Boy Scout Rule's scope discipline.
> *Proposed Verification:* **Already verified empirically** — `flutter build apk --debug` completed with exit code 0 under the current toolchain, and the Flutter-native accessor requires no AGP/Gradle/Kotlin change whatsoever.
> *Default boundary:* Toolchain remediation is tracked as a **separate** initiative and MUST NOT be bundled into the implementation of this specification (CON-009).

> [!WARNING] [ASSUMPTION-005]: `landingpage/panduan.html` is a **static marketing artifact**, not a release-coupled surface.
> *Risk / Trade-off:* If it is published alongside each Play release, its hardcoded `1.2.2 (build 5)` at line 3254 becomes a second user-visible divergence — the same defect class as the About page, but with **no structural fix available** (a static HTML file cannot read the build manifest). Two sub-options exist: (A) decouple it by removing the version literal entirely from the marketing copy; (B) sync it manually and accept recurrence.
> *Proposed Verification:* `[Assumed / Auto-Resolved]` — **Option A (decouple)**. This item does not gate the specification: the landing page is a static marketing artifact with no structural fix available, it is already listed under §1.1 Non-Goals, and §1.1 and §3 are internally consistent in deferring it. The recommendation stands recorded for whenever the owner chooses to execute the one-line cleanup of `landingpage/panduan.html:3254`.
> *Default boundary:* **Option A (decouple)** — a marketing page that must be hand-updated per release is a recurring maintenance liability, whereas a page that makes no version claim cannot drift. Deferred to a separate out-of-scope initiative.

> [!WARNING] [ASSUMPTION-006]: "Sholat" is used verbatim as a Display State name in the corrected About copy, **and is now a canonical `CONTEXT.md` term**.
> *Risk / Trade-off:* Before this revision, `CONTEXT.md` defined "Display State" collectively and named **eight of the nine** states individually, but did not define "Sholat" as its own glossary entry — even though `DisplayStateType.sholat` (`display_state_type.dart:16`) and the existing About copy both use it. That one-term gap made `REQ-004` (every named state must be a `CONTEXT.md` term) contradict `AC-005` (all nine states must be named), rendering the two criteria jointly unsatisfiable.
> *Proposed Verification:* ✅ **Owner-confirmed 2026-10-23 — Option A.** The "Sholat" term was added to `CONTEXT.md` (§2.2), which now names **all nine** Display States. `REQ-004`, `AC-005`, and `AC-006` stand unchanged and are literally satisfiable; no carve-out or exception is required anywhere in this specification.
> *Default boundary (now binding):* "Sholat" is a canonical glossary term at `CONTEXT.md:21-23`, with `_Avoid_: salat, salat prayer`. It is used verbatim in the About copy exactly as it already appears in the codebase and in the existing About copy.

- **[CLARIFICATION-001]:** ✅ **RESOLVED 2026-10-23 — a single bullet listing all nine Display State names inline, in canonical order, separated by `→`.** The two-bullet alternative (five prayer-cycle states plus four informational modes) was rejected because it preserves the "five prayer-cycle" framing this specification exists to correct. The `→` arrow's sequence ambiguity is already disarmed by the §2.1 note, so it does not reintroduce the readability concern that motivated the split. The feature list remains at **7 bullets**. Recorded in `docs/audit/about-page-version-drift-spec-clarification.md` §2 Item 2.

---

## 4. Setting Up Equations & Expressive Notation (Pólya, p. 134–141, 174)

### 4.1 Type-Driven Domain Invariants

The value under specification is a **compile-time constant of the build**, not a domain entity. Type-Driven Design is therefore applied in the narrow sense of making the *invalid* state (a hand-maintained version literal) unrepresentable by construction rather than by convention.

**Invariant I1 — Single Source:**

```text
∀ builds B, ∀ screens S displaying a version:
    rendered(S, B) = B.manifest.version.name ∧ B.manifest.version.buildNumber
```

Where `B.manifest.version` is derived from `pubspec.yaml` by the Flutter tool and injected as `FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER`. The rendered value is a **projection of the build**, never an independent restatement.

**Invariant I2 — Non-Numeric Fallback:**

```text
appBuildName == null  ⟹  rendered version ∉ ℕ-pattern
```

The absent-manifest fallback must be recognisably *not a version*, so that its absence is diagnosable rather than silently wrong (H2).

**Invariant I3 — Manifest Parity (test-enforced):**

```text
∀ test runs T:
    assert( renderedAboutVersion(T) == parseVersion(pubspec.yaml).name )
    ∧ assert( renderedAboutBuild(T) == parseVersion(pubspec.yaml).buildNumber )
```

The right-hand side is parsed from the manifest file, **not** from `appBuildName` — otherwise the test would be self-referential and could not detect a Flutter toolchain regression (H3).

### 4.2 Data Transfer Objects (DTOs) & Interfaces

This feature has **no network or persistence surface**. The "DTO" is the value transferred from the build layer into the presentation layer. It is modelled as an immutable, `const`-constructible value holder so that the presentation layer never restates the value.

```dart
// lib/core/app_version.dart  — NEW FILE (see §5.4)
// Source: package:flutter/services.dart (part of the Flutter SDK — zero new deps)

import 'package:flutter/services.dart';

/// Immutable holder for the application's build identity.
///
/// The values are compile-time constants injected by the Flutter tool from
/// `pubspec.yaml`'s `version:` field (via the `FLUTTER_BUILD_NAME` and
/// `FLUTTER_BUILD_NUMBER` dart-defines). They therefore always describe the
/// code that is actually running.
final class AppVersion {
  const AppVersion._();

  /// The build name — the part of `version:` before the `+` separator.
  /// `null` when the manifest declares no version.
  static const String? buildName = appBuildName;

  /// The build number — the part of `version:` after the `+` separator.
  /// `null` when the manifest declares no build number.
  static const String? buildNumber = appBuildNumber;

  /// Placeholder rendered when the manifest declares no version.
  ///
  /// Deliberately non-numeric so an absent version is visibly absent
  /// rather than silently wrong (Invariant I2).
  static const String unavailable = 'tidak tersedia';

  /// The version to display, or [unavailable] when the manifest has none.
  static const String displayName = buildName ?? unavailable;

  /// The build number to display, or [unavailable] when the manifest has none.
  static const String displayBuildNumber = buildNumber ?? unavailable;
}
```

**Contract notes:**

| Property | Contract |
| :--- | :--- |
| Immutability | `final class` with a private constructor; all members `static const`. No instance state exists. |
| Nullability | `buildName` / `buildNumber` are `String?` (nullable), faithfully mirroring the SDK accessor. The `display*` members are non-nullable `String`. |
| Determinism | `const` throughout — the same binary always renders the same string. |
| Dependency direction | `lib/core/` → Flutter SDK only. Per `docs/ARCHITECTURE.md:214`, `lib/core/` must not import `data`/`domain`/`presentation`. Satisfied. |
| Domain purity | `lib/core/` is NOT `lib/domain/`. CON-006's "zero Flutter imports in `lib/domain/`" invariant is **untouched** — the new file lives in `lib/core/`, alongside the existing `lib/core/theme/` primitives. |

**Why a separate `lib/core/app_version.dart` rather than an inline constant in `about_section.dart`?**

1. **Testability seam.** REQ-002's guard test must assert the *rendered* value. Testing it through the widget is possible, but a dedicated, importable holder lets the test assert the value directly **and** through the widget, giving two independent assertions.
2. **Single-consumer discipline, future-proof.** The value is currently consumed only by `about_section.dart`. Extracting it to `lib/core/` costs one small file and gives any future version-displaying surface (ASSUMPTION-002) a canonical import path rather than an invitation to write a literal.
3. **Dependency-rule conformance.** `lib/core/` is the correct home for cross-cutting, framework-level primitives — exactly what `docs/ARCHITECTURE.md:214` describes ("Shared UI primitives | Flutter only").

> [!NOTE]
> **The `_AppInfo` class is retained, not deleted.** It remains the About-section-local holder for the *static copy* (app name, description, license, feature list, developer credit) — REQ-007 explicitly keeps that copy hand-maintained. Only its `version` and `buildNumber` members change: they are removed and replaced by reads from `AppVersion`.

### 4.3 API Error Contract, Idempotency & 5 UI States Matrix

**Error Contract:** Not applicable — there is no network call, no persistence write, and no failure mode that reaches the user as an error. The only abnormal condition is "manifest declares no version", handled deterministically by REQ-005.

**Idempotency & Pagination:** Not applicable — read-only, single-value surface.

**5 UI States Matrix (About section):**

The About section is a **fully static, read-only surface with no asynchronous data source**. Loading, Empty, Error, and Partial states therefore have no meaningful instantiation — the section renders its entire content synchronously in one frame.

| UI State | Behaviour | Rationale |
| :--- | :--- | :--- |
| **Loading** | **Not applicable.** The version source is a compile-time `const` — there is no pending future, no spinner, and no skeleton. The section renders at first frame with no intermediate state. | `app_version.dart:17,29` — `const`, evaluated at compile time. |
| **Empty** | **Not applicable.** The section always has content: app icon, name, version line, description, feature list, and developer card. There is no dataset that can be empty. | Static copy is unconditionally present. |
| **Error** | **Not applicable.** No operation can fail. The nearest condition is "manifest declares no version" (REQ-005), which renders the `tidak tersedia` placeholder in the normal Populated layout — **not** an error state, and **not** a full-screen error. | No exception path exists; `const` evaluation cannot fail. |
| **Partial** | **Not applicable.** All content is present or none; there is no progressive or paginated loading. | Single synchronous build. |
| **Populated** | The **only** reachable state. The section renders the app icon, the app name, the version line (`Versi <name> · Build <number> · GPL v3`), the description, the feature list, and the developer card. | The steady state for every user interaction with this section. |

**Accessibility & keyboard invariants (Populated state):**

| Invariant | Contract |
| :--- | :--- |
| **D-Pad scroll** | `arrowUp` / `arrowDown` scroll the section by a fixed `_scrollStep` of 120.0 logical pixels, clamped to `[0, maxScrollExtent]` `[VERIFIED: about_section.dart:63, 71-98]`. **REQ-006** requires this to remain unchanged. |
| **Focus** | The section's `Focus` widget uses `autofocus: true` so the D-Pad remote can scroll it immediately on entry `[VERIFIED: about_section.dart:102-104]`. |
| **Key event handling** | Only `KeyDownEvent` and `KeyRepeatEvent` are handled; all other event types return `KeyEventResult.ignored` `[VERIFIED: about_section.dart:72-73]`. |
| **Contrast / legibility** | Unchanged — the version line uses the existing `IslamicTypography.caption` + `IslamicColors.textMuted` tokens. No new colour or type token is introduced. |
| **WCAG 2.1 AA** | No new text semantics. *Measurable bound:* the corrected feature bullet is longer than the original, and the widget test MUST assert that it renders at the 1920×1080 baseline **without a `RenderFlex` overflow** — Flutter surfaces a layout overflow as a thrown error under `testWidgets`, so the assertion is a failing test rather than a visual inspection. The existing `Row` + `Expanded` layout is what makes the bound satisfiable; the bound itself is what proves it. |

### 4.4 Observability, Telemetry & SLIs (RED / USE Metrics)

**Structured Logging:** None introduced. The About section performs no I/O, no network call, and no state mutation — there is no event to log, and adding one would violate the offline-first and minimal-surface posture (CON-005).

**Metrics & Alerts:** None introduced. This is a static display surface, not a service.

> [!NOTE]
> **Existing telemetry is unaffected.** `lib/main.dart:99-104` already logs an app-open event to Firebase Analytics, and its own comment records that Firebase captures `app_version` automatically from the `versionName` originating in `pubspec.yaml`. This specification does not alter that path — it simply brings the **visible** surface into alignment with the same source the **telemetry** surface already uses.

---

## 5. Clean Architecture Seams & Component Boundaries

### 5.1 Architectural Pragmatism Check

**Declared scope: Local Presentation Change with a Core-Primitive Seam.**

This feature is a **static, read-only, single-value display fix** — not an enterprise core domain. Enforcing full 4-layer segregation (a domain entity, a use case, a port interface, and a data adapter for a compile-time string constant) would be pure ceremony and would violate the project's own stated pragmatism rule (`docs/ARCHITECTURE.md` and the AGENTS.md Architectural Pragmatism principle).

What **is** enforced, because it carries real architectural meaning:

- The **Dependency Rule** — the new `lib/core/app_version.dart` depends only on the Flutter SDK. It imports nothing from `lib/data/`, `lib/domain/`, or `lib/presentation/`.
- **Boundary purity** — the value crosses from the *build layer* into the *presentation layer* through exactly one named, importable seam (`AppVersion`). The presentation layer never restates the value.
- **Domain purity (CON-006)** — untouched. The new file is in `lib/core/`, not `lib/domain/`.

### 5.2 Layer Assignment

```text
Entities (Domain Layer)                       ← UNTOUCHED
   └── lib/domain/**                            No change. Zero Flutter imports preserved (CON-006).

Use Cases (Application Layer)                 ← UNTOUCHED
   └── lib/domain/usecases/**                  No change. The version is not domain behaviour.

Interface Adapters (Presenters)               ← MODIFIED (target of the fix)
   └── lib/presentation/pages/settings/sections/about_section.dart
         _AppInfo.version / .buildNumber  ──►  removed (hardcoded literals)
         _AppInfo.version / .buildNumber  ──►  read from AppVersion (new seam)
         features list item #3            ──►  '5 mode' corrected to
                                           '9 status tampilan otomatis: …'

Shared UI Primitives (Core)                   ← NEW FILE
   └── lib/core/app_version.dart
         AppVersion.buildName / .buildNumber   ← compile-time constants from the build manifest
         AppVersion.displayName / .displayBuildNumber
         AppVersion.unavailable                ← non-numeric fallback (Invariant I2)

Frameworks & Drivers                          ← UNTOUCHED
   └── package:flutter/services.dart           Flutter SDK (already a dependency — zero new deps)
```

### 5.3 Dependency Inversion Seams

```text
┌─────────────────────────────────────────────────────────────────┐
│ BUILD LAYER (compile time)                                     │
│   pubspec.yaml:19  version: 1.4.4+15                          │
│        │                                                        │
│        ▼  flutter tool → dart-define → compile-time constant   │
│   package:flutter/services.dart                                │
│   (app_version.dart:17,29 — appBuildName / appBuildNumber)    │
└────────────────────────┬────────────────────────────────────────┘
                         │  one-way, compile-time, no runtime coupling
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ CORE LAYER — lib/core/app_version.dart  (NEW)                  │
│   AppVersion.buildName / .buildNumber / .displayName / ...      │
│   Dependency: Flutter SDK only. No inward-outward violation.   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER — about_section.dart  (MODIFIED)             │
│   _AppInfo.version    → AppVersion.displayName                  │
│   _AppInfo.buildNumber → AppVersion.displayBuildNumber          │
│   features list       → nine canonical Display State names,     │
│                        '9 status tampilan otomatis: …' (§2.1)   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ TEST LAYER — test/analysis/app_version_consistency_test.dart    │
│   (NEW)  parses pubspec.yaml from disk and asserts the          │
│   rendered About values equal the manifest values; plus the     │
│   structural anti-regression scan — no presentation-layer file  │
│   may declare a version / buildNumber display constant         │
│   (AC-011).                                                     │
└─────────────────────────────────────────────────────────────────┘
```

**Direction check:** dependencies point **inward and downward** — presentation → core → framework. No layer reaches back toward an outer layer. `lib/core/` gains no dependency on `lib/presentation/` or `lib/domain/`, preserving `docs/ARCHITECTURE.md:214`.

### 5.4 File Change Set (Surgical — CON-009)

| # | File | Action | Size | Rationale |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `lib/core/app_version.dart` | **CREATE** | XS (1 file) | The new seam. `AppVersion` value holder over `appBuildName`/`appBuildNumber`. |
| 2 | `lib/presentation/pages/settings/sections/about_section.dart` | **MODIFY** | XS (1 file) | Remove the two hardcoded literals; import `AppVersion`; correct the "5 mode" copy to the nine-state bullet. |
| 3 | `test/analysis/app_version_consistency_test.dart` | **CREATE** | S (1 file) | The guard test: parses `pubspec.yaml`, asserts the rendered About values match the manifest. |
| 4 | `test/presentation/pages/settings/sections/about_section_test.dart` | **CREATE** | S (1 file) | Widget test: asserts the About screen renders the manifest version and the corrected nine-state copy, and does NOT render the stale "5 mode" string. |
| 5 | `docs/ARCHITECTURE.md` | **MODIFY** | XS (1 file) | Living Architecture Map Mandate: record the new `lib/core/app_version.dart` seam in the topology (§2) and the version source of truth. |
| 6 | `CONTEXT.md` | **MODIFY** | XS (1 file) | Glossary amendment (§2.2): add the **Sholat** term so all nine Display States are named and `REQ-004` / `AC-006` are literally satisfiable. **Already executed 2026-10-23** — the term sits at `CONTEXT.md:21-23`. |

**Total: 6 files, 2 created, 4 modified.** Task sizing: **S** (comfortably under the M threshold; no task may exceed L per the project standard). File #6 is already complete; the implementation phase therefore touches 5 files.

**Explicitly NOT touched:** `pubspec.yaml` (no dependency change — CON-001), `android/settings.gradle.kts`, `android/gradle/wrapper/gradle-wrapper.properties`, `android/app/build.gradle.kts` (CON-009), `landingpage/panduan.html` (deferred — `[ASSUMPTION-005]`), `lib/domain/**` (CON-006).

> [!NOTE]
> **`CONTEXT.md` is now in scope.** It was previously listed here as explicitly not touched, under the (now-retracted) assumption that "Sholat" would remain an undefined glossary term. Owner decision of 2026-10-23 moved it into the change set as file #6 — see §2.2 and `[ASSUMPTION-006]`.

---

## 6. Acceptance Criteria (Given-When-Then)

### 6.1 Acceptance Criteria

- **AC-001 (Happy Path — REQ-001, REQ-002):**
  *Given* a build whose `pubspec.yaml` declares `version: 1.4.4+15`,  
  *When* the About section renders,  
  *Then* the rendered version line reads `Versi 1.4.4  ·  Build 15  ·  GPL v3`, with the version and build number sourced from `AppVersion.displayName` / `AppVersion.displayBuildNumber`, and **no** numeric version literal appears anywhere in `lib/presentation/pages/settings/sections/about_section.dart`.

- **AC-002 (Manifest-Parity Invariant — REQ-002):**
  *Given* the repository's `pubspec.yaml` at test time, whose `version:` field parses to a name and a build number,  
  *When* the guard test executes,  
  *Then* `AppVersion.displayName` and `AppVersion.displayBuildNumber` are asserted equal to the parsed manifest values — and the test **fails** if they differ.  
  *Procedure:* the guard test asserts the **`AppVersion` constants directly**. This *is* the manifest-parity oracle, and it requires **no widget pump**. The **rendered** version line is asserted separately, by the widget test (`AC-001`, `AC-005`), so the two seams stay independent and neither duplicates the other.

- **AC-003 (Absent Manifest Version — REQ-005, Invariant I2):**
  *Given* a build in which the manifest declares no version (so `appBuildName` is `null`),  
  *When* the About section renders,  
  *Then* the version and build fields display the non-numeric placeholder `tidak tersedia`, the section still renders its complete layout, and **no** numeric version string is presented as if it were the real version.

- **AC-004 (Build-Override Correctness — REQ-001):**
  *Given* the widget test suite executed with `--dart-define=FLUTTER_BUILD_NAME=9.9.9 --dart-define=FLUTTER_BUILD_NUMBER=99`, overriding the manifest's `1.4.4` / `15`,  
  *When* the About section renders,  
  *Then* the rendered version line reads `Versi 9.9.9  ·  Build 99  ·  GPL v3` — the **overridden** values, not the manifest's — proving the displayed value is a genuine property of the compiled artifact rather than a restatement of the file.  
  *Procedure:* `flutter test --dart-define=FLUTTER_BUILD_NAME=9.9.9 --dart-define=FLUTTER_BUILD_NUMBER=99 test/presentation/pages/settings/sections/about_section_test.dart`. Device-free, no new tooling, `check:fast`-grade.  
  *Scope limit:* this criterion proves the **define → rendered-UI** path. The **release-AOT** path carries no empirical version-parity evidence — see the `[!CAUTION]` in §1.2 for the accepted residual risk and its release-gate mitigation hook.

- **AC-005 (Display-State Copy Correction — REQ-003):**
  *Given* the About section's feature list,  
  *When* it renders,  
  *Then* the Display State feature bullet reads exactly `9 status tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → Sholat → Slideshow Announcement → Imam Schedule → Wisdom Quote → Midnight Standby` — stating the count **nine** and naming all nine canonical states — and the strings `5 mode tampilan otomatis` and `9 mode tampilan otomatis` **do not** appear anywhere in the rendered output.

- **AC-006 (Terminology Conformance — REQ-004):**
  *Given* the corrected Display State bullet,  
  *When* it is inspected,  
  *Then* every state name it contains is a canonical term from `CONTEXT.md` (Standby, Pre-Adzan, Adzan, Iqomah, Sholat, Slideshow Announcement, Imam Schedule, Wisdom Quote, Midnight Standby), and none of their `_Avoid_` synonyms (e.g. "carousel", "quote rotation", "sleep mode", "pre-adhan", "Azan", "Iqama", "salat") appears. The bullet's descriptive clause uses **"status tampilan otomatis"** — **not** "mode tampilan otomatis", whose "mode" is the Indonesian rendering of the rejected synonym "screen mode" (`CONTEXT.md:55-57`).

- **AC-007 (D-Pad Navigation Invariance — REQ-006):**
  *Given* the About section rendered at 1920×1080 with content exceeding the viewport height,  
  *When* `arrowDown` then `arrowUp` key events are dispatched,  
  *Then* the scroll offset changes by exactly `_scrollStep` (120.0) in the respective direction, clamped to `[0, maxScrollExtent]`, and the version line remains rendered and correct after scrolling.

- **AC-008 (No New Dependency — CON-001):**
  *Given* the `pubspec.yaml` file after the change,  
  *When* its `dependencies:` block is inspected,  
  *Then* it contains **no** new entry relative to the pre-change baseline — the implementation relies solely on `package:flutter/services.dart` from the Flutter SDK.

- **AC-009 (Analyzer Ratchet — CON-003):**
  *Given* the modified `lib/` and `test/` trees,  
  *When* `dart analyze lib test` runs,  
  *Then* it reports **0 errors, 0 warnings, and ≤ 4 infos** — no growth beyond the measured baseline. *Scope note:* this is the **`lib`/`test`-scoped** measurement, which currently reports 0 warnings; the single warning permitted by the ratchet (`docs/ARCHITECTURE.md:274`, floor `≤ 1`) lives in `tools/replace_opacity.dart` and is outside this scope (`docs/ARCHITECTURE.md:333`). No threshold is changed by this specification.

- **AC-010 (Test Suite Ratchet — CON-004):**
  *Given* the full test suite,  
  *When* `flutter test` runs,  
  *Then* every test passes with **zero failures**, and the total passing count is **≥ 535** (the pre-change baseline) — the count ratchets up by the number of newly added tests.

- **AC-011 (Anti-Regression — No Re-Introduced Literal — REQ-001, REQ-002):**
  *Given* the source tree under `lib/presentation/`,  
  *When* it is scanned for a re-introduced hand-maintained version or build-number literal,  
  *Then* **no** presentation-layer file declares a `version` or `buildNumber` string constant used for display, and every version-displaying surface reads from `AppVersion` — so the original defect class cannot silently return. The scan MUST fail loudly (not skip) if the scan itself cannot execute.

  > [!IMPORTANT]
  > **Why a structural assertion, not a literal-shape regex.** The original defect shipped **two** coupled literals — `version = '1.2.2'` *and* `buildNumber = '5'`. A `<digits>.<digits>.<digits>` pattern matches the first and **cannot** match a bare build number such as `'15'`; a regression that re-introduced `static const String buildNumber = '15';` — the second half of the shipped defect — would pass such a scan silently. Asserting on the **absence of the members** (and on the presence of the `AppVersion` import) is strictly stronger, is immune to the "is `'15'` a version or a build number?" ambiguity, and covers both halves of the defect class by construction rather than by pattern-matching.

- **AC-012 (Formatting — CON-008):**
  *Given* the modified `lib/` and `test/` trees,  
  *When* `dart format --output=none --set-exit-if-changed lib test` runs,  
  *Then* it reports no newly unformatted files relative to the baseline of ≤ 16.

- **AC-013 (APK Size Ratchet — CON-002):**
  *Given* a release build (`flutter build apk --release --target-platform android-arm64`),  
  *When* the artifact size is measured,  
  *Then* it **does not grow beyond** **41.24 MB (43,240,043 bytes)** — this is the binding condition, and it matches the ratchet's own wording (*"Must not grow"*, `docs/ARCHITECTURE.md:282`). The delta is **expected to be ≈ 0 bytes** since no dependency was added; it is deliberately **not** asserted to be *exactly* 0, because inlining a dart-define shifts the Dart snapshot's const pool and string table, and the measurement cannot resolve a single byte.  
  *Release-gate step:* this build is also the point at which the artifact's version is re-confirmed by inspection — see the `[!CAUTION]` in §1.2.

- **AC-014 (Partial Manifest Version — REQ-005):**
  *Given* a manifest declaring `version: 1.4.4` with **no** `+` segment — so `appBuildName` is `1.4.4` while `appBuildNumber` is `null`,  
  *When* the About section renders,  
  *Then* the version field renders `1.4.4` and the build field renders the non-numeric placeholder `tidak tersedia`: the two fields degrade **independently**, and the absence of a build number does not suppress the version.  
  *Procedure:* the guard test's manifest parser splits on the **first** `+` only, and MUST yield a null build number **without throwing** when no `+` is present. The case is asserted explicitly because `AppVersion.buildName` and `AppVersion.buildNumber` are independent nullable fields — the mixed state is representable, reachable, and would otherwise be asserted by no criterion.

### 6.2 Value Sourcing & Positive Input Coverage Table

*Every value the feature produces or displays in AC-001…AC-014 MUST have an explicit named source.*

| Required Output / Computed / Displayed Value | AC Ref | Named Source | Boundary / Edge Variation |
| :--- | :---: | :--- | :--- |
| Displayed version name (`1.4.4`) | `AC-001`, `AC-002` | `AppVersion.displayName` → `AppVersion.buildName` → `appBuildName` → dart-define `FLUTTER_BUILD_NAME` → `pubspec.yaml:19` `version:` field (pre-`+` segment) | Manifest absent → `null` → `AppVersion.unavailable` (`AC-003`); `--build-name` override (`AC-004`) |
| Displayed build number (`15`) | `AC-001`, `AC-002` | `AppVersion.displayBuildNumber` → `AppVersion.buildNumber` → `appBuildNumber` → dart-define `FLUTTER_BUILD_NUMBER` → `pubspec.yaml:19` `version:` field (post-`+` segment) | Manifest without build number → `null` → `AppVersion.unavailable` (`AC-003`); `--build-number` override (`AC-004`) |
| Manifest version parsed by the guard test | `AC-002` | `File('pubspec.yaml').readAsLinesSync()` → first line starting with `version:` → split on `+` `[VERIFIED: feasibility spike — CWD = project root, line = 'version: 1.4.4+15']` | Multi-digit build number; build number absent (no `+`) → name-only parse |
| Rendered version line | `AC-001` | `about_section.dart:163` template — `'Versi ${...}  ·  Build ${...}  ·  ${_AppInfo.license}'`, with the two interpolated values replaced by `AppVersion` reads | `license` remains a static constant (REQ-007) |
| Display State count in feature copy | `AC-005` | `CONTEXT.md:55-57` — *"One of the nine automatic screen modes"*; cross-checked against `lib/domain/entities/display_state_type.dart:2-29` (9 enum values) | Any future addition/removal of a `DisplayStateType` value invalidates the copy → the count must be re-derived from the enum |
| Display State names in feature copy | `AC-005`, `AC-006` | `lib/domain/entities/display_state_type.dart:2-29` enum member names, rendered in canonical Indonesian as defined in `CONTEXT.md` | `_Avoid_` synonyms forbidden (AC-006) |
| Scroll step | `AC-007` | `about_section.dart:63` — `static const double _scrollStep = 120.0;` | Clamped at both ends of `[0, maxScrollExtent]` |
| App name / description / license / developer credit | `AC-001` | `_AppInfo.appName` / `.description` / `.license` / `.developerName` — static copy, unchanged (REQ-007) | N/A — not build-derived |
| Fallback placeholder text | `AC-003`, `AC-014` | `AppVersion.unavailable` = `'tidak tersedia'` | Must be non-numeric (Invariant I2) |
| Displayed build number when the manifest declares **no build number** | `AC-003`, `AC-014` | `AppVersion.displayBuildNumber` → `AppVersion.buildNumber` → `appBuildNumber` → dart-define `FLUTTER_BUILD_NUMBER` → **absent** `+` segment in `pubspec.yaml:19` | Manifest declares `version: 1.4.4` with no `+` → `buildNumber` is `null` → `AppVersion.unavailable`; the **version** field is unaffected (`AC-014`) |
| APK size | `AC-013` | `flutter build apk --release --target-platform android-arm64` artifact measurement | arm64 baseline 41.24 MB `[VERIFIED: docs/ARCHITECTURE.md:282]` |
| Analyzer findings | `AC-009` | `dart analyze lib test` | Baseline 0 errors / 0 warnings / 4 infos |
| Passing test count | `AC-010` | `flutter test` | Baseline 535 / 59 files `[VERIFIED: docs/ARCHITECTURE.md:276]` |
| Presentation-layer version literals | `AC-011` | Structural source scan over `lib/presentation/**`: no file may declare a `version` / `buildNumber` string constant for display; every version-displaying surface must import `AppVersion` | Must fail loudly if the scan cannot execute; must not skip; covers **both** the version and the build-number halves of the defect class |

---

## 7. Testing Strategy & Dimensional Bounds

**Testing Seam:** Three complementary seams, deliberately — two observe the **running application**, one analyses the **source statically**. The third is a genuinely different verification kind, which is why it is named separately rather than folded into the manifest seam.

| Seam | Test file | Asserts |
| :--- | :--- | :--- |
| **Manifest-level invariant** | `test/analysis/app_version_consistency_test.dart` | The values the app renders equal the values parsed from `pubspec.yaml` on disk. This is the **regression guard** for the original defect: it fails if a hardcoded literal is re-introduced, and it fails if the Flutter toolchain stops injecting the define (H3). |
| **Widget-level behaviour** | `test/presentation/pages/settings/sections/about_section_test.dart` | The About screen renders the correct version line, the corrected nine-state copy (`9 status tampilan otomatis: …`), and the stale "5 mode" string is absent; D-Pad scroll still works (AC-007). |
| **Structural anti-regression scan** | `test/analysis/app_version_consistency_test.dart` (same file, additional case) | No presentation-layer file declares a `version` / `buildNumber` display constant, and every version-displaying surface imports `AppVersion` (AC-011). |

**Verification loci for the criteria that need more than a default test run.** Most criteria are satisfied by a plain `flutter test` invocation. **AC-004** needs a **dart-define override**, **AC-014** needs a **specific test file**, and **AC-013** needs a **build invocation**:

| Criterion | Verification locus | Command | Pass condition |
| :--- | :--- | :--- | :--- |
| **AC-004** — build-override correctness | Phase 3 `check:fast` / `check:task` (**a `flutter test` case**, run with a dart-define override) | `flutter test --dart-define=FLUTTER_BUILD_NAME=9.9.9 --dart-define=FLUTTER_BUILD_NUMBER=99 test/presentation/pages/settings/sections/about_section_test.dart` | The About screen renders `9.9.9` / `99`, not the manifest's `1.4.4` / `15` — proving the displayed value is a property of the compiled define, not a restatement of the file. *Scope limit:* the release-AOT path is **not** covered by this criterion — see the `[!CAUTION]` in §1.2 |
| **AC-014** — partial manifest version | Phase 3 `check:task` (**a `flutter test` case**) | `flutter test test/analysis/app_version_consistency_test.dart` | The guard test's parser yields a **null** build number for a manifest with no `+`, **without throwing**; the rendered version field is unaffected while the build field renders `tidak tersedia` |
| **AC-013** — APK size ratchet | Phase 3 `check:full` (**not** a `flutter test` case — requires a build invocation) | `flutter build apk --release --target-platform android-arm64` | Artifact size ≤ **41.24 MB (43,240,043 bytes)**; must not grow. *Release-gate step:* the artifact's version is re-confirmed by inspection here — see the `[!CAUTION]` in §1.2 |
| **AC-009** — analyzer ratchet | Phase 3 `check:fast` | `dart analyze lib test` | 0 errors / 0 warnings / ≤ 4 infos (see the scope note on AC-009) |
| **AC-012** — formatting ratchet | Phase 3 `check:fast` | `dart format --output=none --set-exit-if-changed lib test` | No newly unformatted files (baseline ≤ 16) |
| **AC-010** — test suite ratchet | Phase 3 `check:full` | `flutter test` | Zero failures, passing count ≥ 535 |

> [!NOTE]
> **Why the guard test parses the manifest instead of comparing `AppVersion.buildName` to `appBuildName`.** Comparing two app-internal constants is self-referential: it would pass even if the Flutter toolchain stopped injecting the define, because both sides would read `null`. Parsing `pubspec.yaml` from disk introduces an **external** oracle, so the test genuinely detects both failure modes (H1 and H3).

**Dimension Checks:**

| Dimension | Contract |
| :--- | :--- |
| **Version format** | `name` is `major.minor.patch` (e.g. `1.4.4`); `buildNumber` is a non-negative integer (e.g. `15`). The manifest field is `name+buildNumber`. The parse splits on the **first** `+` only. |
| **Separator semantics** | `+` separates name from build number — it is **not** a semantic-versioning pre-release marker. `1.4.4+15` ⇒ name `1.4.4`, build `15`. |
| **Numeric vs. non-numeric** | `displayName` / `displayBuildNumber` are non-nullable `String`, but MAY hold the non-numeric `unavailable` placeholder. Any consumer MUST NOT assume numeric parseability. |
| **Locale** | Version strings are **locale-invariant** — the manifest format is fixed ASCII and MUST NOT be passed through `intl` formatting or localized. The surrounding UI text is Indonesian, but the version itself is not translated. |
| **Timezone** | Not applicable — no temporal value is displayed. |
| **Currency** | Not applicable. |
| **Tenant** | Not applicable — a single-tenant on-premise deployment. |
| **Null** | Covered by AC-003 (`appBuildName == null` → `unavailable`). |

**Extreme Limiting Cases (Specialization):**

| Case | Expected behaviour |
| :--- | :--- |
| `pubspec.yaml` declares `version: 1.4.4` (no `+` segment) | `buildNumber` is `null` → renders `tidak tersedia` for the build field; the version field still renders `1.4.4`. The guard test's parser must handle a missing `+` without throwing. *(Asserted by `AC-014`.)* |
| `pubspec.yaml` declares no `version:` key at all | `appBuildName` is `null` → both fields render `tidak tersedia`. The guard test's parser must handle a missing line without throwing. *(Asserted by `AC-003`.)* |
| Build number with multiple digits (e.g. `+150`) | Parsed and rendered verbatim; no integer overflow or truncation. |
| Very large build number | Rendered as an opaque string; no numeric conversion is performed anywhere in the implementation. |
| `pubspec.yaml` unreachable from the test CWD | The guard test fails **loudly** with an explicit message rather than silently passing. It MUST NOT skip. |
| About section rendered on a viewport shorter than its content | Scroll offset clamps at `maxScrollExtent`; the version line remains correct and reachable (AC-007). |

> [!CAUTION]
> **A skipped or self-satisfying guard test is worse than no guard test.** The guard test MUST fail (not skip) when `pubspec.yaml` cannot be read, and MUST compare against the parsed manifest rather than against `AppVersion`'s own fields. This is the Floor-Guard requirement in CON-007 applied to the very artifact that enforces the Floor-Guard.

---

## 8. Architectural Decision Records (ADRs)

**No ADR is required.** The Triple-Gate test from the project standard fails on two of three criteria:

1. *Hard to reverse?* — **No.** Replacing two hardcoded string literals with two compile-time constants is a routine, fully reversible refactor.
2. *Surprising without context?* — **No.** `appBuildName` / `appBuildNumber` are the canonical Flutter idiom, documented in the SDK itself (`app_version.dart:5-16`).
3. *Real trade-off?* — **Yes**, but a single one (compile-time truth vs. runtime truth), and it was settled during Discovery — not a durable architectural commitment.

**Existing ADRs are unaffected:** `docs/adr/0001-kemenag-sihat-prayer-times.md` and `docs/adr/0002-pure-dart-astronomy-in-domain.md` both concern the prayer-time domain, which this specification does not touch.

> [!NOTE]
> **`docs/ARCHITECTURE.md` update (mandated).** Under the project's Living Architecture Map Mandate, the implementation MUST record in `docs/ARCHITECTURE.md`: (a) the new `lib/core/app_version.dart` seam in the `lib/` topology (§2 of that document), and (b) the fact that `pubspec.yaml` is the single source of truth for the version surfaced in-app, resolved via `AppVersion`. This is file #5 in the change set (§5.4).

---

## 9. Traceability Matrix

| Requirement | Discovery Ref | Acceptance Criteria | Planned File(s) |
| :--- | :--- | :--- | :--- |
| `REQ-001` Single-Source Version Display | §3.7 Flutter-Native Accessor; §4 Option B2 | `AC-001`, `AC-004`, `AC-008`, `AC-011` | `lib/core/app_version.dart`, `about_section.dart` |
| `REQ-002` Manifest-Parity Invariant | §4 Option C (guard test) | `AC-002`, `AC-011` | `test/analysis/app_version_consistency_test.dart` |
| `REQ-003` Display-State Copy Correction | §3.4 Second Finding | `AC-005` | `about_section.dart`, `about_section_test.dart` |
| `REQ-004` Terminology Conformance | §2.1 Canonical Enumeration; §2.2 Glossary Amendment; `CONTEXT.md:55-57` | `AC-006` | `CONTEXT.md`, `about_section.dart`, `about_section_test.dart` |
| `REQ-005` Graceful Degradation | §5 Unknown 3 / §1.5 H2 | `AC-003`, `AC-014` | `lib/core/app_version.dart`, `about_section.dart` |
| `REQ-006` D-Pad Navigation Invariance | §5 Unknown 2 | `AC-007` | `about_section_test.dart` |
| `REQ-007` Static Artifact Concession | §3.2 (static copy remains hand-maintained) | `AC-001` | `about_section.dart` |
| `CON-001` Zero New Runtime Dependency | §4 Option B2 (no new dependency) | `AC-008` | `pubspec.yaml` (unchanged) |
| `CON-002` APK Size Ratchet | §2 Conditions | `AC-013` | build pipeline (unchanged) |
| `CON-003` Analyzer Ratchet | `docs/ARCHITECTURE.md:273-275` | `AC-009` | all changed files |
| `CON-004` Test Count Ratchet | `docs/ARCHITECTURE.md:276` | `AC-010` | new test files |
| `CON-005` Offline-First | §2 Conditions | `AC-001`…`AC-007`, `AC-014` | all changed files |
| `CON-006` Domain Purity | `docs/ARCHITECTURE.md:214, 279` | `AC-009` | `lib/core/app_version.dart` (not in `lib/domain/`) |
| `CON-007` Floor-Guard | `docs/ARCHITECTURE.md:248-252` | `AC-009`, `AC-010`, `AC-011` | all changed files |
| `CON-008` Formatting | `docs/ARCHITECTURE.md:277` | `AC-012` | all changed files |
| `CON-009` Surgical Edit | §3.8 Scope Fence; `[ASSUMPTION-004]` | `AC-008` (no `pubspec.yaml` change) | file set §5.4 only |

**Assumption coverage:** `[ASSUMPTION-001]` → `AC-005` (owner-confirmed 2026-10-23 — single bullet, nine names, canonical order); `[ASSUMPTION-002]` → `REQ-001` scope + `AC-002` + `AC-011` (structural anti-regression scan); `[ASSUMPTION-003]` → `AC-001`/`AC-003`/`AC-014`; `[ASSUMPTION-004]` → `CON-009`, `AC-008`; `[ASSUMPTION-005]` → Non-Goals §1.1 (`[Assumed / Auto-Resolved]` — Option A, deferred out of scope); `[ASSUMPTION-006]` → `AC-006`, §2.1, §2.2 (owner-confirmed 2026-10-23 — "Sholat" added to `CONTEXT.md`). **All six assumptions map to at least one acceptance criterion or an explicit scope fence. No assumption remains open.**

**Acceptance-criterion coverage:** 14 acceptance criteria (`AC-001`…`AC-014`) across 7 requirements and 9 constraints; every criterion is bound to a command and a pass condition in §7, and every displayed value has a named source in §6.2. **One residual risk is recorded and owned, not eliminated** — the release-AOT path carries no empirical version-parity evidence (owner decision, 2026-10-23; see the `[!CAUTION]` in §1.2 and its release-gate mitigation hook in `AC-013`).
