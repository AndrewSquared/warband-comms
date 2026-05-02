# Warband Comms

Warband Comms is a Return of Reckoning addon that tracks key warband ability cooldowns and shows a compact on-screen view for quick decision making.

## Features

- Tracks selected warband abilities (challenge, channels, interrupts, and Leading the Charge `LTC`)
- Displays active timers by warband member
- Optional center-screen notification support per tracker
- Slash-command driven config access and testing helpers

## Installation (Return of Reckoning)

1. Copy this addon folder into your game path:
   - `Warhammer Online - Return of Reckoning/Interface/AddOns/WarbandComms`
2. Make sure `WarbandComms.mod` is present in that folder.
3. Start the game and enable the addon in the addon list.

## Commands

- `/warbandcomms`
- `/wb-comms`
- `/wbc`
- `/wbcomms` (legacy)
- `/retwbcomms` (deprecated; still works and prints guidance)
- `/rwc` (deprecated; still works and prints guidance)
- `/ret` (deprecated; still works and prints guidance)

Subcommands:

- `clear` - clears current tracker UI data
- `test` - runs local test data flow
- `selftest` - toggles `/say` self-test mode

Examples:

- `/wbc`
- `/wbc clear`
- `/wbc test`

## Current Release

- Addon version: `4.0.0`
- This release includes a full rename from RetWBComms to WarbandComms.
- Existing saved settings from previous naming are not auto-migrated.

## Development Notes

- Main entrypoint: `WarbandComms.lua`
- Module metadata: `WarbandComms.mod`
- UI definitions: `config.xml`, `config-template.xml`, `ui-template.xml`
- Runtime logic: `config.lua`, `ui.lua`, `slash.lua`, `ability_cooldowns.lua`

## License

License is intentionally not finalized yet. Choose one before publishing a public release branch/tag:

- MIT
- GPL-3.0
- Apache-2.0

See `CONTRIBUTING.md` for contribution workflow while licensing is pending.

## Contributing

Issues and pull requests are welcome. Please read `CONTRIBUTING.md` first.
