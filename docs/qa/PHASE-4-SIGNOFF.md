# Phase 4 Signoff

Phase: Capture, preview, save, recording, and recording overlay
Date: 2026-05-03
Build target: iPhone 16 Pro simulator, iOS 18.3; connected iPhone device build
Head commit: `4d36457 [GRWM-405] Mark recording gate superseded`

## Tickets Covered

- GRWM-400 through GRWM-405

## Command Evidence

- `docs/qa/phase-4/xcodebuild-full-tests.log`: PASS
- `docs/qa/phase-4/lint.log`: PASS
- `docs/qa/phase-4/verify-deepar-isolation.log`: PASS
- `docs/qa/phase-4/xcodebuild-generic-ios.log`: PASS
- `docs/qa/phase-4/xcodebuild-device.log`: PASS

## Manual Smoke

- `docs/qa/per-ticket/GRWM-403/simulator-mirror-logo-aspect-followup.jpg`
- `docs/qa/per-ticket/GRWM-403/simulator-photo-preview-3x4-followup.jpg`
- `docs/qa/per-ticket/GRWM-403/simulator-video-preview-3x4-followup.jpg`
- `docs/qa/per-ticket/GRWM-404/simulator-recording-overlay.jpg`

Observed: simulator launches the mirror shell, the resized logo is readable and not clipped, Photo capture opens a 3:4 preview with Mirror above and Save/Done below, Video capture records until the user stops, preview playback controls render, and recording state hides the filter rail and bottom controls while showing the red REC overlay.

## Deviations / Limitations

- GRWM-405 is intentionally superseded. The old spec required an 8s/15s Pro recording gate, but the current product direction is unlimited camera-style recording with no GRWM-imposed cap.
- Real DeepAR camera output, paid-plan watermark removal, and lipstick flicker need one fresh install/run pass on the connected iPhone. The signed device build passes, but simulator uses a DEBUG placeholder MP4.
- The repo currently contains only `Scripts/lint.sh` and `Scripts/verify-deepar-isolation.sh`; the planned hardcoded-color and third-party-SDK audit scripts are not present.

## Sign-off

Tester: Codex
Result: PASS with real-device validation still needed for camera-rendered media
User sign-off: Pending
