# 🔭 Project Discovery Draft: About Page Version Drift & Single-Source-of-Truth Enforcement

**Document Type:** Phase 0 Discovery Draft
**Target Repository:** `sadayana-masjid-tv` (Miqotul Khoir TV / MKT)
**Status:** **Draft — Owner Decision Recorded (Option B, Flutter-native variant)**
**Architect:** Veteran Principal Fullstack Engineer
**Date:** 2026-10-22
**Owner Decision:** Option B selected — single source of truth for the displayed version.

---
<!-- markdownlint-disable-->

## 1. Problem Statement & Business Opportunity (Getting Acquainted)

*Pólya Heuristic: Familiarity and Conception (Pólya, 1945, p. 33). Understand the problem as a whole, its primary purpose, and its overarching value.*

- **The Problem:** The "Tentang Aplikasi" section renders a hardcoded version literal that is **6 releases behind** the real build version. The shipped APK is `1.4.4+15`; the settings screen tells mosque operators the app is `1.2.2 (build 5)`.
- **Business Value & Why Now:** The app is published on Google Play as `gulajava.mini.miqotul_khoir_tv`. A mismatch between the in-app About screen and the Play Store listing is a **trust and supportability defect**: a DKM administrator reporting a bug ("the app says 1.2.2 but Play says 1.4.4") creates an unexplainable discrepancy for both the operator and the maintainer. Fixing this is also a prerequisite for the currently-uncommitted `1.4.4+15` release.
- **Target Persona & Users:** DKM administrators (primary operators who open Settings → Tentang Aplikasi to check what build they are running before raising a support ticket) and the end user via the Play Store listing.

### 1.1 Premise Critique & Failure Inversion

*The question was framed as "is the version on the About page consistent with `pubspec.yaml`?" — a solution-shaped question. The underlying problem is larger than the answer.*

- **Problem vs. Solution:** The observable symptom is a wrong string. The actual defect is **structural**: the version number exists in **three independent, unenforced copies** (§3.2), so drift is not a bug that was introduced — it is the **guaranteed default state** of the design. Correcting the literal without adding a mechanism guarantees recurrence at the next release.
- **Inversion ("Why might this fail?"):** If we hardcode `1.4.4`/`15` and ship, the next version bump re-creates the defect. This is not speculative — **empirically, 6 consecutive releases already drifted** (§3.3). The failure mode is not "we forgot once"; it is "the design makes forgetting invisible."
- **Simpler Alternative (20% effort / 80% value):** ✅ **DELIVERED — and it turned out to be the *entire* solution.** Option B2 (§3.7) requires **one import and two constant substitutions**: no new dependency, no AGP/Gradle/Kotlin change, no async loading, no APK-size impact. The "20% version" was not a compromise — it was strictly better than the version originally under consideration.

---

## 2. The Unknown, Known Data, and Operational Bounds

*Pólya Heuristic: Isolate the principal parts of the problem: What is the unknown? What are the data? What is the condition?*

| Element | Description |
| :--- | :--- |
| **The Unknown** | Which layer shall become the **authoritative source of truth** for the version string presented to the user, and by what mechanism is drift made **structurally impossible** (or at minimum, mechanically detectable before release)? |
| **Known Data** | `pubspec.yaml` (`version: 1.4.4+15`, working tree) · `android/app/build.gradle.kts` (`versionCode = flutter.versionCode`, `versionName = flutter.versionName`) · `lib/presentation/pages/settings/sections/about_section.dart` (hardcoded `_AppInfo.version` / `.buildNumber`) · `landingpage/panduan.html` (hardcoded `1.2.2 (build 5)`) · `docs/ARCHITECTURE.md` §1.2 (hardcoded `1.4.3+14`) · Flutter 3.47.6 / Dart 3.13.5 · AGP 8.11.1, Gradle 8.14, Kotlin 2.2.20 · 59 test files / 535 tests, no CI runner checked in (§7 of ARCHITECTURE.md) |
| **The Conditions & Invariants** | The app is **100% offline / Luring** — no network call may be introduced on this screen. `compileSdk`/`targetSdk` were just raised to `37` and `minSdk` is `24`. APK size ratchet floor is **41.24 MB** (§8.3) — a new plugin must not regress it. Zero-suppression and zero-test-weakening Floor-Guard rules apply. Android TV D-Pad navigation must remain intact (the section is scroll-driven via `KeyEventResult`). |

