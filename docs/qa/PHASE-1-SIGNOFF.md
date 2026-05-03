# Phase 1 Signoff - DeepAR Foundation

Status: Engineering complete; user/device signoff pending.

## Scope

Phase 1 covers GRWM-100 through GRWM-110:

- DeepAR SwiftPM integration and isolation guard
- `DeepARController` bootstrap, camera lifecycle, effect loading, runtime parameter mutation, and recording/capture APIs
- SwiftUI `DeepARView` host with simulator fallback
- Effect manifest/catalog with placeholder thumbnails
- Permissions and capture services

## Commits

| Ticket | Commit |
| --- | --- |
| GRWM-100 | `fc332ad` |
| GRWM-101 | `d8ed32e` |
| GRWM-102 | `7119860` |
| GRWM-103 | `055d583` |
| GRWM-104 | `78be965` |
| GRWM-105 | `52c8850` |
| GRWM-106 | `a7c706c` |
| GRWM-107 | `b73757f` |
| GRWM-108 | `0418668` |
| GRWM-109 | `701d4ae` |
| GRWM-110 | `c3050f1` |

## Automated Verification

| Check | Result | Evidence |
| --- | --- | --- |
| `./Scripts/lint.sh` | PASS | 0 violations across 54 Swift files. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | No `import DeepAR` outside `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` | PASS | Generic iOS compile/link succeeds. |
| `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` | PASS | Full current suite completed on iPhone 16 Pro simulator, iOS 18.3.1, in 13.149s. |
| `jq . GRWMStudio/Resources/Effects/manifest.json` | PASS | Manifest parses as valid JSON. |

## Manual / Visual Verification

| Flow | Result | Evidence |
| --- | --- | --- |
| DeepARView placeholder | PASS | `docs/qa/per-ticket/GRWM-107/deepar-view-placeholder.png`; Computer Use showed the iPhone 16 Pro simulator and visible Magic Mirror fallback. |
| DeepARView initializing state | PASS | `docs/qa/per-ticket/GRWM-107/deepar-view-initializing.png`; Computer Use accessibility tree exposed spinner and label. |
| Launch-time catalog load | PASS | `docs/qa/per-ticket/GRWM-108/catalog-launch-welcome.png`; app advanced to Welcome placeholder instead of `.effectFail`. |

## Blocked Device Gates

Physical-device build remains blocked:

```text
xcodebuild -quiet build -scheme GRWMStudio -destination 'id=00008150-00040D203A88401C' -allowProvisioningUpdates
No Account for Team "84D222Q647"
No profiles for 'app.grwmstudio.ios' were found
```

Because of that, these Phase 1 gates are not honestly complete yet:

- DeepAR license validation on real device
- Live front-camera preview within ~2 seconds
- Camera start/switch behavior with real frames
- `baseBeauty.deepar` visual effect load
- Runtime lipstick recolor within ~80ms
- Real DeepAR photo capture and audio/video recording

## Deviations / Follow-Ups

- The free Beauty Pack does not contain verified brow/blush runtime nodes; those refs remain documented as larger-pack pending in `EffectParameterMap` and `docs/PARAMETER-MAP-SHEET.md`.
- Free-pack material inspection showed some uniforms differ from the app contract, especially foundation and lips; real-device/larger-pack verification must settle those before Mirror shade fidelity is final.
- `08-TESTING-PLAN.md` lists future static scripts that are not yet present in `Scripts/`: localization, third-party SDK, tracking strings, contrast, hardcoded colors, and hardcoded fonts. For Phase 1, the available scripts were run: SwiftLint and DeepAR isolation.

## Sign-Off

Tester: Pending user AM review
Date: 2026-05-02
Build: `c3050f1`
P0 bugs found: Pending
P1 bugs found: Pending
P2/P3 bugs found: Pending
Sign-off: Pending device signing and user smoke test
