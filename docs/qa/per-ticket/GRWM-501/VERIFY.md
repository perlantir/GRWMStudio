# GRWM-501 Save to Locker Verification

Date: 2026-05-03

## Scope

- Added local capture saving for photos and videos.
- Photos write JPEG files to `Documents/captures/<uuid>.jpg` at 0.92 quality.
- Videos copy the temporary MP4 into `Documents/captures/<uuid>.mp4`.
- Added SwiftData `SavedCapture` insertion with kind, filename, look name, and selected shade IDs.
- Added success confetti that returns to the mirror after 1.2s.
- Added inline save-failure banner that keeps preview open.

## Automated Evidence

- Focused save tests and UI smoke: `xcodebuild-focused.log`
- SwiftLint: `lint.log`
- DeepAR import isolation: `verify-deepar-isolation.log`
- Generic iOS no-sign build: `xcodebuild-generic-ios.log`
- Signed connected-device build: `xcodebuild-device.log`

## Visual Evidence

- Simulator save success confetti: `simulator-save-confetti.png`
- Simulator forced save failure banner: `simulator-save-failure.jpg`

## Manual Smoke

- Captured a simulator photo, tapped Save to Locker, verified the Saved confetti overlay, and verified the app returned to the mirror.
- Relaunched with `-GRWMDebugSaveFail`, captured a simulator photo, tapped Save to Locker, and verified the inline save-fail banner stayed in preview.
- Connected-device Debug build completed after the save flow changes.

## Notes

- Save failure was triggered with the DEBUG `-GRWMDebugSaveFail` path because this repo does not currently include the low-disk simulation script referenced by the original ticket text.
- The saved asset service reuses the existing `SavedCapture` schema fields: `mediaPath` stores the generated filename, `name` stores the display look name, and `appliedShadesJSON` stores the sorted shade ID array.
