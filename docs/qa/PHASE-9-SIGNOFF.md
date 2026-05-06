# Phase 9 Signoff

Phase: Error States
Date: 2026-05-05
Build target: iPhone 16 simulator, iOS 18.3.1; generic iOS Debug build
Head commit: this commit (`[GRWM-750-857] Complete phases 8 through 10`)

## Tickets Covered

- GRWM-800 through GRWM-808

## Command Evidence

- `docs/qa/phase-8-10-unit.log`: PASS, 151 tests, 0 failures.
- `docs/qa/phase-8-10-ui.log`: PASS, focused UI smoke, 10 tests, 0 failures.
- `docs/qa/screen-comparisons/screenshot-all-screens.log`: PASS, screenshot inventory UI suite, 9 tests, 0 failures.
- `docs/qa/phase-8-10-audits.log`: PASS, static audits including localization and DeepAR isolation.

## Error Variant Evidence

- `docs/qa/error-screenshots/cam-denied.png`
- `docs/qa/error-screenshots/mic-denied.png`
- `docs/qa/error-screenshots/photo-denied.png`
- `docs/qa/error-screenshots/license.png`
- `docs/qa/error-screenshots/effect-fail.png`
- `docs/qa/error-screenshots/rec-fail.png`
- `docs/qa/error-screenshots/save-fail.png`
- `docs/qa/error-screenshots/no-face.png`
- `docs/qa/error-screenshots/low-storage.png`

Observed: the debug error trigger opens every public error variant, each variant shows its issue chip and close control, and each screen is captured by UI automation. Error copy is localized through the string catalog and the visual shell uses the shared `DHErrorView` and `ErrorTone` surfaces.

## Deviations / Limitations

- The app also has an internal `licenseInvalid` error for missing/invalid DeepAR key states; it is intentionally not part of the 9 public App Store screenshot variants.
- Low-storage remains simulated/mapped in code and screenshot QA; real device low-disk pressure still needs a manual release-candidate check.

## Sign-off

Tester: Codex
Result: PASS
User sign-off: Pending
