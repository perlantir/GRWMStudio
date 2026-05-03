# GRWM-402 Verification

Date: 2026-05-03

## Scope

Implemented `CountdownOverlay` for the mirror video countdown:

- `3 -> 2 -> 1 -> Go!` sequence, defaulting to one second per step.
- Bouncy scale-in / settle / fade-out animation.
- 30% black dim over the mirror.
- Tick sound and medium haptic on each step.
- Cancel path by tapping the cancel control or any dimmed area outside the number.
- `onComplete()` fires after `Go!`.

The DEBUG harness supports `-GRWMDebugCountdownOverlay` for production-speed smoke and `-GRWMDebugCountdownSlow` only for stable screenshot capture.

## Automated Checks

All checks passed:

- `xcodegen generate` -> `xcodegen.log`
- Focused unit tests: `GRWMStudioTests/CountdownOverlayTests` -> `xcodebuild-focused-tests.log`
- Focused UI cancel test: `GRWMStudioUITests/GRWMStudioUITests/testCountdownCancelStopsBeforeCompletion` -> `xcodebuild-ui-cancel-test.log`
- Full simulator test suite, serial -> `xcodebuild-full-tests.log`
- SwiftLint -> `swiftlint.log`
- DeepAR isolation guard -> `verify-deepar-isolation.log`
- Release generic iOS build -> `xcodebuild-release-generic.log`

## Manual Smoke

Simulator: iPhone 16 Pro, iOS 18.3.1, UDID `BFD7E422-B789-4380-9588-B952559B6A92`.

Actions performed:

- Opened Simulator visually with XcodeBuildMCP / Computer Use.
- Built and launched the app with XcodeBuildMCP `build_run_sim`.
- Launched the DEBUG countdown harness using `simctl launch --terminate-running-process`.
- Captured screenshots with `simctl io screenshot`; MCP screenshot capture was intentionally avoided for timing-sensitive states because this simulator session delayed screenshot return by roughly 20 seconds.

Screenshots:

- `countdown-slow-3.png` - stable slow-harness capture of the chunky `3` state.
- `countdown-production-2.png` - production-speed `2` state.
- `countdown-production-1.png` - production-speed `1` state.
- `countdown-production-go.png` - production-speed `Go!` state.
- `countdown-complete-final.png` - `onComplete()` path reached after `Go!`.

Cancel verification:

- `testCountdownCancelStopsBeforeCompletion` launches the slow countdown harness, taps `countdown-cancel-button`, and asserts `countdown-debug-status == "Canceled"`.

## Design Check

Compared against `docs/design-source/v3/dh-screens-6.jsx` -> `DHMirrorCountdown`.

Matched elements:

- Large white 200pt circular number bubble with 8pt `DH.pinkDeep` border.
- Solid chunky shadow and soft pink glow.
- Fredoka display number styling via `DH.font(.display1)`.
- `GET READY` top pill with white dot.
- Sparkle stickers at opposing corners.
- White cancel pill using `DH.font(.buttonSmall)`.
- 30% dimmed mirror background.

Known boundary:

- GRWM-402 validates the overlay in a DEBUG mirror harness. GRWM-403 wires it into the real long-press video flow.
