---
name: "derived-protocol-state"
description: "Prefer helper-derived protocol values at use sites when game state may not be ready during addon initialization"
domain: "runtime-logic"
confidence: "high"
source: "observed"
---

## Context
This applies when addon protocol behavior depends on mutable client state such as realm detection, party membership, or scenario presence. Initialization can happen before every runtime input is trustworthy, so cached fields may become stale or misleading.

## Patterns
- Use a focused helper like `GetOutboundCommsKey()` as the single source of truth.
- Use a focused helper like `GetOutboundChatRoute()` when transport depends on live grouping state.
- Read realm-dependent protocol values at outbound send sites and diagnostic paths instead of caching them during initialization.
- Keep route precedence explicit when multiple grouping states can be true; in this addon the safe order is warband, then scenario, then group, then self-test fallback.
- Remove cached state once all consumers use the helper directly.

## Examples
- `WarbandComms.lua`: `OnCast()` and `PrintSelfCheck()` both call `WarbandComms.GetOutboundCommsKey()` directly.
- `WarbandComms.lua`: `OnCast()` and `PrintSelfCheck()` both call `WarbandComms.GetOutboundChatRoute()` so runtime sends and self-check output stay aligned.

## Anti-Patterns
- Caching protocol keys during initialization when they depend on later-ready game state.
- Hardcoding `/wb` in outbound logic when scenario/group state can be the active transport.
- Letting diagnostics use a different source of truth than the actual outbound send path.
