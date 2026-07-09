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
- Protocol cleanup reviews must sweep both `README.md` and the packaged-copy surface `WarbandComms/README.md`, then spot-check built zips, because release packaging ships README content unchanged even when runtime protocol code is already clean.
- 2026-07-08T21:46:59.901-04:00: WBC-only runtime is provable from `DEFAULT_COMMS_KEY`, `GetOutboundCommsKey()`, `GetAcceptedCommsKeys()`, `OnCast()`, and `TextArrived()` in both root and packaged `WarbandComms.lua`, but repo approval still fails if a listed artifact like `changelog.md` carries legacy slash/protocol references because that is documentation surface, not internal-only noise.
- 2026-07-08T21:46:59.901-04:00: Final protocol-cleanup approval needs three layers of proof together: source runtime (`WarbandComms.lua`), packaged-copy runtime/docs (`WarbandComms/WarbandComms.lua`, `WarbandComms/README.md`), and built `dist` zips searched for `RET`, `DEVA`, and `RetWBComms`; remaining hits are acceptable only under internal `.squad/` history/skill/template files.

### 2026-06-04T23:32:48Z: Decision Inbox Merged

Team decisions consolidated:
- Basher's initial review rejection: roster/UI/test gaps flagged
- Basher's rereview approval: Rusty's revision added roster normalization, update triggers, `/wbc testgroup` and `/wbc testscenario` test harness, packaging revalidation
- Feature now approved as complete enough for stated requirement
- End-to-end verification path established: non-warband roster rendering testable via in-client commands

### Review cycle resolution complete

### 2026-07-09T01:46:59Z: Protocol Cleanup Final Approval

Completed review cycle for WBC-only protocol cutover:
- **Pass 1 rejection:** Livingston's initial pass had lingering README/changelog legacy references
- **Pass 2 rejection:** Yen's cleanup removed most refs but one `/ret` mention remained in changelog 3.3.0 entry
- **Final approval:** Rusty removed the final changelog line. Runtime, packaged surfaces, and docs all aligned. Full WBC-only cutover approved.
- **Decision recorded:** Doc-surface legacy references are review gates. Shipped/explicitly-reviewed artifacts must be clean.
- Team orchestration logged. Status: **Approved and merged**.
