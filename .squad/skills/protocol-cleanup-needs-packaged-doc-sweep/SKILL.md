---
name: "protocol-cleanup-needs-packaged-doc-sweep"
description: "How to verify protocol string removals across runtime, docs, and packaged addon outputs"
domain: "testing"
confidence: "high"
source: "observed"
---

## Context
Use this when WarbandComms removes or renames protocol tags, slash aliases, or other player-visible comms strings. Runtime Lua can be correct while README/changelog text or packaged addon copies still leak the old identifiers.

## Patterns
- Verify runtime behavior first at the source helpers: outbound key helper, accepted inbound key helper, send path, and inbound parser.
- Sweep repository docs for the retired strings, but separate true app/doc hits from internal-only leftovers under `.squad/` and generic words like `SECRET` or `RETRO`.
- Check both `README.md` and `WarbandComms/README.md`; the latter can carry the same stale text into packaged-addon surfaces.
- Build release/test zips and inspect packaged `WarbandComms.lua`, `slash.lua`, and `README.md` so release artifacts are validated, not just source files.

## Examples
- `WarbandComms.lua`: `DEFAULT_COMMS_KEY`, `IsAcceptedCommsKey()`, `GetAcceptedCommsKeys()`, `OnCast()`, and `TextArrived()` are the core runtime proof points for protocol cleanup.
- `python3 scripts/package_release.py --build release --clean` and `python3 scripts/package_release.py --build test` provide a repeatable artifact check.
- A source tree can be WBC-only in `WarbandComms.lua` while `README.md` still says "rename from RetWBComms," which then ships unchanged inside both zips.

## Anti-Patterns
- Declaring protocol cleanup complete after checking only `WarbandComms.lua`.
- Treating generated/package-facing docs as irrelevant when the packager includes them verbatim.
- Reporting `.squad/` history/template references as app misses without separating them from player/runtime surfaces.
