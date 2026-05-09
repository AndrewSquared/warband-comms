## Plan: Warband Comms Rebrand + UX Roadmap

Full internal rename will be done first (as requested), then the checkbox/UI visibility bug will be fixed as the first functional milestone, followed by UI/UX improvements delivered one-at-a-time for safe in-game testing and fast rollback. Open-source readiness will be established early, with license choice handled as a planned decision checkpoint.

**Steps**

1. Phase 0 - Baseline and safety snapshot

- Confirm startup/load path and UI registration flow in WarbandComms.lua, WarbandComms.mod, WarbandComms.xml, config.lua, and ui.lua.
- Capture a pre-change checklist: slash commands available, tracker windows visible/hidden behavior, and current saved settings keys.
- Note expected intentional breakages (no backward compatibility migration, per user decision).

2. Phase 1 - Open-source scaffolding (parallelizable with Phase 2 prep)

- Add README.md with: project purpose, install path for Return of Reckoning, commands, tracker behavior, and contribution workflow.
- Add .gitignore for addon development artifacts and editor/system files.
- Add a license decision section in README and create LICENSE only after final license selection.
- Normalize changelog/version references (Lua version vs .mod version mismatch) and define one source of truth.

3. Phase 2 - Full rebrand to Warband Comms (depends on 1 baseline)

- Rename visible branding in metadata and UI labels from RetWBComms naming to Warband Comms.
- Perform full internal rename scope:
  - Lua global namespace and AddonName value
  - XML window/template names
  - Mod metadata and file/module references
- Keep selected slash strategy:
  - Use canonical commands only: /warbandcomms, /wb-comms, /wbc
  - Remove deprecated/legacy aliases from runtime registration and docs
- Update documentation to reflect the canonical command set.

4. Phase 3 - Fix checkbox/UI visibility sync bug (depends on 2)

- Unify tracker visibility computation into one helper used by both toggle paths:
  - Global toggle path
  - Individual tracker toggle path
- Ensure final visibility always respects both global enabled state and per-tracker state.
- Ensure LayoutEditor state remains consistent when visibility changes from config toggles.
- Validate no regressions in showOnStartup and slash-opened config behavior.

5. Phase 4 - UI improvements delivered incrementally (depends on 3)

- Milestone 4A: independent text size control (header and row text, shared or split settings).
- Milestone 4A refinement: keep LayoutEditor resize behavior intuitive (box/text scale in same direction) while syncing LayoutEditor hidden state with tracker visibility changes.
- Milestone 4A hardening: avoid duplicate LayoutEditor registration side-effects and clean up legacy typo window registrations (interupt) that can produce phantom draggable boxes.
- Milestone 4B: box size controls (width/height, with sane min/max clamps).
- Milestone 4B implementation: added config controls for shared tracker width/height, live apply to all tracker windows, and persisted clamped settings.
- Milestone 4B refinement: normalize title/row alignment to current tracker width and avoid forced re-anchoring during shared resize (prevents position jitter/bounce).
- Milestone 4B UX compare: add switchable resize mode (Uniform vs Relative) so shared controls can either normalize all tracker sizes or preserve per-tracker deltas from LayoutEditor.
- Milestone 4C: background opacity control (and optional background color if low effort).
- Milestone 4C implementation: added shared background opacity control with persisted setting, clamp limits, and live apply across all tracker windows.
- Milestone 4D: header simplification (remove clutter formatting, improve readability).
- Milestone 4D implementation: simplified tracker headers (plain readable titles without decorative separators), improved title spacing, and tuned header contrast for readability.
- Milestone 4E: header emphasis options (color and weight/style presets).
- Milestone 4E implementation: added configurable header emphasis presets with live-applied tone options and style presets for cleaner or stronger title treatment.
- Milestone 4E refinements: switched title alignment to left with extra header spacing, expanded tone choices (removed soft; added red/green/blue), and simplified style choices to Clean/Caps (legacy Strong maps to Caps).
- Milestone 4E refinements: updated LTC display label to "Leading the Charge" for improved readability.
- Milestone 4E follow-up: split Immaculate Defense into its own dedicated `ID` tracker box instead of grouping it under `LTC`.
- After each milestone, run in-client verification before moving to next milestone.

6. Phase 5 - Stabilization and release prep (depends on 4)

- 5A Protocol transition-compat implementation:
  - restore legacy incoming compatibility for [RET]/[DEVA] while keeping [WBC] accepted inbound
  - use single outbound legacy realm key during transition ([RET] on Order, [DEVA] on Destro) to preserve one-message UX
  - keep message payload format unchanged ([key]:tracker:duration:cooldown[:careerIcon])
  - do not dual-send; do not use composite hybrid key formats
