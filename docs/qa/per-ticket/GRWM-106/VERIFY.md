# GRWM-106 Verification

## Scope

Implemented the runtime parameter mutation API on `DeepARController`: color, texture, float/blendshape, and enabled-state parameters now route through the live DeepAR adapter and call the SDK `changeParameter` overloads.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| DeepAR API signature review | PASS | SDK DocC for 5.6.22 exposes `changeParameter(_:component:parameter:vectorValue:)`, `image:`, `floatValue:`, and `boolValue:` overloads. `LiveDeepARClient` converts the app-native vector wrapper into DeepAR `Vector4` at the SDK boundary. |
| `./Scripts/lint.sh` | PASS | 0 violations. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | DeepAR imports remain confined to `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` | PASS | Generic iOS compile/link verification without signing. |
| Focused DeepAR XCTest slice | PASS | iPhone 16 Pro simulator `BFD7E422-B789-4380-9588-B952559B6A92`; bootstrap, effect loading, parameter API, and parameter map tests passed. |
| Physical device build | BLOCKED | `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=00008150-00040D203A88401C' -allowProvisioningUpdates` fails because Xcode has no account for team `84D222Q647` and no development profile for `app.grwmstudio.ios`. |
| On-device lipstick recolor smoke | BLOCKED | Requires a signed device install. The implementation is ready, but visible lipstick recolor within ~80ms cannot be truthfully verified until the Apple account/provisioning blocker is cleared. |

## Notes

- No screenshot was captured for GRWM-106 because the completed portion is SDK/runtime plumbing with no visible simulator UI.
- The free-pack material caveat from GRWM-105 still applies: `docs/PARAMETER-MAP-SHEET.md` notes that some uniforms in the current free pack differ from the app contract, so larger-pack or live-device verification is still required before marking lipstick/foundation parameter fidelity complete.
