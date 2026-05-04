# GRWM-500 Preview Idle Verification

Date: 2026-05-03

## Scope

- Replaced the rough capture preview with a DHPreviewIdle-style screen.
- Added top-left discard X, centered Preview title, and top-right look chip.
- Added 3:4 chunky preview media card for both photos and videos.
- Added zoomable photo preview with pinch and double-tap support.
- Added looping native video playback with muted-by-default audio and tap-to-unmute.
- Added bottom CTAs: Save to Locker and Share.

## Automated Evidence

- Focused preview tests: `xcodebuild-preview-idle-focused.log`
- SwiftLint: `lint.log`
- DeepAR import isolation: `verify-deepar-isolation.log`
- Generic iOS no-sign build: `xcodebuild-generic-ios.log`
- Signed connected-device build: `xcodebuild-device.log`

## Visual Evidence

- Simulator photo preview: `simulator-photo-preview-idle.jpg`
- Simulator video preview after unmute toggle: `simulator-video-preview-idle.jpg`

## Manual Smoke

- Captured a photo from the simulator mirror, verified Preview chrome, Custom mix chip, media card, Save to Locker, Share, and back X.
- Captured a video from the simulator mirror, verified muted playback starts automatically, tapped the mute control, and verified it changes to the unmuted state.
- Tapped back X after preview and verified it returns to the mirror shell.

## Notes

- Save persistence is intentionally only a CTA hook in GRWM-500; disk and SwiftData persistence land in GRWM-501.
- Share presentation is intentionally only a CTA hook in GRWM-500; the share sheet lands in GRWM-506.
- The current simulator video uses the debug placeholder renderer, so the visual asset is a flat placeholder rather than camera footage.
