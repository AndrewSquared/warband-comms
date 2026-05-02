# Warband Comms

Warband Comms is a Return of Reckoning addon that tracks key warband ability cooldowns and shows a compact on-screen view for quick decision making.

## Features

- Tracks selected warband abilities (challenge, channels, interrupts, and Leading the Charge `LTC`)
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

- `WarbandComms-v4.0.0.zip` for the release build
- `WarbandComms-v4.0.0-test.zip` for the test build

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
- `test` - runs local test data flow in test builds
- `selftest` - toggles `/say` self-test mode in test builds

Examples:

- `/wbc`
- `/wbc clear`
- `/wbc test` in a test build

## Current Release

- Addon version: `4.0.0`
- This release includes a full rename from RetWBComms to WarbandComms.
- Existing saved settings from previous naming are not auto-migrated.

## Phase 5 Stabilization Checklist

Run this checklist before release tagging:

1. Load and startup
- Addon loads without XML/Lua errors.
- `/wbc` opens config and toggles display correctly.

2. Tracker visibility and LayoutEditor
- Verify global enable toggle and per-tracker toggles remain in sync.
- Verify hidden trackers stay hidden in LayoutEditor and no phantom entries appear.

3. UI sizing and readability
- Verify `Uniform` and `Relative` resize modes both behave as expected.
- Verify row text scaling also scales career icons and does not overflow timer column.
- Verify header spacing and readability at multiple text sizes.
- Verify header tone/style cycle: Bright/Gold/Red/Green/Blue + Clean/Caps.

4. Tracker content behavior
- Validate ordering and row updates for LTC, Challenge, Channels, and Interrupt.
- Confirm `LTC` header displays as `Leading the Charge`.
- Validate long names are truncated and remain within box bounds.

5. Protocol and compatibility
- Verify outbound messages use `[WBC]`.
- Verify inbound behavior is strict `[WBC]` only (`[RET]`/`[DEVA]` are ignored).

6. Persistence
- Reload UI and relog to verify settings persist:
   - tracker visibility
   - width/height
   - resize mode
   - background opacity
   - header/row text scales
   - header tone/style

7. Optional release gate
- Generate a test build and run `/wbc test` in a controlled environment to confirm expected rows update.
- Smoke-test in an active warband with at least one other player using the current build.

8. Package output
- Run `python scripts/package_release.py --build release --clean`.
- Optionally run `python scripts/package_release.py --build test --clean` for an in-client validation package.
- Confirm the generated zip contains one top-level `WarbandComms/` folder and only the intended runtime files for that build type.

## Development Notes

- Main entrypoint: `WarbandComms.lua`
- Module metadata: `WarbandComms.mod`
- UI definitions: `config.xml`, `config-template.xml`, `ui-template.xml`
- Runtime logic: `config.lua`, `ui.lua`, `slash.lua`, `ability_cooldowns.lua`
- Release packaging: `scripts/package_release.py`

### UI Control Compatibility

- XML schema references use `EASystem.xsd` to match working addon patterns for default WAR controls.
- Existing and future controls can safely use templates such as:
   - `EA_Button_Default`, `EA_Button_DefaultResizeable`, `EA_Button_DefaultCheckBox`, `EA_Button_DefaultMinus`
   - `EA_EditBox_DefaultFrame`
   - `EA_ComboBox_DefaultResizable`, `EA_ComboBox_DefaultResizableSmall`
   - `ScrollWindow` + `VerticalScrollbar` (`EA_ScrollBar_DefaultVerticalChain`)
- `config.lua` includes reusable helpers for robust control behavior across template quirks:
   - `WarbandComms.UIEnsureCheckboxState`
   - `WarbandComms.UIResolveCheckboxToggle`
   - `WarbandComms.UISetEditBoxTextIfExists`
   - `WarbandComms.UIPopulateComboBox`
- Copy-ready XML control examples for future expansion are in `ui-controls-reference.xml` (intentionally not loaded by `WarbandComms.mod`).
- Reference handlers are fully wired in `config.lua` for copied controls:
   - `WarbandComms.OnReferenceToggle`
   - `WarbandComms.OnReferenceNumericChanged`
   - `WarbandComms.OnReferenceComboChanged`
   - `WarbandComms.OnReferenceAdd`
   - `WarbandComms.OnReferenceDelete`

## License

License is intentionally not finalized yet. Choose one before publishing a public release branch/tag:

- MIT
- GPL-3.0
- Apache-2.0

See `CONTRIBUTING.md` for contribution workflow while licensing is pending.

## Contributing

Issues and pull requests are welcome. Please read `CONTRIBUTING.md` first.
