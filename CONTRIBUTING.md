# Contributing to Warband Comms

Thanks for contributing.

## Workflow

1. Open an issue describing the bug or feature.
2. Keep pull requests focused and small.
3. Include reproduction steps for bug fixes.
4. Update `changelog.md` for user-visible changes.
5. If a change affects shipped files or release flow, update the packaging notes in `README.md` and this document.

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

## Release Packaging

Use the manifest-driven packaging script from the repo root.

Release build:

```bash
python scripts/package_release.py --build release --clean
```

Test build:

```bash
python scripts/package_release.py --build test --clean
```

Notes:

- The package contents start from `WarbandComms.mod`, not from a hand-maintained file list.
- The `test` build keeps `tests.lua` and the `/wbc test` and `/wbc selftest` paths for in-client validation.
- The `release` build removes `tests.lua` from the packaged manifest and strips the test-only command paths from the packaged `slash.lua`.
- Repo maintenance files and development-only reference files are intentionally excluded from the generated zip.
- Use `--include-readme` if the target distribution channel expects a readme inside the addon folder.
