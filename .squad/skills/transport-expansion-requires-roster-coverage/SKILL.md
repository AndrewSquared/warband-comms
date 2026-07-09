---
name: "transport-expansion-requires-roster-coverage"
description: "When comms transport expands beyond warband, update roster derivation and verification with it"
domain: "testing"
confidence: "high"
source: "observed"
---

## Context
This applies when WarbandComms broadens who can send protocol messages, such as adding scenario or group chat routes. The addon UI does not render from raw tracker tables alone; it renders through the current roster map.

## Patterns
- Treat outbound chat routing, inbound parsing, roster derivation, and test coverage as one change surface.
- Verify which collection drives header counts and visible rows before declaring a new communication context supported.
- Keep roster precedence aligned with transport precedence so the UI reflects the same teammate scope as outbound chat.
- Normalize party and scenario roster payloads through one shared mapper before `ui.lua` reads `WarbandComms.WarbandMap`.
- Add repeatable coverage for the new context instead of relying on the existing warband-only harness.

## Examples
- `WarbandComms.lua`: `GetOutboundChatRoute()` and `GetActiveRosterRoute()` both follow `warband -> scenario -> group` precedence.
- `WarbandComms.lua`: `MapRosterMembers()` normalizes warband, party, and `GameData.GetScenarioPlayerGroups()` data into `WarbandComms.WarbandMap`.
- `ui.lua`: `GetTrackerStateCounts()` and `UpdateUI()` iterate `WarbandComms.WarbandMap`, so missing roster updates hide otherwise parsed tracker entries.
- `tests.lua` + `slash.lua`: `/wbc testgroup` and `/wbc testscenario` provide repeatable non-warband UI verification paths.

## Anti-Patterns
- Shipping a transport expansion after only changing `OnCast()` and `TextArrived()`.
- Assuming accepted inbound messages automatically appear in the tracker UI.
- Leaving party/scenario membership updates on warband-only events.
- Reusing a warband-only test harness as proof that scenario/group support works.
