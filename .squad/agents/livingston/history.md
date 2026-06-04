# Project Context

- **Owner:** Andrew Karstaedt
- **Project:** warband-comms
- **Description:** Addon for an older MMO private server that centralizes group data and timing information for 24-player coordination.
- **Stack:** Lua, XML, Return of Reckoning / WAR addon APIs, Python release packaging script
- **Created:** 2026-06-03T23:00:49.204-04:00

## Learnings

- Livingston owns runtime Lua logic, settings flow, and addon comms behavior.
- This project depends on stable timing and data-sharing behavior inside the WAR client.

### 2026-06-03T23:29:11.914-04:00: Outbound Key Derived-State Fix

- Updated `WarbandComms.lua` so outbound protocol reads call `WarbandComms.GetOutboundCommsKey()` directly in both `PrintSelfCheck()` and `OnCast()`.
- Removed the `WarbandComms.commsKey` initialization from `OnInitialize()` because cached key state can drift from realm-ready state while derived reads stay correct.
- Reusable pattern: for realm-dependent protocol values in this addon, prefer computing from helper functions at use sites over caching long-lived fields during initialization.
- Key file paths: `WarbandComms.lua`, `.squad/agents/livingston/history.md`, `.squad/decisions/inbox/livingston-outbound-key-source-of-truth.md`, `.squad/skills/derived-protocol-state/SKILL.md`.

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

### 2026-06-03T23:29:11.914-04:00: Outbound Key Implementation Spawn

- Scribe merged decision inbox entry into `.squad/decisions.md`.
- Scribe recorded orchestration log and session log for Livingston outbound key task.
- Implementation task: use `GetOutboundCommsKey()` at all send/selfcheck sites, remove initialization caching.

### 2026-06-03T23:26:54.285-04:00: Outbound Comms Key Strategy Review

- Inspected `WarbandComms.lua` around `GetOutboundCommsKey()`, `GetLegacyRealmCommsKey()`, `OnInitialize()`, `PrintSelfCheck()`, and `OnCast()`.
- Current wiring initializes `WarbandComms.commsKey` in `OnInitialize()` (line 329) and reads it in `OnCast()` (line 616), while `PrintSelfCheck()` still carries a fallback to `GetOutboundCommsKey()`.
- Key runtime tradeoff: cached `commsKey` is simple at send time, but it can drift if initialization happens before `GameData.Player.realm` is ready because the fallback path returns `[WBC]` and the cached field is not recomputed later.
- Addon-specific best-practice recommendation: prefer calling `GetOutboundCommsKey()` at outbound construction/use sites for protocol correctness, clearer derived-state handling, and lower maintenance risk during the current mixed-key compatibility phase.
- Relevant file path: `WarbandComms.lua`.
