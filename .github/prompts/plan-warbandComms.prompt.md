## Plan: Warband Comms Rebrand + UX Roadmap

Full internal rename will be done first (as requested), then the checkbox/UI visibility bug will be fixed as the first functional milestone, followed by UI/UX improvements delivered one-at-a-time for safe in-game testing and fast rollback. Open-source readiness will be established early, with license choice handled as a planned decision checkpoint.

**Steps**
1. Phase 0 - Baseline and safety snapshot
- Confirm startup/load path and UI registration flow in RetWBComms.lua, RetWBComms.mod, RetWBComms.xml, config.lua, and ui.lua.
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
- Milestone 4B: box size controls (width/height, with sane min/max clamps).
- Milestone 4C: background opacity control (and optional background color if low effort).
- Milestone 4D: header simplification (remove clutter formatting, improve readability).
- Milestone 4E: header emphasis options (color and weight/style presets).
- After each milestone, run in-client verification before moving to next milestone.

6. Phase 5 - Stabilization and release prep (depends on 4)
- Validate all trackers across classes and realms.
- Validate inter-player communication behavior still works with chosen naming/protocol strategy.
- Update changelog with explicit breaking changes and migration notes.
- Tag release candidate and gather user feedback loop.

**Relevant files**
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/RetWBComms.lua - Main namespace, init flow, saved settings root, chat protocol handling.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/RetWBComms.mod - Addon metadata, module load identity, version alignment.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/RetWBComms.xml - XML includes and UI asset wiring.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/config.lua - Settings UI generation, checkbox handlers, tracker/global toggles.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/config.xml - Config window naming and structure.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/config-template.xml - Config control template naming.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/ui.lua - Tracker window creation, header formatting, color/alpha application.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/ui-template.xml - Row/header layout, fonts, dimensions.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/slash.lua - Slash aliases and deprecation additions.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/changelog.md - Breaking change and milestone notes.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/README.md - New project docs and governance.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/.gitignore - Repo hygiene.
- c:/Warhammer Online - Return of Reckoning/Interface/AddOns/RetWBComms/LICENSE - License text (after selection).

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

**Decisions**
- Include: full internal+external rename now.
- Include: no backward compatibility migration for saved settings/chat protocol by default.
- Include: first functional milestone is checkbox/UI visibility sync fix.
- Include: remaining UI improvements shipped one-by-one with local client testing.
- Include: keep current aliases, deprecate /ret, and evaluate /wb-comms + /wbc.
- Exclude for now: broad feature additions unrelated to current UX/rename goals.

**Further Considerations**
1. License checkpoint: choose MIT vs GPL-3.0 vs Apache-2.0 before public release branch cut.
2. Communication protocol risk: if chat tag format changes during rename, mixed-version warbands may lose events.
3. Name migration risk: if file/folder/module identity changes, loader behavior must be revalidated in client immediately after Phase 2.