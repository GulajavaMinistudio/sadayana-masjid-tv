# 🔍 Clarification Report [Review Iteration 1]

**Target Document:** `docs/plan/about-page-version-drift-plan.md`  
**Upstream Reference:** `docs/spec/about-page-version-drift-spec.md` (v1.2.0, Readiness 100/100)  
**Canonical Output Path:** `docs/audit/about-page-version-drift-plan-clarification.md`  
**Readiness Score:** **79 / 100**  
**Status:** **Refine Required (Score < 80 — Critical Flaw Veto triggered)**  
**Audited:** 2026-10-23

> [!SUCCESS]
> **REMEDIATION STATUS: RESOLVED**
> This implementation plan has been remediated by Pólya Tactical Planner — plan `v1.0.0` → `v1.1.0` → **`v1.2.0`** (2026-10-23).
> - **Projected Readiness Score:** **100/100**
> - **Iteration 2 refinements (v1.1.0 → v1.2.0) closed the final four points:** (i) `AC-003` is now proven by **exhaustion** — `displayName ∈ {buildName, unavailable}` and `displayBuildNumber ∈ {buildNumber, unavailable}`, asserted independently, plus non-empty/non-numeric placeholder — so it no longer rests on an unprovable `null` instantiation; (ii) `CON-006` gained a mechanical import scan instead of a location claim; (iii) a **STEP-0 baseline capture** block removes the "moving number" ambiguity from every threshold; (iv) `TASK-002` now also asserts the empty-string-define defence (`RISK-002`) that §6 already required.
> - **Applied (all eight §5 items):** scoped `dart analyze lib test` at every gate; formatter gate restated as a **count** (`≤ 15`, measured) with the exit-code caveat; change-set arithmetic corrected to **3 created / 2 modified**; `AC-003` method recorded; `TASK-009` cross-reference corrected to §10; override-isolation rule added to `TASK-011`; `TASK-008` rewritten to the marker rule (seven steps); gate-semantics note with the measured baseline table.
> - **Remaining non-blocking notes (not gaps):** the Spec's §7 table still omits an `AC-003` locus — the plan supplies it and the Spec row is an optional Phase-1 follow-up; release-AOT version parity remains a manual release-gate inspection by owner decision.

---

<!-- markdownlint-disable-->

## 📊 Score Breakdown (Quality Gate Rubric)

- **Completeness (40%):** `32` / 40  
  *Rationale:* All 14 acceptance criteria are mapped to at least one task; the phase sequence, Plan B contingencies, rollback, and risk register are present. Deductions: `AC-003` is bound to a verification method the plan invents (its upstream locus is undefined — see C-4), `AC-011`'s detection rule is under-specified (C-5), and no task verifies `CON-006` (domain purity) other than by absence of a file in `lib/domain/`.
- **Clarity (30%):** `22` / 30  
  *Rationale:* Two gate definitions pair a command with a pass condition that the command cannot produce (C-1, C-2 — measured, not inferred). Three arithmetic/cross-reference drifts exist inside the plan (C-3, C-6), and one scope addition in `TASK-013` is not authorised by the upstream Spec (C-7).
- **Alignment (30%):** `25` / 30  
  *Rationale:* Terminology, file set, and traceability align with the Spec and `CONTEXT.md`; the deviations are confined to the two gate-semantics defects and the unauthorised documentation scope in `TASK-013`.
- **Critical Flaw Veto:** `Triggered`  
  *Reason:* C-1 and C-2 define quality gates that are **red by construction** at the current baseline. A gate that cannot go green invites a Floor-Guard violation (lowering a threshold to pass), which `docs/ARCHITECTURE.md` §8.1 forbids outright. Maximum allowable score capped at **79**.

---

## 🧭 5-Axis Structured Interrogation & Epistemic Doubt Matrix

