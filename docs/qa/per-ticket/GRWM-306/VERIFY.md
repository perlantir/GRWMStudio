# GRWM-306 Verification

## Scope
- Added Eyes subcategories: Shadow, Liner, and Lashes.
- Added free/pro shade data for eyeshadow, eyeliner, and eyelashes.
- Added `EyesTrayView` with inner sub-tabs above `ShadeTrayView`.
- Added gold star lock badges to Pro swatches.
- Added bundled free-pack texture resources under `GRWMStudio/Resources/Effects/textures/`.
- Added per-subcategory eye selection tracking so Shadow, Liner, and Lashes are additive on the shared `.eyes` slot.

## Live Simulator Smoke
- Device: iPhone 16 Pro simulator, iOS 18.3.1.
- Opened Eyes tray and confirmed Shadow is active by default.
- Confirmed Shadow exposes six colors by scrolling the tray: Pink, Purple, Gold, Teal, Brown, Blue.
- Tapped Liner and confirmed four chips: None, Classic, Winged, Double-Flick.
- Confirmed Winged and Double-Flick show gold lock badges.
- Tapped Winged without Pro and confirmed no Pro chip becomes active. `MirrorViewModelTests.testProEyeShadeWithoutEntitlementSetsLicenseError` verifies `lastError == .license`.
- Tapped Classic and confirmed Classic becomes active.
- Tapped Lashes and confirmed four chips: None, Natural, Doll, Drama.
- Confirmed Doll and Drama show gold lock badges.
- Tapped Natural and confirmed Natural becomes active.
- Selected Shadow Pink, switched to Liner Classic, then returned to Shadow and confirmed Pink remains selected.

## Screenshots
- `eyes-shadow-initial.png`
- `eyes-shadow-scrolled-colors.png`
- `eyes-liner-pro-locks.png`
- `eyes-liner-pro-blocked.png`
- `eyes-liner-classic-selected.png`
- `eyes-lashes-pro-locks.png`
- `eyes-lashes-natural-selected.png`
- `eyes-shadow-pink-selected.png`
- `eyes-additive-classic-after-shadow.png`
- `eyes-shadow-selection-persists.png`

## Command Evidence
- `xcodegen.log` — PASS
- `swiftlint.log` — PASS
- `deepar-isolation.log` — PASS
- `xcodebuild-build.log` — PASS
- `xcodebuild-shade-tests.log` — PASS
- `xcodebuild-mirror-tests.log` — PASS
- `xcodebuild-full-test.log` — PASS

## Notes
- The simulator placeholder feed cannot visually prove real DeepAR eyeliner/eyeshadow/lash rendering on a face. Unit tests verify parameter dispatch to the correct DeepAR nodes, and final effect fidelity still needs a real-device DeepAR pass.
