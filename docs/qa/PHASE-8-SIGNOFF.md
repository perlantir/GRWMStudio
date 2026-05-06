# Phase 8 Signoff

Phase: Settings
Date: 2026-05-05
Build target: iPhone 16 simulator, iOS 18.3.1; generic iOS Debug build
Head commit: this commit (`[GRWM-750-857] Complete phases 8 through 10`)

## Tickets Covered

- GRWM-750
- GRWM-751

## Command Evidence

- `docs/qa/phase-8-10-build.log`: PASS, generic iOS build.
- `docs/qa/phase-8-10-unit.log`: PASS, 151 tests, 0 failures.
- `docs/qa/phase-8-10-ui.log`: PASS, focused UI smoke, 10 tests, 0 failures.
- `docs/qa/phase-8-10-audits.log`: PASS, lint, localization, hardcoded color/font audits, third-party SDK audit, tracking marker audit, contrast audit, and DeepAR isolation.

## Manual Smoke

- `docs/qa/manual/2026-05-05-phase-8-10/locker-running.jpg`
- `docs/qa/manual/2026-05-05-phase-8-10/settings-entry.jpg`

Observed: Settings opens from the Locker/Profile gear, renders the Settings hero and Account/Privacy sections, and the focused UI tests scroll to Look & Feel, verify separate Sound and Haptics rows, and exercise the locked Studio Pro parent-gate to paywall route.

## Deviations / Limitations

- External App Store, refund, privacy, help, and terms URL opens are covered by coordinator routing and debounce tests, but real network/Safari account behavior still needs manual device validation before release.
- Delete-all-data is wired through the parent-gated notification path; destructive wipe should be re-checked manually with a populated real locker before App Store submission.

## Sign-off

Tester: Codex
Result: PASS
User sign-off: Pending
