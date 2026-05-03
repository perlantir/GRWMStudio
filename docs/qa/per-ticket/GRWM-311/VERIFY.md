# GRWM-311 Verify

Ticket: Reset/clear all per category and Reset everything
Date: 2026-05-03
Device: iPhone 16 Pro simulator, iOS 18.3.1, portrait

## Scope

Implemented the global reset button in the mirror chrome, added `MirrorViewModel.resetAll()`, added heavy haptic support, and covered reset behavior with focused unit tests.

## Manual Smoke

1. Booted and visually opened the iPhone 16 Pro simulator.
2. Built and launched `app.grwmstudio.ios` from XcodeBuildMCP.
3. Verified the top-right chrome shows the heart button plus a white circular reset button with the counterclockwise icon and pink chunky shadow.
4. Applied Skin, Eyes, and Lips selections by hand.
5. Tapped Reset everything and verified the open Lips tray dismissed, rail state cleared, and the mirror returned to its bare state.
6. Applied Sunday Best from Looks.
7. Tapped Reset everything and verified the Look tray dismissed and the selected look cleared.
8. Revoked simulator camera permission, relaunched to the camera permission state, tapped Reset everything, and verified the app did not crash or navigate away unexpectedly.
9. Restored simulator camera permission after the smoke.

Haptic note: the reset action calls `DHHaptics.heavy()`. Physical haptic output cannot be felt in simulator, so this is code-verified and ready for the real-device pass.

## Screenshots

- `reset-button-chrome.png`
- `reset-before-mixed-selections.png`
- `reset-after-mixed-selections.png`
- `reset-before-look.png`
- `reset-after-look.png`
- `reset-camera-off-before.png`
- `reset-camera-off-after.png`

## Command Evidence

- `xcodegen.log`: PASS
- `swiftlint.log`: PASS, 0 violations in 97 files
- `deepar-isolation.log`: PASS
- `xcodebuild-build.log`: PASS
- `xcodebuild-reset-tests.log`: PASS
- `xcodebuild-full-test.log`: PASS
- `sim-camera-permission.log`: PASS

## Acceptance Notes

- Reset button is visible in mirror chrome and has accessibility label `Reset everything`.
- Reset clears all slot selections, eye sub-selections, active look name, active category, and resets the eyes subcategory to Shadow.
- On a ready DeepAR controller, reset clears every `EffectSlot`.
- In simulator camera-off state, reset remains stable and does not crash.
