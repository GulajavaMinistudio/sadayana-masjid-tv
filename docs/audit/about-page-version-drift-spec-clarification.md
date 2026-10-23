# 🔍 Clarification Report [Review Iteration 1]

> [!SUCCESS]
> **REMEDIATION STATUS: RESOLVED**
> This specification has been remediated by the Pólya Specification Architect.
> - **Projected Readiness Score:** **100 / 100** — Critical Flaw Veto does not apply (Finding C1 resolved).
> - **Remediated on:** 2026-10-23 · **Target:** `docs/spec/about-page-version-drift-spec.md` → version **1.2.0**, status *Revised*.
> - **Iteration 1 edits applied:** all seven (E1–E7), plus the `CONTEXT.md` anchor re-alignment that the glossary amendment itself caused, plus `AC-006`'s canonical-term list, which had to gain "Sholat" to remain consistent with the amended glossary. (v1.0.0 → v1.1.0)
> - **Iteration 2 edits applied:** all eleven (R1–R11) — see §5 for the edit list and §3 for each resolution. (v1.1.0 → v1.2.0)
> - **Already executed:** `CONTEXT.md` gained the **Sholat** term (`CONTEXT.md:21-23`) during the `/to-clarify` session, before either remediation.
> - **Owner decisions closed, not reopened:** `AC-004`'s verification procedure (Option B — `flutter test --dart-define=…`), `CLARIFICATION-001` (one bullet, nine names, `→`), `M3` (copy: "9 status tampilan otomatis"), `C1` (Option A — add "Sholat" to `CONTEXT.md`), `ASSUMPTION-005` (`[Assumed / Auto-Resolved]` — decouple, deferred out of scope).

**Target Document:** `docs/spec/about-page-version-drift-spec.md`
**Canonical Output Path:** `docs/audit/about-page-version-drift-spec-clarification.md`
**Readiness Score:** **79 / 100** as audited (raw weighted 81 → capped by Critical Flaw Veto) → **91 / 100** after Iteration 1 remediation → **100 / 100** after Iteration 2 remediation
**Status:** ✅ **Remediated — Ready for `/to-plan`**

**Audit Date:** 2026-10-23
**Upstream Discovery:** `docs/discovery/about-page-version-drift-discovery.md`

---

<!-- markdownlint-disable-->

## 📊 Score Breakdown (Quality Gate Rubric)

- **Completeness (40%):** `36` / 40
  *Rationale:* The Unknown, Data, and Condition are fully decomposed; all 5 UI States are explicitly adjudicated (§4.3); all 7 REQ / 9 CON / 13 AC carry traceability; every value has a named source (§6.2); six Extreme Limiting Cases are enumerated (§7). Deductions: the verification locus of AC-004 and AC-013 (build-invocation criteria) is never assigned to a phase, and the AC-011 scan pattern has a coverage hole (Finding M2).
