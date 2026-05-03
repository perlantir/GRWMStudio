# GRWM-309 Verification

## Scope
- Added `Shade.lipShades` with five free shades and three Pro shades.
- Updated the manifest lips effect id from `lipstick` to `lips` to match the ticket and keep the free-pack tray functional.
- Wired Lips in `MirrorView`.
- Added bundled lip finish textures: matte, gloss, satin, and glitter.
- Added DEBUG-only `-GRWMDebugHasPro` launch support for simulator entitlement verification; Release builds always default the stub entitlement to false.

## Live Simulator Smoke
- Device: iPhone 16 Pro simulator, iOS 18.3.1.
- Swiped the filter rail to Lips and opened the Lips tray.
- Confirmed the first tray page shows Classic Red, Petal Pink, Nude, and Berry.
- Tapped Petal Pink and confirmed it becomes active.
- Scrolled to the end of the tray and confirmed Plum, Neon Pink, and Disco Brat show gold lock badges.
- Tapped Disco Brat without Pro and confirmed it stays unselected. `MirrorLipViewModelTests.testProLipShadeWithoutEntitlementSetsLicenseError` verifies `lastError == .license`.
- Relaunched with `-GRWMDebugHasPro`, opened Lips, tapped Disco Brat, and confirmed it becomes active.

## Screenshots
- `lips-initial-free-swatches.png`
- `lips-petal-pink-selected.png`
- `lips-pro-locks-visible.png`
- `lips-disco-brat-nonpro-blocked.png`
- `lips-disco-brat-debug-pro-selected.png`

## Command Evidence
- `xcodegen.log` — PASS
- `swiftlint.log` — PASS
- `deepar-isolation.log` — PASS
- `xcodebuild-build.log` — PASS
- `xcodebuild-release-build.log` — PASS
- `xcodebuild-shade-tests.log` — PASS
- `xcodebuild-mirror-lip-tests.log` — PASS
- `xcodebuild-effect-catalog-tests.log` — PASS
- `xcodebuild-full-test.log` — PASS

## Notes
- The simulator placeholder feed cannot visually prove real lipstick rendering on a face. Unit tests verify DeepAR color, texture, and enabled parameter dispatch, and real-device DeepAR fidelity remains a device pass item.