| Interrogation Axis | Coverage & Epistemic Verification | Status |
| :--- | :--- | :---: |
| **1. Goal & Premise Doubt (*Examine Your Guess*)** | The premise is sound and independently re-verified: `appBuildName` / `appBuildNumber` are genuinely `null` when the define is absent (`app_version.dart:17-19, 29-31` uses `bool.hasEnvironment`), so `REQ-005` is satisfiable as written. Plan's `RISK-001` / `RISK-002` honestly disclose the two residual limits. | `[VERIFIED]` |
| **2. User Flows & 5 UI States** | Spec §4.3 establishes a single reachable `Populated` state with the other four explicitly N/A (compile-time `const`, no async source). Plan does not contradict this. | `[VERIFIED]` |
| **3. Edge Cases & Failure Modes (*Sad Paths*)** | Plan B-1/B-2/B-3 cover asset-decode failure, CWD-dependent manifest resolution, and missing AOT artifact. Gaps: the override-run isolation hazard (C-8) and the undefined `AC-011` detection rule (C-5). | `[GAP]` |
| **4. Technical Seams & Quality Ratchets** | Seam placement (`lib/core/`), dependency direction, and change-set confinement match Spec §5.1–5.4. Since 8.2/8.3 gate semantics are mis-stated in three tasks (C-1, C-2). | `[GAP]` |
| **5. Scope Boundaries & Non-Goals** | `CON-009` fence restated in `TASK-014` (`git diff --stat pubspec.yaml android/` empty). One over-reach in `TASK-013` (C-7). | `[GAP]` |

---

## 1. 🚨 Critical Findings & Blocking Gaps

### C-1 — Analyzer gate pairs the wrong command with the wrong pass condition (Blocking)

- **Condition / Requirement (plan §3, `TASK-003`, `TASK-006`, `TASK-011`, `TASK-014`):**
  > "`dart analyze` … Pass conditions: **0 errors / 0 warnings / ≤ 4 infos**"
  > Spec `AC-009` requires: "`dart analyze lib test` … **0 errors, 0 warnings, ≤ 4 infos** — *Scope note:* this is the `lib`/`test`-scoped measurement, which currently reports 0 warnings; the single warning permitted by the ratchet lives in `tools/replace_opacity.dart` and is outside this scope."
- **The Flaw:** The plan binds the **unscoped** command to the **scoped** pass condition. Measured on 2026-10-23 against the current tree:

  | Command | Errors | Warnings | Infos | Exit |
  | :--- | :---: | :---: | :---: | :---: |
  | `dart analyze` (whole package) | 0 | **1** | 4 | **2** |
  | `dart analyze lib test` (scoped) | 0 | **0** | 4 | 0 |

  The single warning is `tools\replace_opacity.dart:6:7 - unused_local_variable`. Under the plan as written, **every** `VERIFY` gate in Phases 1–4 fails on a pre-existing, out-of-scope finding.
- **Architectural Impact:** A `/to-code` agent hitting a permanently red gate faces exactly the pressure the Floor-Guard exists to resist — it may "fix" `tools/replace_opacity.dart` (scope violation, `CON-009`), lower the warning floor (§8.1 violation), or add a suppression (`CON-007` violation). All three are forbidden outcomes caused by a documentation defect, not an implementation defect.

### C-2 — The formatter gate is red by construction, and its baseline is stale (Blocking)

- **Condition / Requirement (plan §3 `TASK-014`):**
  > "`dart format --output=none --set-exit-if-changed lib test` (**≤ 16 files**, and every file touched by this plan formatted)"
  > `docs/ARCHITECTURE.md` §8.3 records the floor as `16`.
