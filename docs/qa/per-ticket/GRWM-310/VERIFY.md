# GRWM-310 Verify

Ticket: Looks preset selector (full-face)
Date: 2026-05-03
Device: iPhone 16 Pro simulator, iOS 18.3.1, portrait

## Scope

Implemented the Looks preset data model, horizontal 100 by 120 card tray, Pro star badges, unavailable "Soon" card treatment, selection into the `.looks` slot, and the switch-out confirmation before returning to per-category shade editing.

## Manual Smoke

1. Booted and visually opened the iPhone 16 Pro simulator.
2. Built and launched `app.grwmstudio.ios` from XcodeBuildMCP.
3. Opened the Looks category from the filter rail.
4. Verified the first page shows Sunday Best, School Day, and dimmed Birthday Glam preview.
5. Scrolled the Looks tray to the end and verified Pro cards show gold stars and dimmed Soon states.
6. Tapped Sunday Best and verified the card selected with the active border.
7. Tapped Skin while Sunday Best was active and verified the "Switch out of Sunday Best?" confirmation.
8. Tapped "Yes, mix it" and verified the `.looks` slot cleared and the Skin tray opened normally.

Simulator note: the camera region is still the simulator placeholder, so real full-face AR transformation cannot be visually proven here. Unit coverage verifies `look1` resolves through the manifest and loads into the `.looks` slot. Real DeepAR face fidelity remains part of the device pass once signing/device access is available.

## Screenshots

- `looks-initial-cards.png`
- `looks-pro-soon-cards.png`
- `looks-sunday-best-selected.png`
- `looks-switch-confirmation.png`
- `looks-switch-confirmed-skin-tray.png`

## Command Evidence

- `xcodegen.log`: PASS
- `swiftlint.log`: PASS, 0 violations in 95 files
- `deepar-isolation.log`: PASS
- `xcodebuild-build.log`: PASS
- `xcodebuild-looks-tests.log`: PASS
- `xcodebuild-mirror-tests.log`: PASS
- `xcodebuild-effect-catalog-tests.log`: PASS
- `xcodebuild-full-test.log`: PASS

## Acceptance Notes

- 8 Looks are present in `Looks.all`.
- `look1` and `look2` are available through manifest aliases to the current free pack assets.
- `look3`, `look4`, and the 4 Pro looks are dimmed with Soon overlays until the larger filter pack lands.
- Selecting a Look preserves per-category rail state visually and uses the `.looks` slot for override priority.
- Switching back to a per-category chip requires confirmation and clears only the `.looks` slot on confirm.
