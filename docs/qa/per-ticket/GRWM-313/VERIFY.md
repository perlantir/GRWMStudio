# GRWM-313 Verify

Ticket: No-face indicator overlay
Date: 2026-05-03
Device: iPhone 16 Pro simulator, iOS 18.3.1, portrait

## Scope

Added `NoFaceTipView`, wired a 1.5s debounced no-face overlay into the camera region, posted a VoiceOver announcement when the tip appears, and extracted the tray host from `MirrorView` to keep lint limits green.

## Manual Smoke

1. Installed and launched the GRWM-313 build on the iPhone 16 Pro simulator.
2. Captured the mirror immediately after launch and verified the no-face tip was not visible before the debounce completed.
3. Waited 2s with simulator placeholder face detection false and verified the tip appeared over the upper camera region.
4. Tapped the Skin rail while the tip was visible and verified the Skin tray opened, proving the tip does not block the filter rail or bottom controls.

Simulator limitation: the simulator cannot provide real face-return events. The face stream unit test verifies `isFaceDetected` changes from DeepAR callbacks, and the actual cover/uncover disappearance timing plus spoken VoiceOver announcement remain pending real-device QA.

## Screenshots

- `no-face-before-debounce.png`
- `no-face-tip-visible.png`
- `no-face-does-not-block-rail.png`

## Command Evidence

- `xcodegen.log`: PASS
- `swiftlint.log`: PASS, 0 violations in 99 files
- `deepar-isolation.log`: PASS
- `xcodebuild-build.log`: PASS
- `xcodebuild-face-stream-test.log`: PASS
- `xcodebuild-full-test.log`: PASS
- `accessibility-announcement.log`: PASS
- `no-face-smoke.log`: PASS

## Acceptance Notes

- Tip appears after the 1.5s no-face debounce in simulator.
- Tip is placed in the upper camera region and uses chunky pink shadow plus a lavender accent.
- Rail taps still work while the tip is visible.
- `NoFaceTipView` posts a VoiceOver announcement on appear.