---

## 3. Codebase Exploration & Architectural Critique

*Pólya Heuristic: Decomposing and Recombining (p. 75) & Analogy (p. 37). Examine existing components, critique architectural debt, and look for analogous solutions.*

### 3.1 Existing Topography Analysis

**Relevant Directories & Modules:**

- `lib/presentation/pages/settings/sections/about_section.dart` — the Settings section in question. Self-contained, read-only `StatefulWidget`; a private `_AppInfo` class holds all static copy (name, version, build, license, description, feature list). Rendered at line 163 as `Versi ${_AppInfo.version} · Build ${_AppInfo.buildNumber} · ${_AppInfo.license}`.
- `lib/presentation/pages/settings/settings_menu_page.dart:69` — mounts `AboutSection()` as one of 15 settings categories.
- `android/app/build.gradle.kts:45-46` — `versionCode = flutter.versionCode` / `versionName = flutter.versionName`. These are injected by the Flutter Gradle plugin from `local.properties`, which `flutter build` writes from `pubspec.yaml`'s `version:` field. **The Android manifest version is therefore always correct and already derives from `pubspec.yaml`.**
- `lib/main.dart:99-100` — an explicit comment confirming the same fact for analytics: *"Firebase Analytics sudah mencatat app_version otomatis dari versionName di pubspec.yaml."* Firebase already consumes `pubspec.yaml` as the source of truth without any manual step.

**Architectural Debt & Seam Vulnerabilities:**

1. **Duplicated source of truth without an enforcement seam.** `pubspec.yaml` is authoritative for *what gets built*; `_AppInfo.version` is authoritative for *what gets displayed*. Nothing links them. `package_info_plus` is **not** a dependency of this project (`grep package_info|PackageInfo` across `lib/`, `pubspec.yaml` → no matches), so the Dart layer currently has **no runtime access** to the installed package version.
2. **The same defect exists outside the About page** (§3.2) — meaning even a "correct" About page would leave the repository self-contradictory.
3. **Zero test coverage for the About section.** `test/presentation/pages/settings/sections/` contains only `alert_settings_section_test.dart`; there is no `about_section_test.dart`. No assertion anywhere compares the displayed version to `pubspec.yaml`.
4. **The About page's feature copy is stale in a second, independent way** — see §3.4.

### 3.2 The Three Unenforced Copies of the Version Number

| # | Location | Declared value | State |
| :--- | :--- | :--- | :--- |
| 1 | `pubspec.yaml:19` | `1.4.4+15` | **Authoritative** (working tree, uncommitted; HEAD is `1.4.3+14`) |
| 2 | `lib/presentation/pages/settings/sections/about_section.dart:17-18` | `1.2.2` / `5` | **Stale — 6 releases behind** |
| 3 | `landingpage/panduan.html:3254` | `1.2.2` (build 5) | **Stale — same 6 releases behind** |
| 4 | `docs/ARCHITECTURE.md:22` | `1.4.3+14` | Matches HEAD; will go stale on commit of `1.4.4+15` |

> [!NOTE]
> Copies 2 and 3 are *user-visible*. Copy 4 is *maintainer-visible*. Only copy 1 is enforced by the build system — which is precisely why the other three decay silently.

### 3.3 Drift Timeline — The Failure Is Empirical, Not Hypothetical

