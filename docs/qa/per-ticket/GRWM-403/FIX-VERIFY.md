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
- The simulator placeholder recording is now generated as a real MP4 in the follow-up below, so preview playback tests can exercise a playable local asset.
- The fresh build is installed on the connected iPhone and ready for real camera-path save testing once the phone is unlocked.

## Follow-up: Preview Playback + Lip Smoothing

Date: 2026-05-03

### Scope

- Fixed photo preview layout with explicit safe-area metrics so the Mirror button stays above the media and Save / Done stay below it.
- Replaced the static video preview icon with an `AVKit.VideoPlayer` surface and explicit Play/Pause control.
- Replaced the simulator placeholder recording with a real generated MP4 so video preview smoke tests exercise playback.
- Added DeepAR parameter-value deduping and texture caching in `MirrorViewModel` so repeated lipstick shade changes skip unchanged texture/enabled writes and only update changed color values.

### Automated Evidence

- Focused capture/mirror regression tests: `xcodebuild-preview-playback-lip-regression-tests-v3.log`
- Video preview playback toggle UI test: `xcodebuild-preview-playback-toggle-ui-v3.log`
- Photo preview layout UI test: `xcodebuild-photo-preview-layout-ui-v2.log`
- Playback/recording smoke after MP4 writer guard: `xcodebuild-preview-playback-smoke-v4.log`
- Generic iOS no-sign build: `xcodebuild-preview-playback-lip-generic-ios-nosign-v3.log`
- SwiftLint: `lint-preview-playback-lip-v4.log`
- DeepAR import isolation: `verify-deepar-isolation-preview-playback-lip-v4.log`

### Visual Evidence

- Photo preview layout: `simulator-photo-preview-layout-v2.png`
- Video preview playback control: `simulator-video-preview-player-v3.png`

### Device Evidence

- Signed connected-device build attempted: `xcodebuild-preview-playback-lip-device-build-v2.log`
- Device build is currently blocked by local Xcode signing state: Xcode reports no account for team `84D222Q647` and no development provisioning profile for `app.grwmstudio.ios`.

## Follow-up: Recording Aspect, Mirror Logo, Heart Route

Date: 2026-05-03

### Scope

- Changed DeepAR video recording output to 720x960 so saved video uses the same 3:4 aspect as the mirror viewport.
- Changed simulator placeholder MP4 generation to 720x960 so playback smoke tests exercise the same geometry.
- Constrained preview media cards to 3:4 so photo/video previews do not render as a taller stretched surface.
- Rebalanced the mirror logo capsule so the wordmark is readable and no longer clipped or squeezed.
- Wired the top-right heart button to the Looks tab placeholder and added a stable UI-test accessibility identifier.
- Removed lipstick texture swaps from shade selection so lips only update color + enabled state, reducing DeepAR parameter churn during video.
- Made `-GRWMDebugAppShell` launch from the Mirror tab every time to avoid UI-test state leaking between runs.

### Automated Evidence

- Focused unit + UI regression tests: `xcodebuild-distortion-logo-lip-focused-tests-full.log`
- Result bundle: `distortion-logo-lip-focused.xcresult`
- SwiftLint: `lint-distortion-logo-lip.log`
- DeepAR import isolation: `deepar-isolation-distortion-logo-lip.log`
- Generic iOS no-sign build: `xcodebuild-generic-ios-distortion-logo-lip.log`
- Signed connected-device build: `xcodebuild-device-distortion-logo-lip.log`

### Visual Evidence

- Mirror shell logo/aspect screenshot: `simulator-mirror-logo-aspect-followup.jpg`
- Photo preview 3:4 screenshot: `simulator-photo-preview-3x4-followup.jpg`
- Video preview 3:4 screenshot: `simulator-video-preview-3x4-followup.jpg`

### Notes

- The device build now succeeds with the local signing state.
- The app was not reinstalled on the connected phone in this follow-up; real-camera validation still needs one install/run pass because simulator video uses the DEBUG placeholder.
- Looks, Feed, Locker, and Settings are still planned ticket surfaces: Looks Library in GRWM-509, Locker in GRWM-502, Feed in GRWM-602, Settings shell in GRWM-605 and full Settings in GRWM-750.
