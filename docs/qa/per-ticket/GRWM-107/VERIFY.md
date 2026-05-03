# GRWM-107 Verification

## Scope

Added `DeepARView`, a UIKit-backed SwiftUI representable that mounts the controller-owned AR view on device and shows branded placeholder/loading states when DeepAR is uninitialized, initializing, failed, or running in the simulator.

## Screenshots

| State | Screenshot |
| --- | --- |
| Simulator placeholder | `docs/qa/per-ticket/GRWM-107/deepar-view-placeholder.png` |
| Initializing spinner | `docs/qa/per-ticket/GRWM-107/deepar-view-initializing.png` |

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| `./Scripts/lint.sh` | PASS | 0 violations. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | DeepAR imports remain confined to `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` | PASS | Generic iOS compile/link verification without signing. |
| `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/DeepARViewTests` | PASS | Verifies placeholder, initializing spinner, and simulator-ready fallback behavior. |
| XcodeBuildMCP simulator run | PASS | Built, installed, and launched on iPhone 16 Pro simulator `BFD7E422-B789-4380-9588-B952559B6A92`, iOS 18.3.1. |
| Computer Use visual smoke | PASS | Simulator was visible on screen; accessibility tree exposed `deepar-placeholder-spinner` and `deepar-placeholder-label`, and the screenshot showed the Dreamhouse pink placeholder/loading UI without crashing. |
| Physical device build | BLOCKED | `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=00008150-00040D203A88401C' -allowProvisioningUpdates` fails because Xcode has no account for team `84D222Q647` and no development profile for `app.grwmstudio.ios`. |
| Live AR preview within ~2s | BLOCKED | Requires a signed install on the connected iPhone. Simulator correctly stays on the Magic Mirror fallback because DeepAR camera preview cannot be validated there. |

## Notes

- The GRWM-107 debug harness is wrapped in `#if DEBUG` and is launch-argument gated, so Release builds cannot reach it.
- `DeepARContainerView` uses Observation tracking so state changes from `.uninitialized` to `.initializing` to `.ready` refresh the UIKit container without waiting for a parent SwiftUI view to redraw.
