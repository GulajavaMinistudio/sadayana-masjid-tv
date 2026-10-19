# Project Memory Log

> This file is managed by the `memory-manager` skill.
> It persists context across AI chat sessions to prevent knowledge loss.
> Do NOT manually edit this file unless necessary.

---

## 📝 Session Checkpoint: 2026-06-03

- **Current SDLC Phase:** Infrastructure / SDLC Tooling Setup (Pre-Development)
- **Active Artifacts:**
  - `AGENTS.md` — Status: ✅ Finalized (Updated with paired Skills mapping)
  - `.opencode/agents/*.md` — Status: ✅ Finalized (All 9 agents refactored to lean persona shells)
  - `.opencode/skills/*/SKILL.md` — Status: ✅ Finalized (All 10 skills created)
- **Achieved Milestones:**
  - Analyzed user's custom SDLC workflow against GitHub Spec Kit; identified and closed gaps (added Clarification and Consistency Check phases)
  - Created 2 new agents: `ClarificationAnalyst.md` and `ArtifactConsistencyChecker.md`
  - Implemented full Separation of Concerns architecture: Agent (Persona/Rules) ↔ Skill (Workflow/Template) for all 9 agents
  - Created 10 skill files total:
    - `product-manager-prd/SKILL.md`
    - `clarification-analyst/SKILL.md`
    - `specification-architect/SKILL.md`
    - `artifact-consistency-checker/SKILL.md`
    - `planner-architect/SKILL.md`
    - `karpathy-guidelines/SKILL.md` (Updated to associate with `@GodModeDev`)
    - `expert-code-reviewer/SKILL.md`
    - `bug-remediation-architect/SKILL.md`
    - `diataxis-documentation-architect/SKILL.md`
    - `memory-manager/SKILL.md`
  - Updated `AGENTS.md` Custom Agents Usage section to list paired Skill names for every agent
  - Updated `AGENTS.md` PROGRESS MEMORY TRACKING rule to delegate to `memory-manager` skill
  - Adopted hybrid memory template inspired by Cline Memory Bank and Claude Session Handoff
  - **Ecosystem Synchronization**: Cloned and adapted all Agents, Skills, and Instructions for native support in Google Antigravity (`.agents/`) and GitHub Copilot (`.github/`).
  - Generated GitHub Copilot-specific `.agent.md` files with YAML frontmatter.
- **Dead-Ends (Do NOT Repeat):**
  - None encountered in this session.
- **Updated Files:**
  - `.opencode/agents/*.md` & `.opencode/skills/*/SKILL.md`
  - `.agents/rules/*.md` (Antigravity Agent Personas)
  - `.agents/skills/*/SKILL.md` (Antigravity Skills)
  - `.agents/instructions/*.md` (Antigravity Global Rules)
  - `.github/agents/*.agent.md` (Copilot Agent Personas)
  - `.github/skills/*/SKILL.md` (Copilot Skills)
  - `.github/instructions/*.md` & `.github/copilot-instructions.md` (Copilot Global Rules)
  - `AGENTS.md` (Universal rules)
- **Decisions Made:**
  - Architecture: Agent files are "Persona", Skill files are "Procedure"
  - Ecosystem scaling: `.opencode/` acts as the Master Source of Truth, which is mirrored/adapted into `.agents/` and `.github/` to ensure native compatibility across VS Code (Copilot), OpenCode, and Antigravity IDE.
- **Next Action / Pending:**
  - Begin actual product development using the newly established SDLC pipeline (start with PRD phase using `@ProductManagerPRD`)
  - Optionally save this checkpoint to version control (`git commit`)

<!-- checkpoint-tail: Completed full Separation of Concerns refactoring for all 9 SDLC agents + 10 paired skills. Synchronized the entire architecture into .agents/ (Antigravity) and .github/ (Copilot) for cross-platform compatibility. Ready to begin actual product development (PRD Phase). -->

---

## 📝 Session Checkpoint: 2026-06-20

- **Current SDLC Phase:** Planning / Bug Remediation
- **Active Artifacts:**
  - `plan/bug-fix-20260620-imam-schedule-emit-after-close.md` — Status: ⏳ Pending (Approved to execute Phase 1)
