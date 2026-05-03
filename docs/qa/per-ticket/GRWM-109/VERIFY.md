# GRWM-109 Verification

## Scope

Replaced the empty permissions stub with a real `PermissionsService` surface and `DefaultPermissionsService` backed by Apple camera, microphone, photo add-only, and notification permission APIs.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| `./Scripts/lint.sh` | PASS | 0 violations. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | DeepAR imports remain confined to `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` | PASS | Generic iOS compile/link verification without signing. |
| `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/PermissionsServiceTests` | PASS | Mock-based tests verify request tracking, status promotion, denied/restricted behavior, and the app environment default. |

## Notes

- No screenshot was captured for GRWM-109 because this ticket adds service plumbing and deliberately does not trigger OS permission prompts without a user tap.
- Real system-prompt behavior is deferred to the onboarding permissions UI tickets, where camera/mic/photo prompts can be driven manually from visible buttons.
