# Project Context

- **Owner:** Andrew Karstaedt
- **Project:** warband-comms
- **Description:** Addon for an older MMO private server that centralizes group data and timing information for 24-player coordination.
- **Stack:** Lua, XML, Return of Reckoning / WAR addon APIs, Python release packaging script
- **Created:** 2026-06-03T23:00:49.204-04:00

## Learnings

- Yen owns release packaging, metadata, and supporting script work for the addon.
- The project ships through an explicit release packaging flow rather than a generic app build pipeline.

### 2026-06-04T23:32:48Z: Decision Inbox Merged

Team decisions consolidated:
- Yen's release help surface fix: `build_release_slash()` in `scripts/package_release.py` now strips help text lines containing `(test builds)` during release packaging
- Release builds advertise only production commands; test builds show full list with test commands marked
- No regression: test handlers still work in test builds, release builds remain clean

Next team phase approved for implementation.