- **Achieved Milestones:**
  - Investigated fatal crash `Bad state: Cannot emit new states after calling close` originating from `ImamScheduleCubit`.
  - Conducted global codebase audit and identified Async-Lifecycle Race Condition in 4 other cubits: `SettingsCubit`, `SetupWizardCubit`, `SlideshowSectionCubit`, and `DisplayStateCubit`.
  - Created and updated the Implementation Plan (v1.1) for a global architectural fix to add `isClosed` guards.
  - Received user approval to proceed with Phase 1 (Test Writing).
- **Dead-Ends (Do NOT Repeat):**
  - None
- **Updated Files:**
  - `plan/bug-fix-20260620-imam-schedule-emit-after-close.md` — Created and finalized plan.
- **Decisions Made:**
  - Decided on a global refactoring approach rather than an isolated fix, ensuring all async cubits are protected against lifecycle dismounts.
- **Next Action / Pending:**
  - Start executing Phase 1: Write lifecycle tests for the 5 vulnerable cubits (`imam_schedule`, `settings`, `setup_wizard`, `slideshow_section`, `display_state`) using `@GodModeDev`.

<!-- checkpoint-tail: Completed root cause analysis for emit-after-close fatal crash. Audited all cubits and identified 5 vulnerable cubits. Created and received approval for a Global Fix Implementation Plan. Ready to execute Phase 1 (Test Writing). -->

---

## 📝 Session Checkpoint: 2026-06-20 (Bug Fix — Phase 1 & 2 Completed)

- **Current SDLC Phase:** Bug Remediation — ✅ COMPLETED
- **Active Artifacts:**
  - `plan/bug-fix-20260620-imam-schedule-emit-after-close.md` — Status: ✅ Finalized (v1.2)
- **Achieved Milestones:**
  - **Phase 1 (Test Writing):** Berhasil menulis 5 lifecycle test files (17 test cases) yang mereproduksi bug `emit-after-close` di semua cubit yang rentan. Hasil: 15 FAIL / 2 PASS (membuktikan bug terbukti direproduksi).
  - **Phase 2 (Remediation):** Berhasil menambahkan `if (isClosed) return;` guard ke 5 cubit. Total 29 guard ditambahkan.
  - **Lifecycle Test Verification (TASK-016):** 17/17 test PASS.
  - **Full Regression Test (TASK-017):** 535/535 test PASS — tidak ada regresi.
  - **Plan Document:** Diperbarui ke v1.2 dengan status semua task dan hasil aktual.
- **Dead-Ends (Do NOT Repeat):**
  - None
- **Updated Files (Production Code):**
  - `lib/presentation/cubits/imam_schedule/imam_schedule_cubit.dart` — 8 guards ditambahkan
  - `lib/presentation/cubits/settings/settings_cubit.dart` — 7 guards ditambahkan
  - `lib/presentation/cubits/setup_wizard/setup_wizard_cubit.dart` — 2 guards ditambahkan
  - `lib/presentation/cubits/slideshow_section/slideshow_section_cubit.dart` — 11 guards ditambahkan
  - `lib/presentation/cubits/display_state/display_state_cubit.dart` — 1 guard di `_tick()`
- **Updated Files (Tests):**
  - `test/presentation/cubits/imam_schedule/imam_schedule_cubit_lifecycle_test.dart` — NEW (7 test)
  - `test/presentation/cubits/settings/settings_cubit_lifecycle_test.dart` — NEW (4 test)
  - `test/presentation/cubits/setup_wizard/setup_wizard_cubit_lifecycle_test.dart` — NEW (2 test)
  - `test/presentation/cubits/slideshow_section/slideshow_section_cubit_lifecycle_test.dart` — NEW (2 test)
  - `test/presentation/cubits/display_state/display_state_cubit_lifecycle_test.dart` — NEW (2 test)
- **Updated Files (Docs):**
  - `plan/bug-fix-20260620-imam-schedule-emit-after-close.md` — v1.2 (all tasks marked complete)
