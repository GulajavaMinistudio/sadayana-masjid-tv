# Project Memory Log

> Active Location: `.agents/instructions/memory.instructions.md`
> This file is managed by the `to-memory` skill.
> It persists context across AI chat sessions to prevent knowledge loss.
> Do NOT manually edit this file unless necessary.

---

## 🧠 Knowledge Base

> This section accumulates cross-session knowledge that must survive compaction.
> Do NOT delete entries here.
> **Compacted 2026-10-23:** checkpoints from 2026-06-03 → 2026-10-22 (6 sessions) removed after promotion; their durable findings now live below. Retained: the two most recent 2026-10-23 checkpoints.

### Architecture & Patterns

- **Flutter-native version identity (no plugin required):** Flutter ≥ 3.41 ships `appBuildName` / `appBuildNumber` as public constants exported from `package:flutter/services.dart` (`flutter/lib/src/services/app_version.dart`). The Flutter tool injects `FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER` as compile-time dart-defines from `pubspec.yaml`'s `version:` field (`flutter_tools/lib/src/runner/flutter_command.dart:1506-1514` → `build_info.dart:364`). The value is baked into the compiled AOT binary, so it always describes the running code. Use this instead of `package_info_plus` for any in-app version display — zero new dependency, zero AGP change, synchronous `const`, trivially assertable in tests. `flutter test` injects the same define (`flutter_tools/lib/src/commands/test.dart:433`). [Source: Session 2026-10-22]
- **`appBuildName` / `appBuildNumber` are genuinely `null` when the define is absent:** the SDK accessor is `bool.hasEnvironment('FLUTTER_BUILD_NAME') ? String.fromEnvironment(...) : null` (`app_version.dart:17-19, 29-31`). Consequence: a null-manifest branch **cannot be instantiated** by any `flutter test` invocation (the guard is constant-folded), and `--dart-define=FLUTTER_BUILD_NAME=` yields the *empty string*, not `null`. [Verified 2026-10-23]
- **Prove an uninstantiable branch by exhaustion, not by mocking:** when an input state cannot exist in the test environment, assert that the output is a member of the *only two* possible values — e.g. `displayName ∈ {buildName, unavailable}` — plus the properties of the fallback (non-empty, non-numeric). This covers both branches without fabricating either, and a re-introduced hardcoded fallback fails immediately. A mocked source would test the mock, not the build. [Source: Session 2026-10-23]
- **Guard tests must use an EXTERNAL oracle:** when asserting that a value matches its source of truth, parse the source file from disk — never compare two app-internal constants. Comparing `AppVersion.buildName` to `appBuildName` is self-referential and would still pass if the toolchain stopped injecting the define (both sides become `null`). The `pubspec.yaml`-parsing pattern is the correct external oracle. [Source: Session 2026-10-22]
- **A quality gate must be MEASURED before it is written into a plan:** a gate that is red by construction manufactures Floor-Guard pressure — the implementer's only escapes are widening scope, lowering a floor, or adding a suppression, and all three are forbidden. Bind the exact command, run it at baseline, and record the number. [Source: Session 2026-10-23]
- **Analyzer gate scope is part of the gate:** `dart analyze` (whole package) reports **1 warning** from `tools/replace_opacity.dart` and exits 2; `dart analyze lib test` reports **0 warnings / 4 infos** and exits 0. Bind `dart analyze lib test` whenever the acceptance criterion is scoped to `lib`/`test`. [Measured 2026-10-23]
- **`dart format --set-exit-if-changed` is not a boolean gate on this repo:** it exits 1 at baseline because 15 pre-existing files are unformatted. The gate must **count the `Changed` lines** and compare against the measured baseline, plus assert the change-set files are absent from the list. [Measured 2026-10-23]
- **Markdown tables break on raw pipes, and the workaround breaks Dart:** a `|` inside a code span still splits a GFM cell, while escaping it as `\|` inside a Dart raw string becomes a literal-escape bug when copied. Express alternations as **two separate patterns** instead of one `a | b` alternation. [Source: Session 2026-10-23]
- **Version drift's root cause is an unenforced duplicate source of truth:** a version restated in N places diverges; this project shipped six consecutive releases (`1.2.4+7` → `1.4.4+15`) without updating the About literal (`1.2.2`/`5`). Fix the *structure* (single seam bound to the build) and add a guard; do not fix the literal. [Source: Session 2026-10-22]
- **Cubit async-lifecycle guard convention:** Every `await` inside a Cubit method must be followed by `if (isClosed) return;` before any `emit()`. Prevents the fatal `Bad state: Cannot emit new states after calling close`. 29 guards across 5 cubits; `PrayerTimeCubit` is the gold-standard reference. [Source: Session 2026-06-20]
- **Layer purity invariants (verified, must not regress):** `lib/domain/` imports only pure Dart (`equatable`, `intl`, `adhan`, `hijri`) — zero Flutter/SQLite/Firebase; `lib/presentation/` must not import `lib/data/`; `lib/data/` must not import `lib/presentation/`; `lib/core/` imports no other layer. [Source: Session 2026-10-15]
- **Documentation authority order:** `docs/ARCHITECTURE.md` is the canonical topology source; `CONTEXT.md` is the canonical ubiquitous-language glossary (**20 terms** as of 2026-10-23, strict `_Avoid_` synonyms — `Sholat` was added that day); `docs/adr/` holds irreversible decisions (`0001-kemenag-sihat-prayer-times`, `0002-pure-dart-astronomy-in-domain`). `docs/ARCHITECTURE_PATTERNS.md` is a pattern guide whose legacy samples are explicitly flagged illustrative. `spec/`, `plan/`, and `Product_Requirement_Document.md` predate several features — the code is the source of truth for runtime behavior. [Source: Session 2026-10-15, count corrected 2026-10-23]
- **Dart string constants are observable in the compiled AOT artifact:** `String.fromEnvironment` values and ordinary string literals are inlined into the Dart snapshot, so they are byte-searchable in the release `libapp.so`. The **uncompressed** AOT library is already in the build tree at `build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/<abi>/libapp.so` — no APK unzip required — so an artifact-level assertion can be written with `dart:io` alone and **zero new dependencies**. [Source: Session 2026-10-23]
- **Anti-regression guards should assert on the ABSENCE of members, not on a literal-shape regex:** a `<digits>.<digits>.<digits>` pattern matches a version but **cannot** match a bare build number, so it silently misses half of a coupled-literal defect. Asserting "no file declares a `version` / `buildNumber` display constant, and every marker-bearing surface imports the canonical holder" is strictly stronger and immune to the "is `'15'` a version or a build number?" ambiguity. [Source: Session 2026-10-23]
- **Recurring drift mode — "the table was updated, the prose qualifying it was not":** observed **five** times (seam count vs. table, assumption verification text vs. criterion, constraint precision vs. acceptance criterion, lead sentence counting rows beneath it, and change-set arithmetic "2 created, 3 modified" vs. a 3+2 reality). The remedy is a **re-audit pass that diffs prose against tables**, not a checklist review. [Source: Session 2026-10-23]
- **Adding a glossary term shifts every subsequent line citation:** inserting a term into `CONTEXT.md` moves every entry below it, silently invalidating the `CONTEXT.md:NN` anchors of every dependent document. After any glossary amendment, **re-resolve every anchor against the live file**. [Source: Session 2026-10-23]
- **Agent/Skill separation of powers (SDLC toolkit):** agent files are *personas*, skill files are *procedures*; `.opencode/` was the original master, mirrored into `.agents/` (Antigravity) and `.github/` (Copilot). Phases are session-locked: an Auditor records findings and hands remediation to the authoring phase — it never edits the artifact it audits. [Source: Session 2026-06-03]

