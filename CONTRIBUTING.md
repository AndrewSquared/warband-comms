# Contributing to Warband Comms

Thanks for contributing.

## Workflow

1. Open an issue describing the bug or feature.
2. Keep pull requests focused and small.
3. Include reproduction steps for bug fixes.
4. Update `changelog.md` for user-visible changes.

## Coding Guidelines

- Keep naming consistent with `WarbandComms`.
- Prefer small, explicit helper functions for UI state logic.
- Avoid introducing hardcoded window name prefixes when `WarbandComms.AddonName` can be used.

## Testing

Manual in-client testing is currently required.

Recommended checks:

1. Addon loads without XML/Lua errors.
2. Slash commands open the config window.
3. Tracker visibility matches checkbox state and global enable state.
4. Timers update correctly in warband and test mode.
