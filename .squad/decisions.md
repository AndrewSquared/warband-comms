# Squad Decisions

## Active Decisions

### User directive: Multi-channel support reprioritization (2026-06-04)

- **By:** Andrew Karstaedt (via Copilot)
- **What:** Reprioritize planned work away from adding more configuration and toward a feature that lets the addon communicate in warbands, groups, and scenarios.
- **Why:** User request — captured for team memory

### Battle-group channel expansion scope review (2026-06-04)

- **Scope Level:** Medium — requires clear precedence rules and multi-file coordination
- **Requirement:** Current: addon sends messages to warband via `/wb <message>`. Proposed: also support groups `/g <message>` and scenarios `/sc <message>`.
- **Implementability:** ✅ Yes. Game client provides chat channels, `SendChatText()` API already in place, protocol is channel-agnostic.
- **Critical ambiguities resolved:**
  1. **Channel precedence:** Exclusive (single source per cast) with priority `warband → scenario → group → solo`.
  2. **Inbound acceptance:** Accept from all three channels (maximize compatibility).
  3. **Scenario vs. group:** Scenarios are public instanced group PvP; groups are smaller raid groups. Precedence reflects warband RvR hierarchy.
  4. **Config:** No new config UI needed for simple exclusive fallback.
- **File surface:** Changes in `WarbandComms.lua` (channel selection in `OnCast()` and `TextArrived()`), no protocol version bump needed.

### Battle-group channel routing decision (2026-06-04)

- **By:** Livingston
- **Decision:** Derive outbound chat transport from live grouping state with explicit precedence `warband → scenario → group → self-test`, while continuing to parse the existing protocol keys on inbound messages.
- **Why:** Keeps scenario and party support explicit without regressing established warband behavior, and diagnostics report the same route that the sender will actually use.

### Battle-group roster normalization decision (2026-06-04)

- **By:** Rusty (revision following Basher's review rejection)
- **Decision:** Treat chat transport expansion as a roster-surface change: outbound routing, inbound parsing, `WarbandComms.WarbandMap` derivation, and in-client verification must all move together, with roster precedence `warband → scenario → group → solo`.
- **Why:** Tracker rows and header counts render from `WarbandComms.WarbandMap`, so scenario/group support is incomplete unless membership mapping and update triggers follow the same live context as the chat lane. Shared roster normalization plus explicit party/scenario harness paths keeps the change small but end-to-end usable.
- **What was rejected:** Initial pass had roster/UI/test paths still warband-only; scenario/group chat messages arrived but didn't render.
- **What was added:** Roster normalization into `WarbandComms.WarbandMap`, roster update triggers for group/scenario state changes, `/wbc testgroup` and `/wbc testscenario` in-client harness commands, expanded `selfcheck` output and documentation, and revalidated packaging.

### Release help surface fix (2026-06-04)

- **By:** Yen (Release/Tooling specialist)
- **Issue:** Release builds advertised test-only commands in help text after handlers were stripped.
- **Solution:** Modified `build_release_slash()` in `scripts/package_release.py` to strip help text lines containing `(test builds)` during release packaging.
- **Result:** Release builds show only production commands; test builds show full list with test commands marked.

### Outbound comms key source of truth (2026-06-03)

- **Decision:** Use `WarbandComms.GetOutboundCommsKey()` directly at outbound and self-check read sites instead of relying on cached `WarbandComms.commsKey` state from initialization.
- **Why:** Outbound protocol selection depends on realm state, and initialization-time caching can hold a fallback value before realm data is ready.
- **Scope:** `WarbandComms.lua` protocol send and self-check paths.

### Livingston Decision — WBC-only protocol cutover (2026-07-08)

- **By:** Livingston
- **Decision:** Remove legacy realm-key compatibility and keep addon comms WBC-only for both outbound sends and inbound parsing.
- **Why:** The runtime and self-check output are simpler and less ambiguous when `GetOutboundCommsKey()`, `GetAcceptedCommsKeys()`, and `IsAcceptedCommsKey()` all agree on a single live key. This also aligns product and maintainer docs with the actual shipped behavior.
- **Scope:** `WarbandComms.lua`, packaged addon mirror under `WarbandComms/`, README/release docs, and maintainer prompt documentation.

### Basher Decision — doc-surface legacy reference threshold (2026-07-08)

- **By:** Basher
- **Decision:** Treat legacy protocol or slash-command references in listed repo docs such as `changelog.md` as review blockers for protocol-cleanup approval, even when the reference is historical.
- **Why:** Runtime WBC-only proof is not enough if maintainers or players can still encounter retired identifiers in current documentation surfaces. Internal `.squad/` notes and generic template noise can be ignored, but a shipped or explicitly-reviewed doc artifact is still product-facing enough to count as a miss.
- **Scope:** Protocol cleanup reviews covering `README.md`, packaged README copies, changelog/release docs, and other explicitly requested documentation artifacts.

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