### Dead-Ends (Do NOT Repeat)

| # | Attempted | Why It Failed | Correct Solution |
|---|-----------|---------------|------------------|
| 1 | Adding `package_info_plus` to read the installed app version at runtime | Requires Android Gradle Plugin ≥ 8.12.1; the project is on AGP 8.11.1. It would force an AGP + Gradle + Kotlin toolchain upgrade (an XL change) to obtain runtime truth that a static read-only string does not need. Also adds APK bytes against the 41.24 MB ratchet floor. | Use Flutter's built-in `appBuildName` / `appBuildNumber` from `package:flutter/services.dart` — same outcome, zero dependency, zero toolchain change. |
| 2 | `dart format .` at the repository root | Crashes with `PathNotFoundException` while walking `build/` (Flutter plugin transform artifacts). | Always scope to `dart format lib test`. |
| 3 | `rm` / `tail` piped commands in the shell tool on Windows | The Windows shell wrapper does not provide these Unix utilities; `rm` fails with "not recognized as an internal or external command". Also: a `;` inside a `dart` invocation is parsed as a *command name* ("Could not find a command named `analyze;`"). | Use the PowerShell tool with `Remove-Item` / `Select-Object`; issue one command per invocation. |
| 4 | Treating the About page's "5 mode tampilan otomatis" claim as an intentional marketing simplification | It contradicted `CONTEXT.md` ("one of the **nine** automatic screen modes") and `docs/ARCHITECTURE.md` ("9-state automatic display machine"). The four extra states are fully reachable via user-facing settings toggles — not dead enum members. | Always validate user-facing copy against `CONTEXT.md` and the enum, not against assumption. |
| 5 | Verifying that a release/AOT build carries the manifest version by running `flutter build apk --debug` | `--debug` produces a **JIT** artifact (kernel snapshot), **not** an AOT build — the release path that actually ships was never observed. | Separate the claim: prove the injection is build-mode-agnostic by source inspection of `flutter_command.dart`; prove the artifact's value by byte-searching the **release** `libapp.so`. Never let a debug result stand in for an AOT one. |
| 6 | Guarding a version invariant by asserting one hard-coded filename imports the seam | True by construction and never examines a new surface — a tautology, not a guard. The exact regression it exists to catch (a second version-displaying surface using a literal) would pass silently. | Marker-based scan: strip comments, match the rendered markers (`RegExp(r'Versi ')` / `RegExp(r'Build ')`), require the seam import; plus an absence scan for `version`/`buildNumber` display members. Add the known consumer as a second layer only — a closed allowlist is brittle. |
| 7 | Binding a whole-package `dart analyze` and a `--set-exit-if-changed` formatter run as boolean gates | Both are red at baseline (1 pre-existing warning; 15 unformatted files, exit 1). A permanently red gate invites the three forbidden escapes: widen scope, lower a floor, add a suppression. | Measure first, then bind: `dart analyze lib test` (0 warnings / 4 infos) and count `Changed` lines of `dart format --output=none --set-exit-if-changed lib test` against the measured baseline. |