- **The Flaw:** Two defects in one clause.
  1. **Exit-code semantics.** `--set-exit-if-changed` returns `1` whenever *any* file is unformatted. Measured 2026-10-23: **exit 1**, `Formatted 173 files (15 changed)`. The gate therefore cannot be green today regardless of this plan's work — so "pass condition ≤ 16 files" is not what the command reports.
  2. **Stale baseline.** The measured count is **15**, not the 16 recorded in §8.3 (measured 2026-10-22). The floor has silently drifted, and `TASK-014`'s mandate to "ratchet up" is expressed in the wrong direction for this row: §8.3 says "Must not grow (`<= 16`)" for unformatted files, which means the *metric* must ratchet **down**.
- **Architectural Impact:** `TASK-014` cannot distinguish "no new unformatted files" from "pre-existing debt" using the stated command, so a genuinely malformed new file could hide inside the 15-item baseline list. The measured list currently contains **no** file this plan touches (`about_section.dart` is absent), which is the fact the gate should assert.

### C-3 — File arithmetic contradicts the plan's own change set (Blocking for traceability)

- **Condition / Requirement:**
  - Plan §1: "5 files touched during implementation (**2 created, 3 modified**)".
  - Plan §7 rollback: "Delete the **two** new files:" followed by an enumeration of **three**; "Restore the **three** modified files:" followed by an enumeration of **two** (`about_section.dart`, `docs/ARCHITECTURE.md`) plus one conditional (`CONTEXT.md`).
- **The Flaw:** The actual remaining change set (Spec §5.4 minus the already-executed `CONTEXT.md`) is **3 created + 2 modified = 5**: created `lib/core/app_version.dart`, `test/analysis/app_version_consistency_test.dart`, `test/presentation/pages/settings/sections/about_section_test.dart`; modified `about_section.dart`, `docs/ARCHITECTURE.md`. Both prose clauses state a different decomposition.
- **Architectural Impact:** Rollback is executed under pressure; a wrong count is exactly how an untracked new file survives a revert and keeps a stale seam alive. This is the same "prose vs. table" drift class already recorded in the project Knowledge Base (pattern: *"the table was updated, the prose qualifying it was not"*).

### C-4 — `AC-003` has no upstream verification locus; the plan silently supplies one (Blocking decision)

- **Condition / Requirement:** Plan §3 Phase 3 note claims `AC-003` "is satisfied structurally, not by a runtime null instantiation," with `RISK-001` disclosing the limitation. Spec §7's *"Verification loci"* table enumerates `AC-004`, `AC-014`, `AC-013`, `AC-009`, `AC-012`, `AC-010` — **`AC-003` is absent**. Spec §7's extreme-limiting-case table nonetheless asserts the no-`version:` case is *"(Asserted by `AC-003`.)"*.
- **The Flaw:** The Spec asserts a proof obligation it never assigns a procedure to. The plan's structural treatment is technically the only honest option (the define is constant-folded, and `--dart-define=FLUTTER_BUILD_NAME=` yields `''`, not `null`), but the plan adopts it **without an owner decision**, so traceability claims a criterion is "covered" by a method the upstream document never sanctioned.
- **Architectural Impact:** `/to-review` will be unable to distinguish "deliberately structural" from "quietly untested". If the residual is not sanctioned upstream, it becomes an unrecorded gap instead of an owned one.

### C-5 — `AC-011`'s detection rule is undefined, and the plan collapses it into a tautology (Blocking)

- **Condition / Requirement:** Plan `TASK-008`:
  > "assert **no** file declares a `version` or `buildNumber` string constant used for display, and assert every version-displaying surface imports `AppVersion` (concretely: `about_section.dart` contains the `core/app_version.dart` import)"
  > Spec `AC-011`: "every version-displaying surface reads from `AppVersion`".
- **The Flaw:** Neither document defines how "version-displaying surface" is detected mechanically. The plan's "concretely" clause pins the assertion to **one hard-coded filename** — so the guard is satisfied by the very file under test, and a *new* surface (the exact regression `[ASSUMPTION-002]` warns about) would never be examined. The absence-of-members half is sound; the presence-of-import half is currently tautological.
- **Architectural Impact:** This is the guard that makes the whole initiative durable. A tautological guard is worse than none, because the project would believe it is protected.

