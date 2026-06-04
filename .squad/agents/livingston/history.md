# Project Context

- **Owner:** Andrew Karstaedt
- **Project:** warband-comms
- **Description:** Addon for an older MMO private server that centralizes group data and timing information for 24-player coordination.
- **Stack:** Lua, XML, Return of Reckoning / WAR addon APIs, Python release packaging script
- **Created:** 2026-06-03T23:00:49.204-04:00

## Learnings

- Livingston owns runtime Lua logic, settings flow, and addon comms behavior.
- This project depends on stable timing and data-sharing behavior inside the WAR client.

### 2026-06-03: Comms Flow Audit — Uninitialized Outbound Key

**Issue:** `WarbandComms.commsKey` is used in `OnCast()` line 616 but never initialized.
- Line 616: `local message = chatChannel .. WarbandComms.commsKey .. ":" .. tracker ..`
- This breaks outbound protocol messages (nil key sent to warband)
- `GetOutboundCommsKey()` exists and works correctly, but `OnCast` doesn't call it
- `PrintSelfCheck()` correctly reads outbound via `GetOutboundCommsKey()` (line 153)

**Pattern observed:** Read-only paths (`PrintSelfCheck`) use `GetOutboundCommsKey()`, but write paths (`OnCast`) try to use uninitialized `commsKey`.

**Recommendation:** Fix `OnCast()` to call `GetOutboundCommsKey()` when building outbound message, or initialize `WarbandComms.commsKey` during addon init.

### 2026-06-04T03:09:18Z: Scribe Session — Memory Sync

Scribe recorded Livingston's audit findings in team orchestration log and session log.

**Action items extracted for team decision:**
1. Apply fix to `OnCast()` line 616 to use `GetOutboundCommsKey()`
2. OR initialize `WarbandComms.commsKey` during addon initialization
3. Add regression test to verify outbound key is always defined

**Impact:** Critical — affects all outbound warband chat protocol messages.