### Key Metrics & Baselines

- **Passing tests:** `535 / 535` across 59 test files — `flutter test --reporter=expanded`, ≈ 26 s. [Measured 2026-10-22]
- **Analyzer findings:** whole-package `dart analyze` = 0 errors / **1 warning** / 4 infos (exit 2; the warning is `tools/replace_opacity.dart`). Scoped `dart analyze lib test` = **0 errors / 0 warnings / 4 infos** (exit 0). Floors: warnings `≤ 1`, infos `≤ 4`. [Measured 2026-10-23]
- **Unformatted Dart files:** `15` (`lib` + `test`) via `dart format --output=none --set-exit-if-changed lib test`. Supersedes the previously recorded `16`. [Measured 2026-10-23]
- **Release APK size:** `41.24 MB` (43,240,043 bytes), arm64, unminified (`isMinifyEnabled = false`). Ratchet floor — must not grow. [Measured 2026-10-22]
- **Database schema:** v11, 5 tables, sequential `if (oldVersion < N)` migrations. [Verified 2026-10-15]
- **City dataset:** 514 cities across 34 provinces (`assets/data/cities.json`). [Verified 2026-10-22]
- **Display State model:** 9 sealed states with deterministic priority — prayer cycle (Pre-Adzan → Adzan → Iqomah → Sholat) → Midnight Standby → Slideshow Announcement → Imam Schedule → Wisdom Quote → Standby (fallback), on a 1 s tick. [Verified 2026-10-22]
- **Domain glossary:** `CONTEXT.md` holds **20 terms** across 3 groups (19 + `Sholat`, added 2026-10-23). [Verified 2026-10-23]
- **Flutter / Dart:** Flutter 3.47.6 stable, Dart 3.13.5, SDK constraint `^3.11.0`. [Verified 2026-10-22]
- **Android toolchain floor:** AGP 8.11.1, Gradle 8.14, Kotlin 2.2.20, minSdk 24, `compileSdk`/`targetSdk` 37. Flutter 3.47.6 template ships AGP 9.1.0 / Gradle 9.3.1 / Kotlin 2.4.0 — the project trails the template and emits three "will soon be dropped" warnings. `compileSdk 37` is unsupported by AGP 8.11.1 (caps at API 36); the build still succeeds. [Verified 2026-10-22]

---

## 📝 Session Checkpoint: 2026-10-23 (Version-Drift Spec — 3 Clarification Iterations, Readiness 100/100)

