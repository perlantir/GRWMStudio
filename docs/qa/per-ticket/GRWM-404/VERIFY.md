# GRWM-404 Recording Overlay Verification

Date: 2026-05-03

## Scope

- Added the chunky red recording pill over the mirror viewport.
- Added elapsed-time display for uncapped camera-style recording.
- Added a stop chip below the FAB.
- Hid mirror bottom controls and filter rail while recording.
- Preserved the newer product direction: no 8s/15s recording cap is reintroduced.

## Automated Evidence

- Recording overlay UI test: `xcodebuild-recording-overlay-ui.log`
- SwiftLint: `lint.log`
- DeepAR import isolation: `verify-deepar-isolation.log`
- Generic iOS no-sign build: `xcodebuild-generic-ios.log`
- Signed connected-device build: `xcodebuild-device.log`

## Visual Evidence

- Simulator recording state: `simulator-recording-overlay.jpg`

## Notes

- The ticket spec mentions cap-color behavior for the last 2 seconds of an 8s/15s cap. That behavior is intentionally omitted because the current product direction is unlimited camera-style recording.
- The focused UI test verifies the overlay appears, elapsed text is visible, the stop chip exists, and the filter rail plus flip camera control are hidden while recording.