- 5B Transition communication:
  - document that mixed-version warbands are supported during transition mode
  - note that outbound key is temporarily legacy for interoperability and that sunset back to WBC-only is planned
  - add clear release note text for future cutover criteria/timeline
- 5C Settings UI medium refactor:
  - introduce layout constants in config.lua to reduce hardcoded coordinates
  - normalize control alignment/spacing and dynamic section placement
  - fix window height calculation to use max(tracker rows, notification rows)
  - consolidate repeated label/color init logic for maintainability
- 5D Stabilization and release prep:
  - validate all trackers across classes and realms
  - validate inter-player communication behavior for mixed-version and WBC-only clients
  - tag release candidate and gather user feedback loop

7. Phase 6 - CI/CD release automation (depends on 5)

- Add shared release-state validation script for version sync, changelog top-entry checks, and package structure checks.
- Add PR workflow (`PR Validation`) to run validation checks and build/verify both release and test zips.
- Add tag workflow (`Release Publish`) triggered by `vX.Y.Z` to build release zip, validate it, generate notes from changelog, and upload GitHub Release asset.
- Add PR template with explicit maintainer in-client validation gate before tagging.
- Update README/CONTRIBUTING/RELEASING docs so the developer path is: PR -> approval + in-client validation -> tag -> automated GitHub release asset upload.

Decision change (2026-05-03): superseded prior WBC-only hard-break plan; adopted silent transition compatibility to minimize chat noise and preserve mixed-version warband interoperability.

**Phase 5 kickoff (in progress)**

- Added a dedicated stabilization and release checklist in README to run through in-client before tagging.
- Completed static editor validation on touched Lua/XML files (no parser errors reported).
- Decision updated: backwards compatibility restored for transition period; no dual-send fallback.
- Completed: protocol transition behavior is implemented (single outbound legacy realm key by realm; inbound accepts [WBC]/[RET]/[DEVA]).
- Completed: 5C settings UI medium refactor (grouping cleanup, layout constants, clickable value controls).
- Completed: refreshed test-build validation helpers with `/wbc testboxes` (full tracker-box population) and `/wbc testcenter` (LTC/ID alert preview).
- Completed (2026-05-09): in-client mixed-version verification matrix for 5A/5C.
- Follow-up: keep monitoring during next stabilization sweep; no immediate tuning blockers recorded.

**UI hotfix track (2026-05-03, in progress)**

- Completed: readability baseline improvements for small tracker sizes (minimum width clamp, compact row behavior, cleaner header summary alignment).
- Completed: config UX polish (label-only tooltips and white center value labels between [-]/[+]).
- Completed: centralized resize sync path so width/height changes consistently re-run clamp + internal layout + header fit logic.
- Completed: external LayoutEditor dimension drift detection with cache-based re-sync in the UI update loop.
- Completed: Relative mode switch now normalizes each tracker's live LayoutEditor dimensions before applying +/- deltas.
- Completed: ready-state timers now render a green `0` instead of blank text.
- Completed: Resize Mode value control widened so full "Uniform"/"Relative" labels are visible (no clipped "Unifor"/"Relati" states).
- Completed: header visibility hardening for the repro path (LayoutEditor resize -> switch Uniform to Relative -> apply +/-), with compact thresholds tuned so short titles remain stable while shrinking toward compact widths.
- Completed: short-height overflow mitigation by capping rendered rows to available tracker height when windows are vertically compressed.
- Planned enhancement: add optional direct numeric input controls for Box Width/Height (with clamp + Apply) so verification and tuning are not limited to +/-10 step increments.
- Completed (2026-05-09): in-client verification pass for downward width transitions across all five trackers (focus: Challenge and ID) at 120-170px range.

UI hotfix verification matrix (completed 2026-05-09; retain as regression checklist):

1. Baseline reset

- Use `/wbc testboxes` to populate all trackers.
- Set Resize Mode to Uniform and click the Box Width value to reset to default baseline (125).

2. Repro path validation

- In LayoutEditor, resize Challenge and ID to different sizes using corner handles (WAR LayoutEditor does uniform corner scaling; edge-only drag is not available).
- Switch Resize Mode from Uniform to Relative.
- Press Box Width [-] in repeated steps down to the smallest clamped width.
- Expected: header title remains visible as a short title until compact hide threshold; no premature disappearance while shrinking.

