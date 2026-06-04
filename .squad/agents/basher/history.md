# Project Context

- **Owner:** Andrew Karstaedt
- **Project:** warband-comms
- **Description:** Addon for an older MMO private server that centralizes group data and timing information for 24-player coordination.
- **Stack:** Lua, XML, Return of Reckoning / WAR addon APIs, Python release packaging script
- **Created:** 2026-06-03T23:00:49.204-04:00

## Learnings

- Basher owns testing, instrumentation, and regression coverage for the squad.
- WarbandComms changes need validation against real coordination scenarios, not just static UI checks.
- Scenario/group transport work is incomplete unless `WarbandComms.WarbandMap` is expanded beyond warband-driven membership, because tracker rows and header counts render from that roster.
- The current in-client harness in `tests.lua` only synthesizes warband rosters, so channel/roster changes need fresh coverage for party and scenario contexts.
- The revised scenario/group transport implementation is reviewable through `WarbandComms.GetOutboundChatRoute()`, `GetActiveRosterRoute()`, `MapCurrentRosterMembers()`, and the non-warband harness entries in `tests.lua` and `slash.lua`.
- Release verification for this addon is repeatable with `python3 scripts/package_release.py --build test`, `python3 scripts/package_release.py --build release --clean`, and `python3 scripts/validate_release_state.py`.

### 2026-06-04T23:32:48Z: Decision Inbox Merged

Team decisions consolidated:
- Basher's initial review rejection: roster/UI/test gaps flagged
- Basher's rereview approval: Rusty's revision added roster normalization, update triggers, `/wbc testgroup` and `/wbc testscenario` test harness, packaging revalidation
- Feature now approved as complete enough for stated requirement
- End-to-end verification path established: non-warband roster rendering testable via in-client commands

### Review cycle resolution complete
