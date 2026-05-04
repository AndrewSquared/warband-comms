# Release Checklist

Run through this before tagging a release.

## What changes repo content vs what does not

- Steps 1 through 8 are validation/testing/packaging checks and should not require code changes when the release branch is already ready.
- Step 9 is where intentional release content updates are finalized (version alignment, changelog finalization, last release fixes if needed), then tagged/published.
- If any check in steps 1 through 8 fails, fix the underlying issue, commit, and re-run the failed checks before tagging.

## Repeatable release flow (recommended)

1. Ensure local branch is up to date and clean.
2. Complete checklist steps 1 through 8.
3. Finalize release content (step 9), commit, and push.
4. Create and push tag.
5. Confirm GitHub Release workflow artifacts.

Suggested command sequence:

- git status --short --branch
- python3 scripts/validate_release_state.py --build release
- python3 scripts/package_release.py --build release --clean
- python3 scripts/validate_release_state.py --build release --zip dist/WarbandComms-v<version>.zip
- git add -A
- git commit -m "chore: finalize v<version> release notes and metadata"
- git push origin <release-branch>
- git tag v<version>
- git push origin v<version>

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

- [ ] Validate ordering and row updates for LTC, ID, Challenge, Channels, and Interrupt.
- [ ] Confirm `LTC` header displays as `Leading the Charge`.
- [ ] Confirm `ID` header displays as `Immaculate Defense`.
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

- [ ] Generate a test build and run `/wbc testboxes` in a controlled environment to confirm all tracker boxes populate as expected.
- [ ] Run `/wbc testcenter` in a test build and confirm LTC and Immaculate Defense center-screen labels resolve correctly.
- [ ] Smoke-test in an active warband with at least one other player using the current build.

## 8. Package output

- [ ] Ensure PR checks passed (`PR Validation` GitHub Actions workflow).
- [ ] Optional local preflight: run `python3 scripts/validate_release_state.py`.
- [ ] Optional local package smoke test: run `python3 scripts/package_release.py --build release --clean`.

## 9. Tag and publish

- [ ] Bump version in `WarbandComms.mod` and `WarbandComms.lua` if not already done.
- [ ] Ensure `changelog.md` top heading is the release heading in format `<version> (YYYY-MM-DD)` (not `Unreleased`).
- [ ] Keep versioning aligned with protocol state: use a minor release while `[RET]` / `[DEVA]` compatibility remains, and save `4.0.0` for the compatibility removal release.
- [ ] Commit final changelog entry and any last fixes.
- [ ] Confirm `LICENSE` exists at repo root and `README.md` references MIT licensing.
- [ ] Complete maintainer in-client validation and PR approval before tagging.
- [ ] Run `git tag v<version>` and `git push origin v<version>`.
- [ ] Confirm `Release Publish` workflow completes and attaches `WarbandComms-v<version>.zip` to the GitHub Release.
