# 🥊 Pólya Grilling Alignment Log — About Page Version Drift

**Session Focus:** Spec / Phase 1 — `docs/spec/about-page-version-drift-spec.md`
**Sessions:** Iteration 1 (2026-10-23) · Iteration 2 (2026-10-23)
**Sparring Method:** `/to-grill-me` Phase-1 lens — seam boundaries · sad paths · data-model invariants · verification determinism
**Companion Gate:** `/to-clarify` Readiness Score (0–100) — quantified separately in `docs/audit/about-page-version-drift-spec-clarification.md`

---

## Key Decisions Settled

### Iteration 1

1. **Glossary treatment of "Sholat"** — Chosen **Option A** (add the term to `CONTEXT.md`).
   - *Rationale:* `CONTEXT.md` named eight of the nine Display States; "Sholat" was the sole omission. That one-term gap made `REQ-004` (every named state must be a `CONTEXT.md` term) contradict `AC-005` (all nine states must be named) — the two criteria were jointly unsatisfiable, so the mandated widget test could not be written without guessing. Adding the term resolves it at the cost of one line.
   - *Trade-Off Accepted:* `CONTEXT.md` enters the file change set (5 → 6 files). The alternative — a permanent carve-out in `REQ-004` — would have institutionalised a second unenforced source of truth, which is the exact defect class this initiative exists to eliminate.
   - *Executed:* `CONTEXT.md:21-23`.

2. **Wording of the Display State feature bullet** — Chosen **Option A** ("9 **status** tampilan otomatis").
   - *Rationale:* `CONTEXT.md` defines **Display State** with `_Avoid_: screen mode, layout`. *"mode tampilan otomatis"* is the Indonesian rendering of the rejected synonym. The domain layer already says "status tampilan" in four independent places (`display_state_type.dart:1`, `display_state.dart:10`, `transition_config.dart:4`, `evaluate_display_state_use_case.dart:11`), and *"mode tampilan"* occurred in exactly one place before this decision — the About copy itself.
   - *Trade-Off Accepted:* One word of copy churn ("mode" → "status"). No `_Avoid_` entry added to `CONTEXT.md`; no carve-out needed in `REQ-004`.

3. **Bullet shape** — Chosen **Option A** (one bullet, nine names, `→`, canonical enum order).
   - *Rationale:* The two-bullet split would preserve the "five prayer-cycle" framing the specification exists to correct. The `→` arrow's sequence ambiguity is already disarmed by §2.1's note.
   - *Trade-Off Accepted:* A longer single bullet. The feature list stays at 7 bullets; only one string changes.

4. **Landing-page coupling (`landingpage/panduan.html`)** — **Option A (decouple)**, deferred out of scope.
   - *Rationale:* A static marketing artifact cannot read the build manifest, so no structural fix exists. A page that makes no version claim cannot drift.
   - *Trade-Off Accepted:* The landing page keeps a stale `1.2.2 (build 5)` at line 3254 until a separate one-line cleanup is executed.

### Iteration 2

5. **Verification method for `AC-004`** — Chosen **Option B** (`flutter test --dart-define=…` only).
   - *Rationale:* The owner selected the cheapest procedure that binds the criterion to a command: `flutter test --dart-define=FLUTTER_BUILD_NAME=9.9.9 --dart-define=FLUTTER_BUILD_NUMBER=99` proves define → rendered UI, device-free, `check:fast`-grade, with no new tooling and no new dependency.
   - *Trade-Off Accepted (recorded in the specification, not only here):*
     - The **AOT/release path carries no empirical version-parity evidence.** It rests on source reasoning: the dart-define injection at `flutter_command.dart:1506-1514` is build-mode-agnostic.
     - A rejected alternative (Option A) would have added a release-artifact byte-scan of `build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/arm64-v8a/libapp.so` — the audit established that the uncompressed AOT `libapp.so` is already in the build tree, so it needed no zip extraction and only `dart:io`.
     - A rejected alternative (Option C) required a human reading a screen on hardware — the pattern `CON-007` (Floor-Guard) exists to eliminate.

6. **Ten mechanical resolutions (R2–R11)** — all determinate, no owner input required.
   - *Rationale:* Each closes a defect found by the Iteration-2 re-interrogation; the full table with rationale lives in `docs/audit/about-page-version-drift-spec-clarification.md` §3.
   - *Trade-Off Accepted:* The specification gains one acceptance criterion (`AC-014`, the mixed-null manifest branch) and one documented residual risk (no empirical AOT parity evidence).

---

## Assumptions Updated

- `[ASSUMPTION-001]`: **Resolved** → a single bullet enumerating all nine Display State names inline, canonical enum order, `→` separator. Owner-confirmed 2026-10-23.
- `[ASSUMPTION-002]`: **Resolved** → the About section remains the only in-app version surface; enforced by the **structural** anti-regression scan (`AC-011`) — no presentation-layer file may declare a `version` / `buildNumber` display constant, and every version-displaying surface must import `AppVersion`.
- `[ASSUMPTION-003]`: **Validated** → `appBuildName` / `appBuildNumber` are non-null for every build from this toolchain; the null branch is specified by `REQ-005` and asserted by `AC-003` (+ `AC-014` for the mixed case).
- `[ASSUMPTION-004]`: **Validated** → the Android toolchain upgrade and the `compileSdk 37` reconciliation are separate initiatives and MUST NOT be bundled (CON-009).
- `[ASSUMPTION-005]`: **Auto-resolved** → Option A (decouple `landingpage/panduan.html`), deferred out of scope.
- `[ASSUMPTION-006]`: **Resolved** → "Sholat" is a canonical `CONTEXT.md` term at `CONTEXT.md:21-23`; the glossary's "nine automatic screen modes" claim is now consistent with the terms it names.

