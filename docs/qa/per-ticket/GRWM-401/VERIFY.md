# GRWM-401 Verification

Date: 2026-05-03

## Scope

Implemented the photo capture path from the mirror FAB to an in-memory DeepAR screenshot, a 100ms flash state, shutter sound trigger, heavy haptic trigger, preview routing, and the `rec-fail` banner path.

## Automated Checks

- `xcodegen generate` PASS (`xcodegen.log`)
- Debug simulator build PASS (`xcodebuild-build.log`)
- Focused tests PASS (`xcodebuild-focused-tests.log`)
  - `DeepARControllerRecordingTests`
  - `MirrorCaptureViewModelTests`
- Full serial test suite PASS (`xcodebuild-full-tests.log`)
- SwiftLint PASS (`swiftlint.log`)
- DeepAR isolation audit PASS (`verify-deepar-isolation.log`; script emits no text on success)
- Release generic iOS build PASS (`xcodebuild-release-generic.log`)

## Manual Smoke

Device: iPhone 16 Pro simulator, iOS 18.3.1 (`BFD7E422-B789-4380-9588-B952559B6A92`)

- Launched with `-GRWMDebugAppShell`; mirror opened in portrait light mode.
- Captured baseline mirror state: `mirror-before-photo.jpg`.
- Tapped the center capture FAB; app routed to the photo preview placeholder with the rendered simulator capture image: `photo-preview-placeholder.jpg`.
- Launched with `-GRWMDebugAppShell -GRWMDebugPhotoCaptureFail`; tapped the center capture FAB; chunky `rec-fail` banner appeared: `photo-capture-failure-banner.jpg`.

## Notes

- The 100ms flash state is covered by `MirrorCaptureViewModelTests`; it is intentionally too brief to reliably screenshot with the simulator tool.
- The DeepAR delegate-to-`UIImage` bridge is covered by `testRecordingServiceTakeScreenshotReturnsDelegateImage`.
- Effect-baked photo fidelity requires a signed real-device DeepAR run. The simulator uses the documented placeholder camera path, so applying lipstick cannot prove DeepAR effect compositing here.