---

## 2. 🧩 Resolved Items & Agreements (The "Grill Me" Log)

- **Item 1 (2026-10-23) — Analyzer command scope.**
  - **Options:** (A) `dart analyze lib test` everywhere, matching `AC-009`; (B) keep `dart analyze` and restate the pass condition as `≤ 1 warning`.
  - **Engineering Recommendation:** **(A).** The Spec is normative and its scope note already explains why the `tools/` warning is out of scope; (B) would make every gate depend on a file this change is forbidden to touch (`CON-009`).
  - **Agreed Decision:** **[Assumed / Auto-Resolved] — (A).** Mechanical consequence of the normative Spec, not a judgment call. Every `VERIFY` row, §9 traceability row, and §10 command block uses `dart analyze lib test`.

- **Item 2 (2026-10-23) — `AC-011` detection rule** ✅ **RESOLVED — Option A (owner-confirmed, 2026-10-23).**
  - **Options:** (A) marker-based scan — any presentation file rendering a version/build display marker must import `AppVersion`; (B) closed allowlist of files importing `AppVersion`; (C) keep the plan's single hard-coded filename assertion.
  - **Engineering Recommendation:** **(A)**, with a known-consumer assertion as a second layer.
  - **Agreed Decision:** **Option A.** (C) was rejected outright — asserting a single hard-coded filename is true by construction and therefore tests nothing.
  - **Normative rule for `TASK-008` (replaces the current "concretely:" clause):**

    | Step | Operation | Failure condition |
    | :--- | :--- | :--- |
    | 1 | Enumerate `lib/presentation/**/*.dart` recursively via `dart:io`. | If the directory or any file cannot be read → **throw**, never skip (`AC-011`, `CON-007`). |
    | 2 | Strip `//`, `///`, and `/* … */` comments from each file's source before matching. | Stripping is required: `splash_page.dart:51` contains the unrelated comment *"versi lama"*, which must not become a false positive. |
    | 3 | Match the **code** against `RegExp(r'Versi ')` **or** `RegExp(r'Build ')` — capitalised, matching the rendered template shape `'Versi ${…}  ·  Build ${…}'`. Two separate patterns are used deliberately: a single alternation carries a `\|` that both breaks a GFM table cell and risks being copied into Dart as an escaping bug. | Lower-case prose (e.g. the `splash_page.dart` comment) never matches; no exception list is needed. |
    | 4 | Every file that matches MUST contain an import of `core/app_version.dart`. | A matching file without the import fails the scan — this is the generic guard against a future surface (`[ASSUMPTION-002]`). |
    | 5 | Assert the **absence** of any `static const String version` / `static const String buildNumber` display member anywhere under `lib/presentation/**`. | Covers both halves of the shipped defect (`'1.2.2'` **and** `'5'`) by construction rather than by literal-shape matching. |
    | 6 | Assert the known consumer `about_section.dart` imports `AppVersion`. | Second layer: pins the one surface that must exist today. |

  - **Rejected variant — closed set.** Asserting that the set of files importing `AppVersion` is *exactly* `{about_section.dart}` was considered and **rejected**: it is brittle and forces churn on every legitimate future consumer, while adding nothing over step 4 (which already fails when a marker-bearing file lacks the import). Layer 2 therefore asserts the known consumer only, not a closed set.
  - **Two-sided invariant:** `marker ⇒ imports AppVersion` (forward) **and** `no display literal exists` (inverse). Neither alone covers the defect class.

