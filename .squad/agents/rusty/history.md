# Project Context

- **Owner:** Andrew Karstaedt
- **Project:** warband-comms
- **Description:** Addon for an older MMO private server that centralizes group data and timing information for 24-player coordination.
- **Stack:** Lua, XML, Return of Reckoning / WAR addon APIs, Python release packaging script
- **Created:** 2026-06-03T23:00:49.204-04:00

## Learnings

- Rusty owns scope, decisions, and review for the WarbandComms squad.
- The project centers on coordinating 24-player group communication and timers inside the game client.

### 2026-06-04T23:32:48Z: Decision Inbox Merged

Team decisions recorded and consolidated:
- User directive to prioritize multi-channel support (reprioritization from config focus)
- Scope assessment complete: warband/group/scenario transport is implementable as single-channel exclusive send with priority fallback
- Routing decision: derive outbound from live grouping state with explicit precedence
- Roster decision: treat transport expansion as roster-surface change, normalize `WarbandComms.WarbandMap` derivation
- Review cycle complete: initial rejection (roster/UI gaps) → revision approval (roster normalization + test coverage added)
- Tooling fix: release help surface consistency resolved

Team ready to move into next phase.

### Battle-Group Channel Expansion Scope Review (2026-06-04)

- **Core requirement:** Support scenarios (`/sc`) and groups (`/g`) in addition to warband (`/wb`).
- **Protocol is channel-agnostic:** Message format stays identical; only the channel prefix changes.
- **Implementability:** Yes — limited to `OnCast()` and `TextArrived()` logic in `WarbandComms.lua`.
- **Critical ambiguity resolved:** Channel exclusivity (send to one active channel per cast using priority fallback: warband > scenario > group) is the safest default. Inbound accepts all three channels for robustness.
- **File impact:** `WarbandComms.lua` (primary), `slash.lua` (minimal), config UI (only if per-channel toggle added).
- **No protocol version bump required** — existing comms keys (`[WBC]`, `[RET]`, `[DEVA]`) remain valid.
- **Game API prerequisites:** Must verify `IsScenarioActive()` and `IsGroupActive()` exist in WAR client; confirm `SystemData.ChatLogFilters` has GROUP and SCENARIO constants.
- **Key insight:** Addon already uses `GROUP_LEAVE` event (line 327), suggesting game API awareness of group context. Group/scenario feature is a natural extension of existing warband-only send logic.

### Battle-Group Roster Revision (2026-06-04T19:11:35.238-04:00)

- End-to-end transport expansion in this addon must update `WarbandComms.WarbandMap`, not just chat send/parse paths; `ui.lua` still renders rows and header counts from that roster map.
- `WarbandComms.lua` now needs a live roster helper that follows the same precedence as outbound routing (`warband -> scenario -> group -> solo`) so tracker visibility matches the channel teammates can actually use.
- Scenario roster data comes from `GameData.GetScenarioPlayerGroups()` flat records (`sgroupindex`/`sgroupslotnum`), while party roster data comes from `PartyUtils.GetPartyData()`; both should flow through shared roster normalization before UI update.
- Repeatable non-warband verification belongs in `tests.lua` and `slash.lua`; `/wbc testgroup` and `/wbc testscenario` are the useful in-client paths for validating party/scenario roster rendering.
