# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Scope, architecture, and review | Rusty | Break work down, resolve trade-offs, review changes, route multi-agent work |
| UI layout and config UX | Linus | XML windows, config controls, tracker presentation, spacing and interaction fixes |
| Addon runtime and comms logic | Livingston | Lua event handling, tracker state, settings, chat protocol, game integration |
| Testing and instrumentation | Basher | In-client test harness, edge-case checks, regression coverage, verification strategy |
| Release and packaging | Yen | `.mod` shipping surface, release prep, packaging script, metadata and distribution |
| Code review | Rusty | Review PRs, check quality, suggest improvements |
| Testing | Basher | Write tests, find edge cases, verify fixes |
| Scope & priorities | Rusty | What to build next, trade-offs, decisions |
| Session logging | Scribe | Automatic — never needs routing |
| Backlog monitoring | Ralph | Watch assigned work, backlog status, issue and PR follow-through |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, assign `squad:{member}` label | Lead |
| `squad:rusty` | Pick up issue and complete the work | Rusty |
| `squad:linus` | Pick up issue and complete the work | Linus |
| `squad:livingston` | Pick up issue and complete the work | Livingston |
| `squad:basher` | Pick up issue and complete the work | Basher |
| `squad:yen` | Pick up issue and complete the work | Yen |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, the **Lead** triages it — analyzing content, assigning the right `squad:{member}` label, and commenting with triage notes.
2. When a `squad:{member}` label is applied, that member picks up the issue in their next session.
3. Members can reassign by removing their label and adding another member's label.
4. The `squad` label is the "inbox" — untriaged issues waiting for Lead review.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for "what port does the server run on?"
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a feature is being built, spawn the tester to write test cases from requirements simultaneously.
7. **Issue-labeled work** — when a `squad:{member}` label is applied to an issue, route to that member. The Lead handles all `squad` (base label) triage.