- **Item 3 (2026-10-23) — `TASK-013` scope.** The plan's `TASK-013` items (c) *"19 terms → 20"* and (d) *"1.4.3+14 → manifest-derived"* are **not** part of the Spec §8 mandate, which requires only (a) the new seam in the topology and (b) `pubspec.yaml` as the single source of truth.
  - **Options:** (A) keep both, with explicit owner approval recorded; (B) keep (c) only (traceable to `REQ-004`) and demote (d) to `NOTICED BUT NOT TOUCHING`; (C) drop both.
  - **Engineering Recommendation:** **(A).** Both statements are factually false today (`CONTEXT.md` holds 20 terms; `pubspec.yaml:19` declares `1.4.4+15`), they live in a file the Spec already places in the change set, and leaving a known-false version claim in the canonical architecture map reproduces the exact drift class this initiative eliminates.
  - **Agreed Decision:** ✅ **Option A — owner-confirmed 2026-10-23.** Both items are retained in `TASK-013` as an explicitly sanctioned scope addition to the Spec §8 mandate. Recorded here so `/to-review` does not read them as requirement drift. `CON-009` remains satisfied because `docs/ARCHITECTURE.md` is file #5 of the Spec §5.4 change set.
  - **Note for `/to-code`:** if further stale statements are discovered in `docs/ARCHITECTURE.md` beyond (c) and (d), they are **out of scope** — log them as `NOTICED BUT NOT TOUCHING`. The sanction covers exactly these two corrections.

---

## 3. ⚠️ Assumed / Auto-Resolved / Out of Scope (The 20% We Skip)

- **C-6 — Cross-reference drift in `TASK-009`:** the task instructs recording the override invocation in "§3 **Phase 4** row `TASK-011`", but `TASK-011` is a Phase 3 verification task and `§3` contains no verification table; the commands actually live in §10.
  - **Resolution:** `[Assumed / Auto-Resolved]` — correct the reference to §10 during remediation. No owner input needed.

- **C-7 — Override-run isolation hazard (new, not yet in the plan):** `TASK-011`'s override invocation is correctly scoped to `about_section_test.dart`, but the plan never states **why** that scoping is mandatory. Running the **analysis** test (or the full suite) under `--dart-define=FLUTTER_BUILD_NAME=9.9.9` would make `AC-002`'s manifest-parity oracle fail by design — `AppVersion` would legitimately diverge from `pubspec.yaml`.
  - **Resolution:** `[Assumed / Auto-Resolved]` — add one sentence to `TASK-011` and §10 stating the override must never be applied to `test/analysis` or to `check:full`.

- **C-8 — `check:fast` exit-code semantics:** `docs/ARCHITECTURE.md` §8.2 defines `check:fast` as bare `dart analyze`, which exits `2` at baseline (measured). The plan inherits this without stating that the gate is baseline-relative, not exit-code-zero.
  - **Resolution:** `[Assumed / Auto-Resolved]` — state "no new findings vs. baseline" as the gate semantics; do not modify §8.2 (out of `CON-009` scope).

- **C-9 — `CON-006` (domain purity) verification:** the plan maps it to `TASK-001`; the mechanical proof is simply that the new file lands in `lib/core/`. 
  - **Resolution:** `[Assumed / Auto-Resolved]` — sufficient as-is; `dart analyze lib test` plus the file's location is the whole contract. No new task.

- **C-10 — The 3-way task split proposed in the previous planning session is *not* applied.** The plan still holds 15 tasks. This audit does not block on it and does not treat it as a defect: the split is an execution-granularity preference, not a correctness issue.
  - **Resolution:** `[Assumed / Out of Scope]` for this audit. If adopted later, `TASK-014` must be split before it can be executed safely (verification gate + separate ratchet-documentation step).

---

## 4. 📚 Domain Glossary (`CONTEXT.md`) & ADR Alignment

- **Domain Glossary Updates:** **None required.** The plan uses only canonical terms (nine Display States, `Sholat` included) and introduces no new business vocabulary. "Version" / "Build Number" remain deliberately excluded per Spec §2. Note: the glossary has grown to **20 terms**, which is what makes `TASK-013` item (c) true — see §2 Item 3.
- **ADRs Required:** **None.** The Triple-Gate test still fails on two of three criteria (reversible; unsurprising), consistent with Spec §8.

