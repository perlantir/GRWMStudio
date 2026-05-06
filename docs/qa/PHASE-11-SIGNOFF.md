# Phase 11 Signoff — Testing

Date: 2026-05-05
Owner: Codex
Status: PASS with live-AR visual confirmation still required

## Scope

Phase 11 covers GRWM-900 through GRWM-906: unit coverage gates, critical XCUITest journeys, lightweight snapshot primitives, performance tests, accessibility/localization checks, Maestro smoke coverage, and the manual QA matrix deliverable.

This pass also includes the eye-product regression fix requested before Phase 11:
- Eyeshadow now uses its own `eyeshadowEnabled` DeepAR parameter instead of toggling eyeliner.
- Shared `baseBeauty` parameters are reset after bootstrap and per-slot clear so eyeshadow, liner, lashes, brows, base, cheeks, and lips do not inherit stale settings.
- The classic eyeliner mask keeps its source dimensions while dropping the opaque background that could show as wings between the eyes.

## Feed Behavior

Feed is a first-party, read-only curated inspiration feed. It is not a user social feed: no accounts, no posting, no comments, no UGC, and no analytics/tracking SDK. The visible cards are bundled/curated inspiration content for kids-safe browsing.

## Automated Evidence

| Gate | Command / Artifact | Result |
| --- | --- | --- |
| Unit tests + coverage | `docs/qa/phase-11-unit-final.log`, `docs/qa/test-results/phase-11-unit-final.xcresult` | PASS: 202 tests, 0 failures |
| Coverage gate | `docs/qa/phase-11-coverage-gate-final.log` | PASS: Mirror 87.68%, Capture 89.63%, Library 89.39%, Commerce 98.48% |
| Critical UI journeys | `docs/qa/phase-11-critical-ui-final.log`, `docs/qa/test-results/phase-11-critical-ui-final.xcresult` | PASS: 8 journeys, 0 failures, 126.339s |
| Static audits | `docs/qa/phase-11-static-audits-final.log` | PASS: SwiftLint, localization, hardcoded colors/fonts, SDK audit, tracking audit, contrast, DeepAR isolation |
| Maestro syntax | `docs/qa/phase-11-maestro-syntax-final.log` | PASS |
| Maestro smoke | `docs/qa/phase-11-maestro-final-pass.log`, `docs/qa/maestro/phase-11-final-pass/` | PASS: Mirror Feed Locker Smoke in 15s |
| Physical-device build | `docs/qa/phase-11-device-build-final.log` | PASS: signed Debug build for connected iPhone |
| Physical-device install | `docs/qa/phase-11-device-install-final.log` | PASS: installed `app.grwmstudio.ios` |
| Physical-device launch | `docs/qa/phase-11-device-launch-final.log` | PASS: launched `app.grwmstudio.ios` |

## Manual / Visual Notes

- Simulator visual smoke was exercised through XCUITest and Maestro. Maestro walked Mirror, selected Skin/Fair, visited Feed, and landed in Locker.
- The connected iPhone build installed and launched. The device log capture showed DeepAR SDK v5.6.22 initializing and face tracking mode activating.
- I could not complete a human visual AR fidelity pass from the device screen in this run. The code and manifest checks cover the eye-wing regression at the parameter/texture level, but lipstick/eyes/lashes pixel behavior should still be visually checked on the phone before calling the AR makeup fully signed off.

## Known Follow-Up

- Run a live-device visual pass for eyeshadow, eyeliner, lashes, and lipstick after this commit lands.
- If any eye artifacts remain, the next suspect is the bundled DeepAR source mesh/effect pack rather than app-side parameter routing, because the app now isolates eyeshadow vs eyeliner parameters and resets shared beauty state.

Sign-off:
- Engineering automated gates: PASS
- Device install/launch: PASS
- Live AR visual fidelity: PENDING HUMAN CHECK
