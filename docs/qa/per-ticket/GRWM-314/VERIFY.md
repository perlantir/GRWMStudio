# GRWM-314 Verify

## Scope

Added the bottom-left mirror camera controls, VM flip/flash state, DeepAR no-arg camera switching, and the 50% white flash overlay.

## Manual Smoke

1. Launched a fresh simulator build with `build_run_sim`.
2. Verified the controls render as small white chunky circles above the filter rail and do not resize the mirror layout.
3. Tapped the flash button at simulator point `(106,566)` and verified the full-screen 50% white overlay appears with the bolt lit yellow underneath.
4. Tapped the flip button at simulator point `(60,566)`. The simulator placeholder cannot switch a physical camera, so the device-path switch is covered by source and VM tests; real-device flip remains part of Phase 1+ device QA.
5. Recording-hide behavior is unit-covered by forcing `controller.isRecordingVideo = true`; visible recording UI does not exist until GRWM-403.

## Screenshots

- `mirror-controls-default.jpg`
- `mirror-flash-tapped.jpg`
- `mirror-flash-on.jpg`
- `mirror-flip-tapped.jpg`

## Command Evidence

- `xcodegen.log`: PASS
- `swiftlint.log`: PASS
- `xcodebuild-build.log`: PASS
- `xcodebuild-controls-tests.log`: PASS
- `xcodebuild-full-test.log`: PASS
- `deepar-isolation.log`: PASS
- `source-grep.log`: PASS
- `manual-smoke.log`: PASS

## Notes

- A first live pass exposed oversized control buttons caused by unconstrained chunky-shadow shape expansion. The final build constrains each control to a fixed 44pt button with a 50pt visual frame.
- Real camera switching cannot be validated in this simulator placeholder path; the on-device path calls `DeepARController.switchCamera(toFront:)` from `MirrorViewModel.flipCamera()`.