- **Decisions Made:**
  - Pola standar `if (isClosed) return;` sebelum `emit()` post-await ditetapkan sebagai konvensi arsitektural project untuk semua Cubit di masa mendatang.
  - Referensi pola: `PrayerTimeCubit` (sudah implementasi sejak awal dan menjadi gold standard).
- **Next Action / Pending:**
  - Siap untuk `git commit` dengan pesan deskriptif.
  - Pertimbangkan membuat aturan lint atau code snippet untuk mengingatkan developer agar selalu menambahkan guard saat menulis method async baru di Cubit.
  - Lanjutkan ke fitur berikutnya sesuai roadmap (Plan 13+).

<!-- checkpoint-tail: Bug fix emit-after-close SELESAI PENUH. Phase 1 (17 lifecycle tests) + Phase 2 (29 isClosed guards di 5 cubit). Full test suite 535/535 PASS. Tidak ada regresi. Plan v1.2 difinalisasi. Siap commit dan lanjut ke fitur berikutnya. -->

---

## 📝 Session Checkpoint: 2026-10-15

- **Active Memory Path:** `.agents/instructions/memory.instructions.md`
- **Current SDLC Phase:** Utility: Architecture Mapping (`/to-map`) — ✅ Completed
- **Active Artifacts:**
  - `docs/ARCHITECTURE.md` — Status: ✅ Finalized (canonical architecture map: topology diagram, 9-state machine, seams, 9 invariants, directory matrix, hotspots)
- **Achieved Milestones:**
  - Executed full `/to-map` workflow with source-driven scan of `lib/`, `test/`, `docs/`, `spec/`, `plan/`, `assets/`, `android/`, `tools/`, `landingpage/` (zero assumptions; all counts verified from source).
  - Created `docs/ARCHITECTURE.md` as the canonical architecture map (template-compliant, English technical artifact per AGENTS.md language policy).
  - Verified architectural invariants by import-scan: `lib/domain/` is pure Dart (only `equatable`/`intl`/`adhan`/`hijri`); no `presentation → data` imports; no `data → presentation` imports; `lib/core/` imports no other layer.
  - Verified runtime facts: 9-state sealed `DisplayState` with deterministic priority (prayer → midnight → slideshow → imam_schedule → wisdom → standby, 1 s tick); DB schema v11 (5 tables); 514 cities; 11 wisdom quotes; 114 Dart files in `lib/`; 59 test files; DI = RepositoryProvider ×7 + BlocProvider ×3 global.
  - Added discovery links: `README.md` Dokumentasi table row + `AGENTS.md` Documentation bullet.
- **Dead-Ends (Do NOT Repeat):**
  - None encountered in this session.
- **Updated Files:**
  - `docs/ARCHITECTURE.md` — NEW canonical architecture map (250 lines).
  - `README.md` — added `docs/ARCHITECTURE.md` row to Dokumentasi table (pipe-aligned).
  - `AGENTS.md` — added canonical architecture map link to Documentation bullet.
- **Decisions Made:**
  - `docs/ARCHITECTURE.md` is now the canonical topology document; `docs/ARCHITECTURE_PATTERNS.md` is flagged as partially stale (still describes a 5-state machine vs 9 states in code).
  - Documented pragmatic deviation: `CalculatePrayerTimesUseCase` imports pure-Dart `adhan`/`hijri` inside the domain layer — recommend recording as an ADR.
  - Recommended bootstrapping `CONTEXT.md` (glossary) and `docs/adr/` (decision records) per AGENTS.md expectations.
- **Next Action / Pending:**
  - Update or retire `docs/ARCHITECTURE_PATTERNS.md` (5-state → 9-state drift).
  - Optionally: create `CONTEXT.md` + first ADRs (adhan/hijri domain dependency; Kemenag SIHAT method).
  - Consider `git commit` for the docs changes (no commit requested yet; working tree also holds the `/to-init` polya-sdlc migration).

<!-- checkpoint-tail: /to-map completed — docs/ARCHITECTURE.md created (topology, 9 invariants, drift findings), links added to README.md + AGENTS.md. Hotspot: ARCHITECTURE_PATTERNS.md still describes 5-state machine. -->

