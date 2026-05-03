# GRWM-104 Verification

## Scope

Implemented slot-based DeepAR effect loading and clearing. `loadEffect(_:slot:)` resolves `EffectFile.bundleURL()`, calls `switchEffect(withSlot:path:)`, waits for `didSwitchEffect(_:)` with a 4s timeout, and records `loadedEffects`. Clearing a slot sends `path: nil` and removes local tracking.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| DeepAR effect API verified against SDK DocC | PASS | Confirmed `switchEffect(withSlot:path:)` and delegate `didSwitchEffect(_:)`. |
| `./Scripts/lint.sh` | PASS | 0 violations. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | DeepAR imports remain confined to `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` | PASS | Device compile/link verification without signing. |
| Effect resource layout check | PASS | `baseBeauty.deepar` is copied to `GRWMStudio.app/Effects/baseBeauty.deepar`, matching `EffectFile.bundleURL()`. |
| `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/DeepARControllerBootstrapTests -only-testing:GRWMStudioTests/DeepARControllerEffectTests` | PASS | iPhone 16 Pro simulator, iOS 18.3.1, x86_64. Result bundle reports 7 passed, 0 failed, 0 skipped. |
| Physical iPhone effect smoke | BLOCKED | Same signing blocker as GRWM-103: Xcode has no account for team `84D222Q647` and no development provisioning profile for `app.grwmstudio.ios`. |

## Notes

- The first hosted effect tests exposed that `.deepar` resources were being flattened into the app bundle root. `project.yml` now copies `Resources/Effects` as a folder resource so runtime lookup preserves the `Effects/` subdirectory.
- The load bookkeeping uses per-slot request IDs so an older cancelled or timed-out load cannot clear a newer load's continuation.
- No screenshot was captured for GRWM-104 because visible effect verification requires a signed physical-device run.
