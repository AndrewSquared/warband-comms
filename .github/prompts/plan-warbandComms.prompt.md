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
  - Keep existing aliases for transition
  - Mark /ret as deprecated
  - Add /wb-comms and /wbc aliases if command parser accepts hyphen tokenization
- Update documentation to reflect new command set and deprecation messaging.

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
- After each milestone, run in-client verification before moving to next milestone.

6. Phase 5 - Stabilization and release prep (depends on 4)
- 5A Protocol hard-break implementation:
  - remove legacy incoming compatibility for [RET]/[DEVA]
  - keep [WBC] as the single outbound/inbound protocol key
  - remove legacy deprecation warning path tied to legacy key acceptance
- 5B Breaking-change communication:
  - document protocol break clearly in changelog and README
  - add migration note: mixed-version warbands are not supported after this change
- 5C Settings UI medium refactor:
  - introduce layout constants in config.lua to reduce hardcoded coordinates
  - normalize control alignment/spacing and dynamic section placement
  - fix window height calculation to use max(tracker rows, notification rows)
  - consolidate repeated label/color init logic for maintainability
- 5D Stabilization and release prep:
  - validate all trackers across classes and realms
  - validate inter-player communication behavior for WBC-only clients
  - tag release candidate and gather user feedback loop

**Phase 5 kickoff (in progress)**
- Added a dedicated stabilization and release checklist in README to run through in-client before tagging.
- Completed static editor validation on touched Lua/XML files (no parser errors reported).
- Decision confirmed: remove RET/DEVA compatibility now (breaking change), no temporary dual-send fallback.
- Completed: 5A protocol hard-break implementation (WBC-only inbound/outbound behavior).
- Completed: 5C settings UI medium refactor (grouping cleanup, layout constants, clickable value controls).
- Pending: run in-client verification matrix for 5A/5C and perform any follow-up tuning.

**Relevant files**
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/WarbandComms.lua - Main namespace, init flow, saved settings root, chat protocol handling.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/WarbandComms.mod - Addon metadata, module load identity, version alignment.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/WarbandComms.xml - XML includes and UI asset wiring.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/config.lua - Settings UI generation, checkbox handlers, tracker/global toggles.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/config.xml - Config window naming and structure.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/config-template.xml - Config control template naming.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/ui.lua - Tracker window creation, header formatting, color/alpha application.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/ui-template.xml - Row/header layout, fonts, dimensions.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/slash.lua - Slash aliases and deprecation additions.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/changelog.md - Breaking change and milestone notes.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/README.md - New project docs and governance.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/.gitignore - Repo hygiene.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms/LICENSE - License text (after selection).

**Verification**
1. Launch addon and confirm module loads with no XML/Lua reference errors after rename.
2. Confirm all slash aliases work, including deprecation message behavior for /ret and new aliases if added.
3. Reproduce prior checkbox mismatch case and verify fixed behavior for:
- tracker checked + global off
- tracker unchecked + global on
- toggling from config vs UI editor
4. Confirm LayoutEditor reflects real visibility state after each toggle action.
5. After each UI milestone, verify readability in active combat and idle states on common resolutions.
6. Validate persistence by reload/restart: settings, visibility states, and layout positions remain as expected.
7. Confirm protocol hard-break behavior:
- WBC-only clients interoperate normally.
- Legacy RET/DEVA messages are ignored.
- Mixed-version warbands are expected to be non-interoperable.
8. Confirm settings UI refactor behavior:
- control rows align evenly across columns
- dynamic tracker/notification sections size and anchor correctly
- config window height fits larger of tracker/notification lists

**Decisions**
- Include: full internal+external rename now.
- Include: no backward compatibility migration for saved settings/chat protocol by default.
- Include: first functional milestone is checkbox/UI visibility sync fix.
- Include: remaining UI improvements shipped one-by-one with local client testing.
- Include: keep current aliases, deprecate /ret, and evaluate /wb-comms + /wbc.
- Include: immediate removal of RET/DEVA protocol compatibility as a breaking change.
- Include: medium settings UI refactor (layout consistency + maintainability), not a full redesign.
- Exclude: temporary dual-send fallback and legacy protocol compatibility modes.
- Exclude for now: broad feature additions unrelated to current UX/rename goals.

**Further Considerations**
1. License checkpoint: choose MIT vs GPL-3.0 vs Apache-2.0 before public release branch cut.
2. Communication protocol compatibility is intentionally strict after Phase 5A: all participants must run WBC-only versions.
3. Release note visibility: breaking protocol change should be highlighted in release title/body and changelog top section.
4. Name migration risk: if file/folder/module identity changes, loader behavior must be revalidated in client immediately after Phase 2.