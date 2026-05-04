3.6.0 (2026-05-03)

- improved small-size tracker readability by enforcing a higher minimum box width clamp (120)
- removed header summary slash separators and tightened spacing for cleaner count alignment
- updated config center value labels (between [-] and [+]) to render white for better consistency
- added label-only config tooltip placeholders (static labels and dynamic tracker/notification labels)
- fixed header summary counters scaling with row text size; counters now follow header text scale, capped at default size
- fixed counter positions not updating when text scale changes (ApplyTextScale now re-runs layout)
- fixed header title text not abbreviating at small box sizes; space estimation now derived from box width instead of label content dimensions
- fixed header title text not re-fitting when box width changes; resize paths now re-evaluate title fit after layout
- fixed tracker key normalization in header title fitting so Challenge consistently resolves to short title behavior (`CHAL`) in compact widths
- added compact header thresholds: force short title at small widths and hide title text at extreme small form factors
- added deterministic compact row mode at narrow widths (<=140): row names are hidden and rows render as class icon + colored timer for legibility
- added external tracker-dimension change detection and cache-based re-sync so LayoutEditor-resized windows are normalized through the same layout/header pass
- fixed Relative resize mode now normalizes LayoutEditor-set window sizes through the clamp pipeline on mode switch, preventing stale baselines from causing mismatched widths when +/- buttons are pressed
- fixed ready-state timer now shows green "0" instead of blank so at-a-glance status is unambiguous
- hardened compact header title visibility thresholds so short tracker titles remain visible across the small-width clamp range during downward resize transitions
- widened Resize Mode value control so "Uniform" and "Relative" labels render fully (no "Unifor"/"Relati" clipping confusion)
- fixed short-height tracker overflow by capping rendered rows to available tracker height, preventing text/icon spill when boxes are vertically compressed
- added repository no-image policy enforcement (pre-commit helper plus CI workflow checks) to prevent binary image drift
- expanded release automation docs/workflows and added scripted changelog validation tooling for release readiness

- note: `4.0.0` is reserved for the future WBC-only protocol cutover that removes legacy `[RET]` / `[DEVA]` behavior

- full internal/external rebrand from RetWBComms to WarbandComms
- renamed core addon files to WarbandComms.lua, WarbandComms.xml, and WarbandComms.mod
- updated module metadata and saved variable root to WarbandComms.Settings
- fixed tracker visibility sync logic so per-tracker toggles always respect global enabled state
- fixed notification checkbox initialization to read from settings.notifications
- added slash aliases: /warbandcomms, /wb-comms, /wbc
- deprecated /ret slash command with in-chat guidance to /wbc
- deprecated /retwbcomms and /rwc slash commands with in-chat guidance to /wbc
- added independent text size controls for tracker headers and row text in config
- finalized text scaling behavior: +/- controls set addon text scale; LayoutEditor resize remains intuitive (box and text scale together)
- synced LayoutEditor hidden state with tracker visibility toggles
- hardened LayoutEditor registration to avoid duplicate/phantom entries and clean legacy interupt typo registrations
- added tracker box width and height controls in config with live apply and clamp limits
- persisted tracker box width and height settings across reload/restart
- fixed shared box resize jitter by removing forced window re-anchoring during width/height changes
- normalized tracker title and row alignment to the current box width for consistent header positioning
- added resize mode switch for box controls: Uniform (normalize all tracker sizes) or Relative (preserve per-tracker layout deltas)
- added background opacity controls in config with live apply and persisted setting
- cleaned up realm-specific protocol tags by using a single comms key: [WBC]
- temporary compatibility: still accepts incoming legacy tags [RET]/[DEVA] while emitting [WBC]
- deprecation notice: legacy [RET]/[DEVA] parser path is deprecated and scheduled for removal in a future release
- fixed tracker row text overflow by constraining name/timer layout and truncating long names inside box bounds
- row text size control now also scales career icons and keeps icon/name spacing aligned
- adjusted background opacity clamp to full 0%-100% range
- simplified tracker headers for readability (plain titles, cleaner spacing, improved contrast)
- added header emphasis presets in config with live-applied tone and style options for tracker titles
- refined header emphasis: titles are now left-aligned for steadier strong styling, soft tone removed, and red/green/blue tones added
- simplified header styles to Clean/Caps (legacy Strong now maps to Caps) and added default title padding/margins
- increased top header spacing inside tracker boxes and updated LTC title text to "Leading the Charge"
- added release checklist in RELEASING.md
- fixed row name vertical overlap by making row height scale-aware with centered row icons
- fixed local self-cast updates: outgoing tracked casts now mirror into local tracker rows even when own /wb chat does not echo back
- planned 4.0.0: remove legacy [RET]/[DEVA] protocol compatibility so the addon accepts and emits [WBC] only
- cleaned up config settings grouping: tracker appearance controls are now clearly separated from notification toggles
- improved config control ergonomics: value fields are now clickable reset controls (header/row text, width/height, background opacity)
- refactored config layout logic with shared constants, consistent dynamic row spacing, and max-column window height sizing
- moved master tracker checkbox to the tracker list area as "Toggle All" and reduced individual tracker toggle size for clearer visual hierarchy
- polished config visual hierarchy: centered Tracker Appearance heading, softened setting labels, gold value text, and clearer +/- button presentation
- adjusted config layout spacing/alignment based on in-client review: improved label-to-value spacing, aligned tracker/notification section headers, and restored equal checkbox size for Toggle All and all sub-toggles
- fixed config regressions: Toggle All now updates all tracker checkbox states, checkbox boxes render again, notification rows sit closer to headers (including LTC), and +/- brackets no longer clip
- fixed tracker list click layering: tracker rows now start below Toggle All so the master toggle remains fully clickable
- enabled forward UI control compatibility: switched XML schema references to EASystem.xsd and added reusable config.lua helpers for checkbox, editbox, and combobox behavior
- added `ui-controls-reference.xml` as a non-loaded copy/paste template pack for future controls
- removed deprecated/legacy slash aliases and kept canonical slash commands only (/warbandcomms, /wb-comms, /wbc)
- fully wired reference UI handlers in config.lua for copied controls from `ui-controls-reference.xml`
- fixed tracker toggling flow: enabling an individual tracker now re-syncs master toggle state
- refined Toggle All semantics: set-all action; master checkbox reflects "all trackers enabled"
- added cross-platform packaging workflow via `scripts/package_release.py` with separate `test` and `release` build modes
- transition compatibility: restored inbound parsing for [RET]/[DEVA] while retaining [WBC]; outbound uses single legacy realm key ([RET] Order / [DEVA] Destro)
- added `/wbc selfcheck` to print outbound key, accepted inbound keys, tracker enable state, and self-test status
- added `/wbc help` to print in-chat command help
- added tracked morale ability `Immaculate Defense` (ID `613`) with fixed-cooldown handling
- split `Immaculate Defense` into its own dedicated `ID` tracker box instead of sharing `LTC`
- fixed center-screen LTC-family notifications to resolve and display the specific ability name (for example, `Immaculate Defense`)
- refreshed in-client test harness: `/wbc testboxes` now fills all tracker boxes, uses generated names, and covers all 24 careers; added `/wbc testcenter` for LTC/ID alert previews
- updated packaging/docs so release and test zips include `README.md` by default and ship license files matching `LICENSE*`
- added +/- bidirectional controls for Resize Mode, Header Tone, and Header Style in config
- finalized repository licensing under MIT and added root LICENSE file/reference updates