---

## 5. 📝 Next Actions

**No blocking question remains open on `AC-011`** — the owner selected **Option A**, and the normative six-step marker rule is recorded in §2 Item 2. `TASK-008` was rewritten to that rule (plus a seventh `CON-006` import-scan step in `v1.2.0`); the previous "concretely: `about_section.dart` contains the import" clause is superseded in full.

Remediation required before `/to-code` (**all mechanical — every owner decision is now settled**). **Status: ✅ all eight items applied in `v1.1.0`; item 7 was extended to seven steps and item 4 upgraded to an exhaustion proof in `v1.2.0`.**

1. Replace `dart analyze` with `dart analyze lib test` in `TASK-003`, `TASK-006`, `TASK-011`, `TASK-014`, §9 and §10 (C-1).
2. Restate the formatter gate as: *the count of files reported by `dart format --output=none --set-exit-if-changed lib test` is ≤ 15 (measured 2026-10-23) and none of the five change-set files appears in that list*; note the exit code is non-zero at baseline (C-2).
3. Correct §1 to "**3 created, 2 modified**" and rewrite §7's rollback enumeration to match (C-3).
4. Record the `AC-003` verification method as an owner-sanctioned residual — either as a one-line amendment carried into `/to-review`, or by requesting the Spec's §7 table be extended (C-4).
5. Fix the `TASK-009` cross-reference (§10, not "§3 Phase 4 row TASK-011") (C-6).
6. Add the override-isolation sentence to `TASK-011` (C-7).
7. **Rewrite `TASK-008`** to the six-step marker-based rule in §2 Item 2, including the comment-stripping step (`splash_page.dart:51` false-positive defence) and the explicit "throw, never skip" failure mode (C-5, owner-resolved 2026-10-23).
8. Add the gate-semantics note for `check:fast` (baseline-relative, not exit-code-zero) (C-8).

Then re-audit with `/to-clarify @docs/plan/about-page-version-drift-plan.md`.

---

## 7. 📈 Projected Score After Remediation (Addendum, 2026-10-23)

*Status: remediation **applied** in two passes (`v1.1.0`, `v1.2.0`). The Auditor recorded the findings; `/to-plan` executed the fixes — separation of powers preserved.*

| Criterion | Iteration 1 | v1.1.0 | v1.2.0 (final) | What closed the remaining points |
| :--- | :---: | :---: | :---: | :--- |
| Completeness (40%) | 32 | 38 | **40** | `AC-003` proven by two-branch exhaustion (falsifiable `anyOf` + non-numeric regex); `CON-006` proven by an import scan; `RISK-002` defended by an explicit assertion in `TASK-002` |
| Clarity (30%) | 22 | 28 | **30** | STEP-0 baseline-capture block removes every "moving number" — thresholds are re-anchored to measurement before code changes |
| Alignment (30%) | 25 | 30 | **30** | Traceability restored; `AC-009` bound to its normative scoped command; `TASK-013` additions owner-sanctioned |
| **Total** | **79** | **96** | **100 / 100** | Critical Flaw Veto lifted once C-1 and C-2 were corrected — both gates now pass at the measured baseline |

> **User Decision Prompt:** *All three clarification items are settled (Item 1 auto-resolved, Items 2 and 3 owner-confirmed as Option A). The plan was remediated in two passes — v1.1.0 (the eight §5 corrections) and v1.2.0 (the four closure refinements) — reaching a projected Readiness Score of **100/100**. Proceed to `/to-code @docs/plan/about-page-version-drift-plan.md`, or re-audit first with `/to-clarify`.*
>
> *Iteration 1 closes at **79/100 — Refine Required** until remediation is applied. This score is a record of the document as authored, not of the decisions taken during the audit.*
