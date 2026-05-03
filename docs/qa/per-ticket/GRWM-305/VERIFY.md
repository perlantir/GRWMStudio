# GRWM-305 Verification

## Scope
- Added Base shade data for None, Soft, Glow, and Glam.
- Added placeholder LUT strip resources under `GRWMStudio/Resources/Effects/luts/`.
- Wired the Base category tray into `MirrorView` with `base.none` as the implicit default.
- Added model tests for free shades, default behavior, and LUT parameter dispatch.

## Live Simulator Smoke
- Device: iPhone 16 Pro simulator, iOS 18.3.1.
- Opened the app and tapped the Base rail chip.
- Confirmed the tray shows Clear plus 4 chips: None, Soft, Glow, Glam.
- Confirmed None is active by default when there is no Base selection.
- Tapped Glow and confirmed the Glow chip becomes active.
- Tapped None and confirmed it clears the Base slot and returns to the implicit active state.
- Tapped Glam after Glow and confirmed selection switches cleanly.
- Tapped Clear and confirmed it behaves like None.

## Screenshots
- `base-tray-none-default.png`
- `base-glow-selected.png`
- `base-none-selected.png`
- `base-glam-selected.png`
- `base-clear-returns-none.png`

## Command Evidence
- `xcodegen.log` — PASS
- `swiftlint.log` — PASS
- `deepar-isolation.log` — PASS
- `xcodebuild-build.log` — PASS
- `xcodebuild-shade-tests.log` — PASS
- `xcodebuild-mirror-tests.log` — PASS
- `xcodebuild-full-test.log` — PASS

## Notes
- The simulator placeholder camera feed cannot honestly prove the visual LUT tint or DeepAR's internal crossfade. The runtime path is covered by `MirrorViewModelTests.testSelectBaseShadeAppliesLUTParameters`, which verifies `lutEnabled` and `lutTexture` are sent to the controller with an image parameter. Final color-grade fidelity still needs a real-device DeepAR pass.
