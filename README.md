# Warband Comms

Warband Comms is a Return of Reckoning addon that tracks key warband ability cooldowns and shows a compact on-screen view for quick decision making.

## Features

- Tracks selected warband abilities (challenge, channels, interrupts, Leading the Charge `LTC`, and Immaculate Defense)
- Displays active timers by warband member
- Optional center-screen notification support per tracker
- Slash-command driven config access, with optional in-client test helpers for development builds

## Installation (Return of Reckoning)

1. Copy this addon folder into your game path:
   - `Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms`
2. Make sure `WarbandComms.mod` is present in that folder.
3. Start the game and enable the addon in the addon list.

## Packaging Releases

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

This produces zip files in `dist/`:

- `WarbandComms-v3.6.0.zip` for the release build
- `WarbandComms-v3.6.0-test.zip` for the test build

Packaging behavior:

- The script reads `WarbandComms.mod` as the source of truth for runtime files.
- Both zips contain a single top-level `WarbandComms/` folder ready to drop into `Interface/AddOns/`.
- Repo-only files such as `.git/`, `.github/`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `changelog.md`, and `ui-controls-reference.xml` are not included.
- `README.md` is excluded by default to keep the addon package minimal; add `--include-readme` if you want it in the zip.
- The `test` build keeps `tests.lua` and the `/wbc test` and `/wbc selftest` commands intact for in-client addon testing.
- The `release` build removes `tests.lua` from the packaged `WarbandComms.mod` and strips the test-only slash command paths from the packaged `slash.lua`.

Lua addon testing note:

- For pure Lua projects, testing is often done with standalone tools such as `busted` or `luaunit`.
- For game addons like this one, a large part of testing is usually done inside the client because game APIs, UI state, and event flow do not exist outside the game.
- `tests.lua` is the in-client test harness for this addon, and `slash.lua` exposes that harness through `/wbc test` in development-oriented builds.

## Commands

- `/warbandcomms`
- `/wb-comms`
- `/wbc`

Subcommands:

- `clear` - clears current tracker UI data
- `help` - prints command help in chat
- `selfcheck` - prints protocol/runtime diagnostics in chat
- `test` - runs local test data flow in test builds
- `selftest` - toggles `/say` self-test mode in test builds

Examples:

- `/wbc`
- `/wbc help`
- `/wbc selfcheck`
- `/wbc clear`
- `/wbc test` in a test build

## Current Release

- Addon version: `3.6.0`
- This release includes a full rename from RetWBComms to WarbandComms while keeping transition-mode protocol compatibility.
- Legacy inbound compatibility remains enabled for `[WBC]`, `[RET]`, and `[DEVA]`; outbound still uses the single realm-specific legacy key during transition.
- `4.0.0` is reserved for the future protocol cutover that removes the old `[RET]` / `[DEVA]` behavior.
- Existing saved settings from previous naming are not auto-migrated.

## Acknowledgements

WarbandComms was inspired by earlier community work that was passed along through multiple hands.

Thank you to the original creator and maintainers of that prior work. If you are the original author (or can provide canonical attribution details), please open an issue or pull request so proper credit can be recorded here.

## Provenance

Parts of this project may trace back to earlier community-shared addon code received without complete authorship or license history.

If you can provide authoritative source, authorship, or licensing information for predecessor code, please open an issue so attribution and licensing records can be updated.

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

## License

This project is licensed under the MIT License.

See [LICENSE](LICENSE) for full terms.

## Contributing

Issues and pull requests are welcome. Please read `CONTRIBUTING.md` first.
