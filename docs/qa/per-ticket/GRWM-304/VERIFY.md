# GRWM-304 Verify

Ticket: GRWM-304 - Skin filter shade picker
Date: 2026-05-03
Simulator: iPhone 16 Pro, iOS 18.3.1 (`BFD7E422-B789-4380-9588-B952559B6A92`)

## Commands

- `xcodegen generate` - PASS (`xcodegen.log`)
- `./Scripts/lint.sh` - PASS, 0 violations across 81 Swift files (`swiftlint.log`)
- `./Scripts/verify-deepar-isolation.sh` - PASS (`deepar-isolation.log`)
- `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-build.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' -only-testing:GRWMStudioTests/ShadeTests CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-shade-tests.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' -only-testing:GRWMStudioTests/MirrorViewModelTests CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-mirror-tests.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-full-test.log`)

## Live Smoke

- Launched on simulator with XcodeBuildMCP and verified visually with Computer Use.
- Tapped Skin: tray slid in above the filter rail with Clear, Fair, Light, Medium, Tan visible and remaining shades reachable by horizontal scroll.
- Tapped Medium: swatch expanded and displayed the checkmark badge immediately.
- Tapped Clear: Medium checkmark disappeared and selection state cleared.
- Swiped the rail, tapped Lips: Skin tray dismissed and the Lips chip selected without showing a Skin tray.

## Screenshots

- `skin-tray-open.png` - Skin tray visible.
- `skin-medium-selected.png` - Medium selected with checkmark.
- `skin-clear.png` - selection cleared.
- `lips-dismisses-skin-tray.png` - switching to Lips dismisses Skin tray.

## Acceptance Notes

- `Shade`, `EffectParam`, `ParamValue`, and `RGBA` are added for app-authored shade data.
- `Shade.skinShades` contains six free inclusive tones: Fair, Light, Medium, Tan, Deep, Rich.
- `MirrorViewModel.selectShade(in:shade:)` now supports typed `Shade`, loads by `effectID`, applies typed params, and records `shadeID` for tray checkmarks.
- Live foundation tint cannot be visually confirmed in Simulator because GRWM still uses the DeepAR placeholder path there. Runtime parameter application is covered by `MirrorViewModelTests.testSelectTypedShadeLoadsEffectAppliesParametersAndTracksSelectionID`; real tint validation remains a signed-device gate.
