# Project Context

- **Owner:** Andrew Karstaedt
- **Project:** warband-comms
- **Description:** Addon for an older MMO private server that centralizes group data and timing information for 24-player coordination.
- **Stack:** Lua, XML, Return of Reckoning / WAR addon APIs, Python release packaging script
- **Created:** 2026-06-03T23:00:49.204-04:00

## Learnings

- Yen owns release packaging, metadata, and supporting script work for the addon.
- The project ships through an explicit release packaging flow rather than a generic app build pipeline.

### 2026-07-08T21:51:36Z: Documentation cleanup pass

Removed all user/app-facing RET and DEVA references from packaged documentation:
- README.md: removed "full rename from RetWBComms" mention to avoid confusing players about legacy rebrand
- WarbandComms/README.md: same cleanup to keep shipped README clean
- changelog.md: removed full rebrand section mentioning deprecated /ret, /retwbcomms, /rwc commands (kept historical 2.x-3.4 references as version history)
- .github/prompts/plan-warbandComms.prompt.md: removed "from RetWBComms naming" phrase from Phase 2 description

Result: No active RET/DEVA references remain in shipped docs. All remaining mentions are in historical archive (version 2-3 notes) which document what past releases did.

### 2026-06-04T23:32:48Z: Decision Inbox Merged

Team decisions consolidated:
- Yen's release help surface fix: `build_release_slash()` in `scripts/package_release.py` now strips help text lines containing `(test builds)` during release packaging
- Release builds advertise only production commands; test builds show full list with test commands marked
- No regression: test handlers still work in test builds, release builds remain clean

Next team phase approved for implementation.

### 2026-07-09T01:46:59Z: Team Coordination — WBC-Only Cleanup Completion

Yen's doc-surface cleanup pass (2026-07-08T21:51:36Z) was part of multi-agent review cycle:
- Livingston: runtime cleanup
- Yen: app-facing docs
- Rusty: final changelog reference removal
- Basher: review gate enforcement
Result: Full WBC-only cutover approved. Team decisions merged to `.squad/decisions.md`.