3. Cross-tracker transition sweep

- Repeat step 2 while watching LTC, Channels, Interrupt, Challenge, and ID.
- Expected at 120-170px range: short-title fallback is stable, summary counters remain aligned, row mode changes only at compact row threshold.

4. Ready-state timer validation

- Wait for at least one row to reach ready state.
- Expected: timer text shows green `0` (not blank).

5. Persistence check

- Reload UI or restart client.
- Expected: per-tracker Relative differences persist and header behavior remains stable after reload.

Latest in-client verification notes:

- Steps 2 and 3: pass for title behavior; compact abbreviations are showing appropriately during the tested transitions.
- Step 4: pass; ready-state timer displays green `0` as expected.
- Step 5: pass; Relative mode differences and header behavior persisted correctly after reload.
- Additional finding from earlier testing: very short heights could cause overflow; mitigation was implemented and re-check passed during the 2026-05-09 sweep.

**Phase 6 kickoff (in progress)**

- Added `scripts/validate_release_state.py` for version/changelog/package validation.
- Added `.github/workflows/pr-validate.yml` for pull-request packaging/validation checks.
- Added `.github/workflows/release.yml` for tag-driven release publishing with changelog-based notes.
- Added `.github/pull_request_template.md` with explicit maintainer in-client release gate checkbox.
- Pending: run first dry-run release tag and confirm GitHub release asset upload behavior end-to-end.

**Relevant files**

- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/WarbandComms.lua - Main namespace, init flow, saved settings root, chat protocol handling.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/WarbandComms.mod - Addon metadata, module load identity, version alignment.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/WarbandComms.xml - XML includes and UI asset wiring.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/config.lua - Settings UI generation, checkbox handlers, tracker/global toggles.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/config.xml - Config window naming and structure.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/config-template.xml - Config control template naming.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/ui.lua - Tracker window creation, header formatting, color/alpha application.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/ui-template.xml - Row/header layout, fonts, dimensions.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/slash.lua - Slash command registration and command handlers.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/changelog.md - Breaking change and milestone notes.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/README.md - New project docs and governance.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/.gitignore - Repo hygiene.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/LICENSE - License text (after selection).

**Verification**

1. Launch addon and confirm module loads with no XML/Lua reference errors after rename.
2. Confirm canonical slash commands work: /warbandcomms, /wb-comms, /wbc.
3. Reproduce prior checkbox mismatch case and verify fixed behavior for:

- tracker checked + global off
- tracker unchecked + global on
- toggling from config vs UI editor

4. Confirm LayoutEditor reflects real visibility state after each toggle action.
5. After each UI milestone, verify readability in active combat and idle states on common resolutions.
6. Validate persistence by reload/restart: settings, visibility states, and layout positions remain as expected.
7. Confirm protocol transition behavior:

- new clients ingest [WBC], [RET], and [DEVA] correctly
- outbound from current addon uses one legacy realm key message per cast (no duplicates)
- mixed-version warbands (old/new) interoperate on both realms
- malformed or unknown protocol keys are ignored

8. Confirm settings UI refactor behavior:

- control rows align evenly across columns
- dynamic tracker/notification sections size and anchor correctly
- config window height fits larger of tracker/notification lists

**Decisions**

- Include: full internal+external rename now.
- Include: no backward compatibility migration for saved settings by default.
- Include: first functional milestone is checkbox/UI visibility sync fix.
- Include: remaining UI improvements shipped one-by-one with local client testing.
- Include: canonical slash command set only (/warbandcomms, /wb-comms, /wbc).
- Include: temporary transition compatibility mode (single outbound legacy realm key + broad inbound key acceptance).
- Include: preserve one-message UX; exclude dual-send.
- Include: medium settings UI refactor (layout consistency + maintainability), not a full redesign.
- Exclude: composite key-in-one-message formats (e.g., [RET][WBC]) due parser incompatibility.
- Exclude for now: immediate strict WBC-only hard-break until migration completion criteria are met.
- Exclude for now: broad feature additions unrelated to current UX/rename goals.

**Further Considerations**

1. License selection resolved: MIT (see LICENSE and README).
2. Protocol policy is transition-first: maintain mixed-version interoperability now, then reintroduce strict WBC-only after defined adoption threshold.
3. Release-note visibility: highlight transition compatibility behavior now and pre-announce eventual WBC-only cutover.
4. Name migration risk: if file/folder/module identity changes, loader behavior must be revalidated in client immediately after Phase 2.
