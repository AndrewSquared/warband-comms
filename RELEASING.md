# Release Checklist

Run through this before tagging a release.

## 1. Load and startup

- [ ] Addon loads without XML/Lua errors.
- [ ] `/wbc` opens config and toggles display correctly.

## 2. Tracker visibility and LayoutEditor

- [ ] Verify global enable toggle and per-tracker toggles remain in sync.
- [ ] Verify hidden trackers stay hidden in LayoutEditor and no phantom entries appear.

## 3. UI sizing and readability

- [ ] Verify `Uniform` and `Relative` resize modes both behave as expected.
- [ ] Verify row text scaling also scales career icons and does not overflow timer column.
- [ ] Verify header spacing and readability at multiple text sizes.
- [ ] Verify header tone/style cycle: Bright/Gold/Red/Green/Blue + Clean/Caps.

## 4. Tracker content behavior

- [ ] Validate ordering and row updates for LTC, Challenge, Channels, Interrupt, and Immaculate Defense.
- [ ] Confirm `LTC` header displays as `Leading the Charge`.
- [ ] Validate long names are truncated and remain within box bounds.

## 5. Protocol and compatibility

- [ ] Verify outbound messages use legacy realm key during transition (`[RET]` on Order, `[DEVA]` on Destro).
- [ ] Verify inbound behavior accepts `[WBC]`, `[RET]`, and `[DEVA]`.
- [ ] For `3.6.x` transition releases, keep the above legacy compatibility intact; reserve `4.0.0` for the future WBC-only cutover.

## 6. Persistence

Reload UI and relog to verify settings persist:

- [ ] tracker visibility
- [ ] width/height
- [ ] resize mode
- [ ] background opacity
- [ ] header/row text scales
- [ ] header tone/style

## 7. Optional release gate

- [ ] Generate a test build and run `/wbc test` in a controlled environment to confirm expected rows update.
- [ ] Smoke-test in an active warband with at least one other player using the current build.

## 8. Package output

- [ ] Run `python scripts/package_release.py --build release --clean`.
- [ ] Optionally run `python scripts/package_release.py --build test --clean` for an in-client validation package.
- [ ] Confirm the generated zip contains one top-level `WarbandComms/` folder and only the intended runtime files for that build type.

## 9. Tag and publish

- [ ] Bump version in `WarbandComms.mod` and `WarbandComms.lua` if not already done.
- [ ] Keep versioning aligned with protocol state: use a minor release while `[RET]` / `[DEVA]` compatibility remains, and save `4.0.0` for the compatibility removal release.
- [ ] Commit final changelog entry and any last fixes.
- [ ] Confirm `LICENSE` exists at repo root and `README.md` references MIT licensing.
- [ ] `git tag v<version>` and push.
- [ ] Attach the release zip to the GitHub release.