---

## Actionable Document Diffs

Applied to `docs/spec/about-page-version-drift-spec.md` during Iteration 1 (v1.0.0 → **v1.1.0**, 20 surgical edits):

- §2 note — glossary coverage restated as "eight of the nine" (pre-revision); the "no `CONTEXT.md` change" default retracted.
- §2.2 — **new** Glossary Amendment section for "Sholat".
- §2.1 — mandated bullet → `9 status tampilan otomatis: …`; the `CONTEXT.md` status column updated for all nine states; a note records the "status, not mode" rationale.
- §3 — `[ASSUMPTION-001]`, `[ASSUMPTION-005]`, `[ASSUMPTION-006]` updated to owner-confirmed / auto-resolved; `[CLARIFICATION-001]` marked RESOLVED.
- §4.3 — key-event anchor corrected to `about_section.dart:72-73`.
- §5.2 / §5.3 — the mandated copy named explicitly in the layer assignment and the seam diagram.
- §5.4 — file change set grown to **6 files**; `CONTEXT.md` added as file #6 and removed from the "Explicitly NOT touched" list.
- §6 — `AC-005` given the exact canonical string and the anti-regression assertion; `AC-006`'s canonical-term list gained "Sholat"; `AC-009` given its analyzer scope; `AC-011` converted from a literal-shape regex to a structural assertion with an `IMPORTANT` rationale.
- §6.2 — the `AC-011` value-sourcing row rewritten to the structural scan.
- §7 — a **verification-locus table** added, binding every non-`flutter test` criterion to a command and a pass condition.
- §9 — the `REQ-004` row and the assumption-coverage line updated.

**Outstanding for the Specification Author (Iteration 2, R1–R11):** ✅ **ALL APPLIED.** The eleven edits tabulated in `docs/audit/about-page-version-drift-spec-clarification.md` §5 were applied to `docs/spec/about-page-version-drift-spec.md` (v1.1.0 → **v1.2.0**) on 2026-10-23. The specification now carries **14 acceptance criteria** (`AC-001`…`AC-014`), every criterion is bound to a command and a pass condition, and the one residual risk (no empirical release-AOT version-parity evidence) is recorded as a `CAUTION` in §1.2 with its release-gate mitigation hook in `AC-013`.

**Post-remediation verification (Iteration 3):** ✅ **100 / 100** — `docs/audit/about-page-version-drift-spec-clarification.md` §"Review Iteration 3". The verification pass caught **two** further residuals, both introduced by the R-series remediation itself, and both fixed:

- **V3-1** — `CON-002` still read *"the expected delta is exactly 0 bytes"* after `AC-013` was rewritten to *"≈ 0 bytes, not asserted to be exactly 0"*. The constraint contradicted its own acceptance criterion. Rewritten to match (`CON-002` now states the binding *"must not grow beyond"* and the *"≈ 0 bytes"* expectation, and points to `AC-013` as its executable form).
- **V3-2** — §7's lead sentence still counted the special invocations loosely ("Two need a specific invocation, and one needs a build") while the table beneath it had been rewritten. Rewritten to name each criterion's specific requirement.

> **Pattern worth carrying forward.** Both residuals share one failure mode: *a table was updated while the prose qualifying it was not* — the exact drift class this initiative exists to eliminate, appearing inside the document written to eliminate it. The same mode produced two of Iteration 2's findings. It is a standing argument for the re-audit pass: a checklist-only verification would have shipped a document whose prose contradicted its own tables.

---

## ADR Proposal

**None.** No decision in either session meets the Triple-Gate test (hard to reverse · surprising without context · real trade-off). The accepted AOT residual risk is a verification-scope decision with a named owner and a mitigation hook — a scope boundary, not a durable architectural commitment.

---

## Evidence Gathered During Grilling (read-only probes)

| Probe | Result | Bearing on the decisions |
| :--- | :--- | :--- |
| `app-release.apk` → `lib/arm64-v8a/libapp.so` (6,620,040 bytes) byte-scan | `"1.2.2"` FOUND @505563 · `"5 mode tampilan otomatis"` FOUND @377212 · `"Miqotul Khoir TV"` FOUND @334265 · `"1.4.4"` NOT FOUND | Dart constants are observable in the shipped AOT artifact; the defect is confirmed on the AOT path; the "AOT verified" citation in §1.2 is misattributed (`--debug` is JIT) |
| `build/**/libapp.so` for `arm64-v8a` | Present **uncompressed** at `build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/arm64-v8a/libapp.so` (6,620,040 bytes — byte-identical to the APK entry) | Grounded Option A's cost: no zip extraction and no new dependency would be required |
| `CONTEXT.md` anchor re-verification (10 terms) | All 10 resolve to the expected term headings after the "Sholat" insertion shifted every subsequent entry by four lines | The glossary amendment was propagated to every citation in the specification |
| `grep 'mode tampilan'` across `lib/` | Exactly one hit — `about_section.dart:35`; the domain layer uses "status tampilan" in four places | Grounded the "status, not mode" decision in codebase reality rather than taste |