3.5.3 (Historical Archive)

  1.0 LTC Window(Mainline)
  2.0 Challenge Window (Enlil)
  2.1 (Mainline) - fixed LTC active time from >170 to >110 - fixed Challenge active time from >20 to >23 - Add LTC summary window (intended for non tanks for quick status check) - Add config options for LTC summary, LTC Notifications, Challenge UI - Right aligned timer text in UI - Add function to map warband members to dictionary - Register for OnBattleGroupUpdated and trigger check that "List members" are in warband. - Removed Challenge notifications (to center screen) - add /slash command to clear all list - add /wbcomms as alias command to /rwc - made config menu moveable - made ui winows movable - moved config func to new file config.lua - moved util funcs to new file utils.lua
  2.2 (Mainline) - reworked UpdateUI() to loop over WarbandMap (members) to provide consistent ordering and remove ppl who left warband. - add tests.lua for updating UI. /script WarbandComms.StartTest() - removed LTC Summary Window (for now, maybe forever) - added versioning to Saved Setting - do not show on startup after first time
  2.2.1 (Mainline) - fixes chat message name type - aka sender. Chat not read correctly. Added test for reading from /chat.
  3.0.0 (Enlil) - fixed adding players to the list when using challenges and LTC while in wb - Add Channeling window for dps channeling abilities - Add cd tracker for Whirling Axe (white lion ability) only
  3.1.0 (Mainline) - update test to incorporate adding players fix from 3.0.0 - add test for Annihilate - add Whilring Axe, Retribution and Annihilate + Wrecking Ball as DPS Channels Tracker
  3.1.1 (Mainline) - moved ui functions to new file ui.lua - condition chat_key on player's realm (["RET"] or ["DEVA"]) - removed obsolete .Test() function
  3.2.3 (Mainline) - refactor: CreateUI(tracker) to loop over Trackers array - fixed CreateUI() always using ltc settings - removed rezzes - normalised commsKey (aka chat_key) (instead of healer_key and tank_key) - refactor OnUpdate(), OnCast() and TextArrived() to DRY functions based off super trackedAbilities list - prevented double chat messages on casting channels ("not averageLatency") - gets cooldown data from action bar for tracked/enabled abilities :star: - dynamically create UI windows from ui-template.xml - adds "Into The Fray" to LTC tracker (Tank/Onslaught)
  3.3.0 (Mainline) - added /ret to slash commands - ensure 8 names fit in windows (reduce row height, increase and hardode window height, smaller windows+++) - fixed test to work with change to ability:duration:cooldown format from per 3.2.3 - added more test abilities to ensure at least 8 names appear - added Destro Tank Challenges (Enlil) - added career Icons to UI
  3.3.1 (Mainline) - Fix if new cooldown has not triggered and logged cooldown is only 1.5-2s - Move solo WarbandMap to MapWarbandMembers() - add Sorc's channel Disastrous Cascade (needs testing) - add sort ordering warbandmap - use case it put Longest DPS channels top of list
  3.4.1 (Mainline) - try fix cooldowns put in chat with value of 0 or 2 - moved /slash stuff to new flie: slash.lua and added some test slash commands - only use /say if selfTest is true - some local table performance updates (use local tinsert, tsort) - some more perfomance optimisations (via ChatGPT) - refactored config window to create tracker settings dynamically - added global "enabled" settings - added Interrupts Tracker (SM, WL, Mara)
  3.5.3 (Mainline) - fixed Marauder Interrupt Mouth of Tzeentch ability id - refactored "Notifications" to be dynamical created (DRY), so extendable - debounce OnBattleGroupUpdated client hook (performance optimisation) - added code for fixedCooldowns (for abilities not on proper action bars, e.g. morale)