| Date | Commit | `pubspec.yaml` | About page updated? |
| :--- | :--- | :--- | :--- |
| 2026-03-27 | `de57026` | `1.2.2+5` | ✅ **Yes** — last sync |
| — | `805da60` | `1.2.4+7` | ❌ |
| — | `677a69c` | `1.4.0+10` | ❌ |
| — | `c1f3fdb` | `1.4.1+11` | ❌ |
| — | `42d515d` | `1.4.2+12` | ❌ |
| — | `3de364e` | `1.4.3+14` | ❌ |
| 2026-10-22 | *uncommitted* | `1.4.4+15` | ❌ |

**Six consecutive version bumps, zero About-page updates, ~7 months.** No reviewer, linter, or test flagged it. This is the signature of a **missing invariant check**, not of carelessness.

### 3.4 Second Finding — Feature Copy Contradicts the Implementation

While validating the About page's other claims, one more inconsistency surfaced. `about_section.dart:35` advertises:

> `'5 mode tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → Sholat'`

But `lib/domain/entities/display_state_type.dart:2-29` defines **nine** `DisplayStateType` values: `standby`, `preAdzan`, `adzan`, `iqomah`, `sholat`, `slideshowAnnouncement`, `imamSchedule`, `wisdomQuote`, `midnightStandby`. `docs/ARCHITECTURE.md:20` and `:181` both document the **9-state** model, and `:336` explicitly records that the *previous* 5-state description was corrected as outdated. The About page is a **surviving instance of that already-resolved 5-state inaccuracy**, now applied to user-facing copy rather than internal docs.

> [!WARNING]
> [ASSUMPTION-001]: The About page's `5 mode` claim is treated as a **copy defect to be corrected to 9**, not as an intentional user-facing simplification. Rationale: `ARCHITECTURE.md:336` already ruled the 5-state description obsolete, and the app ships Slideshow / Imam Schedule / Wisdom Quote / Midnight Standby features that are reachable from the main display. Default boundary: if the owner prefers a simplified marketing list, this item is downgraded to "leave as-is" — but then the string must not claim to enumerate the display modes.

**Verified as accurate** (checked, not assumed):
- `'Database 514 kota & 34 provinsi Indonesia'` — **confirmed accurate** by parsing `assets/data/cities.json` (514 city records, 34 distinct `province_name` values).
- `'7 waktu sholat: Subuh, Syuruq, Dhuha, Dzuhur, Ashar, Maghrib, Isya'` — **confirmed accurate** against `lib/domain/entities/daily_prayer_times.dart:54-61`.
- `'Koreksi ketinggian tempat (DPL/Elevasi)'` — **confirmed accurate**; `cities.json` carries an `elevation` key per record.
- `'Kalkulasi waktu sholat 100% offline — standar Kemenag RI (SIHAT)'` — consistent with ADR-0001 and `ARCHITECTURE.md:20`.
- `license = 'GPL v3'` — consistent with `ARCHITECTURE.md:22` (GPL-3.0).

### 3.5 Analogous Solutions & Prior Art

- **Internal Analogy — Firebase Analytics (already solved, in-repo):** `lib/main.dart:99-100` documents that `app_version` is captured automatically from the `versionName` that originates in `pubspec.yaml`. The project has already accepted the principle *"the platform owns the version; do not restate it."* The About page is the last surface that violates it.
- **Internal Analogy — Gradle → manifest injection:** `android/app/build.gradle.kts:45-46` demonstrates the mechanism that keeps the *installed* artifact correct. The gap is purely on the Dart/display side.
- **Internal Analogy — ratchet culture (ratchet §8.3):** The repository already institutionalizes "measure the baseline, then forbid regression" for analyzer findings, test counts, and APK size. A **version-consistency ratchet** is the same pattern applied to one more metric, and it fits the project's established discipline rather than fighting it.
- **External Prior Art — First-Party (supersedes the third-party option):** Flutter 3.47.6 itself ships `appBuildName` / `appBuildNumber` (`package:flutter/services.dart`), populated at compile time from `pubspec.yaml` (§3.7). This is the canonical Flutter solution and it is **already available with zero cost**. `package_info_plus` (Flutter Community, verified publisher) remains the canonical *runtime* alternative, but it is strictly heavier for this use case.

### 3.6 Toolchain Compatibility Assessment (for Option B)