- **Active Memory Path:** `.agents/instructions/memory.instructions.md`
- **Current SDLC Phase:** Phase 1 (Specification) — ✅ Complete and verified.
- **Active Artifacts:**
  - `docs/discovery/about-page-version-drift-discovery.md` — Status: ✅ Finalized (280 lines, upstream)
  - `docs/spec/about-page-version-drift-spec.md` — Status: ✅ **v1.2.0** (722 lines) — 7 REQ · 9 CON · **14 AC**. Readiness Score **100/100** (Completeness 40 · Clarity 30 · Alignment 30 · Critical Flaw Veto: none), verified by three independent clarification iterations.
  - `docs/audit/about-page-version-drift-spec-clarification.md` — Status: ✅ Finalized (535 lines) — Iterations 1 (79), 2 (91), 3 (100, post-remediation verification)
  - `docs/audit/about-page-version-drift-spec-decisions.md` — Status: ✅ Finalized (97 lines) — Grilling Alignment Log
- **Achieved Milestones:**
  - **Resolved the spec's blocking contradiction (C1).** `REQ-004` (every named Display State must be a `CONTEXT.md` term) contradicted `AC-005` (all nine states must be named), because `CONTEXT.md` named only **eight of nine** — "Sholat" was the sole omission. Owner chose **Option A**: add the term. `CONTEXT.md` now defines all nine Display States.
  - **Corrected the mandated About copy.** Now `9 status tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → Sholat → Slideshow Announcement → Imam Schedule → Wisdom Quote → Midnight Standby` — "status" instead of "mode", matching four domain-layer precedents and clearing the `CONTEXT.md` `_Avoid_: screen mode` collision.
  - **Proved empirically that the defect reached the AOT path.** Read-only byte-scan of the existing release `libapp.so`: `"1.2.2"` present, `"1.4.4"` absent.
  - **Closed the anti-regression guard hole.** `AC-011` rewritten from a `<digits>.<digits>.<digits>` regex (cannot match a bare build number) to a **structural assertion**.
  - **Added `AC-014`** for the mixed-null manifest branch (`version: 1.4.4` with no `+`).
  - **Re-aligned every `CONTEXT.md:NN` anchor** after the glossary amendment shifted all entries below it.
- **Updated Files:** `CONTEXT.md` (+1 term `Sholat`), `docs/spec/...-spec.md` (v1.0.0 → v1.2.0, 31 surgical edits), `docs/audit/...-spec-clarification.md` (new), `docs/audit/...-spec-decisions.md` (new). **No production code touched.**
- **Decisions Made:** `AC-004` verification = `flutter test --dart-define=…` only (release byte-scan declined, recorded as a `CAUTION` with a release-gate mitigation hook). Audit/Author separation preserved; the third verification pass caught two self-inflicted defects from the preceding remediation.
- **Next Action / Pending:** `/to-plan` (completed in the following checkpoint).

<!-- checkpoint-tail: Version-drift spec reached 100/100 at v1.2.0 with 14 AC after three clarification iterations; blocking contradiction resolved by adding "Sholat" to CONTEXT.md; AC-011 hardened to a structural assertion; AC-014 added for the mixed-null branch. Next: /to-plan. -->

---

## 📝 Session Checkpoint: 2026-10-23 (Phase 2 — Plan Authored, Audited, Remediated to 100/100)

- **Active Memory Path:** `.agents/instructions/memory.instructions.md`
- **Current SDLC Phase:** Phase 2 (Devising a Plan) — ✅ Complete at **100/100**. 🛑 **Pause Rule pending:** awaiting explicit owner approval before `/to-code`. No production code written.
- **Active Artifacts:**
  - `docs/plan/about-page-version-drift-plan.md` — Status: ✅ **v1.2.0**, 15 tasks across 4 phases, **Readiness 100/100** (Completeness 40 · Clarity 30 · Alignment 30). Change set: 3 CREATE + 2 MODIFY (+ `CONTEXT.md` pre-completed).
  - `docs/audit/about-page-version-drift-plan-clarification.md` — Status: ✅ Finalized — Iteration 1 scored **79/100** (Critical Flaw Veto), now stamped `REMEDIATION STATUS: RESOLVED` with projection `79 → 96 → 100`.
