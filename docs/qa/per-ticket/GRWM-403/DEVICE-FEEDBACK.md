# GRWM-403 Device Feedback Follow-Up

Date: 2026-05-03

## User-Reported Issues

- Video attempt behaved like photo capture.
- Shade tray covered the face/makeup region.
- DeepAR.ai watermark visible.
- Preview screen did not expose obvious save/back actions.
- Returning from preview could leave the mirror in a restart-required state.
- Initial no-face tip appeared while a face was visible.
- Header logo was too compressed.
- Stacking lashes and lipstick could freeze the mirror.

## Fixes Applied

- Replaced the capture button's SwiftUI gesture stack with direct touch tracking so hold/release is less likely to fall back to a photo tap.
- Added explicit preview controls: `Mirror`, `Save`, and `Done`.
- Moved shade/looks tray placement lower so it does not cover the central face area as aggressively.
- Increased the startup grace period before the no-face tip appears.
- Enlarged the mirror header logo capsule.
- Added selection serialization and shared `baseBeauty.deepar` loading so lashes/lips do not repeatedly load the same DeepAR effect pack in separate slots.

## Watermark

The `DeepAR.ai` text is emitted by the DeepAR SDK/license tier, not by GRWM Studio UI. Do not attempt to hide or cover it in app code. A paid/no-watermark DeepAR license is required before release.

## Verification

- `xcodegen generate`: PASS
- Focused simulator tests: PASS
- Generic iOS no-sign build: PASS
- SwiftLint from generic iOS build: PASS, 0 violations

## Remaining Blocker

Physical-device reinstall of this follow-up build is blocked by Apple signing/provisioning:

```text
No Account for Team "84D222Q647".
No profiles for 'app.grwmstudio.ios' were found.
```

After Xcode account/provisioning is refreshed, rerun the physical-device install and repeat the manual video, preview, face-tip, and stacked-filter smoke tests.

