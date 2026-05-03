# GRWM-400 Verify

Ticket: Capture FAB + state machine
Date: 2026-05-03
Simulator: iPhone 16 Pro, iOS 18.3.1 (`BFD7E422-B789-4380-9588-B952559B6A92`)

## Command Evidence

- `xcodegen.log`: PASS
- `xcodebuild-build.log`: PASS
- `swiftlint.log`: PASS, 0 violations
- `deepar-isolation.log`: PASS
- `xcodebuild-capture-tests.log`: PASS
- `xcodebuild-full-test.log`: PASS
- `xcodebuild-release-build.log`: PASS with DeepAR SDK deprecation warnings only

## Manual Smoke

- Opened Simulator.app through Computer Use and launched the app with XcodeBuildMCP.
- First visual pass caught a real overlap: the new capture FAB was hidden behind the existing center plus. Evidence: `layout-overlap-before.jpg`.
- Fixed the integration by putting the capture FAB in `AppShell`'s mirror-only center slot and hiding the default tab-bar plus on Mirror.
- Verified the normal idle state in the live simulator. Evidence: `capture-fab-idle.jpg`.
- Verified tap and long-press behavior with XcodeBuildMCP:
  - Tap at `(201, 760)` emitted `photoCapture`.
  - Long press at `(201, 760)` for 5000ms emitted `videoCapture began` and `videoCapture duration=5.078939`.
- Verified the recording visual state using DEBUG-only launch arg `-GRWMDebugCaptureRecording`. Evidence: `capture-fab-recording-debug.jpg`.

## Notes

- `capture-fab-recording-progress.png` is retained as a tooling-attempt artifact; XcodeBuildMCP's long-press call blocks until release, so that file captured the post-release idle state rather than the mid-hold state.
- The DEBUG recording visual hook is wrapped in `#if DEBUG`; Release build completed successfully.
- Real camera/photo/video capture wiring lands in GRWM-401 and GRWM-403.
