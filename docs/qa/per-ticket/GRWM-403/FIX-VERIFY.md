# GRWM-403 Capture Preview Bugfix Verification

Date: 2026-05-03

## Scope

- Replaced hold-to-record with camera-style Photo / Video capture selection.
- Removed the fixed video recording duration cap.
- Dismissed shade and Looks trays after a selection is applied.
- Kept preview as an overlay over the active mirror route so returning to Mirror does not restart DeepAR.
- Moved the preview Mirror button above the media and the Save / Done bar below the media.
- Reworked photo/video save through a nonisolated Photos add-only save service.
- Preserved DeepAR SDK isolation.

## Automated Evidence

- Focused unit + UI tests: `xcodebuild-preview-save-route-focused-tests.log`
- Generic iOS no-sign build: `xcodebuild-preview-save-route-generic-ios-nosign.log`
- Signed connected-device build: `xcodebuild-preview-save-route-device-build.log`
- SwiftLint: `lint.log`
- DeepAR import isolation: `verify-deepar-isolation.log`

## Device Evidence

- Installed on connected iPhone: `devicectl-install-preview-save-route.log`
- Launch attempt after install: `devicectl-launch-preview-save-route.log`
- Launch was denied because the phone was locked after install; the app replacement itself succeeded.
- Latest pulled crash log: `crashlogs/GRWMStudio-2026-05-03-134327.ips`
- Crash root cause: old Photos save closure touched SwiftUI/actor-isolated work on `com.apple.PHPhotoLibrary.changes`.

## Visual Evidence

- `simulator-video-mode-selected.jpg`
- `simulator-recording-started.jpg`
- `simulator-video-preview-layout.jpg`
- `simulator-back-to-mirror-after-preview.jpg`
- `simulator-photo-preview-layout.jpg`
- `simulator-photo-save-after-photos-add-grant.jpg`
- `simulator-video-save-after-keep-add-only.jpg`

## Notes

- Simulator photo save verified to `Saved to Photos` after granting `photos-add`.
- Simulator video save still fails after the Photos permission dialog because the simulator DeepAR placeholder video is not a real video container. The real-device path now records to a `.mov` URL for DeepAR and preserves that extension through capture handoff.
- The fresh build is installed on the connected iPhone and ready for real camera-path save testing once the phone is unlocked.