> [!IMPORTANT]
> **Superseded by §3.7.** The AGP-compatibility analysis below was written before the Flutter-native accessor was discovered. It is retained for traceability because it explains *why* the naive `package_info_plus` route was rejected. The recommended path no longer touches AGP, Gradle, or Kotlin at all.

| Requirement | `package_info_plus` 10.2.2 / 9.x | This project | Verdict |
| :--- | :--- | :--- | :--- |
| Flutter | ≥ 3.38.1 | 3.47.6 | ✅ |
| Dart | ≥ 3.10 (9.x: 3.11) | 3.13.5 | ✅ |
| Kotlin | ≥ 2.2.0 | 2.2.20 | ✅ |
| Gradle wrapper | ≥ 8.13 | 8.14 | ✅ |
| Android Gradle Plugin | **≥ 8.12.1** (9.0.0+) | **8.11.1** | ⚠️ **Below by one patch release** |
| Project template baseline | Flutter 3.47.6 template ships AGP **9.1.0** | 8.11.1 | ⚠️ Project already trails the template |

`AGP 8.12.0 / 8.12.1 / 8.12.2 / 8.12.3` are all published on `dl.google.com` and would satisfy the constraint. Alternatively `package_info_plus 8.3.1` (Dart 3.3+, compileSDK 34, Gradle 8.4) is compatible with AGP 8.11.1 as-is but is 14 months stale.

### 3.7 **[KEY FINDING]** Flutter-Native Version Accessor — No Dependency, No Toolchain Change

*Pólya Heuristic: "Do you know a related problem? [that has been] solved before" (p. 37-43). The Flutter SDK already solves this exact problem internally — the project was simply not using it.*

**Discovery:** Flutter 3.47.6 ships a first-party accessor for exactly the value we need:

- `D:\Aplikasi\flutter_windows_stable\flutter\packages\flutter\lib\src\services\app_version.dart:17-19` — `const String? appBuildName = bool.hasEnvironment('FLUTTER_BUILD_NAME') ? String.fromEnvironment('FLUTTER_BUILD_NAME') : null;`
- `D:\...\app_version.dart:29-31` — `const String? appBuildNumber = … 'FLUTTER_BUILD_NUMBER' …`
- Exported publicly via `packages/flutter/lib/services.dart:13` (`export 'src/services/app_version.dart';`) — so it is reachable as `package:flutter/services.dart` with **zero new dependencies**.

**How the value reaches the define (the mechanism that makes drift impossible):**

1. `flutter_tools/lib/src/runner/flutter_command.dart:1506-1514` — every Flutter build/run command injects `FLUTTER_BUILD_NAME=$buildName` and `FLUTTER_BUILD_NUMBER=$buildNumber` into `dartDefines`, where `buildName`/`buildNumber` default to `project.manifest.buildName` / `project.manifest.buildNumber` — i.e. **parsed directly from `pubspec.yaml`**.
2. `flutter_tools/lib/src/build_info.dart:364` — dart-defines are encoded and passed to the Dart compiler, so the constant is **baked into the compiled AOT binary**.

**Why this is strictly better than `package_info_plus` for this project:**

| Property | `package_info_plus` | Flutter-native `appBuildName` |
| :--- | :--- | :--- |
| New runtime dependency | ✅ Required | ❌ **None** (`package:flutter/services.dart` is already imported everywhere) |
| AGP / Gradle / Kotlin change | ✅ Required (AGP ≥ 8.12.1) | ❌ **None** |
| APK size impact | Small but non-zero | **Exactly zero** |
| Source of truth | Android `PackageInfo` (runtime platform query) | `pubspec.yaml` (compile-time injection) |
| Reflects `--build-name` override | ✅ | ✅ — the define is populated from `buildName ?? project.manifest.buildName`, so the CLI override wins |
| Async? | ✅ — `Future<PackageInfo>` | ❌ — **synchronous `const`**, no loading state, no `FutureBuilder` |
| Reflects an *overridden* build | Runtime truth (may differ from `pubspec`) | Compile-time truth (always matches what was compiled) |
| Testability | Needs platform-channel mocking | **`const` — trivially assertable** |

