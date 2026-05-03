# GRWM-315 Verify

## Scope

Added inline effect-load failure handling, retry state, 60-second failure-window escalation, and the mint failure banner over the camera region.

## Manual Smoke

1. Temporarily changed the first manifest effect id from `baseBeauty` to `baseBeauty-broken`.
2. Built and launched with `build_run_sim`.
3. Opened the Skin tray and tapped Fair.
4. Verified the mint banner appears inline over the camera region with title, helper copy, sparkle, chunky shadow, and `Try again` CTA.
5. Moved the banner to a top-level overlay so it renders above tray chrome and can receive taps.
6. Waited beyond 4 seconds and verified the banner auto-dismisses.
7. Restored the manifest id to `baseBeauty` before final build/test checks.

Retry and third-failure escalation are covered by focused unit tests. The simulator coordinate path did not provide a reliable retry-button screenshot before the 4-second auto-dismiss.

## Screenshots

- `effect-fail-banner.jpg`
- `effect-fail-dismissed.jpg`

## Command Evidence

- `xcodegen.log`: PASS
- `swiftlint.log`: PASS
- `xcodebuild-build.log`: PASS
- `xcodebuild-effect-failure-tests.log`: PASS
- `xcodebuild-full-test.log`: PASS
- `deepar-isolation.log`: PASS
- `source-grep.log`: PASS
- `manual-smoke.log`: PARTIAL PASS, with limitation noted
- `hardcoded-colors.log`: script unavailable in this repo snapshot

## Acceptance Notes

- First and second failures keep the mirror in `.running`/inline-banner mode.
- Third failure within 60 seconds moves `MirrorViewModel.state` to `.failed(.effectFail)`.
- Any successful shade or look selection resets the failure counter/window and clears `.effectFail`.