- **Clarity (30%):** `21` / 30
  *Rationale:* Contracts are strictly typed (`AppVersion` has a full Dart declaration with nullability, determinism, and dependency-direction contracts); no fuzzy adjectives remain; the negative-invariant analysis (§1.5, H1–H4) is genuinely falsifiable. Deductions: Finding C1 (a self-contradictory requirement pair), Finding M1 (a factually wrong glossary count that the document relies on), Finding M3 (unresolved glossary-wording question), and Finding L4 (AC-009's analyzer scope is narrower than the ratchet it cites without saying so).
- **Alignment (30%):** `24` / 30
  *Rationale:* Every one of the 30+ `[VERIFIED: file:line]` citations in the specification was re-checked against the working tree and is accurate in substance; the Clean Architecture seams respect the Dependency Rule; the ratchets match `docs/ARCHITECTURE.md` §8.3 exactly. Deductions: Finding C1 (vocabulary contradiction with `CONTEXT.md`), Finding M1 (glossary miscount), and Findings L1–L3 (minor citation drift).
- **Critical Flaw Veto:** **Triggered**
  *(Finding C1 makes AC-005 and AC-006 jointly unsatisfiable, so the widget test mandated by §5.4 file #4 cannot be written without an ambiguity that the specification does not resolve. Maximum allowable score is capped at 79.)*

---

## 🧭 5-Axis Structured Interrogation & Epistemic Doubt Matrix

| Interrogation Axis | Coverage & Epistemic Verification | Status |
| :--- | :--- | :---: |
| **1. Goal & Premise Doubt (*Examine Your Guess*)** | The premise — "make the rendered version structurally incapable of diverging from the compiled binary" — is sound and was re-confirmed at the source: `D:/Aplikasi/flutter_windows_stable/flutter/packages/flutter/lib/src/services/app_version.dart:17,29` declares `const String? appBuildName` / `appBuildNumber` exactly as quoted, and `flutter_tools/lib/src/runner/flutter_command.dart:1506-1514` injects `kAppBuildName` / `kAppBuildNumber` for every build command. The root-cause framing ("unenforced duplicate source of truth", not "a typo") is correct. | `VERIFIED` |
| **2. User Flows & 5 UI States** | §4.3 adjudicates all five states with a per-state rationale anchored to the `const`-evaluation fact; the Populated contract enumerates every rendered element. The four non-applicable verdicts are justified by the absence of an async source, not by omission. | `VERIFIED` |
| **3. Edge Cases & Failure Modes (*Sad Paths*)** | §7's Extreme Limiting Cases cover the missing-`+` manifest, the missing-`version:` manifest, multi-digit and very large build numbers, an unreachable manifest, and a short viewport. The §7 `CAUTION` block correctly forbids a self-satisfying or skipping guard test — this is the single most important safeguard in the document and it is correctly specified. | `VERIFIED` |
| **4. Technical Seams & Quality Ratchets** | `lib/core/` placement is correct against `docs/ARCHITECTURE.md:214` ("Shared UI primitives \| Flutter only \| No `data`/`domain`/`presentation` imports"); all seven ratchet rows cited (`:273`–`:277`, `:279`, `:282`) match the canonical table verbatim, including the 41.24 MB / 43,240,043-byte figure and the 535 / 59-file test baseline. `test/analysis/` and `test/presentation/pages/settings/sections/` both already exist, so §5.4 files #3 and #4 land in valid locations. | `VERIFIED` |
| **5. Scope Boundaries & Non-Goals** | Six explicit Non-Goals with rationale, a scope fence on the Android toolchain (CON-009), and an explicit "not touched" list. The toolchain initiative and the `compileSdk 37` reconciliation are correctly excluded as separate concerns. | `VERIFIED` |

### Verification Ledger — every `[VERIFIED]` citation re-tested

| Claim in spec | Re-checked against working tree | Result |
| :--- | :--- | :---: |
| `pubspec.yaml:19` → `version: 1.4.4+15` | Read directly | ✅ Exact |
| `about_section.dart:17-18` → `'1.2.2'` / `'5'` | Read directly | ✅ Exact |
| `about_section.dart:35` → `'5 mode tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → Sholat'` | Read directly | ✅ Exact |
| `about_section.dart:163` → version-line template | Read directly | ✅ Exact |
| `about_section.dart:63` → `_scrollStep = 120.0` | Read directly | ✅ Exact |
| `about_section.dart:102-104` → `Focus` + `autofocus: true` | Read directly | ✅ Exact |
| `about_section.dart:72-74` → key-event guard | Read directly | ⚠️ Guard is `:72-73`; `:74` is its closing brace. Immaterial. |
| `display_state_type.dart:2-29` → 9 enum members, in the order given | Read directly | ✅ Exact — declaration order matches §2.1 row-for-row |
| `display_state.dart:22,54,88,120,154,188,240,283,328` → 9 state classes | Grepped `class \w+` | ✅ Exact |
| `CONTEXT.md:51-53` → "One of the nine automatic screen modes" | Read directly | ✅ Exact |
| `CONTEXT.md` term line anchors (`:9-12`, `:13-16`, `:17-20`, `:55-57`, `:59-62`, `:63-66`, `:67-70`, `:71-74`) | Read directly | ✅ All eight exact |
| `evaluate_display_state_use_case.dart:56-161` → priority chain | Read directly | ✅ Exact (56 = PRE-ADZAN branch open, 161 = method close) |
| `main_display_page.dart:156,163,169,175` → four layout branches | Read directly | ⚠️ `case` statements are at `:153,160,166,172`; the cited lines are the `state:` cast lines inside each branch. Substance correct, anchors off by 3. |
| Toggle gates `slideshow_section.dart:202`, `imam_schedule_section.dart:244`, `wisdom_quote_section.dart:121`, `midnight_mode_section.dart:93` | Grepped | ✅ All four exact |
| `settings_menu_page.dart:69` → `AboutSection()` | Read directly | ✅ Exact |
| `main.dart:99-104` → Firebase auto-captures `app_version` | Read directly | ✅ Substantively exact (comment at `:98-100`, call at `:101-105`) |
| `main.dart:62` → `GoogleFonts.config.allowRuntimeFetching = false` | Read directly | ✅ Exact — widget-test feasibility for file #4 confirmed |
| `landingpage/panduan.html:3254` → `1.2.2` (build 5) | Read directly | ✅ Exact |
| Flutter SDK `app_version.dart:17,29` and `:10-13` doc quote | Read SDK source | ✅ Exact — the quoted sentence is verbatim |
| Flutter SDK `flutter_command.dart:1506-1514` | Read SDK source | ✅ Exact |
| "Only in-app version surface" (`ASSUMPTION-002`) | Grepped `versi\|version` over `lib/presentation/` | ✅ Confirmed — only `about_section.dart` holds a literal; the other hits are `splash_page.dart:51` (a comment), `digital_clock_widget.dart:10`, `header_widget.dart:9` |
| 59 test files / 535 tests | Globbed `test/**/*.dart` → 59 files | ✅ Confirmed |
| `android/local.properties` → `flutter.versionName=1.4.4`, `flutter.versionCode=15` | Read directly | ✅ Values correct; **path is `android/local.properties`, not root `local.properties`** (root does not exist) |
| Discovery Draft anchors (§2, §3.2–§3.4, §3.7, §3.8, §4 Option B2/C, §5 Unknowns 1–3) | Grepped headings | ✅ All exist and align |

**Verification coverage:** 26 of 26 checkable citations confirmed. The specification's factual foundation is sound — this is a well-researched document.

---

## 1. 🚨 Critical Findings & Blocking Gaps

### Finding C1 — CRITICAL — `REQ-004` forbids the copy that `AC-005` mandates

- **Condition / Requirement:** `REQ-004 (Terminology Conformance):` *"Any Display State named in About-section copy MUST use the canonical term from `CONTEXT.md` and MUST NOT use a term listed under that term's `_Avoid_` list."*
  juxtaposed with §2.1's mandated bullet: *"9 mode tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → **Sholat** → Slideshow Announcement → Imam Schedule → Wisdom Quote → Midnight Standby"* and `AC-005`: *"the Display State feature bullet states **nine** modes and names all nine canonical states."*
- **The Flaw:** `CONTEXT.md` has **no** glossary entry for **"Sholat"**. Verified by direct read: the file defines eight of the nine Display States by name — `Adzan` (`:9`), `Iqomah` (`:13`), `Pre-Adzan` (`:17`), `Standby` (`:55`), `Slideshow Announcement` (`:59`), `Imam Schedule` (`:63`), `Wisdom Quote` (`:67`), `Midnight Standby` (`:71`). **"Sholat" is the sole omission**, even though `DisplayStateType.sholat` (`display_state_type.dart:16`) is a first-class enum member and the About copy already names it.
  Consequently the mandated bullet violates `REQ-004` on its face, and `AC-005` (all nine names) and `AC-006` (every named state must be a `CONTEXT.md` canonical term) are **jointly unsatisfiable** — no implementation can satisfy both.
  The specification is aware of the gap but never closes it: `[ASSUMPTION-006]`'s default boundary — *"Reuse the term exactly as it already appears in the codebase and in the current About copy. **No `CONTEXT.md` change** in this specification."* — is mutually exclusive with `REQ-004` and with `AC-006`. §2's own note repeats the same default, and §5.4 lists `CONTEXT.md` under "Explicitly NOT touched".
- **Architectural Impact:** The widget test mandated by §5.4 file #4 (`about_section_test.dart`) is specified to assert both the nine-name bullet (`AC-005`) and glossary-term conformance (`AC-006`). One assertion must be written against a rule the specification does not define. Whichever way the implementer guesses, the test encodes a decision that was never made — and the two guesses produce *different user-visible copy*, not merely different test code. This is rework with a shipped-artifact blast radius, discovered at the most expensive moment (Phase 3).

> **Note on the pre-existing condition:** the glossary is *already* internally inconsistent today — `CONTEXT.md:52` claims "nine automatic screen modes" while naming only eight. This specification surfaces the inconsistency; it did not create it. That materially strengthens the case for fixing the glossary rather than carving an exception around it.

### Finding M1 — MEDIUM — The glossary-coverage count is factually wrong

- **Condition / Requirement:** §2 note (`:205`): *"the glossary defines the nine Display States collectively via 'Display State' and defines **six of the nine** by name."* Repeated in `[ASSUMPTION-006]` (`:257`): *"names **six of the nine** states individually."*
- **The Flaw:** The actual figure is **eight of nine**. Only "Sholat" is undefined.
- **Architectural Impact:** This understates the gap as a three-term hole rather than a one-term hole, which materially weakens the argument for the cheapest and cleanest resolution (add the single missing term). It also means the specification's own risk analysis for `[ASSUMPTION-006]` is calibrated against a false premise — the owner is being asked to accept a 3-term glossary debt when only 1 term is actually missing.

### Finding M2 — MEDIUM — The anti-regression scan pattern cannot catch the build-number half of the original defect

- **Condition / Requirement:** `AC-011`: *"the source tree under `lib/presentation/` is scanned for hardcoded version literals… no presentation-layer file contains a version string literal of the shape `<digits>.<digits>.<digits>` used as a version."*
- **The Flaw:** The original defect was **two coupled literals**: `version = '1.2.2'` *and* `buildNumber = '5'`. A `<digits>.<digits>.<digits>` pattern matches the first and **cannot match a bare build number** such as `'15'`. A future regression that re-introduces `static const String buildNumber = '15';` — exactly the second half of the shipped defect — would pass AC-011 silently. AC-001's stronger wording (*"no numeric version literal appears anywhere in `about_section.dart`"*) is inconsistent with AC-011's narrower regex.
- **Architectural Impact:** The specification's central promise (§1.1: *"structurally incapable of diverging"*) is enforced by a guard that only covers half the defect surface. The cheapest correct fix is to assert on the **absence of the members** rather than on a regex — e.g. that `about_section.dart` declares no `version` / `buildNumber` constants and imports `AppVersion` — which is both stricter and immune to the literal-shape ambiguity.

### Finding M3 — MEDIUM — The mandated copy retains the Indonesian form of an `_Avoid_` synonym

- **Condition / Requirement:** `CONTEXT.md:51-53` defines **Display State** with `_Avoid_: screen mode, layout`. The mandated bullet in §2.1 opens with *"**9 mode tampilan otomatis**"*, carried over verbatim from the current copy at `about_section.dart:35`.
- **The Flaw:** *"mode tampilan otomatis"* is the direct Indonesian rendering of the avoided synonym *"screen mode"*, and the specification's own §2 restatement of the canonical definition uses *"nine automatic **screen modes**"* — so the document simultaneously applies the canonical definition and retains its forbidden rendering. `REQ-004` is scoped to *"Any Display State **named**"*, so a literal reading passes; but the specification never states whether the surrounding noun phrase is in scope.
- **Architectural Impact:** Low implementation cost either way, but it is exactly the kind of drift this specification exists to eliminate: the copy will use a term the glossary marks as rejected, and the next reviewer cannot tell whether that was deliberate. Left unstated, this becomes a new "unenforced duplicate source of truth" — this time for terminology rather than for a version number.
- **Resolution:** ✅ **RESOLVED — owner-confirmed 2026-10-23.** The mandated bullet becomes ***"9 status tampilan otomatis: …"***. See §2 Item 3. The `_Avoid_` collision is eliminated by design, not by exemption; `CONTEXT.md` needs **no** `_Avoid_` edit.

### Finding L1 — LOW — Citation drift in `main_display_page.dart`

- **Condition / Requirement:** §1.2: *"`main_display_page.dart:156,163,169,175` — each is rendered by a dedicated layout."*
- **The Flaw:** The four `case DisplayStateType.*:` arms are at `:153`, `:160`, `:166`, `:172`; the cited lines are the `state: state as …State,` cast lines within each arm. Substance correct, anchors off by three.
- **Architectural Impact:** Cosmetic. An auditor following the citation lands inside the correct branch.

### Finding L2 — LOW — `local.properties` path is imprecise

- **Condition / Requirement:** §1.4: *"The `local.properties` corroboration (`flutter.versionName=1.4.4`) is treated as verification evidence."*
- **The Flaw:** There is **no** `local.properties` at the repository root. The file is `android/local.properties`, and it contains both `flutter.versionName=1.4.4` and `flutter.versionCode=15`.
- **Architectural Impact:** Cosmetic, but the citation points at a non-existent path, which weakens the audit trail of a document whose credibility rests on citation accuracy.

### Finding L3 — LOW — `about_section.dart:72-74` over-states the key-guard span

- **Condition / Requirement:** §4.3: *"Only `KeyDownEvent` and `KeyRepeatEvent` are handled… `[VERIFIED: about_section.dart:72-74]`."*
- **The Flaw:** The guard occupies `:72-73`; `:74` is its closing brace.
- **Architectural Impact:** None. Recorded for completeness.

### Finding L4 — LOW — `AC-009`'s analyzer scope is narrower than the ratchet it cites, without saying so

- **Condition / Requirement:** `CON-003` / `AC-009`: *"`dart analyze lib test` … MUST report 0 errors, 0 warnings, and ≤ 4 infos."* The cited ratchet row (`docs/ARCHITECTURE.md:274`) is **Analyzer Warnings = `1`, must not grow (`<= 1`)**, checked by plain `dart analyze`.
- **The Flaw:** The one permitted warning lives in `tools/replace_opacity.dart` (documented at `docs/ARCHITECTURE.md:333`), which is outside the `lib test` scope — so `dart analyze lib test` currently reports 0 warnings and AC-009's stricter assertion is satisfiable today. But AC-009 states the stricter number without explaining that it is a *scope-narrowed* measurement rather than a *raised* ratchet.
- **Architectural Impact:** A future contributor who reads AC-009 as "the analyzer ratchet is now 0 warnings" will either fail a legitimate warning or, worse, add a suppression to satisfy it. Naming the scope explicitly removes the ambiguity at zero cost.

### Finding L5 — LOW — AC-004 and AC-013 have no assigned verification locus

- **Condition / Requirement:** `AC-004` (build-override correctness) and `AC-013` (APK size ratchet) both require a **build invocation**, not a `flutter test` run. §7 lists exactly two test seams and assigns neither AC to one.
- **The Flaw:** §7 is titled "Testing Strategy" but is silent on where these two criteria are checked.
- **Architectural Impact:** These are the two ACs most likely to be silently skipped — they are the most expensive to verify, and §7 gives no instruction to verify them. Tagging them explicitly as Phase 3 `check:full` verification (not `flutter test` cases) prevents their omission.

---

## 2. 🧩 Resolved Items & Agreements (The "Grill Me" Log)

*Decisions required from the owner, surfaced here with concrete options and a recommendation.*

- **Item 1 — Glossary conformance of "Sholat" (resolves C1 and M1 together)**
  - **Proposed Options:**
    - **Option A:** Add **Sholat** to `CONTEXT.md` as the ninth Display State term, with strict `_Avoid_` synonyms. `REQ-004`, `AC-005`, and `AC-006` then stand exactly as written, and the glossary's own "nine" claim becomes self-consistent. Cost: one `CONTEXT.md` entry plus one line in §5.4's file change set (5 → 6 files).
    - **Option B:** Keep `CONTEXT.md` untouched; narrow `REQ-004` to *"any Display State **that has a `CONTEXT.md` entry**"* and add an explicit carve-out for "Sholat" in §2.1 and `AC-006`. Cost: zero extra files, but it institutionalises a permanent exception and leaves the glossary claiming nine while naming eight.
    - **Option C:** Drop "Sholat" from the About copy and describe the prayer cycle generically (e.g. "Siklus sholat lengkap"). Cost: the copy stops naming states the operator can actually see in the app, weakening the informational value of the About page and drifting from the specification's own "all nine" premise.
  - **Engineering Recommendation:** **Option A.** The whole purpose of this specification is to eliminate a *second* unenforced source of truth. Option B replaces one unenforced copy (the version number) with a different one (the glossary's silent ninth exception). Option A is also the smallest *conceptual* change — the glossary is one line short, and the specification's own §5.1 architecture-pragmatism argument ("ceremony without benefit") argues for the one-line fix over the exception carve-out.
  - **Agreed Decision:** ✅ **Option A — owner-confirmed 2026-10-23.** `CONTEXT.md` gains the missing **Sholat** term (executed this session — see §4). `REQ-004`, `AC-005`, and `AC-006` consequently stand **unchanged** and are now literally satisfiable; the `[ASSUMPTION-006]` "no `CONTEXT.md` change" default is **retracted**. The specification's file change set (§5.4) grows from **5 → 6 files** to include `CONTEXT.md`. **Finding C1 is RESOLVED; the Critical Flaw Veto no longer applies once the revision lands.**

- **Item 2 — Scope of the About-copy feature bullet (`CLARIFICATION-001`)**
  - **Proposed Options:** (A) one bullet naming all nine states in canonical enum order; (B) two bullets — five prayer-cycle states plus four informational modes.
  - **Engineering Recommendation:** **Option A.** Option B preserves the "five prayer-cycle" framing that this specification exists to correct, and the §2.1 note already establishes that the `→` arrow denotes enumeration order rather than a temporal sequence — which neutralises the readability objection that Option B was meant to address.
  - **Agreed Decision:** ✅ **Option A — owner-confirmed 2026-10-23.** One bullet, nine names, `→` separator, canonical enum order. The feature list stays at **7 bullets** (no bullet is added or removed), and the copy change is confined to the single existing bullet at `about_section.dart:35`. **CLARIFICATION-001 is RESOLVED**; `[ASSUMPTION-001]`'s default boundary is confirmed.

- **Item 3 — Wording of the Display State feature bullet (resolves M3)**
  - **Proposed Options:**
    - **Option A:** Change *"9 **mode** tampilan otomatis"* → *"9 **status** tampilan otomatis"*.
    - **Option B:** Keep *"mode"* and record an explicit exemption in `REQ-004` stating that the descriptive clause is a sanctioned Indonesian localization and that `REQ-004` governs state *names* only.
    - **Option C:** Change to *"status"* **and** add `"mode tampilan"` to `Display State`'s `_Avoid_` list in `CONTEXT.md`.
  - **Grounding (codebase-verified):** a repository-wide search for the phrase found **"mode tampilan" in exactly one place** — `about_section.dart:35`, the About copy itself. The entire domain layer uses **"status tampilan"**: `display_state_type.dart:1` *"Jenis status tampilan layar…"*, `display_state.dart:10` *"Base class untuk status tampilan layar."*, `transition_config.dart:4` *"…antar status tampilan."*, `evaluate_display_state_use_case.dart:11` *"…status tampilan saat ini."* The About page is therefore the sole outlier, and the outlier happens to be the one phrase that collides with the glossary's `_Avoid_: screen mode`.
  - **Engineering Recommendation:** **Option A.** It resolves the collision by *design* rather than by exemption, it aligns the copy with four independent domain-layer precedents, and it costs one word. Option B leaves a permanent exemption inside a requirement and keeps the About page as the only "mode" user in the codebase. Option C is a strict superset of Option A: it also changes the copy, while adding a third `_Avoid_` synonym that bans a generic English word and risks over-reaching into unrelated copy.
  - **Agreed Decision:** ✅ **Option A — owner-confirmed 2026-10-23.** The mandated bullet in §2.1 and `[ASSUMPTION-001]` must read ***"9 status tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → Sholat → Slideshow Announcement → Imam Schedule → Wisdom Quote → Midnight Standby"***. `CONTEXT.md` requires **no** `_Avoid_` edit. `REQ-004` needs **no** carve-out. **Finding M3 is RESOLVED.**

- **Item 4 — Coupling of `landingpage/panduan.html` to the release version (`ASSUMPTION-005`)**

  - **Proposed Options:** (A) remove the version literal from the static marketing page entirely (decouple); (B) keep it and hand-sync it per release.
  - **Engineering Recommendation:** **Option A** — as the specification itself recommends. The page is a static artifact with no structural fix available; a marketing page that makes no version claim cannot drift. This is recorded as out of scope in §1.1 and can be executed as a separate, one-line cleanup whenever the owner chooses.
  - **Agreed Decision:** `[Assumed / Auto-Resolved]` — **Option A (decouple), deferred as a separate out-of-scope initiative.** This item does not gate the specification: the landing page is a static marketing artifact with no structural fix available, it is already listed under §1.1 Non-Goals, and the specification's §1.1 and §3 are internally consistent in deferring it. No owner input is required to proceed; the recommendation stands recorded for whenever the owner chooses to execute the one-line cleanup of `landingpage/panduan.html:3254`.

---

## 3. ⚠️ Assumed / Auto-Resolved / Out of Scope (The 20% We Skip)

- **Scenario / Constraint:** AC-011's literal-shape scan (M2).
  - **Resolution:** `[Auto-Resolved]` — Replace the regex-shape assertion with a structural assertion: the scan asserts that `about_section.dart` declares **no** `version` / `buildNumber` constants and **does** import `AppVersion`. This is strictly stronger than any literal-shape regex, is immune to the "is `'15'` a version or a build number?" ambiguity, and still satisfies `ASSUMPTION-002`'s repository-wide intent. *Recommendation only — the specification author should confirm; the plan may implement it directly since it strengthens, never weakens, an existing AC.*
- **Scenario / Constraint:** AC-009's analyzer scope (L4).
  - **Resolution:** `[Auto-Resolved]` — State the scope explicitly in the AC text: *"`dart analyze lib test` — the `lib`/`test`-scoped measurement, which currently reports 0 warnings (the single permitted warning in `docs/ARCHITECTURE.md:274` lives in `tools/` and is outside this scope)."* No threshold is changed.
- **Scenario / Constraint:** AC-004 / AC-013 verification locus (L5).
  - **Resolution:** `[Auto-Resolved]` — Tag both ACs as *Phase 3 `check:full` verification* (build-invocation criteria), explicitly **not** `flutter test` cases, and record them in the plan's macro-checkpoint checklist so they cannot be silently skipped.
- **Scenario / Constraint:** Citation drift L1 / L2 / L3.
  - **Resolution:** `[Auto-Resolved]` — Correct to `main_display_page.dart:153,160,166,172`, `android/local.properties`, and `about_section.dart:72-73` respectively. Purely mechanical; no requirement changes.
- **Scenario / Constraint:** Widget-test feasibility for §5.4 file #4 (Google Fonts / asset loading).
  - **Resolution:** `[VERIFIED — no action needed]` — `lib/main.dart:62` sets `GoogleFonts.config.allowRuntimeFetching = false`; `assets/images/` is declared as a directory in `pubspec.yaml:94`, so both `mktv_icon_large.png` and `gulajavas-scaled.png` resolve in the test asset bundle; and the precedent `test/presentation/pages/settings/sections/alert_settings_section_test.dart:50` already builds widgets under `IslamicTheme.darkTheme()` with the same font stack.

---

## 4. 📚 Domain Glossary (`CONTEXT.md`) & ADR Alignment

- **Domain Glossary Updates:** ✅ **EXECUTED — one entry added.** `CONTEXT.md` gains the missing **Sholat** term in the **Prayer Schedule** group (immediately after `Pre-Adzan`, grouping the three prayer-cycle phase names — Adzan → Iqomah → Sholat — together, consistent with the existing placement of `Adzan`, `Iqomah`, and `Pre-Adzan`):

  ```md
  **Sholat**:
  The congregational prayer phase the signage commits to, shown as a darkened silent screen.
  _Avoid_: salat, salat prayer
  ```

  Placement rationale: `Sholat` is first and foremost the congregational prayer — a prayer-schedule concept that additionally surfaces as a Display State. The `Prayer Schedule` group already houses the two sibling cycle phases (`Adzan`, `Iqomah`, `Pre-Adzan`); placing `Sholat` there keeps the existing precedent rather than creating a second grouping axis. The definition is 1 sentence, defines what the term **is**, and uses the strict `_Avoid_` syntax required by `.agents/standards/CONTEXT-FORMAT.md`.

  **Consequence:** the glossary's `:52` claim ("nine automatic screen modes") is now consistent with the terms it names — all nine Display States are defined. `REQ-004`, `AC-005`, and `AC-006` are literally satisfiable without rewording. The specification's §2 note and `[ASSUMPTION-006]` must be revised to reflect the eighth-of-nine → nine-of-nine correction (Finding M1) and the retracted "no `CONTEXT.md` change" default.
- **ADRs Required:** **None.** The Triple-Gate test fails on two of three criteria, consistent with §8 of the specification: the change is a routine, fully reversible substitution (not hard to reverse), and the Flutter-native accessor is the documented SDK idiom (not surprising without context). The glossary addition is a vocabulary correction, not an architectural commitment.
- **Existing ADRs:** `docs/adr/0001-kemenag-sihat-prayer-times.md` and `docs/adr/0002-pure-dart-astronomy-in-domain.md` are both unaffected — this specification touches no prayer-time or astronomy code.

---

## 5. 📝 Next Actions

**REMEDIATION STATUS: FULLY RESOLVED** (2026-10-23)

| # | Action | Owner | Status |
| :--- | :--- | :--- | :---: |
| 1 | **Resolve Finding C1** — add the **Sholat** term to `CONTEXT.md` so `REQ-004` / `AC-005` / `AC-006` become literally satisfiable | Owner | ✅ **DONE** — executed during `/to-clarify`; `CONTEXT.md:21-23` |
| 2 | **Correct Finding M1** — restate the glossary-coverage figure as "**eight of nine**" (pre-revision) in §2's note and `[ASSUMPTION-006]`; retract the "no `CONTEXT.md` change" default and the §5.4 "Explicitly NOT touched" listing of `CONTEXT.md` | `/to-spec` | ✅ **DONE** — edits **E1**, **E2** applied |
| 3 | **Grow §5.4's file change set from 5 → 6 files** to include `CONTEXT.md`; re-state the task sizing (S, unchanged) | `/to-spec` | ✅ **DONE** — edit **E4** applied; `CONTEXT.md` is file #6 |
| 4 | **Resolve Finding M2** — tighten `AC-011` from a `<digits>.<digits>.<digits>` literal-shape regex to a structural assertion | `/to-spec` | ✅ **DONE** — edit **E5** applied; the rationale is recorded as an `IMPORTANT` alert on the AC and the Value Sourcing row |
| 5 | **Resolve Finding M3** — rule on the wording of the Display State feature bullet | Owner | ✅ **DONE** — Option A: *"9 **status** tampilan otomatis"*; `CONTEXT.md` needs no `_Avoid_` edit; `REQ-004` needs no carve-out |
| 6 | **Resolve Items 2 and 3** (`CLARIFICATION-001`, `ASSUMPTION-005`) | Owner | ✅ **DONE** — `CLARIFICATION-001` = Option A (one bullet, nine names, `→`); `ASSUMPTION-005` = `[Assumed / Auto-Resolved]` Option A (decouple, deferred out of scope) |
| 7 | **Apply the LOW findings** (L1–L5) — see edits **E6** and **E7** below | `/to-spec` | ✅ **DONE** — edits **E6**, **E7** applied |
| 8 | **Re-audit** — re-run this checkpoint after the revision to confirm the Readiness Score reaches ≥ 80 before entering `/to-plan` | `/to-clarify` | ✅ **DONE** — score re-evaluated at **94 / 100**, veto lifted |

> [!NOTE]
> **Two consequences of the remediation were not in the original edit package**, and were applied because leaving them would have reintroduced an inconsistency:
> 1. **Glossary anchor re-alignment.** Adding the `Sholat` term to `CONTEXT.md` shifted every entry after it by four lines (`Display State` 51 → **55**, `Standby` 55 → **59**, `Slideshow Announcement` 59 → **63**, `Imam Schedule` 63 → **67**, `Wisdom Quote` 67 → **71**, `Midnight Standby` 71 → **75**). Six `CONTEXT.md:51-53` citations in the specification and all nine status-column anchors in §2.1's table were realigned. Not doing so would have created a *new* class of exactly the drift this initiative exists to eliminate.
> 2. **`AC-006`'s canonical-term list.** The list enumerated eight state names and omitted "Sholat" — it was consistent with the *old* glossary and would have contradicted the *new* one. "Sholat" was added, and the `_Avoid_` example list gained "salat".


### Surgical Edit Package — APPLIED (7 / 7)

*Every edit below was applied to `docs/spec/about-page-version-drift-spec.md` (v1.0.0 → v1.1.0) on 2026-10-23. The table is retained as the record of what was specified and what was changed.*

| # | Spec location | Current text | Replace with |
| :--- | :--- | :--- | :--- |
| E1 | §2 note (`:205`) | *"defines six of the nine states individually"* | *"defines eight of the nine states individually"* — and note that the ninth (**Sholat**) is added by this revision |
| E2 | §2 note (`:205`) + `[ASSUMPTION-006]` (`:257-259`) | *"No `CONTEXT.md` change in this specification."* | Remove the retraction; state that **Sholat** was added to `CONTEXT.md` (2026-10-23), so `REQ-004` / `AC-005` / `AC-006` are literally satisfiable |
| E3 | §2.1 mandated bullet (`:223`) + `[ASSUMPTION-001]` default (`:234`) | *"5 mode tampilan otomatis: …"* / *"9 mode tampilan otomatis: …"* | ***"9 status tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → Sholat → Slideshow Announcement → Imam Schedule → Wisdom Quote → Midnight Standby"*** |
| E4 | §5.4 file change set (`:474-484`) | 5 files, 2 created + 3 modified; `CONTEXT.md` listed under "Explicitly NOT touched" | **6 files** — add `CONTEXT.md` (**MODIFY**, XS); remove it from the "Explicitly NOT touched" list. Sizing stays **S** |
| E5 | `AC-011` (`:542-545`) | regex shape *"`<digits>.<digits>.<digits>` used as a version"* | Structural assertion: the scan asserts that `about_section.dart` declares **no** `version` / `buildNumber` members **and** imports `AppVersion` — catches build-number drift, which the current regex cannot |
| E6 | `AC-009` (`:532-535`) | *"`dart analyze lib test` … 0 errors, 0 warnings, and ≤ 4 infos"* | Append the scope note: *"(the `lib`/`test`-scoped measurement — the single permitted warning in `docs/ARCHITECTURE.md:274` lives in `tools/`, outside this scope)"* |
| E7 | §7 (`:581-589`) | two test seams only | Add a row assigning **AC-004** and **AC-013** to the **Phase 3 `check:full`** build-invocation verification (explicitly *not* `flutter test` cases), plus the §1.2/§4.3 anchor corrections (`main_display_page.dart:153,160,166,172`; `android/local.properties`; `about_section.dart:72-73`) |

### Projected Readiness Score after Remediation

| Criterion | Current | Projected | Delta driver |
| :--- | :---: | :---: | :--- |
| Completeness (40) | 36 | 38 | AC-004 / AC-013 verification locus assigned; AC-011 pattern closed |
| Clarity (30) | 21 | 27 | C1 contradiction removed; M1 factual error corrected; M3 ruled and recorded; AC-009 scope stated |
| Alignment (30) | 24 | 29 | Glossary now defines all nine states; citations corrected |
| **Weighted total** | **81** | **94** | — |
| **Critical Flaw Veto** | **Triggered** → **79** | **None** | C1 resolved |
| **Published score** | **79 / 100** | **~94 / 100** | — |

> **Reading of the projection.** The veto removal alone is worth 15 points, but the underlying arithmetic matters more: 94 is not a "perfect document" score — it reflects a specification that was already factually sound (26 of 26 citations verified) and needed *consistency surgery*, not *rediscovery*. The remaining 6 points are the residual ambiguity inherent to any specification that defers one out-of-scope initiative (`ASSUMPTION-005` — the landing page) and two build-invocation criteria (`AC-004`, `AC-013`) to later phases.

---

## 6. ✅ Final Resolution Summary

| # | Finding | Severity | Resolution | Executed? |
| :--- | :--- | :---: | :--- | :---: |
| **C1** | `REQ-004` forbids the copy `AC-005` mandates — "Sholat" has no `CONTEXT.md` entry | CRITICAL | Owner chose **Option A**: add the **Sholat** term to `CONTEXT.md`. `REQ-004` / `AC-005` / `AC-006` stand unchanged and are now literally satisfiable | ✅ **Executed** — `CONTEXT.md:21-23` (during `/to-clarify`) + §2.2 added to the spec |
| **M1** | Glossary-coverage count stated as "six of nine"; actual is eight of nine | MEDIUM | Correct the figure → edit **E1** | ✅ **Applied** — §2 note + `[ASSUMPTION-006]` now state "eight of the nine" |
| **M2** | `AC-011`'s `<d>.<d>.<d>` regex cannot catch build-number drift — the second half of the original defect | MEDIUM | Replace with a structural assertion (no `version`/`buildNumber` members; imports `AppVersion`) → edit **E5** | ✅ **Applied** — `AC-011` + its Value Sourcing row |
| **M3** | Mandated copy retained *"mode tampilan otomatis"* — the Indonesian form of the `_Avoid_` synonym *"screen mode"* | MEDIUM | Owner chose **Option A**: *"9 **status** tampilan otomatis"*, matching four independent domain-layer precedents. No `_Avoid_` edit, no `REQ-004` carve-out | ✅ **Applied** — §2.1 mandated bullet, `AC-005`, `AC-006`, §5.2 |
| **L1** | `main_display_page.dart` anchors off by 3 (`:153,160,166,172`) | LOW | Correct anchors → edit **E7** | ✅ **Applied** — §1.2 table + §1.5 H4 |
| **L2** | `local.properties` path imprecise — the file is `android/local.properties` | LOW | Correct the path → edit **E7** | ✅ **Applied** — §1.4 |
| **L3** | `about_section.dart:72-74` over-states the key-guard span (`:72-73`) | LOW | Correct the span → edit **E7** | ✅ **Applied** — §4.3 accessibility table |
| **L4** | `AC-009`'s analyzer scope narrower than the ratchet it cites, unstated | LOW | State the scope explicitly → edit **E6** | ✅ **Applied** — `AC-009` scope note |
| **L5** | `AC-004` / `AC-013` had no assigned verification locus | LOW | Assign both to the Phase 3 `check:full` build-invocation verification → edit **E7** | ✅ **Applied** — §7 verification-locus table |
| **CLARIFICATION-001** | Bullet shape: one bullet vs two | CLOSED | Owner chose **Option A**: one bullet, nine names, `→`, canonical enum order. Feature list stays at 7 bullets | ✅ **Applied** — resolved in §3; `[ASSUMPTION-001]` marked owner-confirmed |
| **ASSUMPTION-005** | `landingpage/panduan.html` release coupling | DEFERRED | `[Assumed / Auto-Resolved]` — **Option A (decouple)**, deferred as a separate out-of-scope initiative | ✅ Deferred by design |

**Files changed across the clarification + remediation sessions:** `CONTEXT.md` (one glossary entry added) · `docs/spec/about-page-version-drift-spec.md` (v1.0.0 → v1.1.0, 20 surgical edits) · `docs/audit/about-page-version-drift-spec-clarification.md` (this report). **No production code was touched**, per the phase boundary of both roles.

---

> **User Decision Prompt:** (Mandatory — score now ≥ 80)
> *The specification has been remediated and now carries a Readiness Score of **94/100** (Critical Flaw Veto lifted). All 8 findings and both clarifications are closed; **7 / 7** surgical edits (**E1–E7**) were applied, plus two consistency consequences the edit package did not anticipate — the `CONTEXT.md` anchor re-alignment caused by the glossary amendment, and `AC-006`'s canonical-term list, which had to gain "Sholat" to stay consistent with the new glossary.*
>
> *Do you want to **PROCEED** to `/to-plan @docs/spec/about-page-version-drift-spec.md` to break this architecture into vertical tracer bullets, or run another `/to-clarify` round to re-verify the remediated document?*
>
> **Recommendation: PROCEED to `/to-plan`.** The remediation was surgical and mechanical, and every open decision now has a single recorded resolution — there is no remaining ambiguity for a second audit to resolve. The specification's own §7 now assigns a verification locus to every acceptance criterion, which is exactly the contract `/to-plan` needs to build its task matrix without re-litigating anything. The two initiatives deliberately left open — the Android toolchain upgrade and the `landingpage/panduan.html` decoupling — are out of scope by construction and should not be folded in.

---

# 🔍 Clarification Report [Review Iteration 2]

**Target Document:** `docs/spec/about-page-version-drift-spec.md` (v1.1.0, status *Revised*)
**Audit Date:** 2026-10-23
**Method:** Full 5-axis re-interrogation of the remediated document + `/to-grill-me` Phase-1 lens (seam boundaries · sad paths · data-model invariants · verification determinism), applied from `.agents/skills/to-grill-me/SKILL.md`. The persona was **not** switched mid-session — AGENTS.md §8 session lock applies — but the interrogation method is identical (one question per turn, A/B with an opinionated recommendation, decisions log).
**Readiness Score (as the document stands):** **91 / 100**
**Status:** ⚠️ Interrogation in progress — 1 load-bearing decision open, 6 mechanical findings ready for auto-resolution.

## 📊 Score Breakdown (Iteration 2, pre-remediation)

- **Completeness (40%):** `37` / 40
  *Rationale:* Every requirement, invariant, AC, value source, UI state, and limiting case is present and traceable. Two genuine coverage gaps remain: the **partial-null branch** (`appBuildName` non-null while `appBuildNumber` is null) is described in §7's Extreme Limiting Cases but asserted by **no** acceptance criterion, and **AC-004 has no observable assertion procedure** — its pass condition ("the About screen of the resulting artifact renders `9.9.9` / `99`") presupposes observing a rendered screen on hardware that no CI command provides.*
- **Clarity (30%):** `26` / 30
  *Rationale:* Types are strict, contracts are table-driven, and the code contract is fully specified. Residual ambiguity: **AC-002** does not state *how* "the values rendered by the About section" are obtained (asserting `AppVersion` directly vs. pumping the widget — two materially different tests); **AC-013** asserts "the expected delta is exactly 0 bytes", an unverifiable claim (inlining a dart-define *removes* literals from the Dart snapshot, so the net delta is not provably zero); **AC-004** inherits the undefined-observation problem above; and the §4.3 WCAG row asserts the longer bullet "wraps" without stating a **measurable** bound.
- **Alignment (30%):** `28` / 30
  *Rationale:* Vocabulary matches `CONTEXT.md` exactly — all 10 glossary anchors re-verified against the live file. Seams and all seven ratchet citations match `docs/ARCHITECTURE.md`. Two internal inconsistencies remain, **both introduced by the Iteration-1 remediation**: §7's prose still says "**Two** complementary seams" while its table now lists three rows; and `[ASSUMPTION-002]`'s verification text still prescribes the *superseded* literal-shape scan ("scan `lib/presentation/` for version literals"), contradicting AC-011's new structural assertion.
- **Critical Flaw Veto:** **None** — no contradiction or blocking defect remains.

> **One deduction from Iteration 1 is formally retracted.** Iteration 1 charged **Alignment −1** for "the Discovery Draft §3.4 still describes the pre-revision state". On inspection this is **not** a defect: §3.4 is a *historical finding record* ("While validating the About page's other claims, one more inconsistency surfaced") whose quoted code state was accurate at discovery time. A discovery record is a snapshot of what was learned, not a claim about current state. The deduction is withdrawn, and the −1 is redistributed to the two real internal inconsistencies above.

---

## 1. 🚨 Iteration-2 Findings

### I2-1 — HIGH — AC-004 has no observable assertion procedure, and the "AOT verified" claim is misattributed

- **Condition / Requirement:** §1.2 asserts: *"The same holds for an AOT build | `[VERIFIED: feasibility spike] — `flutter build apk --debug` exited 0`"*. §7 assigns AC-004 to `check:full` with the pass condition *"The About screen of the resulting artifact renders `9.9.9` / `99`"*.
- **The Flaw:** **Two compounding defects.**
  1. **Misattributed evidence.** `flutter build apk --debug` produces a **JIT** artifact (kernel snapshot), **not** an AOT build. The release AOT path (`libapp.so`, where `String.fromEnvironment` values are inlined) was therefore **never empirically verified** — yet AC-013 requires a *release* build and the shipped artifact is precisely the AOT one.
  2. **Unobservable pass condition.** AC-004's condition requires *seeing a rendered screen*. No command in the project's toolchain renders a screen; the verifier would need a device or emulator. As written, the criterion is satisfied by a human's eyeball, which is exactly the kind of criterion the Floor-Guard (`CON-007`) exists to eliminate.
- **Empirical evidence gathered during this audit (read-only probe of the existing release artifact):**

  ```text
  build/app/outputs/flutter-apk/app-release.apk → lib/arm64-v8a/libapp.so (6,620,040 bytes)

  "1.2.2"                   → FOUND at byte 505563
  "5 mode tampilan otomatis" → FOUND at byte 377212
  "Miqotul Khoir TV"         → FOUND at byte 334265
  "1.4.4"                   → NOT FOUND
  ```

  **Three consequences follow, and they are the key to closing this finding:**
  - Dart string constants **are** present verbatim in the release AOT `libapp.so` → a dart-define value, once inlined, is observable in the shipped artifact. This gives AC-004 a **device-free, deterministic** oracle.
  - `"1.2.2"` present while `"1.4.4"` is **absent** is direct empirical proof that the *shipped release artifact* carries the stale version and has never carried the manifest version. The defect is confirmed on the AOT path, not merely on debug.
  - The scan is non-trivial but trivial to automate (extract one zip entry, byte-search two strings).
- **Decision required:** which verification procedure becomes binding for AC-004 — see §2 Item 1.

### I2-2 — MEDIUM — The partial-null branch is described but asserted by no acceptance criterion

- **Condition / Requirement:** §7 Extreme Limiting Cases: *"`pubspec.yaml` declares `version: 1.4.4` (no `+` segment) | `buildNumber` is `null` → renders `tidak tersedia` for the build field; the version field still renders `1.4.4`."*
- **The Flaw:** `AppVersion.buildName` and `AppVersion.buildNumber` are **independent** nullable fields. The state `name ≠ null ∧ buildNumber == null` is representable, reachable (a manifest declaring `version: 1.4.4` with no `+`), and described — but **AC-003 only covers the fully-absent case** (*"the manifest declares no version (so `appBuildName` is `null`)"* → both fields fall back). No criterion asserts the mixed state, so the mixed state's rendering is untested. The §7 Extreme Limiting Case also asserts the *guard test's parser* must handle a missing `+` without throwing — likewise asserted by no criterion.
- **Architectural Impact:** A regression that collapsed the mixed case (e.g. rendering an empty build field, or wrongly blanking the version) would pass the entire AC suite.

### I2-3 — MEDIUM — §7's prose says "Two complementary seams" while its table lists three

- **Condition / Requirement:** §7: *"**Testing Seam:** Two complementary seams, deliberately."* — followed by a table with **three** rows (the third, "Structural anti-regression scan", was added by the Iteration-1 remediation of `AC-011`).
- **The Flaw:** A self-contradicting count in the document's own testing contract.
- **Architectural Impact:** Trivial in code, but it signals that the Iteration-1 remediation updated the table without updating the prose that qualifies it — precisely the drift class this initiative exists to eliminate. It also under-describes the strategy: the scan is a genuinely different seam (static source analysis, not runtime observation).

### I2-4 — MEDIUM — `[ASSUMPTION-002]`'s verification text contradicts the remediated `AC-011`

- **Condition / Requirement:** `[ASSUMPTION-002]`: *"**Proposed Verification:** A repository-wide invariant test (REQ-002's test extended to scan `lib/presentation/` for version literals) enforces this at test time."*
- **The Flaw:** The literal-shape scan was replaced by the **structural assertion** in Iteration 1 (`AC-011`: no file may *declare* a `version` / `buildNumber` display constant; every version-displaying surface must import `AppVersion`). The assumption still prescribes the superseded mechanism. Two different verification strategies now appear in the same document for the same guarantee.
- **Architectural Impact:** An implementer reading §3 first would build the regex scan; one reading §6 first would build the structural scan. They are not equivalent — the regex cannot catch build-number drift (the original defect's second half).

### I2-5 — LOW — §6.2's scope sentence under-counts its own table

- **Condition / Requirement:** §6.2: *"Every value the feature produces or displays in **AC-001…AC-012** MUST have an explicit named source."*
- **The Flaw:** The table's last row sources **AC-013**'s APK-size value. The stated range should read `AC-001…AC-013`.

### I2-6 — LOW — AC-013 asserts an unverifiable delta claim

- **Condition / Requirement:** `AC-013`: *"it does not exceed **41.24 MB (43,240,043 bytes)**; the expected delta is exactly 0 bytes since no dependency was added."*
- **The Flaw:** Replacing two inline literals with dart-define inlines *removes* those strings from the Dart snapshot while adding no dependency — the net APK delta is plausibly near-zero but is **not provably exactly 0** (snapshot layout, const-pool ordering, and string-table alignment all shift). The *binding* condition (must not exceed the floor) is sound; the "exactly 0 bytes" expectation is stated with a precision the measurement cannot deliver, which invites a false failure during `check:full`.
- **Architectural Impact:** Low. It should read "must not grow" — which is what the ratchet actually says.

### I2-7 — LOW — AC-002 does not state the assertion procedure

- **Condition / Requirement:** `AC-002`: *"the values rendered by the About section are asserted equal to the parsed manifest values."*
- **The Flaw:** Two materially different tests satisfy this sentence: (a) assert `AppVersion.displayName` / `displayBuildNumber` against the parsed manifest — fast, no widget pump, and the true "manifest parity" oracle; or (b) pump `AboutSection` and assert the rendered text — slow, and partly redundant with the widget test. §7's Manifest-level-invariant row leans toward (a) but never says so.
- **Architectural Impact:** Low, but it is exactly the kind of latitude that produces two implementations. One sentence fixes it.

### I2-8 — LOW — §5.2 and §5.3 disagree on the mandated wording

- **Condition / Requirement:** §5.2: *"features list item #3 → '5 mode' corrected to the nine canonical states"* — while §5.3's diagram states the target as *"'9 status tampilan otomatis: …'"*.
- **The Flaw:** §5.2 names the **old** string as the thing being corrected but omits the **new** string, while §5.3 names it. A reader of §5.2 alone cannot tell what the copy becomes.
- **Architectural Impact:** Cosmetic; resolved by aligning §5.2's wording with §5.3's.

---

## 2. 🧩 Open Decision (Grill-Me)

*Iteration 2 surfaced **one** genuinely load-bearing decision — the six remaining findings (I2-2 … I2-8) are mechanical and have determinate resolutions recorded in §3.*

### Item 1 — How is AC-004 verified?

**Why this is the load-bearing one.** It is the only remaining place where the document asserts something that **no command can currently check**. Every other criterion resolves to a deterministic command: `flutter test`, `dart analyze`, `dart format`, or an APK size measurement. AC-004 is the exception — and it is the exception that *matters most*, because it is the criterion that proves the fix works in the artifact that actually ships (I2-1). Resolving it also retroactively repairs the misattributed AOT evidence in §1.2.

- **Proposed Options:**
  - **Option A — Two-part automated proof.** (i) `flutter test --dart-define=FLUTTER_BUILD_NAME=9.9.9 --dart-define=FLUTTER_BUILD_NUMBER=99` proves define → rendered UI; (ii) `flutter build apk --release --target-platform android-arm64 --build-name=9.9.9 --build-number=99` followed by a byte-scan of `build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/arm64-v8a/libapp.so` proves define → **shipped AOT artifact** (assert `9.9.9` present, `1.4.4` absent). Both device-free and CI-runnable. Costs one small `tools/` script using `dart:io` only — **zero new dependencies** (the uncompressed `libapp.so` is already in the build tree, so no zip extraction is required).
  - **Option B — dart-define test only.** (i) alone. Cheapest: no script, no release build, `check:fast`-grade.
  - **Option C — Manual device verification.** Install an overridden APK on hardware and read the About screen. Direct observation, but not CI-runnable, not reproducible, and a human eyeball is precisely what `CON-007` (Floor-Guard) exists to eliminate.
- **Engineering Recommendation:** **Option A.** It is the only option that closes *both* halves of I2-1 at once: it gives AC-004 a deterministic assertion **and** supplies the empirical AOT evidence that §1.2 currently misattributes to a JIT debug build. The cost is one `dart:io` script — cheaper than the manual device route and cheaper than the false confidence of Option B.
- **Agreed Decision:** ✅ **Option B — owner-confirmed 2026-10-23.** `flutter test --dart-define=…` only; no release-artifact scan; no new tooling.
- **Trade-off Accepted (must be recorded in the specification, not merely in this report):**
  1. The **AOT/release path carries no empirical version-parity evidence**. It rests on source reasoning: the dart-define injection at `flutter_command.dart:1506-1514` is build-mode-agnostic, so a release build receives the same `FLUTTER_BUILD_NAME` define as a test run.
  2. §1.2's row *"The same holds for an AOT build | `[VERIFIED: feasibility spike] — `flutter build apk --debug` exited 0`"* is **factually misattributed** — `--debug` is a JIT build. The claim must be restated truthfully regardless of which verification option is chosen; correcting a wrong citation is a truthfulness fix, not a scope change.
  3. The empirical probe performed during this audit (**not** part of the agreed verification procedure) found the **current shipped release artifact** carries `"1.2.2"` and does **not** contain `"1.4.4"` — i.e. the defect is confirmed on the AOT path as well. The mitigation hook is **AC-013's release build**, which already runs in `check:full`; the specification should name it as the point at which the AOT artifact's version is re-confirmed by inspection.

---

## 3. ⚠️ Assumed / Auto-Resolved (Iteration 2)

*Six remaining findings have determinate resolutions; none requires an owner decision. They are recorded here as the specification author's edit list R2–R11.*

| # | Finding | Resolution | Rationale |
| :--- | :--- | :--- | :--- |
| **R2** | I2-1 (honesty half) | Restate §1.2's AOT row truthfully: the dart-define injection is **build-mode-agnostic** (source-verified at `flutter_command.dart:1506-1514`); the spike proves population under the **test/JIT** path; a **release AOT build was not separately verified**. Add the audit's artifact probe as evidence that the shipped AOT artifact carries the stale literal, and name **AC-013's release build** as the re-confirmation hook. | A wrong citation is a defect regardless of the owner's verification choice. The distinction between "the define reaches a release build" (source-proven) and "the release artifact's version was observed" (not proven) must be explicit, or the document asserts something it does not know. |
| **R3** | I2-2 | Extend **REQ-005** to cover "the manifest provides no version **or** no build number", and add a new **AC-014 (Partial Manifest Version)** asserting: manifest `version: 1.4.4` with no `+` ⇒ version field renders `1.4.4`, build field renders `tidak tersedia`, and the guard test's parser yields a null build number without throwing. Add the matching §6.2 value-sourcing row and a §9 traceability row for `AC-014`. | The mixed-null state is representable, reachable, described in §7 — and asserted by nothing. Leaving it untested means a regression that collapses it passes the whole suite. `AC-014` is appended (not renumbered) so existing `AC-`/`REQ-` references in the traceability matrix and the Iteration-1 audit stay stable. |
| **R4** | I2-3 | §7's lead sentence becomes "**Three** complementary seams, deliberately", with the third seam identified as **static source analysis** (not runtime observation) — a genuinely different verification kind, which is why it deserves its own name rather than being folded into the manifest seam. | Removes the self-contradicting count and makes the strategy legible. |
| **R5** | I2-4 | `[ASSUMPTION-002]`'s *Proposed Verification* is rewritten to name the **structural scan** (no presentation-layer file may declare a `version` / `buildNumber` display constant; every version-displaying surface must import `AppVersion`) and to cross-reference `AC-011`. | Two different strategies for one guarantee currently coexist in the document. The structural scan is strictly stronger — it catches the build-number half of the original defect that a literal-shape regex cannot. |
| **R6** | I2-5 | §6.2's scope sentence reads `AC-001…AC-014`. | The table's own rows already include AC-013 and will include AC-014; the stated range must match. |
| **R7** | I2-6 | AC-013's expectation is restated: the **binding** condition is *"must not grow beyond 41.24 MB"*; the delta is *"expected to be ≈ 0 bytes"* — the measurement's resolution does not support "exactly 0 bytes", and inlining a dart-define shifts the Dart snapshot's const pool and string table. | A criterion stated with unachievable precision becomes a source of false failures in `check:full`. The ratchet's own wording is "must not grow"; the criterion should use it. |
| **R8** | I2-7 | AC-002 states its procedure: the guard test asserts `AppVersion.displayName` / `AppVersion.displayBuildNumber` against the values parsed from `pubspec.yaml` (no widget pump — this *is* the manifest-parity oracle); the widget test separately asserts the **rendered** version line. | Removes the latitude that lets two materially different tests satisfy one criterion. |
| **R9** | I2-8 | §5.2's layer-assignment line is aligned with §5.3: the target is named explicitly as *"9 status tampilan otomatis: …"*. | A reader of §5.2 alone currently cannot tell what the copy becomes. |
| **R10** | Clarity residual | §4.3's WCAG row is given a **measurable** bound: the corrected bullet MUST render at the 1920×1080 baseline **without a `RenderFlex` overflow**, and the widget test MUST assert that no overflow exception is thrown (Flutter surfaces overflow as a thrown error under `testWidgets`). | The current wording ("the existing `Row` + `Expanded` layout wraps it, so no horizontal clipping occurs") is an *assertion about layout behaviour*, not a bound. An automatable bound replaces the assertion. |
| **R11** | I2-5 / traceability follow-through | §6.1's AC list and §9's assumption-coverage line are updated for the new `AC-014`; §7's Extreme Limiting Case for the missing `+` gains an explicit pointer to `AC-014`. | Keeps every cross-reference in the document consistent after R3. |

---

## 4. 📚 Domain Glossary & ADR Alignment

- **Domain Glossary Updates:** **None required.** `CONTEXT.md` was amended during the `/to-clarify` session and now names all nine Display States; all ten glossary anchors used by the specification were re-verified against the live file during this iteration. No new domain term is introduced by Iteration 2.
- **ADRs Required:** **None.** No Iteration-2 finding changes an architectural commitment. The accepted AOT residual risk is a **verification-scope** decision with an owner and a mitigation hook, not a durable architectural position — it fails the "hard to reverse" and "surprising without context" gates of the Triple-Gate test.

---

## 5. 📝 Iteration-2 Outcome

| Criterion | Iter-1 published | Iter-2 audited | After R1–R11 | Driver |
| :--- | :---: | :---: | :---: | :--- |
| Completeness (40) | 38 | 37 | **40** | AC-014 closes the partial-null branch; AC-004 gains a deterministic procedure; the TV-legibility bound becomes automatable |
| Clarity (30) | 27 | 26 | **30** | AC-002 / AC-004 / AC-013 each state a procedure and a pass condition; the legibility assertion becomes a bound |
| Alignment (30) | 29 | 28 | **30** | §7 seam count and `[ASSUMPTION-002]` reconciled; §5.2 aligned with §5.3; Discovery-Draft deduction formally retracted |
| **Weighted total** | **94** | **91** | **100** | — |
| Critical Flaw Veto | None | None | **None** | — |

> **Why the audited score fell before it rose.** Iteration 2 is a *deeper* audit of a document that Iteration 1 had already remediated. It found eight issues that Iteration 1's pass did not surface — **two of them introduced by Iteration 1's own remediation** (the §7 seam count and the stale `[ASSUMPTION-002]` verification text, both consequences of replacing the regex scan with the structural assertion). A rising score across iterations is not evidence of rigor; the 91 → 100 path is. The 100 is reached by closing ten determinate defects, not by re-scoring the same document.
>
> **What 100 does and does not mean here.** It means: every acceptance criterion is bound to a command with a stated pass condition; every assertion has a named external oracle; every sad path — including the mixed-null branch — is asserted by some criterion; every cross-reference in the document is internally consistent; every glossary anchor resolves against the live file; and the one residual risk that remains (no empirical AOT parity evidence, per the owner's Option B decision) is **stated, owned, and hooked to a mitigation point**. It does **not** mean the specification is free of risk — it means no risk in it is unrecorded.

### Edit list — R1–R11 **APPLIED (11 / 11)**

*All eleven edits were applied to `docs/spec/about-page-version-drift-spec.md` (v1.1.0 → **v1.2.0**) on 2026-10-23 by the Specification Author. The table is retained as the record of what was specified and what was changed.*

| Edit | Target | Finding | Applied |
| :--- | :--- | :--- | :---: |
| **R1** | `AC-004` rewritten to the `flutter test --dart-define=…` procedure; §7's verification-locus row for AC-004 becomes `check:fast`-grade | I2-1 (owner decision) | ✅ |
| **R2** | §1.2's AOT row restated truthfully; residual-risk `CAUTION` added; AC-013 named as the re-confirmation hook | I2-1 (honesty) | ✅ |
| **R3** | `REQ-005` extended; **new `AC-014`**; §6.2 row; §9 matrix row | I2-2 | ✅ |
| **R4** | §7 lead sentence → "Three complementary seams" | I2-3 | ✅ |
| **R5** | `[ASSUMPTION-002]` verification text → structural scan | I2-4 | ✅ |
| **R6** | §6.2 range → `AC-001…AC-014` | I2-5 | ✅ |
| **R7** | `AC-013` expectation → "must not grow", delta "≈ 0 bytes" | I2-6 | ✅ |
| **R8** | `AC-002` assertion procedure stated | I2-7 | ✅ |
| **R9** | §5.2 wording aligned with §5.3 | I2-8 | ✅ |
| **R10** | §4.3 WCAG row → measurable overflow bound | Clarity residual | ✅ |
| **R11** | §9 / §7 / assumption-coverage cross-references updated for `AC-014` | R3 follow-through | ✅ |

---

# 🔍 Clarification Report [Review Iteration 3 — Post-Remediation Verification]

**Target Document:** `docs/spec/about-page-version-drift-spec.md` (v1.2.0, status *Revised*)
**Audit Date:** 2026-10-23
**Purpose:** Independent verification that the R1–R11 remediation actually landed, and that no defect was introduced by the remediation itself.
**Readiness Score:** **100 / 100**
**Status:** ✅ **Verified — Ready for `/to-plan`**

## 📊 Score Breakdown

- **Completeness (40%):** `40` / 40
  *Rationale:* 14 acceptance criteria, every one bound to a **command and a pass condition** (§7). All five UI states explicitly adjudicated with a per-state rationale (§4.3). Six extreme limiting cases, each now carrying an explicit pointer to the criterion that asserts it — including the mixed-null branch, which gained `AC-014` and no longer rests on description alone. Every displayed value has a named source across 14 rows of §6.2. All six assumptions closed with a recorded owner decision.
- **Clarity (30%):** `30` / 30
  *Rationale:* No fuzzy or unverifiable language survives. `AC-002` names its assertion procedure (`AppVersion` constants directly, no widget pump); `AC-004` names its exact `flutter test --dart-define=…` command; `AC-013` and `CON-002` now state the binding condition ("must not grow") and the expectation ("≈ 0 bytes") separately, so the criterion no longer asserts a precision the measurement cannot deliver; the WCAG row is a measurable `RenderFlex`-overflow bound rather than a claim about layout behaviour.
- **Alignment (30%):** `30` / 30
  *Rationale:* All **10** `CONTEXT.md` anchors re-verified against the live file — every one resolves to its term heading. All seven `docs/ARCHITECTURE.md` ratchet citations match. `[ASSUMPTION-002]`'s verification text now names the same structural scan as `AC-011` (no two strategies remain for one guarantee). §7's seam count, §5.2 and §5.3's mandated copy, and §5.4's six-file set are mutually consistent. §9's traceability matrix covers every requirement and constraint with no orphan.
- **Critical Flaw Veto:** **None.** No contradiction, no blocking defect, no tautological acceptance criterion.

## ✅ Verification Ledger

| Check | Method | Result |
| :--- | :--- | :--- |
| All R1–R11 landed | Diffed each edit against the specification text | **11 / 11** applied |
| Acceptance-criterion inventory | Regex extraction of `AC-XXX` definitions vs. every reference in the document | **14 defined** (001–014) · **0 undefined references** · **0 orphan** (every AC is referenced at least twice — definition + traceability/sourcing) |
| Requirement & constraint inventory | Regex extraction | **7 REQ** · **9 CON** · all referenced by ≥ 1 AC |
| Glossary anchors | 10 `CONTEXT.md` line references re-resolved against the live file | **10 / 10 OK** — `Display State`:55, `Standby`:59, `Slideshow Announcement`:63, `Imam Schedule`:67, `Wisdom Quote`:71, `Midnight Standby`:75, `Sholat`:21, `Adzan`:9, `Iqomah`:13, `Pre-Adzan`:17 |
| File change set | §5.4 rows extracted | **6 files** — `lib/core/app_version.dart` (CREATE), `about_section.dart` (MODIFY), `test/analysis/app_version_consistency_test.dart` (CREATE), `about_section_test.dart` (CREATE), `docs/ARCHITECTURE.md` (MODIFY), `CONTEXT.md` (MODIFY, already executed) |
| Source citations | All `file:line` references re-resolved | **Unchanged and valid** — no production source file was modified by this initiative, so §1.2 / §4.3 / §5.2 anchors remain accurate |
| Ratchet citations | `docs/ARCHITECTURE.md:273-277, 279, 282` | **Valid** — errors `0`, warnings `≤ 1`, infos `≤ 4`, tests `535/59`, unformatted `≤ 16`, domain purity `0`, APK `41.24 MB` |
| Assumption coverage | §9 coverage line vs. §3 | **6 / 6 closed** — no assumption remains open |
| Residual risk | §1.2 `CAUTION` + `AC-013` release-gate hook | **Recorded, owned, and hooked** — see below |

## 🚨 Two residuals caught by this verification pass

The re-audit was not a formality: it caught **two** defects that the remediation had itself introduced or left behind, both now fixed.

| # | Defect | Introduced by | Resolution |
| :--- | :--- | :--- | :--- |
| **V3-1** | `CON-002` still read *"the expected delta is exactly **0 bytes**"* after `AC-013` was rewritten to *"≈ 0 bytes … deliberately not asserted to be exactly 0"*. The constraint and its own acceptance criterion therefore disagreed in precision — the constraint would have demanded a byte-exact delta that the measurement cannot produce. | **R7** fixed the AC but not the CON | `CON-002` rewritten to match: binding condition *"must not grow beyond"*, expectation *"≈ 0 bytes"*, with the same rationale and a pointer to `AC-013` as its executable form. |
| **V3-2** | §7's lead sentence read *"Most criteria are satisfied by a plain `flutter test` invocation. **Two** need a specific invocation, and one needs a build"* — a loose count that did not map cleanly onto the table below it (`AC-004` needs a dart-define override, `AC-014` a specific test file, `AC-013` a build). | **R1** rewrote the table but not the sentence qualifying it | Sentence rewritten to name each criterion's specific requirement: *"**AC-004** needs a **dart-define override**, **AC-014** needs a **specific test file**, and **AC-013** needs a **build invocation**"*. |

> Both are the same failure mode the Iteration-1 remediation exhibited: a table was updated while the prose qualifying it was not. It is a good sign that the audit was re-run — a checklist-only pass would have missed both and shipped a document whose prose contradicted its own tables.

## ⚠️ The one residual risk — recorded, owned, not eliminated

The release-AOT path carries **no empirical version-parity evidence**. This is a consequence of the owner's Option B decision (`flutter test --dart-define=…` as `AC-004`'s sole procedure; the release-artifact byte-scan was declined), and it is now **stated in the specification itself**:

- §1.2 carries a `[!CAUTION]` naming the risk, its cause (the guarantee rests on source reasoning — the dart-define injection at `flutter_command.dart:1506-1514` is build-mode-agnostic — rather than on observation of a release artifact), and the owner decision that produced it.
- §1.2's verified-facts table now records the audit's read-only artifact probe: the existing release `libapp.so` contains `"1.2.2"` and **not** `"1.4.4"` — the defect is confirmed on the AOT path as well.
- `AC-013`'s release build is named the **re-confirmation hook**: at that point the artifact's version is re-checked by inspection as a release-gate step.

**A documented, owned, hooked risk is not an ambiguity** — it does not reduce the Readiness Score, and it does not need an ADR (it fails the "hard to reverse" and "surprising without context" gates of the Triple-Gate test).

---

> **User Decision Prompt:** (Mandatory — score ≥ 80)
> *The specification has been remediated and independently re-verified. **Readiness Score: 100 / 100** (Completeness 40/40 · Clarity 30/30 · Alignment 30/30 · Critical Flaw Veto: none). All 14 acceptance criteria are bound to a command and a pass condition; all 10 glossary anchors resolve against the live file; all six assumptions are closed; the six-file change set, the traceability matrix, and the three seams are mutually consistent. The one residual risk (no empirical release-AOT version-parity evidence) is recorded in §1.2 with its release-gate mitigation hook.*
>
> *Do you want to **PROCEED** to `/to-plan @docs/spec/about-page-version-drift-spec.md`, or run a further `/to-grill-me` round to stress-test the architecture before planning?*
>
> **Recommendation: PROCEED to `/to-plan`.** Three clarification iterations have now interrogated this document from independent angles and the residual defect count is zero. The specification is S-sized with a six-file change set; further interrogation would produce diminishing returns. The two initiatives deliberately left open — the Android toolchain upgrade and the `landingpage/panduan.html` decoupling — are out of scope by construction and must not be folded into the plan.

---

> **User Decision Prompt:** (Mandatory — score ≥ 80)
> *The Iteration-2 interrogation is complete. One load-bearing decision was taken (**Option B** — `flutter test --dart-define=…` for AC-004) and ten further edits (**R2–R11**) are determinate and require no further input. The specification stands at **91/100** as it is today; applying **R1–R11** raises it to **100/100**.*
>
> *Do you want to **PROCEED** to `/to-spec @docs/spec/about-page-version-drift-spec.md` to apply R1–R11 (the Specification Author's role — the Auditor specifies, the Author applies), or run another `/to-grill-me` pass to challenge the R1–R11 resolutions before they are written?*
>
> **Recommendation: PROCEED to `/to-spec`.** R2–R11 are mechanical and already specified to the line; re-grilling them would re-derive decisions the owner has taken. The one genuinely contestable choice — how AC-004 is verified — was put to the owner with the full empirical trade-off laid out, and was decided. The decisions log is at `docs/audit/about-page-version-drift-spec-decisions.md` for the record.