The Flutter docstring is explicit about the semantics we want: *"this constant is embedded in the compiled application itself, so it always describes the code that is actually running."* That is precisely the invariant the About page needs.

**Empirical verification (feasibility spike, executed 2026-10-22):**

A throwaway test was created at `test/analysis/_spike_app_version_test.dart` and executed with `flutter test`:

```text
SPIKE appBuildName=[1.4.4] appBuildNumber=[15]
00:00 +1: All tests passed!
```

- `appBuildName` → `1.4.4` and `appBuildNumber` → `15` — **exactly matching** `pubspec.yaml:19` (`version: 1.4.4+15`).
- Confirms `flutter test` also injects the define (`test.dart:433` calls the same `getBuildInfo`), so a **guard test can assert against these constants directly** — no file-parsing of `pubspec.yaml` required.
- The spike file was **deleted** after verification; the working tree contains no residue (only the new `docs/discovery/` directory is untracked).

**Corroborating evidence:** `android/local.properties` already carries `flutter.versionName=1.4.4` and `flutter.versionCode=15` — written by the Flutter tool from the same `pubspec.yaml` manifest. This independently confirms the `1.4.4+15` bump is real and in-flight, resolving `[ASSUMPTION-003]` (§5).

### 3.8 Collateral Finding — Flutter Deprecation Warnings on the Current Toolchain

The feasibility build (`flutter build apk --debug`, exit code 0) succeeded but emitted three Flutter-side deprecation warnings:

```text
Warning: Flutter support for your project's Gradle version (8.14.0) will soon be dropped.
  Please upgrade your Gradle version to a version of at least 9.1.0 soon.
Warning: Flutter support for your project's Android Gradle Plugin version (8.11.1) will soon be dropped.
  Please upgrade your Android Gradle Plugin version to a version of at least 9.0.1 soon.
Warning: Flutter support for your project's Kotlin version (2.2.20) will soon be dropped.
  Please upgrade your Kotlin version to a version of at least 2.3.20 soon.
```

Flutter 3.47.6's own template ships **AGP 9.1.0 / Gradle 9.3.1 / Kotlin 2.4.0** (`gradle_utils.dart:44-52`), so the project is a full major version behind on all three axes. This is **pre-existing debt unrelated to the version-drift defect** and is explicitly **out of scope** for this initiative (§3.8). It is recorded here because it interacts with the `compileSdk 37` bump already pending in the working tree: AGP 8.11.1 supports at most **API 36**, whereas AGP 9.1.0 is the first release supporting **API 37** — so the pending `compileSdk = 37` / `targetSdk = 37` change is **already inconsistent** with the pinned AGP, and will need AGP ≥ 9.1.0 (plus Gradle ≥ 9.3.1) to be officially supported.

> [!WARNING]
> [ASSUMPTION-004]: The uncommitted `compileSdk`/`targetSdk` bump to `37` in `android/app/build.gradle.kts` is **intentional in-flight work**, but the current AGP 8.11.1 officially supports only API 36. *Evidence:* the build succeeds today (AGP emits a warning rather than an error for an unsupported `compileSdk`), yet Flutter's own support matrix caps AGP 8.11.1 at API 36. *Downstream risk:* any future Flutter or AGP validation may hard-fail this build. *Default boundary:* **this is a separate initiative from the version-drift fix** and MUST NOT be silently bundled into it — it is flagged here for the owner's awareness only.

---

## 4. Candidate Architectures & Trade-Off Matrix

*Pólya Heuristic: The Inventor's Paradox (Pólya, 1945, p. 121) — Evaluate whether a more general architectural abstraction yields a cleaner, more maintainable solution than narrow ad-hoc modifications.*

