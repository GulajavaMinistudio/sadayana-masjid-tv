---
goal: Repository Architecture and Clean Architecture Seams Documentation
date_created: 2026-10-15
last_updated: 2026-10-15
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
- **Domain Ubiquitous Language:** No `CONTEXT.md` glossary exists yet (recommended bootstrap). Key domain concepts used throughout code and documents: Prayer Time (Subuh, Syuruq, Dhuha, Dzuhur, Ashar, Maghrib, Isya), Pre-Adzan, Adzan, Iqomah, Sholat, Ihtiyat (time correction), Elevation / DPL, Jum'at handling, Display State, Wisdom Quote, Slideshow Announcement, Imam Schedule (imam & khatib), Midnight Standby (power saving), Treasury (Kas Masjid), Running Text.
- **Target Environments:** Android TV / Smart TV / set-top boxes (primary; published on Google Play as `gulajava.mini.miqotul_khoir_tv`, GPL-3.0, app version 1.4.3+14). Windows/Linux/macOS desktop is also supported at runtime via SQLite FFI for development and testing.

---

## 2. High-Level Tech Stack & Tooling

| Dimension | Technologies / Tools | Configuration Files |
| :--- | :--- | :--- |
| **Primary Language(s)** | Dart (SDK ^3.11.0); Kotlin (Android host layer) | `pubspec.yaml`, `android/app/build.gradle.kts` |
| **Core Frameworks** | Flutter (Material); `flutter_bloc` 9 (Cubit); `flutter_screenutil` (1920×1080 baseline); `google_fonts` (Poppins bundled offline) | `pubspec.yaml`, `lib/core/theme/` |
| **Persistence / Storage** | SQLite via `sqflite` (schema v11, 5 tables); `path_provider` app-directory file storage for slideshow images; bundled JSON seed assets | `lib/data/datasources/database_helper.dart`, `assets/data/` |
| **Domain Calculation** | `adhan` (astronomical prayer times); `hijri` (Hijri calendar); `intl` (id_ID formatting); `crypto` (SHA-256 PIN hashing) | `pubspec.yaml` |
| **Audio & Media** | `audioplayers` + `audioplayers_android_exo` (pre-adzan/pre-iqomah alerts); `image_picker` (slideshow images); `marquee` (running text) | `pubspec.yaml`, `assets/sound/` |
| **External SaaS** | Firebase Analytics + Crashlytics (project `mqotulkhoir7`; monitoring only, off the critical path) | `firebase.json`, `lib/firebase_options.dart` |
| **Build & Packaging** | Flutter + Gradle Kotlin DSL; `compileSdk 36`, `minSdk 24`, `targetSdk 36`; multiDex; core library desugaring; release signing via `signing.properties` | `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml` |
| **Testing Harnesses** | `flutter_test`, `bloc_test`, `mocktail`, `sqflite_common_ffi` (in-memory SQLite), `fake_async` — 59 test files under `test/` | `test/`, `pubspec.yaml` |
| **Linter & Formatters** | `flutter_lints` (recommended Flutter preset) | `analysis_options.yaml` |

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
| INV-005 | **Async Cubit lifecycle safety** | Convention after the `emit-after-close` incident: `if (isClosed) return;` before every post-`await` `emit()` (29 guards across 5 Cubits, recorded 2026-06-20) |
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
├── assets/                          # data (JSON), fonts (Poppins), images, sound
├── android/                         # Android TV host project (Gradle Kotlin DSL)
├── spec/                            # 6 technical specifications (SDLC history)
├── plan/                            # 37 feature / bugfix implementation plans
├── docs/                            # Guides + this architecture map
├── tools/                           # One-off Python/Dart automation scripts
├── landingpage/                     # Static HTML promo & user-guide pages
├── .agents/ · .github/ · .commandcode/   # AI-agent SDLC toolkit (skills, rules, instructions)
└── [root files]                     # pubspec.yaml, analysis_options.yaml, firebase.json, AGENTS.md, README.md, ...
```

### 6.2 Directory Responsibilities Matrix

| Directory / Module | Primary Purpose | Clean Architecture Layer | Allowed Dependencies | Rules & Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `lib/domain/` | Entities, use cases & ports | Entities + Use Cases (Core) | Pure Dart (`equatable`, `intl`, `adhan`, `hijri`) | Zero Flutter/SQLite/Firebase imports (verified); no dependency on outer layers |
| `lib/data/` | SQLite, file & audio adapters | Interface Adapters + Frameworks & Drivers | `lib/domain/`, `sqflite`, `path_provider`, `audioplayers`, `image_picker` | Implements domain ports; must not import `lib/presentation/` (verified) |
| `lib/presentation/` | Cubits, pages, widgets | Interface Adapters (presenters) | `lib/domain/`, `lib/core/`, `flutter_bloc`, ScreenUtil | Must not import `lib/data/` (verified); feature pages use page-scoped Cubits |
| `lib/core/` | Islamic theme tokens & TV sizing helpers | Shared UI primitives | Flutter only | No `data`/`domain`/`presentation` imports (verified) |
| `test/` | Automated suites mirroring `lib/` | Verification | All layers + `bloc_test`, `mocktail`, `sqflite_common_ffi`, `fake_async` | In-memory SQLite for repository tests; 59 test files |
| `assets/` | Seed JSON, fonts, images, alert sounds | Resources | — | `cities.json` (514 records) · `wisdom_quotes.json` (11 catalog) · Poppins bundled for offline use |
| `spec/` · `plan/` · `docs/` | SDLC artifacts (specs, plans, guides) | Documentation | — | Historical documents may drift from code; code is the source of truth |
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
- **Static Analysis:** `analysis_options.yaml` (`flutter_lints`).
- **CI / Build Pipeline:** none checked in (`.github/workflows/` is absent). Quality gates run locally per `docs/DEVELOPMENT_WORKFLOW.md`: `dart format .` → `dart analyze` → `flutter test --reporter=expanded` → `flutter build apk`.

---

## 8. Architectural Health & Known Seams

- **Primary Seams:**
  - **Domain ports** — 6 repository interfaces + 2 service interfaces; new capabilities enter through a new port/adapter pair.
  - **Sealed `DisplayState`** — new display modes are additive: state class + evaluation window + layout.
  - **Versioned settings singleton** — optional features add columns through a new `if (oldVersion < N)` migration block.
  - **Composition root** — `lib/main.dart` is the single registration point for new repositories and Cubits.
  - **Page-scoped Cubit pattern** — feature sections (Slideshow, Imam Schedule) instantiate and dispose their own Cubit locally.
- **Technical Debt / Hotspots:**
  - **Documentation drift:** `docs/ARCHITECTURE_PATTERNS.md` still describes a 5-state machine while production code implements 9 states. Update or retire that pattern document.
  - **Pragmatic domain dependency:** `CalculatePrayerTimesUseCase` imports the third-party pure-Dart libraries `adhan` and `hijri` inside the domain layer. Acceptable pragmatism (no Flutter/infra coupling), but worth recording as an ADR.
  - **Manual DI in `main.dart`:** all wiring lives in one widget builder; fine at current scale, revisit when the provider count grows.
  - **Missing scaffolding:** no `CONTEXT.md` glossary and no `docs/adr/` directory; `AGENTS.md` expects both for terminology and decision records.
  - **No CI pipeline checked in:** `dart analyze` and the full test suite currently run locally only.
  - **Historical artifacts:** `spec/`, `plan/`, and `Product_Requirement_Document.md` predate several features; treat the code as the source of truth.
- **Recent Architecture Decisions:**
  - `if (isClosed) return;` guard convention for async Cubits after the `emit-after-close` crash — 29 guards applied across 5 Cubits (recorded 2026-06-20 in `.agents/instructions/memory.instructions.md`).
  - Kemenag SIHAT calculation parameters (Subuh 20°, Isya 18°, ihtiyat +2 min) with elevation (DPL) correction.
  - Firebase Analytics `logAppOpen` deferred until after the first frame to avoid ANR on TV hardware.
  - Offline-first mandate: Google Fonts runtime fetching disabled; Poppins font bundled in the APK.
- **Reference Documents:** `README.md` · `docs/ARCHITECTURE_PATTERNS.md` (partially stale) · `docs/SPECIFICATION_OVERVIEW.md` · `docs/DEVELOPMENT_WORKFLOW.md` · `docs/EXECUTION_WORKFLOW.md` · `docs/UI_UX_GUIDE.md` · `docs/TESTING_GUIDE.md` · `spec/` · `plan/` · `Product_Requirement_Document.md`.
