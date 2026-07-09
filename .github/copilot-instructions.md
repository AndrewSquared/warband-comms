# Copilot Instructions — WarbandComms

## Project Overview

WarbandComms is a **Return of Reckoning** (Warhammer Online MMO) addon. It tracks warband ability cooldowns and displays compact on-screen timers per player. The addon is written in **Lua + XML** using the game's EASystem UI framework.

This is a game addon — there is no Node.js, no browser, no Python runtime target. Do not suggest standard software engineering tooling (npm, pytest, etc.) for the addon code itself. Python is only used for the release packaging script in `scripts/`.

---

## Repository Layout

| File/Folder | Purpose |
|---|---|
| `WarbandComms.lua` | Main namespace, init, `trackedAbilities` table, chat protocol handling, saved settings root |
| `WarbandComms.mod` | Addon metadata and runtime module manifest — source of truth for what files ship |
| `WarbandComms.xml` | Top-level XML includes and UI asset wiring |
| `config.lua` | Config window logic: all control handlers, Decrease/Increase/Reset/Toggle functions, layout helpers |
| `config.xml` | Config window static UI definitions and event handler bindings |
| `config-template.xml` | Template for dynamically created config rows (trackers + notifications) |
| `ui.lua` | Tracker window creation, layout, row rendering, state colors |
| `ui-template.xml` | Row and header layout, fonts, dimensions |
| `slash.lua` | Slash command registration (`/wbc`, `/wb-comms`, `/warbandcomms`) and subcommand dispatch |
| `ability_cooldowns.lua` | Ability cooldown data (supplemental to `trackedAbilities`) |
| `utils.lua` | Shared utility functions |
| `tests.lua` | In-client test harness — **test builds only**, stripped from release packages |
| `ui-controls-reference.xml` | Copy-paste XML snippets for future controls — **not loaded by `.mod`** |
| `scripts/package_release.py` | Cross-platform release packager |
| `RELEASING.md` | Pre-release checklist and tagging steps |

---

## Language and Framework Conventions

- **Lua**: addon Lua runs inside the WAR client. No standard library beyond game-provided APIs and EASystem functions. No `require`, no file I/O outside saved variables.
- **XML**: uses `EASystem.xsd` schema. Control templates like `EA_Button_Default`, `EA_Button_DefaultResizeable`, `EA_Button_DefaultCheckBox`, `EA_Button_DefaultMinus`, `EA_EditBox_DefaultFrame`, and combo/scroll variants are available. See `.github/prompts/ui-controls.prompt.md` for full reference.
- **Event handlers**: XML buttons bind to Lua via `EventHandler name="WarbandComms.FunctionName" event="OnLButtonUp"`.
- **Saved settings**: loaded from and written to `WarbandComms.Settings` (the saved variables root).
- **Comms protocol**: chat messages use format `[KEY]:tracker:duration:cooldown[:careerIcon]`.

---

## Protocol — Current State

- **Outbound**: always uses `[WBC]`.
- **Inbound**: accepts `[WBC]` only.
- **Do not dual-send.** One message per cast.

---

## Trackers

Five active trackers, each with a key in `WarbandComms.trackedAbilities`:

| Tracker key | Display name | Notes |
|---|---|---|
| `LTC` | Leading the Charge | Tank mobility/morale support abilities such as LTC and Into the Fray |
| `ID` | Immaculate Defense | Dedicated M4 morale box, `fixedCooldown=true`, cd=180, duration=10 |
| `challenge` | Challenge | Tank challenge abilities |
| `channels` | Channels | DPS channel abilities |
| `interrupt` | Interrupts | SM, WL, Mara |

`fixedCooldown=true` means the addon does not read the action bar for this ability — it uses the hardcoded `cooldown` value when the chat message arrives.

---

## UI State Colors (in `ui.lua` `UpdateUI`)

| State | Color | RGB |
|---|---|---|
| Ready (timer ≤ 0) | Green | `92, 195, 0` |
| Active (timer ≥ cooldown − duration) | White | `255, 255, 255` |
| On cooldown | Red | `230, 90, 90` |

---

## Config Layout Constants (in `config.lua`)

- Left column x: `20`
- Right column x: `350`
- Row spacing is dynamic, computed from a base y offset and row index.
- The config window height is set to whichever is taller: tracker rows or notification rows.

---

## Slash Commands

Canonical commands: `/warbandcomms`, `/wb-comms`, `/wbc`

| Subcommand | Behavior |
|---|---|
| _(none)_ | Open/toggle config |
| `clear` | Clear all tracker UI data |
| `help` | Print command list in chat |
| `selfcheck` | Print outbound key, inbound keys, tracker states, self-test flag |
| `testboxes` | Populate all tracker boxes with generated sample warband data — test builds only |
| `testcenter` | Show LTC/ID center-screen notification samples — test builds only |
| `test` | Compatibility alias for `testboxes` — test builds only |
| `selftest` | Toggle `/say` echo mode — test builds only |

---

## Config Controls Pattern

Numeric controls (text scale, width, height, opacity) all follow the `[-]` / value label / `[+]` pattern:
- `Decrease*` handler calls `GetPreviousPresetValue()` or clamps a numeric value down
- `Increase*` handler calls `GetNextPresetValue()` or clamps a numeric value up
- Value label is a clickable reset control

Toggle-style controls (Resize Mode, Header Tone, Header Style) also have `[-]` / `[+]` buttons using `GetPreviousPresetValue` / `GetNextPresetValue` with a defined order table.

Styling: all `[-]` and `[+]` labels are colored gold via `ApplyControlLabelStyling()` in `InitConfig`.

---

## Build and Release

- **Test build**: retains `tests.lua`, `/wbc testboxes`, `/wbc testcenter`, `/wbc selftest`, and `/wbc test` compatibility alias
- **Release build**: strips `tests.lua` from `.mod` and removes test-only slash paths from `slash.lua`
- Run `python scripts/package_release.py --build release --clean` to produce `dist/WarbandComms-v<version>.zip`
- Packaged zips include `README.md` by default and ship license files matching `LICENSE*`
- Before tagging, complete [RELEASING.md](../RELEASING.md)

---

## Key Prompt Files

These files in `.github/prompts/` provide deeper reference context — read them at the start of relevant sessions:

- [`ui-controls.prompt.md`](prompts/ui-controls.prompt.md) — XML control templates, Lua UI helpers, copy-ready reference patterns
- [`plan-warbandComms.prompt.md`](prompts/plan-warbandComms.prompt.md) — Full phase roadmap, architecture decisions, verification steps