| Dimension | Option A: Manual Sync | Option B1: Runtime Read via `package_info_plus` | Option B2: Flutter-Native `appBuildName` **[RECOMMENDED]** | Option C: Centralized Constant + Guard Test |
| :--- | :--- | :--- | :--- | :--- |
| **Summary** | Manually replace `1.2.2`/`5` with `1.4.4`/`15`; update `panduan.html`; update `ARCHITECTURE.md` | Add `package_info_plus`; read `PackageInfo.fromPlatform()` at runtime and render `version`/`buildNumber` from it | Replace the hardcoded literals with `appBuildName` / `appBuildNumber` from `package:flutter/services.dart` | Keep a single `AppVersion` constant module; add a test that parses `pubspec.yaml` and asserts the constants equal it |
| **Clean Architecture Seams** | None — copy stays duplicated | Reads across the platform boundary (Infrastructure → Presentation) | Compile-time injection from the build manifest (Build → Presentation); no runtime platform coupling | Pure Dart constant + test-only file read; no new runtime coupling |
| **New runtime dependency** | None | ✅ **Required** | ❌ **None** | None |
| **Complexity & Risk** | Lowest effort, **highest recurrence risk** — 6/6 releases already drifted | Medium: new dependency, **AGP ≥ 8.12.1 bump** (project is on 8.11.1), async load, `PackageInfo.fromPlatform()` must not be called before `runApp()` | **Lowest**: one import + two constant substitutions; **synchronous `const`**, no loading state, no `FutureBuilder`, no platform channel | Low–medium: one new constant module + one test file; **no new runtime dependency, no AGP change** |
| **Reversibility (Two-Way Door?)** | Trivially reversible, but **re-drifts** | Reversible (remove dep + restore literal); AGP bump is the deeper part | Fully reversible (restore two string literals) | Fully reversible |
| **APK size impact** | Zero | Small (pure-Kotlin plugin, no native libs) — must be re-measured against the 41.24 MB floor | **Exactly zero** | Zero |
| **Reflects `--build-name` override?** | ❌ | ✅ (reads the installed artifact) | ✅ (`flutter_command.dart:1507` — `buildName ?? manifest.buildName`, so the CLI override wins) | ❌ (mirrors `pubspec.yaml` only) |
| **Detects drift before release?** | ❌ | ✅ N/A — drift impossible by construction | ✅ N/A — drift impossible by construction | ✅ **Yes** — `flutter test` fails on mismatch |
| **Testability** | n/a | Needs platform-channel mocking | **`const` — trivially assertable; already proven by spike (§3.7)** | Requires parsing `pubspec.yaml` in the test |
| **Recommendation** | Rejected as a *complete* answer; acceptable only as an immediate hotfix | Rejected — the AGP bump it forces is a **separate, larger initiative** (§3.8) and buys runtime truth this app does not need | **[RECOMMENDED]** — drift structurally impossible at the lowest possible cost | **Retain as the guard test** — complements B2 by asserting the rendered value matches `pubspec.yaml` |

> [!IMPORTANT]
> **B2 and C are complementary, not competing.** Option B2 makes drift *structurally impossible* at the point of display; Option C's guard test makes it *detectable* if someone later re-introduces a hardcoded literal. Keeping both satisfies the Pólya "Looking Back" test — the result must be verifiable, not merely correct once.

---

## 5. Technical Feasibility Spikes & Open Risks

*Pólya Heuristic: Auxiliary Problem (Pólya, 1945, p. 50). Can we introduce an easier, temporary stepping stone to resolve high-risk unknowns?*

- **Technical Unknown 1 — Does the Flutter-native accessor expose the correct value in every build mode?** — ✅ **RESOLVED (spike executed 2026-10-22).**
  - *Spike:* throwaway test at `test/analysis/_spike_app_version_test.dart` asserting `appBuildName` / `appBuildNumber` are non-null; executed via `flutter test`.
  - *Findings:* `appBuildName=[1.4.4]`, `appBuildNumber=[15]` — **exactly matching `pubspec.yaml:19`**. `flutter test` injects the define (it calls the same `getBuildInfo`, `test.dart:433`), so the guard test can assert against these constants directly. The spike file was deleted; no residue remains.
  - *Corollary:* a separate `flutter build apk --debug` spike also succeeded (exit code 0), confirming the constant is populated in an **AOT build**, not only under the test runner.

