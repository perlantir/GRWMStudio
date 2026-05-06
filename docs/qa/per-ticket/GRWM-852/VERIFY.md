# GRWM-852 VERIFY

Date: 2026-05-04
Target: iOS Simulator
Ticket: GRWM-852 - Animations pass (DHAnim curves + canned transitions)

## What changed

1. Added `GRWMStudio/DesignSystem/DHAnim.swift` as the shared animation catalog.
2. Replaced scattered ad-hoc springs and repeaters with `DHAnim` / `.dhAnimation(...)` across the main interaction surfaces:
   - Mirror tray/category changes
   - Filter rail chips
   - Eye sub-tabs
   - Shade swatches
   - Countdown overlay
   - Recording pulse
   - Save toast
   - Press states for buttons/chips/error CTAs
   - Splash progress
   - Avatar editor shake/swatch selection
3. `stickerBob()` now routes through the shared wobble animation and still respects Reduce Motion.

## Static checks

All checks below passed:

```sh
rg -n "withAnimation\\(\\.spring|withAnimation\\(\\.easeInOut|\\.animation\\(\\.spring|\\.animation\\(\\.easeInOut|\\.animation\\(\\.bouncy|\\.animation\\(\\.snappy" GRWMStudio
swiftlint --strict --config .swiftlint.yml
bash Scripts/verify-deepar-isolation.sh
xcodegen generate
xcodebuild build -scheme GRWMStudio -destination 'id=FC58B5F0-CE16-415B-AE8C-1C42B1184EE3' CODE_SIGNING_ALLOWED=NO
```

The grep returned zero matches in app code, which confirms the spring/ease/bouncy/snappy callsites are now funneled through `DHAnim`.

## Test coverage

Focused tests passed:

```sh
xcodebuild test -scheme GRWMStudio -destination 'id=FC58B5F0-CE16-415B-AE8C-1C42B1184EE3' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/SettingsPreferencesTests -only-testing:GRWMStudioTests/CountdownOverlayTests -only-testing:GRWMStudioTests/MirrorCaptureViewModelTests -only-testing:GRWMStudioUITests/SettingsPolishUITests

xcodebuild test -scheme GRWMStudio -destination 'id=FC58B5F0-CE16-415B-AE8C-1C42B1184EE3' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioUITests/GRWMStudioUITests/testCountdownCancelStopsBeforeCompletion -only-testing:GRWMStudioUITests/GRWMStudioUITests/testFilterRailAccessibilityLabelsAndSelection -only-testing:GRWMStudioUITests/GRWMStudioUITests/testPhotoPreviewLayoutControlsVisible -only-testing:GRWMStudioUITests/GRWMStudioUITests/testRecordingOverlayHidesMirrorControls -resultBundlePath build/GRWM-852-ui.xcresult
```

Passed UI smoke coverage:

- `testCountdownCancelStopsBeforeCompletion`
- `testFilterRailAccessibilityLabelsAndSelection`
- `testPhotoPreviewLayoutControlsVisible`
- `testRecordingOverlayHidesMirrorControls`

## Screenshots

- `countdown-overlay.png` - debug countdown overlay rendered in Simulator
- `photo-preview-layout-controls.png` - preview screen with controls visible after photo capture
- `recording-overlay.png` - recording state with overlay visible and mirror controls hidden

Artifacts:

- `docs/qa/per-ticket/GRWM-852/countdown-overlay.png`
- `docs/qa/per-ticket/GRWM-852/photo-preview-layout-controls.png`
- `docs/qa/per-ticket/GRWM-852/recording-overlay.png`
- `build/GRWM-852-ui.xcresult`

## Manual smoke note

Simulator was launched visually and the app was re-launched into representative states during the pass. The strongest evidence for the interactive motion surfaces comes from the focused UI smoke tests above plus the exported screenshots, because those runs reliably drove the surfaces back into the expected UI states after earlier simulator sessions left the app on stale overlay screens.

## Boundaries

- I verified that the motion system is centralized and that the affected UI surfaces still render and behave correctly.
- I did not complete an OS-level Settings-app toggle of Reduce Motion in this pass. Reduce Motion handling is wired into `DHAnim.respecting(...)` and the `stickerBob()` modifier, but the final end-user feel with Reduce Motion enabled still deserves a dedicated live pass.
- This ticket verifies representative motion surfaces, not every screen in the app. Broader whole-app visual lock is still the job of the later snapshot/accessibility passes.
