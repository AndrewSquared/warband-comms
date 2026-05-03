# Warband Comms

Warband Comms is a Return of Reckoning addon that tracks key warband ability cooldowns and shows a compact on-screen view for quick decision making.

> Reader note: this README is organized with player/user setup first. Maintainer and developer/release details are in **Developer & Release Notes** further below.

## Features

- Tracks selected warband abilities across five compact boxes that can each be turned on or off: `LTC`, `Immaculate Defense`, `Challenge`, `Channels`, and `Interrupt`
- Displays active timers by warband member
- Optional center-screen notification support per tracker
- Improved compact-mode legibility by enforcing a safer minimum tracker width
- Cleaner tracker header summaries with slash separators removed
- Config setting labels now support tooltip placeholders for inline guidance
- Slash-command driven config access, with optional in-client test helpers for development builds

## Installation (Return of Reckoning)

1. Copy this addon folder into your game path:
   - `Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms`
2. Make sure `WarbandComms.mod` is present in that folder.
3. Start the game and enable the addon in the addon list.

## Commands

- `/wbc`
- `/wb-comms`
- `/warbandcomms`

Subcommands:

- `clear` - clears current tracker UI data
- `help` - prints command help in chat
- `selfcheck` - prints protocol/runtime diagnostics in chat
- `testboxes` - runs local tracker-box test data flow in test builds (`test` also works as a compatibility alias)
- `testcenter` - triggers LTC/Immaculate Defense center-screen sample notifications in test builds
- `selftest` - toggles `/say` self-test mode in test builds

Examples:

- `/wbc`
- `/wbc help`
- `/wbc selfcheck`
- `/wbc clear`
- `/wbc testboxes` in a test build
- `/wbc testcenter` in a test build

Test build notes:

- `testboxes` populates all five tracker boxes, including a dedicated Immaculate Defense box.
- Test harness warband names are generated per run so rows look more like live data while still covering all 24 careers.

## Current Release

- Addon version: `3.6.0`
- This release includes a full rename from RetWBComms to WarbandComms while keeping transition-mode protocol compatibility.
- Legacy inbound compatibility remains enabled for `[WBC]`, `[RET]`, and `[DEVA]`; outbound still uses the single realm-specific legacy key during transition.
- Immaculate Defense now has its own dedicated `ID` tracker box instead of sharing the LTC box.
- Current branch UX updates: minimum tracker width clamp raised to 120, header slashes removed from summary counts, and config value labels between `[-]`/`[+]` set to white.
- Current branch UX updates: label-only tooltip placeholders added for config setting labels and dynamic tracker/notification row labels.
- `4.0.0` is reserved for the future protocol cutover that removes the old `[RET]` / `[DEVA]` behavior.
- Existing saved settings from previous naming are not auto-migrated.

## License

This project is licensed under the MIT License.

See [LICENSE](LICENSE) for full terms.

## Developer & Release Notes

The sections below are primarily for maintainers and contributors.

### Packaging Releases

Use the cross-platform packaging script to create either a development test build or a handoff-ready release build from the runtime manifest.

Release build:

```bash
python scripts/package_release.py --build release --clean
```

Test build:

```bash
python scripts/package_release.py --build test --clean
```

If your machine uses a different launcher name, use the equivalent interpreter command for your environment, for example:

```bash
py -3 scripts/package_release.py --build release --clean
python3 scripts/package_release.py --build test --clean
```

Windows note:

- Prefer `py -3` on Windows if available (Python Launcher).
- If `python` opens the Microsoft Store or says Python was not found, install Python from python.org or winget and enable PATH during install.
- If the Store alias still intercepts `python`, disable the `python.exe` / `python3.exe` App execution aliases in Windows Settings.
- You can always run with the full interpreter path, for example:

```powershell
& "$env:LocalAppData\Programs\Python\Python312\python.exe" scripts/package_release.py --build release --clean
```

Quick verify:

```powershell
py -3 --version
python --version
```

### Repository Hygiene Standard

This repository enforces a no-process-images policy in source control:

- Development screenshots/mockups belong in local ignored folders such as `.dev-artifacts/` or `screenshots/`.
- A local pre-commit hook and CI check both block tracked image files.
- Hook setup (once per clone): `python scripts/setup_hooks.py`
- Manual check command:

```bash
python scripts/check_no_images.py --staged
```

- Alternate launchers are supported (`py -3` or `python3`).

This produces zip files in `dist/`:

- `WarbandComms-v3.6.0.zip` for the release build
- `WarbandComms-v3.6.0-test.zip` for the test build

Packaging behavior:

- The script reads `WarbandComms.mod` as the source of truth for runtime files.
- Both zips contain a single top-level `WarbandComms/` folder ready to drop into `Interface/AddOns/`.
- Repo-only files such as `.git/`, `.github/`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `changelog.md`, and `ui-controls-reference.xml` are not included.
- `README.md` is included by default; use `--no-readme` to omit it.
- License files matching `LICENSE*` are included in packaged zips.
- The `test` build keeps `tests.lua` and test-only slash command paths for in-client addon testing (`/wbc testboxes`, `/wbc testcenter`, `/wbc selftest`, plus `/wbc test` compatibility alias).
- The `release` build removes `tests.lua` from the packaged `WarbandComms.mod` and strips the test-only slash command paths from the packaged `slash.lua`.

Lua addon testing note:

- For pure Lua projects, testing is often done with standalone tools such as `busted` or `luaunit`.
- For game addons like this one, a large part of testing is usually done inside the client because game APIs, UI state, and event flow do not exist outside the game.
- `tests.lua` is the in-client test harness for this addon.
- The in-client harness covers all tracker boxes, uses generated sample names, and includes a dedicated center-screen notification test for LTC and Immaculate Defense.

## Acknowledgements

WarbandComms builds on earlier community work originally authored by Mainline and Enlil.

Thank you to Mainline and Enlil for the original addon foundation this project evolved from.

## Provenance

Maintained by Andrew Karstaedt as a continuation of community addon work originally authored by Mainline and Enlil.

## Release Checklist

See [RELEASING.md](RELEASING.md) for the full pre-release verification checklist.

## Development Notes

- Main entrypoint: `WarbandComms.lua`
- Module metadata: `WarbandComms.mod`
- UI definitions: `config.xml`, `config-template.xml`, `ui-template.xml`
- Runtime logic: `config.lua`, `ui.lua`, `slash.lua`, `ability_cooldowns.lua`
- Release packaging: `scripts/package_release.py`

### UI Control Compatibility

See [`.github/prompts/ui-controls.prompt.md`](.github/prompts/ui-controls.prompt.md) for available control templates, reusable Lua helpers, and copy-ready XML reference blocks.

## Contributing

Issues and pull requests are welcome. Please read `CONTRIBUTING.md` first.
