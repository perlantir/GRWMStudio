# GRWM-110 Verification

## Scope

Implemented local capture persistence, DeepAR photo/video controller methods, delegate callbacks, recording auto-stop, and the `RecordingService` facade.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| `./Scripts/lint.sh` | PASS | 0 violations. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | DeepAR imports remain confined to `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` | PASS | Generic iOS compile/link verification without signing. |
| `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/CaptureServiceTests -only-testing:GRWMStudioTests/DeepARControllerRecordingTests` | PASS | Verifies captures directory creation, JPEG writing, MP4 move, screenshot delegate path, 720 x 1280 video start, stop, auto-stop, and `RecordingService`. |
| Physical device build | BLOCKED | `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=00008150-00040D203A88401C' -allowProvisioningUpdates` fails because Xcode has no account for team `84D222Q647` and no development profile for `app.grwmstudio.ios`. |
| On-device photo/video smoke | BLOCKED | Requires a signed install on the connected iPhone. Simulator tests prove local persistence and delegate wiring with mocks, but real DeepAR camera/audio recording still needs device verification. |

## Notes

- No screenshot was captured for GRWM-110 because this ticket adds capture plumbing and the real visible capture controls are introduced in later Mirror/Capture UI tickets.
- Save failures currently surface through `DeepARController.SetupError.captureFailed` or `.recordingFailed`; the final user-facing `saveFail`/`recFail` routing is still owned by the dedicated error UI tickets.