---

## 📝 Session Checkpoint: 2026-10-15 (Architecture Patterns Drift Fix + Docs Standards Bootstrap)

- **Active Memory Path:** `.agents/instructions/memory.instructions.md`
- **Current SDLC Phase:** Bypass Mode: `/to-quick-fix` — ✅ Completed (+ documentation standards bootstrap under explicit user-approved session override)
- **Active Artifacts:**
  - `docs/ARCHITECTURE_PATTERNS.md` — Status: ✅ Finalized (v2.1.0; drift fixed: 9-state model, schema v11, canonical-map banner)
  - `CONTEXT.md` — Status: ✅ Created (domain glossary bootstrap, 19 terms, per `.agents/standards/CONTEXT-FORMAT.md`)
  - `docs/adr/0001-kemenag-sihat-prayer-times.md` — Status: ✅ Created (Accepted)
  - `docs/adr/0002-pure-dart-astronomy-in-domain.md` — Status: ✅ Created (Accepted)
- **Achieved Milestones:**
  - Fixed `docs/ARCHITECTURE_PATTERNS.md` drift (1,562 → 1,252 lines, 7 surgical edits): 5-State Hierarchy → verified 9-State model (sealed class + real `StandbyState` sample + per-state trigger table); transition logic → actual priority chain (`prayer → midnight → slideshow → imam_schedule → wisdom → standby`, 1 s tick via `EvaluateDisplayStateUseCase`); UI rendering → real 9-layout switch (class names verified from `MainDisplayPage`); old v1 DB DDL → v11 summary (5 tables, FK, sequential migrations, indexes); repository note + footer (v2.1.0); canonical-map banner with illustrative-sample disclaimer.
  - Bootstrapped `CONTEXT.md` (19 domain terms in 3 groups: Prayer Schedule, Display Features, Mosque Administration) and the first two ADRs in `docs/adr/` using `.agents/standards/` formats.
  - Verified zero residual critical drift via grep (`5-State`, `_dbVersion = 1`, `PrayerTimeRepository`, `_populateCities` all gone). No Dart code touched — docs-only; Flutter test suite unaffected.
  - Session override exercised: `/to-map` → `/to-quick-fix` → standards work in one session (explicitly authorized by user; `[Session Override Active]` marker printed).
- **Dead-Ends (Do NOT Repeat):**
  - None encountered in this session.
- **Updated Files:**
  - `docs/ARCHITECTURE_PATTERNS.md` — 7 surgical drift-fix edits.
  - `CONTEXT.md` — NEW (domain glossary).
  - `docs/adr/0001-kemenag-sihat-prayer-times.md` — NEW (first ADR).
  - `docs/adr/0002-pure-dart-astronomy-in-domain.md` — NEW (second ADR).
- **Decisions Made:**
  - `docs/ARCHITECTURE.md` stays the single canonical topology source; `ARCHITECTURE_PATTERNS.md` is now a pattern guide whose legacy samples (Prayer Calculation, Setup Wizard, Testing) are explicitly flagged as illustrative by the banner — deeper refresh remains an optional follow-up.
  - Kemenag SIHAT standard and pure-Dart astronomy in domain recorded as ADR-0001/ADR-0002.
  - No commits (user instruction); changes stay uncommitted alongside the polya-sdlc toolkit migration.
- **Next Action / Pending:**
  - Optional follow-up: deeper refresh of remaining legacy samples in `ARCHITECTURE_PATTERNS.md`.
  - Optional: `git commit` when the user is ready (docs batch: drift fix + CONTEXT.md + ADRs).
  - `.commandcode/settings.json` still untracked — decide track vs gitignore before committing.

<!-- checkpoint-tail: ARCHITECTURE_PATTERNS.md drift fixed (9-state + schema v11 + banner), CONTEXT.md bootstrapped (19 terms), ADR 0001-0002 created via standards formats. No commit (per user). Pending: optional legacy-sample refresh, commit decision, settings.json tracking. -->

---
