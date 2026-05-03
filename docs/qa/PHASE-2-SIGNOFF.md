# Phase 2 Signoff - Onboarding

Status: Engineering complete; user/device signoff pending.

## Scope

Phase 2 covers GRWM-200 through GRWM-205:

- Onboarding state router and persistence
- Welcome screen
- COPPA-safe parent info screen with local-only SwiftData profile storage
- Permissions screen for Camera, Microphone, and add-only Photos
- Camera-denied recovery screen with Settings return handling
- App shell with floating 5-tab `DHTabBar`

## Commits

| Ticket | Commit |
| --- | --- |
| GRWM-200 | `fd3806d` |
| GRWM-201 | `0fc2cc7` |
| GRWM-202 | `df768f3` |
| GRWM-203 | `7349cee` |
| GRWM-203 follow-up | `e19da1e` |
| GRWM-204 | `f854d30` |
| GRWM-205 | `b0f9374` |

## Automated Verification

| Check | Result | Evidence |
| --- | --- | --- |
| `./Scripts/lint.sh` | PASS | `docs/qa/phase-2/swiftlint.log`; 0 violations across 66 Swift files. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | `docs/qa/phase-2/deepar-isolation.log`; no `import DeepAR` outside `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` | PASS | `docs/qa/phase-2/xcodebuild-test.log`; full current suite completed on iPhone 16 Pro simulator, iOS 18.3.1, in 13.286s. |
| COPPA copy scan | PASS | `docs/qa/per-ticket/GRWM-203-copy-fix/social-copy-scan.log`; old Photos prompt copy removed from app/config/docs surfaces. |

## Manual / Visual Verification

| Flow | Result | Evidence |
| --- | --- | --- |
| Welcome | PASS | `docs/qa/phase-2/manual/welcome.png`; matched the V01 pink card, face illustration, dots, and CTA composition. |
| Parent info | PASS | `docs/qa/phase-2/manual/parent-info.png`; confirmed local-only copy and no age, recap, or social fields. |
| Permissions happy path | PASS | `docs/qa/phase-2/manual/permissions-granted-required.png`; camera and mic granted, Photos optional, Continue available. |
| Photos prompt copy | PASS | `docs/qa/phase-2/manual/photos-permission-prompt.png`; system prompt now says add to Photos only when Save is tapped. |
| Camera denied | PASS | `docs/qa/phase-2/manual/permissions-denied.png`; denying Camera routes to the dedicated recovery screen. |
| App shell after onboarding | PASS | `docs/qa/phase-2/manual/app-shell-after-onboarding.png`; onboarding completes to the floating tab shell. |
| Tab interactions and persistence | PASS | `docs/qa/per-ticket/GRWM-205/`; Mirror, Looks, Feed, Locker, FAB-to-Mirror, and `dh_last_tab` relaunch persistence verified by hand. |

## Deviations / Follow-Ups

- Parent Info intentionally diverges from `screens-6.jsx` where the mock includes age chips, weekly recap, and recovery-link/email-sending language. The user approved removing non-COPPA-safe elements; the implemented version stores optional parent email only as a local hash and never transmits it.
- The available repo scripts are `lint.sh` and `verify-deepar-isolation.sh`. Future scripts listed in `08-TESTING-PLAN.md` are not yet present: localization, third-party SDK, tracking strings, contrast, hardcoded colors, and hardcoded fonts.
- Physical-device validation remains blocked by signing: no local Xcode account/profile for Team `84D222Q647` and bundle `app.grwmstudio.ios`.
- The `phase-2-complete` tag is intentionally not created yet because the user planned to perform AM review/signoff.

## Sign-Off

Tester: Pending user AM review
Date: 2026-05-02
Build: `e19da1e`
P0 bugs found: Pending
P1 bugs found: Pending
P2/P3 bugs found: Pending
Sign-off: Pending device signing and user smoke test
