# Phase 0 Signoff

Phase: Bootstrap (`GRWM-001` through `GRWM-010`)
Head SHA: `d21ba57`
Date: 2026-05-02
Simulator: iPhone 16, iOS 26.4
Status: Pending user acknowledgement

## Scope Completed

- Xcode project, app target, test targets, SwiftLint build phase, and XcodeGen project spec.
- DH design tokens, font registration, chunky shadow, stickers, button/card/chip primitives, wallpapers.
- App environment, root coordinator, root container, and the first animated splash screen.
- Per-ticket QA evidence under `docs/qa/per-ticket/GRWM-001/` through `docs/qa/per-ticket/GRWM-010/`.

## Automated Evidence

| Check | Result | Evidence |
|---|---:|---|
| SwiftLint | PASS, 0 violations | `docs/qa/phase-0/swiftlint.log` |
| DeepAR isolation | PASS | `docs/qa/phase-0/deepar-isolation.log` |
| Build | PASS | `docs/qa/phase-0/xcodebuild-build.log` |
| Tests | PASS, 7 total tests | `docs/qa/phase-0/xcodebuild-test.log` |

Available scripts at this phase:

```text
Scripts/lint.sh
Scripts/verify-deepar-isolation.sh
```

The additional static audit scripts listed in `08-TESTING-PLAN.md` section 7 are not present in the Phase 0 repo yet, so they were not runnable for this signoff.

## Manual Smoke

Computer Use opened the Simulator app and confirmed the running app reached the post-splash `Welcome placeholder`.

Screenshots:

- `docs/qa/phase-0/splash-visible.png`
- `docs/qa/phase-0/welcome-after-transition.png`

Observed flow:

1. Cold launch on iPhone 16 simulator.
2. Splash displayed with striped pink wallpaper, decorative sparkles, bow, GRWM logo, progress bar, and loading label.
3. After the timed splash animation, route advanced to `Welcome placeholder`.

## Design Notes

- `SplashView` follows the checked-in JSX from `docs/design-source/v3/dh-screens-1.jsx`.
- That JSX differs from the GRWM-010 ticket paraphrase; the implementation follows the JSX as the project source of truth.
- `DHWallpaperStripes` now supports a secondary stripe width so the splash can match its 30/2 stripe pattern while preserving the GRWM-008 default 24/24 pattern.

## Deviations And Risks

- `AGENTS.md` remains locally modified by an external process and was intentionally not staged.
- The Phase 0 app still uses placeholder route screens after splash; real onboarding starts in later tickets.
- No DeepAR SDK code is present yet; DeepAR integration begins in Phase 1.
- No remote push was performed in this workspace.

Sign-off:

- Engineering: Codex
- User: Pending