- **Technical Unknown 2 — Does replacing the literals with `const` values affect the D-Pad scroll behaviour?**
  - *Finding:* **No.** The change is confined to the two `_AppInfo` string constants; the scroll controller, focus node, and `KeyEventResult` handling in `_handleKeyEvent` are untouched. Unlike the `package_info_plus` route, there is **no async load**, hence no `FutureBuilder`, no loading state, and no risk of a pending future interacting with focus changes.

- **Technical Unknown 3 — Will a widget test on `AboutSection` attempt network access via Google Fonts?**
  - *Spike:* `IslamicTypography` uses `GoogleFonts.poppins`, and `GoogleFonts.config.allowRuntimeFetching = false` is set in `lib/main.dart:62` — i.e. **only at runtime, not in tests**.
  - *Mitigation:* the precedent already exists — `test/presentation/pages/settings/sections/alert_settings_section_test.dart` builds widgets under `IslamicTheme.darkTheme()` with the same font stack, so the pattern is proven to work in this repo.

- **Technical Unknown 4 — Does `landingpage/panduan.html` need to track the version, or be decoupled?**
  - *Spike:* determine whether the landing page is published as static content alongside the Play release, or is a static marketing artifact.
  - *Default boundary:* if it is a static marketing page, decouple it from the release version (remove the version literal entirely) rather than duplicating it — a third copy that must be maintained is worse than no copy.

- **Technical Unknown 5 — Is the AGP / `compileSdk 37` inconsistency a blocker for this initiative?** — ✅ **RESOLVED: NO, and it must stay out of scope.**
  - *Finding:* the feasibility build succeeded (exit 0), so `compileSdk 37` on AGP 8.11.1 warns but does not fail. The Flutter-native accessor requires **no AGP, Gradle, or Kotlin change whatsoever**, so the version-drift fix is fully independent of the toolchain-upgrade question.
  - *Boundary:* the toolchain upgrade (AGP 9.1.0 / Gradle 9.3.1 / Kotlin 2.4.0) is a **separate initiative** (§3.8, `[ASSUMPTION-004]`) and MUST NOT be bundled into this one — bundling it would convert an XS change into an XL one and violate the Surgical Edit Mandate.

> [!WARNING]
> [ASSUMPTION-002]: The About section is the **only** in-app surface that displays the version. *Verified:* a `grep` for `versi|version` across `lib/presentation/` returns matches only in `about_section.dart` (the other hits are unrelated — `masehiDate`, `TASK-010`, an unrelated "versi lama" comment in `splash_page.dart:51`). Default boundary: if a splash-screen or header version badge is added later, it MUST read from the same source established here.

> [!WARNING]
> [ASSUMPTION-003]: ✅ **RESOLVED — the `1.4.4+15` bump is real and in-flight.** *Evidence:* `android/local.properties:4-5` carries `flutter.versionName=1.4.4` / `flutter.versionCode=15`, written by the Flutter tool from the same `pubspec.yaml` manifest — independent corroboration that the bump is not a stray local edit. *Consequence for this initiative:* **the version literal no longer has to be written by hand at all** — Option B2 reads it from the build, so the correct value is supplied automatically regardless of which release ships. *Residual boundary:* the same reasoning applies to `panduan.html` and `ARCHITECTURE.md`, which are **static files that cannot read the build manifest** — those still require a manual value and are therefore the ones where Option C's guard test carries the real weight.

---

## 6. Strategic Recommendation & Handoff to Specification

