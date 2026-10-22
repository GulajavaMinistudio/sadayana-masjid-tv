---
goal: Repository Architecture and Clean Architecture Seams Documentation
date_created: 2026-10-15
last_updated: 2026-10-22
status: 'Active'
tags: ["architecture", "clean-architecture", "polya-topography", "system-map"]
---
<!-- markdownlint-disable -->

# Repository Architecture Documentation

![Status: Active](https://img.shields.io/badge/status-active-brightgreen)

This document serves as the canonical architectural map of the repository. It outlines the system topology, Clean Architecture seams, directory responsibilities, and module constraints to assist developers and AI agents in navigating and maintaining the codebase safely.

---

## 1. Executive Overview & Domain Context

- **System Purpose:** Miqotul Khoir TV (MKT) is an offline-first Android TV digital signage application for mosques. It computes astronomical prayer times with zero internet dependency (Kemenag RI / SIHAT standard with elevation correction), operates a 9-state automatic display machine, and ships a 4-step setup wizard plus a PIN-protected 15-category settings menu operated entirely via D-Pad remote. Primary users: DKM administrators (operators) and congregation (viewers).
- **Domain Ubiquitous Language:** The canonical glossary lives in [`CONTEXT.md`](../CONTEXT.md) — 19 terms across 3 groups (Prayer Schedule, Display Features, Mosque Administration), each carrying strict `_Avoid:_` synonym rules that MUST be honoured in code, specs, and user-facing copy. Key concepts: Prayer Time (Subuh, Syuruq, Dhuha, Dzuhur, Ashar, Maghrib, Isya), Pre-Adzan, Adzan, Iqomah, Sholat, Ihtiyat (time correction), Elevation / DPL, Jum'at handling, Display State, Wisdom Quote, Slideshow Announcement, Imam Schedule (imam & khatib), Midnight Standby (power saving), Treasury (Kas Masjid), Running Text.
- **Target Environments:** Android TV / Smart TV / set-top boxes (primary; published on Google Play as `gulajava.mini.miqotul_khoir_tv`, GPL-3.0, app version 1.4.3+14). Windows/Linux/macOS desktop is also supported at runtime via SQLite FFI for development and testing.

---

## 2. High-Level Tech Stack & Tooling

| Dimension | Technologies / Tools | Configuration Files |
| :--- | :--- | :--- |
| **Primary Language(s)** | Dart (SDK ^3.11.0); Kotlin (Android host layer, JVM target 17) | `pubspec.yaml`, `android/app/build.gradle.kts` |
| **Core Frameworks** | Flutter 3.47.6 stable (Material); `flutter_bloc` 9.1.1 (Cubit); `flutter_screenutil` 5.9.3 (1920×1080 baseline); `google_fonts` 8.2.1 (Poppins bundled offline) | `pubspec.yaml`, `lib/core/theme/` |
| **Persistence / Storage** | SQLite via `sqflite` (schema v11, 5 tables); `path_provider` app-directory file storage for slideshow images; bundled JSON seed assets | `lib/data/datasources/database_helper.dart`, `assets/data/` |
| **Domain Calculation** | `adhan` 2.0.0+1 (astronomical prayer times); `hijri` 3.0.1 (Hijri calendar); `intl` 0.20.3 (id_ID formatting); `crypto` 3.0.7 (SHA-256 PIN hashing) | `pubspec.yaml` |
| **Audio & Media** | `audioplayers` 6.8.1 + `audioplayers_android_exo` 0.1.4 (pre-adzan/pre-iqomah alerts); `image_picker` 1.2.3 (slideshow images); `marquee` 2.3.0 (running text) | `pubspec.yaml`, `assets/sound/` |
| **External SaaS** | Firebase Analytics + Crashlytics (project `mqotulkhoir7`; monitoring only, off the critical path) | `firebase.json`, `lib/firebase_options.dart` |
| **Build & Packaging** | Flutter + Gradle Kotlin DSL; `compileSdk 36`, `minSdk 24`, `targetSdk 36`; multiDex; core library desugaring; release signing via `android/signing.properties` | `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml` |
| **Testing Harnesses** | `flutter_test`, `bloc_test` 10.0.0, `mocktail` 1.0.5, `sqflite_common_ffi` 2.4.2+1 (in-memory SQLite), `fake_async` 1.3.3 — 59 test files / 535 tests under `test/` | `test/`, `pubspec.yaml` |
| **Linter & Formatters** | `flutter_lints` 6.0.0 (recommended Flutter preset; no custom rule overrides) | `analysis_options.yaml` |

> [!WARNING]
> **Deliberate dev-dependency boundary:** `lib/main.dart` imports `package:sqflite_common_ffi/sqflite_ffi.dart` to install the desktop SQLite factory, while `sqflite_common_ffi` is declared only under `dev_dependencies`. The analyzer reports this as `depend_on_referenced_packages`. It is **intentionally not "fixed"**: promoting the package to `dependencies` makes the transitive `sqlite3` package compile SQLite from C source and bundle `libsqlite3.so` into every Android APK (**+1.65 MB** measured, 41.24 → 42.89 MB) for a code path that never executes on Android TV. See §8.4 `EX-005` for the full rationale and the measured A/B evidence.

---

## 3. Pólya's Topological Map ("Draw a Figure")

*Pólya Heuristic (How to Solve It, p. 99): "Draw a figure... to find a lucid representation for your nongeometrical problem is an important step."*

### 3.1 C4 / High-Level System Container Topology

```text
┌────────────────────────────────────────────────────────────────────────────┐
│ RUNTIME HOST — Android TV / Smart TV / Set-Top Box                         │
│ D-Pad remote input · 1920×1080 landscape · 100% offline runtime            │
└────────────────────────────────────────────────────────────────────────────┘
                                    │  Flutter runtime (landscape-locked)
                                    ▼
┌────────────────────────────────────────────────────────────────────────────┐
│ PRESENTATION — lib/presentation/           [Interface Adapters]            │
│ Cubits: PrayerTime · DisplayState (1s tick) · Settings (global)            │
│         SetupWizard · SlideshowSection · ImamSchedule (page-scoped)        │
│ Pages:  Splash ▶ SetupWizard (4 steps) ▶ MainDisplay (9 layouts)           │
│         15 settings sections · D-Pad navigation · ScreenUtil 1920×1080     │
└────────────────────────────────────────────────────────────────────────────┘
                                    │  depends on abstract ports (DIP)
                                    ▼
┌────────────────────────────────────────────────────────────────────────────┐
│ DOMAIN CORE — lib/domain/         [Entities · Use Cases · Ports]           │
│ 13 Entities (Equatable) · sealed DisplayState hierarchy = 9 states         │
│ 2 Use Cases: CalculatePrayerTimes · EvaluateDisplayState (pure)            │
│ 8 Ports: 6 Repository interfaces + 2 Service interfaces                    │
└────────────────────────────────────────────────────────────────────────────┘
                                    │  implements ports (DIP)
                                    ▼
┌────────────────────────────────────────────────────────────────────────────┐
│ DATA ADAPTERS — lib/data/         [Adapters · Frameworks & Drivers]        │
│ 6 Repository Impls ▶ 7 Local Data Sources ▶ SQLite "miqotul_khoir.db" v11  │
│ 2 Service Impls: AudioAlert · SlideshowFileStorage (app file storage)      │
│ Seed assets: cities.json (514) · wisdom_quotes.json (11) · Poppins         │
└────────────────────────────────────────────────────────────────────────────┘

Outbound (monitoring, non-critical path): Firebase Analytics + Crashlytics ▶ Cloud
Composition root: lib/main.dart — manual DI (RepositoryProvider ×7 · BlocProvider ×3)
```

### 3.2 Domain Display State Machine (9 States)

`DisplayStateCubit` evaluates the active display state every 1 second (`Timer.periodic`) by invoking `EvaluateDisplayStateUseCase` — a pure function whose first matching time window wins (deterministic priority order, source: `lib/domain/usecases/evaluate_display_state_use_case.dart`):

```text
  1. Prayer phases     per obligatory prayer, from DailyPrayerTimes:
                       Standby ▶ Pre-Adzan (H-N min) ▶ Adzan ▶ Iqomah ▶ Sholat
  2. Midnight Standby  optional power-saving window (cross-midnight)
  3. Slideshow         optional announcement image rotation (3 slots)
  4. Imam Schedule     optional imam/khatib schedule of the day
  5. Wisdom Quote      optional Quran/Hadith quote rotation
  6. Standby           fallback resting layout
```

Sealed class hierarchy in `lib/domain/entities/display_state.dart`:
`StandbyState` · `PreAdzanState` · `AdzanState` · `IqomahState` · `SholatState` · `SlideshowAnnouncementState` · `ImamScheduleState` · `WisdomQuoteState` · `MidnightStandbyState`.

---

## 4. Clean Architecture Seams & Component Boundaries

*Dependency Rule: Source code dependencies MUST point inwards toward high-level business policies.*

```text
Entities (Domain Layer)
   └── Pure business logic, value objects, and domain invariants (Zero external dependencies)
Use Cases (Application Layer)
   └── Workflow orchestration, transaction boundaries, input/output ports
Interface Adapters (Controllers, Gateways, Presenters)
   └── HTTP controllers, repository implementations, external client adapters
Frameworks & Drivers (DB, Web Server, UI Runtimes)
   └── Web frameworks, ORM drivers, cloud SDKs, third-party libraries
```

### 4.1 Layer Breakdown

- **Domain Layer — `lib/domain/`:**
  - Contains: 13 entities (incl. the sealed `DisplayState` hierarchy), 6 abstract repository interfaces, 2 abstract service interfaces, 2 use cases (`CalculatePrayerTimesUseCase`, `EvaluateDisplayStateUseCase`).
  - Invariant: pure Dart only — imports limited to `dart:*`, `equatable`, `intl`, and the pure-Dart astronomy libraries `adhan`/`hijri`. Zero Flutter, SQLite, or Firebase imports (verified by import scan).
- **Use Cases — `lib/domain/usecases/`:**
  - `CalculatePrayerTimesUseCase` depends only on the `SettingsRepository` port; `EvaluateDisplayStateUseCase` is a pure function over `DateTime`, `DailyPrayerTimes`, `TransitionConfig`, and content lists.
  - Invariant: orchestrates domain rules without touching delivery mechanisms.
- **Interface Adapters — `lib/data/repositories/`, `lib/data/models/`, `lib/data/datasources/`, and `lib/presentation/cubits/`:**
  - Repository implementations map SQLite rows ↔ domain entities (`fromMap`/`toMap`); local data sources own the query surface; Cubits act as presenters converting domain state into UI states.
  - Invariant: presentation must never import `lib/data/` directly (verified); all wiring happens at the composition root.
- **Frameworks & Drivers — `lib/data/services/`, `main.dart`, platform folders:**
  - `DatabaseHelper` (sqflite singleton, schema v11, seed loader, migrations); `AudioAlertServiceImpl` (audioplayers); `SlideshowFileStorageServiceImpl` (path_provider file I/O); Firebase SDKs; Android host project.
- **Composition Root — `lib/main.dart`:**
  - Manual dependency injection, no service locator: builds data sources → repository implementations → use cases → Cubits, then registers 7 `RepositoryProvider`s (Settings, City, WisdomQuote, SlideshowImage, SlideshowFileStorage, Imam, ImamSchedule) and 3 global `BlocProvider`s (PrayerTime, DisplayState, Settings). `SetupWizardCubit`, `SlideshowSectionCubit`, and `ImamScheduleCubit` are created page-scoped inside their own pages.

---

## 5. Data Flow Lifecycle & Core Invariants

### 5.1 Standard Request/Execution Flow

1. **App Bootstrap (cold start)** — `main()` executes in order: Flutter binding → `GoogleFonts.config.allowRuntimeFetching = false` → desktop-only SQLite FFI factory → `intl` `id_ID` locale → database warm-up → landscape orientation lock → `Firebase.initializeApp` → Crashlytics error handlers → `runApp` → post-first-frame `logAppOpen`.
2. **Initial Routing (first-run gate)** — `SplashPage` waits 2 s for branding, then reads `SettingsRepository.isFirstRun()`: first run (or read failure) routes to `SetupWizardPage`; otherwise it reloads `SettingsCubit` from the database and routes to `MainDisplayPage`.
3. **Dependency Wiring** — repository providers feed use cases and Cubits; global Cubits live for the app lifetime, page-scoped Cubits are created inside feature pages.
4. **Prayer-Time Calculation** — `PrayerTimeCubit` → `CalculatePrayerTimesUseCase` → `SettingsRepository` (SQLite) → astronomical calculation via `adhan` + `hijri` → manual ihtiyat corrections and elevation (DPL) applied → `DailyPrayerTimes` emitted; refreshed by a midnight timer.
5. **Display State Loop** — `DisplayStateCubit` ticks every 1 s → `EvaluateDisplayStateUseCase.evaluate(now, dailyPrayerTimes, transitionConfig, ...)` applies the priority order from §3.2 → one of 9 sealed states is emitted → `MainDisplayPage` switches to the matching layout.
6. **Persistence Flow** — Cubit → repository port → repository implementation → local data source → `sqflite` (transactions; foreign keys enforced via `PRAGMA foreign_keys = ON`).
7. **Media & File Flow** — slideshow images are copied into app-document storage with metadata rows in `slideshow_images`; alert audio plays bundled `assets/sound/` files.
8. **Observability** — Crashlytics captures fatal framework and uncaught async errors; Analytics only logs `app_open` after the first frame (non-blocking by design).

### 5.2 Architectural Invariants

| ID | Invariant | Enforcement / Evidence |
| :--- | :--- | :--- |
| INV-001 | **Dependency Rule** — `lib/domain/` is pure Dart | Verified: domain imports only `dart:*`, `equatable`, `intl`, `adhan`, `hijri`; zero Flutter/SQLite/Firebase imports |
| INV-002 | **Presentation never imports `lib/data/`** | Verified by import scan; `lib/main.dart` is the only wiring point (DIP) |
| INV-003 | **Data never imports `lib/presentation/`** | Verified by import scan |
| INV-004 | **Ports are the only cross-boundary contract** | 6 repository + 2 service abstract interfaces live in `lib/domain/` |
| INV-005 | **Async Cubit lifecycle safety** | Convention after the `emit-after-close` incident: `if (isClosed) return;` before every post-`await` `emit()` — **31 guards across all 6 Cubits** (8 `ImamScheduleCubit`, 11 `SlideshowSectionCubit`, 7 `SettingsCubit`, 2 `SetupWizardCubit`, 2 `PrayerTimeCubit`, 1 `DisplayStateCubit`); 29 were added by the 2026-06-20 remediation, 2 pre-date it in `PrayerTimeCubit` (the reference implementation) |
| INV-006 | **100% offline runtime** | Fonts, cities, quotes, and sounds are bundled; no runtime network fetch; Firebase is non-blocking and not required for any feature |
| INV-007 | **Database integrity & versioning** | `_databaseVersion = 11` with sequential `if (oldVersion < N)` migrations; FK enforcement on; `settings` is a singleton row (`CHECK (id = 1)`) |
| INV-008 | **TV-safe rendering** | ScreenUtil baseline 1920×1080 (`.sp/.w/.h/.r` everywhere); landscape lock; minimum 48×48 logical-pixel targets; anti burn-in (dimmed Sholat screen, Midnight drift) |
| INV-009 | **Timer lifecycle symmetry** | Every timer started by a Cubit (tick timers, countdowns) is cancelled in `close()`/`dispose()`; `PrayerTimeCubit` is the reference implementation |

---

## 6. Directory Tree Map & Responsibilities

### 6.1 Repository Topography

```text
[Project Root]
├── lib/
│   ├── core/theme/                  # Islamic colors, typography, ThemeData, TV safe area
│   ├── data/
│   │   ├── datasources/             # DatabaseHelper singleton + 6 local data sources
│   │   ├── models/                  # 6 SQLite row models (fromMap/toMap)
│   │   ├── repositories/            # 6 port implementations
│   │   └── services/                # AudioAlert & SlideshowFileStorage implementations
│   ├── domain/
│   │   ├── entities/                # 13 Equatable entities (incl. 9-state sealed DisplayState)
│   │   ├── repositories/            # 6 abstract ports
│   │   ├── services/                # 2 abstract ports
│   │   └── usecases/                # CalculatePrayerTimes, EvaluateDisplayState
│   ├── presentation/
│   │   ├── cubits/                  # 6 Cubits (3 global + 3 page-scoped)
│   │   ├── pages/                   # Splash, MainDisplay (9 layouts), SetupWizard, Settings
│   │   └── widgets/                 # 14 reusable Android-TV widgets
│   ├── firebase_options.dart        # Generated FlutterFire configuration
│   └── main.dart                    # Composition root + app bootstrap
├── test/                            # 59 test files mirroring lib/ + Kemenag comparison
│   ├── analysis/                   # Kemenag SIHAT comparison harness
│   ├── core/ · data/ · domain/ · presentation/   # Mirror of lib/ layers
│   └── preview_test.dart · widget_test.dart      # Root-level smoke tests
├── assets/                          # data (JSON), fonts (Poppins ×5), images, sound
├── android/                         # Android TV host project (Gradle Kotlin DSL)
├── spec/                            # 6 technical specifications (SDLC history)
├── plan/                            # 36 feature / bugfix implementation plans (+ README)
├── docs/                            # Guides + this architecture map
│   └── adr/                         # Architecture Decision Records (0001, 0002)
├── tools/                           # One-off Python/Dart automation scripts
├── landingpage/                     # Static HTML promo & user-guide pages
├── .agents/ · .commandcode/         # AI-agent SDLC toolkit (skills, rules, instructions)
└── [root files]                     # pubspec.yaml, analysis_options.yaml, firebase.json, AGENTS.md, README.md, ...
```

### 6.2 Directory Responsibilities Matrix

| Directory / Module | Primary Purpose | Clean Architecture Layer | Allowed Dependencies | Rules & Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `lib/domain/` | Entities, use cases & ports | Entities + Use Cases (Core) | Pure Dart (`equatable`, `intl`, `adhan`, `hijri`) | Zero Flutter/SQLite/Firebase imports (verified); no dependency on outer layers |
| `lib/data/` | SQLite, file & audio adapters | Interface Adapters + Frameworks & Drivers | `lib/domain/`, `sqflite`, `path_provider`, `audioplayers`, `image_picker` | Implements domain ports; must not import `lib/presentation/` (verified) |
| `lib/presentation/` | Cubits, pages, widgets | Interface Adapters (presenters) | `lib/domain/`, `lib/core/`, `flutter_bloc`, ScreenUtil | Must not import `lib/data/` (verified); feature pages use page-scoped Cubits |
| `lib/core/` | Islamic theme tokens & TV sizing helpers | Shared UI primitives | Flutter only | No `data`/`domain`/`presentation` imports (verified) |
| `test/` | Automated suites mirroring `lib/` | Verification | All layers + `bloc_test`, `mocktail`, `sqflite_common_ffi`, `fake_async` | In-memory SQLite for repository tests; 59 files / 535 tests; mirrors `lib/` layer-for-layer (`test/{core,data,domain,presentation}`) plus `test/analysis/` |
| `assets/` | Seed JSON, fonts, images, alert sounds | Resources | — | `cities.json` (514 records) · `wisdom_quotes.json` (11 catalog) · Poppins ×5 weights bundled for offline use · 1 alert sound |
| `spec/` · `plan/` | SDLC artifacts (specs, plans) | Documentation | — | Historical documents may drift from code; code is the source of truth |
| `docs/` | Architecture map, ADRs, guides | Documentation | — | `ARCHITECTURE.md` (this file) is the canonical topology; `adr/` holds Accepted decision records |
| `tools/` | One-off automation scripts (city seeding, codemods) | Tooling | — | Not part of the shipped application |
| `landingpage/` | Static HTML promo & user-guide pages | Auxiliary | — | `index.html`, `panduan.html` + assets |
| `android/` | Android TV host project | Frameworks & Drivers | — | LEANBACK launcher; `minSdk 24` / `targetSdk 36`; Firebase Gradle plugins |

---

## 7. Key Configuration Files & Entry Points

- **App Initialization:** `lib/main.dart` — bootstrap order: Flutter binding → Google Fonts offline lock → desktop SQLite FFI (Windows/Linux/macOS only) → `intl` `id_ID` locale → database warm-up → landscape lock → Firebase init → Crashlytics handlers → `runApp` → post-frame `logAppOpen`.
- **Routing / First-Run Gate:** `lib/presentation/pages/splash_page.dart` — 2 s branding delay, `isFirstRun()` check, error fallback to the setup wizard.
- **Database / Migrations:** `lib/data/datasources/database_helper.dart` — v11, sequential `if (oldVersion < N)` chain, tables: `settings` (singleton), `cities` (seeded), `slideshow_images`, `imams`, `imam_schedules`; indexes `idx_cities_province`, `idx_cities_name`.
- **Seed Data Assets:** `assets/data/cities.json` (514 city/kabupaten records with elevation) · `assets/data/wisdom_quotes.json` (11-item Quran/Hadith catalog).
- **Android TV Host:** `android/app/src/main/AndroidManifest.xml` (`LEANBACK_LAUNCHER` intent filter; leanback and touchscreen features declared optional; TV banner) · `android/app/build.gradle.kts` (applicationId `gulajava.mini.miqotul_khoir_tv`, SDK levels, release signing, Firebase plugins).
- **Firebase:** `lib/firebase_options.dart` · `firebase.json` · `android/app/google-services.json` (project `mqotulkhoir7`).
- **Static Analysis:** `analysis_options.yaml` (`flutter_lints` 6.0.0 preset; excludes platform folders; no custom rule overrides).
- **CI / Build Pipeline:** none checked in — neither `.github/` nor any CI runner exists. Quality gates run locally per §8.2: `dart analyze` → `flutter test --reporter=expanded` → `dart format --output=none --set-exit-if-changed lib test` → `flutter build apk`.
- **Release Signing:** `android/signing.properties` supplies `storeFile` / `storePassword` / `keyAlias` / `keyPassword` to the Gradle `release` signing config. **The file was tracked in git and is absent from `.gitignore`** — mitigated on 2026-10-22 (gitignored + untracked), but keystore rotation and history purge remain open — see §8.6 `EX-001`.

---

## 8. Mechanical Quality Constraints, Verification Commands & Ratchets

*Quality bars are enforced mechanically via speed-tiered commands, non-regressing ratchets, and Floor-Guard anti-tampering rules. Every baseline in this section was **measured**, not estimated, on 2026-10-22 against Flutter 3.47.6 stable / Dart SDK ^3.11.0 on Windows.*

> [!IMPORTANT]
> The `check:fast` / `check:task` / `check:full` tiers below are **mapped onto this repository's real Dart/Flutter toolchain**. They are not shell aliases — run the exact CLI commands shown. No CI runner is checked in (§7), so these gates are executed locally by the developer or agent.

### 8.1 The Immutable Quality Floor (Zero Setup, Always Enforced)

- **Zero Suppressions:** No `// ignore:` or `// ignore_for_file:` directives added to silence analyzer findings; no `analysis_options.yaml` rule weakened or excluded to hide a diagnostic.
- **Zero Test Weakening:** No `skip:` markers, no `xdescribe` / `xtest`, no deleted failing tests, no stripped assertions.
- **Zero Unimplemented Stubs:** No `TODO` / `FIXME` placeholders in shipped Dart code. *(Verified: 0 occurrences across all 114 files in `lib/`.)*
- **Zero Secrets in VCS:** No credential material committed to the repository. *(Locally mitigated 2026-10-22 — the signing properties file is gitignored and untracked. **Still open:** keystore rotation and history purge require owner action — see §8.6 `EX-001`.)*
- **Zero Bar-Lowering:** Agents MUST NEVER lower the numeric floors recorded in §8.3, weaken `analysis_options.yaml`, or relax an assertion to make a gate pass.

### 8.2 Speed-Tiered Verification Commands

| Tier | Target Latency | When Executed | Exact CLI Command(s) |
| :--- | :--- | :--- | :--- |
| **`check:fast`** | `< 15s` | Every file edit (Micro level) | `dart analyze` |
| **`check:task`** | `< 90s` | End of each Vertical Tracer Bullet | `dart analyze` + `flutter test <scoped paths> --reporter=expanded` |
| **`check:full`** | `< 5m` | Macro Phase Checkpoint / `/to-review` / pre-release | `dart analyze` + `flutter test --reporter=expanded` + `dart format --output=none --set-exit-if-changed lib test` + `flutter build apk --debug` |

Measured reference: the full `flutter test` suite (59 files, 535 tests) completes in **≈ 26 s**; `check:full` is therefore dominated by the APK build step.

> [!WARNING]
> **Never run `dart format .` at the repository root.** It crashes with `PathNotFoundException` while walking `build/` (Flutter plugin transform artifacts). Always scope it to `dart format lib test`. The pre-commit checklist in `docs/DEVELOPMENT_WORKFLOW.md` was corrected to the scoped form on 2026-10-22.

### 8.3 Non-Regressing Quality Ratchets (Measure & Hold)

*Each baseline below was measured on 2026-10-22 and is an immutable floor. Metrics may only improve (ratchet up), never regress.*

| Metric / Dimension | Current Ratchet Floor | Required Direction | Checked By |
| :--- | :--- | :--- | :--- |
| **Analyzer Errors** | `0` | Must not grow (`= 0`) | `dart analyze` |
| **Analyzer Warnings** | `1` | Must not grow (`<= 1`) | `dart analyze` |
| **Analyzer Infos** | `4` | Must not grow (`<= 4`) | `dart analyze` |
| **Passing Tests** | `535 / 535` (59 files) | Must not drop | `flutter test --reporter=expanded` |
| **Unformatted Dart Files (`lib` + `test`)** | `16` | Must not grow (`<= 16`) | `dart format --output=none --set-exit-if-changed lib test` |
| **TODO / FIXME in `lib/`** | `0` | Must not grow (`= 0`) | `grep -r "TODO\|FIXME" lib/` |
| **Domain Purity Violations** (`lib/domain/` importing Flutter / SQLite / Firebase) | `0` | Must not grow (`= 0`) | import scan over `lib/domain/**` |
| **`presentation → data` Import Violations** | `0` | Must not grow (`= 0`) | import scan over `lib/presentation/**` |
| **`data → presentation` Import Violations** | `0` | Must not grow (`= 0`) | import scan over `lib/data/**` |
| **Release APK Size (arm64, unminified)** | `41.24 MB` (43,240,043 bytes) | Must not grow (`<= 41.24 MB`) | `flutter build apk --release --target-platform android-arm64` |

> [!NOTE]
> **The APK-size ratchet is baselined against an unminified build.** The release build sets `isMinifyEnabled = false` and `isShrinkResources = false` in `android/app/build.gradle.kts`, so R8 never runs. The `41.24 MB` floor is therefore the *unminified* size — enabling R8 will **reduce** it substantially. Treat that drop as an explicit ratchet adjustment (re-baseline downwards), never as an unexplained change. Enabling minification later must also be checked against the `EX-005` native-SQLite floor before it is adopted.

> [!TIP]
> **APK composition at the 41.24 MB baseline** (arm64 release, 2026-10-22): `libflutter.so` 11.20 MB · `classes.dex` ×3 20.65 MB · `flutter_assets` 13.29 MB · `libapp.so` 6.31 MB · `res` 1.68 MB. The two largest *addressable* items are the uncompressed PNG assets — `assets/images/mosque_silhouette.png` alone is 6.63 MB, and `mktv_icon_large_transparent.png` 2.34 MB.

### 8.4 Approved Rule Exceptions (Time-Bounded)

*Any rare exception to the Quality Floor requires explicit human approval, a named owner, and an expiry date (default 90 days).*

| ID | Rule / Check Bypassed | File Path & Line | Technical Rationale | Approved By | Expires On |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `EX-005` | **Dependency Correctness** — `depend_on_referenced_packages` info lint | `lib/main.dart:11` | `sqflite_common_ffi` is imported by production code but is deliberately kept in `dev_dependencies`. Promoting it to `dependencies` **does** clear the lint, but the transitive `sqlite3` package (3.5.2) compiles SQLite from C source via `code_assets`, so the Android release build then bundles `libsqlite3.so` into **every** APK. Measured A/B on 2026-10-22: **41.24 MB → 42.89 MB (+1.65 MB, +4.0%)** for a code path that never executes on Android TV (guarded by `Platform.isWindows/isLinux/isMacOS`). The `sqlite3` package exposes no opt-out for native-asset bundling, and Dart conditional imports cannot express desktop-vs-mobile (there is no `dart.library.desktop`). Keeping it a dev-dependency is the smaller, YAGNI-correct trade-off for the shipped Android TV artifact. No suppression directive was added — the lint is left visible and documented here. | *Pending maintainer approval* | *Proposed 2027-01-20 (90 days)* |

### 8.5 Resolved Floor-Guard Violations (2026-10-22 Remediation)

| ID | Rule Violated | File Path | Resolution |
| :--- | :--- | :--- | :--- |
| `EX-003` | **Zero Unimplemented Stubs** | `android/app/build.gradle.kts` | Both stock Flutter `// TODO:` comments removed. The Application ID is specified on the line below the deleted comment, and the release `signingConfig` is wired to the `release` signing config — replaced by a comment documenting that it reads `android/signing.properties`. |
| `EX-004` | **Zero Suppressions** | `test/presentation/cubits/imam_schedule/imam_schedule_cubit_lifecycle_test.dart` | The redundant per-line `// ignore: invalid_use_of_protected_member` was deleted. The file-level `// ignore_for_file:` on line 1 already covers the diagnostic, so suppression behaviour is unchanged while the `duplicate_ignore` warning is cleared. |

> [!NOTE]
> `EX-002` (`depend_on_referenced_packages` on `lib/main.dart`) was **not** closed by promoting the dependency — measurement showed that trade-off costs +1.65 MB in every shipped APK. It was reclassified as a deliberate, time-bounded exception (`EX-005`) in §8.4, pending maintainer approval.

### 8.6 Open Floor-Guard Violations (Owner Action Required)

*These are recorded violations, not sanctioned exceptions. None carries maintainer approval or an expiry date, and none may be extended — each must be remediated.*

| ID | Rule Violated | File Path | Detail & Required Remediation | Owner |
| :--- | :--- | :--- | :--- | :--- |
| `EX-001` | **Zero Secrets in VCS** | `android/signing.properties` (committed in `67acf7e`, 2026-03-07) | Release keystore credentials (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`) were committed with **non-empty values** and the file was **not** covered by `.gitignore`. The keystore binary (`android/upload-keystore-gulajava.jks`) was correctly ignored, but the passwords that unlock it were published to both public remotes (`github/main` and `gitlab/main`). **Mitigated locally:** the path is now in `.gitignore` and the file was untracked via `git rm --cached` (the local copy is preserved for the developer). **Still required — owner action:** (1) **rotate the keystore** and publish an upload-key replacement in the Play Console — deleting the file from history alone is insufficient because it is already cached on both remotes; (2) purge the file from git history on both remotes; (3) confirm whether the same password was reused elsewhere. | Project maintainer |

---

## 9. Architectural Health & Known Seams

- **Primary Seams:**
  - **Domain ports** — 6 repository interfaces + 2 service interfaces; new capabilities enter through a new port/adapter pair.
  - **Sealed `DisplayState`** — new display modes are additive: state class + evaluation window + layout.
  - **Versioned settings singleton** — optional features add columns through a new `if (oldVersion < N)` migration block.
  - **Composition root** — `lib/main.dart` is the single registration point for new repositories and Cubits.
  - **Page-scoped Cubit pattern** — feature sections (Slideshow, Imam Schedule) instantiate and dispose their own Cubit locally.
- **Technical Debt / Hotspots:**
  - **Critical — signing credentials in version control:** `android/signing.properties` was committed with non-empty `storePassword` / `keyPassword` and was not covered by `.gitignore`, publishing the release signing credentials to both public remotes. Mitigated locally on 2026-10-22 (gitignored + untracked); **keystore rotation and history purge still require owner action** — see §8.6 `EX-001`.
  - **Packaging hygiene:** `sqflite_common_ffi` remains a dev-dependency imported by `lib/main.dart` — deliberately, because promoting it costs +1.65 MB of native SQLite in every shipped APK (§8.4 `EX-005`).
  - **Unminified release build:** `isMinifyEnabled = false` and `isShrinkResources = false` mean R8 never runs; the APK-size ratchet is baselined against the current unminified build at **41.24 MB** (§8.3) — enabling minification later will read as a *regression* against that floor and must be handled as an explicit ratchet adjustment, not a silent drop.
  - **Oversized image assets:** `assets/images/mosque_silhouette.png` (6.63 MB), `mktv_icon_large_transparent.png` (2.34 MB) and `mktv_icon_large.png` (1.47 MB) are uncompressed PNGs totalling 11.55 MB of the 41.24 MB APK — the largest addressable payload. Converting them to WebP/optimised PNG, or dropping the unused variants, would shrink the artifact substantially.
  - **Manual DI in `main.dart`:** all wiring lives in one widget builder; fine at current scale, revisit when the provider count grows.
  - **No CI pipeline checked in:** neither `.github/` nor any CI runner exists — `dart analyze` and the full test suite currently run locally only.
  - **Residual analyzer findings:** 1 warning (`tools/replace_opacity.dart` — unused local variable) and 4 infos (`lib/main.dart` — the deliberate `depend_on_referenced_packages`, §8.4 `EX-005`; `lib/presentation/pages/settings/sections/slideshow_section.dart` — missing type annotation; `test/preview_test.dart` — deprecated `onPopPage` and an `avoid_print`). All are at or below the §8.3 ratchet floors.
  - **Historical artifacts:** `spec/`, `plan/`, and `Product_Requirement_Document.md` predate several features; treat the code as the source of truth.
- **Resolved Since the Previous Map (2026-10-15 → 2026-10-22):**
  - `docs/ARCHITECTURE_PATTERNS.md` no longer describes a 5-state machine — it was refreshed to v2.1.0 and now documents the verified 9-state model, schema v11, and the real priority chain.
  - `CONTEXT.md` glossary was bootstrapped — 19 domain terms across 3 groups with strict `_Avoid:_` synonym rules.
  - `docs/adr/` was created — `0001-kemenag-sihat-prayer-times.md` and `0002-pure-dart-astronomy-in-domain.md`, both Accepted.
  - The pragmatic `adhan`/`hijri` domain dependency is now formally recorded as ADR-0002 rather than merely flagged as a suggestion.
- **Resolved by the 2026-10-22 Remediation Pass:**
  - `docs/DEVELOPMENT_WORKFLOW.md` drift — the 5-state reference, the fictional `test/{unit,widget,integration}/` layout, the stale `.github/instructions/` memory path, the wrong `adb` applicationId path, and the broken unscoped `dart format .` command were all corrected; a canonical-map banner now points readers to `docs/ARCHITECTURE.md`.
  - `docs/SPECIFICATION_OVERVIEW.md` now flags that SPEC-04 still describes the obsolete 5-state model, so the historical spec cannot be mistaken for an implementation reference.
  - `EX-003` and `EX-004` closed (§8.5); analyzer findings reduced from 6 to 5 (warnings 2→1). `EX-002` was re-measured and reclassified as `EX-005` (§8.4) after an A/B release build proved that the linter's suggested fix costs +1.65 MB of native SQLite in every shipped APK.
  - Release APK size ratchet established at **41.24 MB** (arm64, unminified) — previously unbaselined (§8.3).
- **Recent Architecture Decisions:**
  - `if (isClosed) return;` guard convention for async Cubits after the `emit-after-close` crash — 31 guards across all 6 Cubits (recorded 2026-06-20 in `.agents/instructions/memory.instructions.md`).
  - **[ADR-0001](adr/0001-kemenag-sihat-prayer-times.md)** — Kemenag SIHAT calculation parameters (Subuh 20°, Isya 18°, ihtiyat +2 min) with elevation (DPL) correction.
  - **[ADR-0002](adr/0002-pure-dart-astronomy-in-domain.md)** — pure-Dart `adhan` / `hijri` are permitted inside `lib/domain/`; Flutter, SQLite, and Firebase imports remain forbidden there.
  - Firebase Analytics `logAppOpen` deferred until after the first frame to avoid ANR on TV hardware.
  - Offline-first mandate: Google Fonts runtime fetching disabled; Poppins font bundled in the APK.
- **Reference Documents:** `README.md` · `CONTEXT.md` · `docs/adr/` · `docs/ARCHITECTURE_PATTERNS.md` (illustrative samples; banner flags the divergence from real APIs) · `docs/SPECIFICATION_OVERVIEW.md` · `docs/DEVELOPMENT_WORKFLOW.md` (partially stale) · `docs/EXECUTION_WORKFLOW.md` · `docs/UI_UX_GUIDE.md` · `docs/TESTING_GUIDE.md` · `spec/` · `plan/` · `Product_Requirement_Document.md`.
