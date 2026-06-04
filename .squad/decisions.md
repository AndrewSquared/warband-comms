# Squad Decisions

## Active Decisions

### Outbound comms key source of truth (2026-06-03)

- **Decision:** Use `WarbandComms.GetOutboundCommsKey()` directly at outbound and self-check read sites instead of relying on cached `WarbandComms.commsKey` state from initialization.
- **Why:** Outbound protocol selection depends on realm state, and initialization-time caching can hold a fallback value before realm data is ready.
- **Scope:** `WarbandComms.lua` protocol send and self-check paths.

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