- **Selected Architectural Path:** **Option B2 — Flutter-Native `appBuildName` / `appBuildNumber`** (`package:flutter/services.dart`), **plus** an Option-C-style guard test retained as the mechanical regression check.
  - *Why:* it is the only option in which the displayed version is **guaranteed** to be the version that was actually compiled into the running binary — which is the exact semantic an operator needs when reading "Tentang Aplikasi" to file a support ticket. It generalizes the principle the project already accepted for Firebase (`lib/main.dart:99-100`) and for the Android manifest (`build.gradle.kts:45-46`), eliminating the last copy that restates the build's version.
  - *Why not `package_info_plus` (Option B1):* it would force an **AGP ≥ 8.12.1 toolchain upgrade** — a materially larger change that belongs to a separate initiative (§3.8) — and introduces an async platform-channel round-trip, a new runtime dependency, and a non-zero APK-size delta against a 41.24 MB ratchet floor. For a static, read-only string on an offline app, that cost buys runtime truth this application has no use for.
  - *Cost profile:* one import + two constant substitutions in `_AppInfo`. Synchronous, zero-dependency, zero-APK-impact, and directly assertable in tests (proven by spike, §3.7).
- **High-Impact Decisions (ADR Candidate):** **No ADR required.** The Triple-Gate test fails on two of three criteria: (1) *Hard to reverse?* — No, swapping a hardcoded literal for a build-injected constant is a routine, fully reversible refactor. (2) *Surprising without context?* — No, `appBuildName` is the canonical Flutter idiom and is documented in the SDK itself. Only criterion (3), *Real trade-off*, holds (compile-time truth vs. runtime truth). **Do not create an ADR.**
- **Domain Vocabulary Candidates (`CONTEXT.md`):** None required. "Application Version" and "Build Number" are generic technical terms, not business-domain concepts; `CONTEXT.md` is reserved for Prayer Schedule / Display Features / Mosque Administration vocabulary. **No `CONTEXT.md` change.**

### 6.1 Downstream Readiness Checklist (for `/to-prd` or `/to-spec`)

- [x] **The Unknown:** Authoritative source of truth identified; the mechanism that makes drift structurally impossible is now empirically validated (§3.7 spike).
- [x] **The Data:** All four version-bearing locations are enumerated and their values recorded (§3.2); the toolchain constraints are quantified (§3.6, §3.8).
- [x] **The Condition:** Offline-only, APK-size ratchet, D-Pad navigation, and Floor-Guard constraints are stated (§2).
- [x] **Clean Architecture Seams:** Build-manifest injection (Build → Presentation) for the display value; a pure test-layer invariant for the guard test.
- [x] **Risks & Spikes:** Five spikes — one executed and resolved (§5, Unknowns 1 & 5), one proven to be a non-issue (Unknown 2), two with documented mitigations (Unknowns 3 & 4); four numbered assumptions tagged `[ASSUMPTION-001..004]`, two of them already resolved by evidence.
- [x] **Scope Fence:** The AGP / Gradle / Kotlin toolchain upgrade is explicitly **excluded** and recorded as a separate initiative (§3.8).

### 6.2 Forking Handoff Actions (`/to-prd` or `/to-spec`)

- **Path A (Optional Product Requirements — User Stories & SMART AC):**
  ```text
  /to-prd @docs/discovery/about-page-version-drift-discovery.md Formulate a Product Requirements Document (PRD) covering user stories and SMART acceptance criteria for correct version display and drift prevention.
  ```

- **Path B (Direct Technical Specification — Fast-Track Blueprint):**
  ```text
  /to-spec @docs/discovery/about-page-version-drift-discovery.md Formulate the technical specification, DTO contracts, and Clean Architecture seams for the single-source-of-truth version display — replacing the hardcoded `_AppInfo.version` / `.buildNumber` with Flutter's `appBuildName` / `appBuildNumber` (`package:flutter/services.dart`), correcting the `5 mode` copy claim to 9 display states, and adding the guard test that asserts the rendered version matches `pubspec.yaml`.
  ```

> [!NOTE]
> The scope of this Discovery Draft is deliberately narrow: **one user-visible defect** (stale version) plus **one collateral content defect** (`5 mode` → 9 states). It does not propose a release-process overhaul; the guard test is the smallest mechanism that converts a silent, recurring failure into a loud, pre-release one.