- **Achieved Milestones:**
  - Authored the plan implementing Spec v1.2.0 as **4 phases / 15 tasks** (all XS–S, max 2 files, vertical slices, every phase ending in `VERIFY` + `APPROVAL`): P1 seam + manifest oracle; P2 nine-state copy + widget harness; P3 structural scan, build-override proof, D-Pad invariance; P4 living docs + release gate.
  - **Audited the plan and found 6 real defects, 2 of them measured against the live toolchain** — see KB Dead-End #7. Scored 79/100 with the Critical Flaw Veto, because both gates were red by construction.
  - **Owner decisions recorded:** (a) `AC-011` detection rule = **Option A marker-based scan** (strip comments → match `RegExp(r'Versi ')`/`RegExp(r'Build ')` → require the seam import; plus absence scan), with the known consumer as a second layer and a **closed allowlist explicitly rejected** as brittle; (b) `TASK-013` keeps both `docs/ARCHITECTURE.md` drift corrections (`19→20 terms`, stale `1.4.3+14`) as an owner-sanctioned addition to the Spec §8 mandate, exact scope only — anything further is `NOTICED BUT NOT TOUCHING`.
  - **Remediation pass 1 (v1.1.0):** eight surgical corrections — scoped analyzer, formatter count semantics, change-set arithmetic, `AC-003` locus, `TASK-009` cross-reference, override-isolation rule, `TASK-008` rewrite, gate-semantics note. Projection 96.
  - **Refinement pass 2 (v1.2.0):** four closures to reach 100 — (i) `AC-003` proven by **exhaustion** (`displayName ∈ {buildName, unavailable}`, independently for each field, + non-empty/non-numeric placeholder) so it no longer rests on an uninstantiable `null` branch; (ii) `CON-006` proven by an import scan; (iii) **STEP-0 Baseline Capture** block removing every "moving number"; (iv) `RISK-002` empty-string-define defence actually asserted in `TASK-002`.
  - Pre-verified `TASK-008`'s expected match set: only `about_section.dart:17,18,163` in all of `lib/presentation`; `splash_page.dart:51` has a lower-case *"versi lama"* comment that the capitalised marker and comment-stripping both neutralise.
- **Dead-Ends (Do NOT Repeat):** KB #6 (tautological single-filename guard) and KB #7 (boolean gates red by construction) were both discovered and rejected in this session. KB #2/#3 also applied.
- **Updated Files:**
  - `docs/plan/about-page-version-drift-plan.md` — NEW, then v1.0.0 → v1.1.0 → **v1.2.0** via surgical edits only.
  - `docs/audit/about-page-version-drift-plan-clarification.md` — NEW (190 lines): 7 findings (C-1…C-7), 5-Axis matrix, decision log, three-column score projection.
  - `.agents/instructions/memory.instructions.md` — KB extended, 6 old checkpoints compacted, this checkpoint appended.
  - **`lib/` and `test/` are untouched.** `docs/plan/` and `docs/audit/` are still untracked; no commits made.
- **Decisions Made:**
  - Every gate is **baseline-relative**, never exit-code-zero; thresholds were measured before being written.
  - The proposed 3-way task split from the planning Q&A (`TASK-005A/B`, `013A/B`, `014A/B` → 18 tasks) was **proposed but NOT applied** — the plan still has **15 tasks**. Do not assume it exists.
  - Plan-level residuals carried to `/to-review`: the Spec §7 table still has no `AC-003` locus (plan supplies it; Spec row is an optional Phase-1 follow-up) and release-AOT version parity remains a manual release-gate inspection by owner decision.
- **Next Action / Pending:**
  - **Await explicit owner approval of the Pause Rule**, then run `/to-code @docs/plan/about-page-version-drift-plan.md` (interactive recommended over `auto`, because `TASK-001` touches production code and `TASK-008` depends on the final shape of `about_section.dart`).
  - Out of scope, deliberately: Android toolchain upgrade (AGP 8.11.1 → 9.1.0 / Gradle 8.14 → 9.3.1 / Kotlin 2.2.20 → 2.4.0) and decoupling `landingpage/panduan.html:3254`'s hardcoded `1.2.2 (build 5)`.
  - Commit decision pending: `docs/spec/`, `docs/audit/`, `docs/discovery/`, `docs/plan/` are untracked; `CONTEXT.md`, `AGENTS.md`, and this file are modified.

<!-- checkpoint-tail: Phase 2 COMPLETE — plan v1.2.0 at 100/100 (15 tasks, 4 phases, 3 CREATE + 2 MODIFY), audit 79→96→100 with two measured gate defects fixed and AC-003 proven by exhaustion. Pause Rule pending explicit approval; no production code touched. Next: /to-code interactive. Split proposal NOT applied. -->

---
