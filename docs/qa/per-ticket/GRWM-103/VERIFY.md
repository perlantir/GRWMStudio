# GRWM-103 Verification

## Scope

Implemented DeepAR camera lifecycle methods using the SDK 5.6.22 `CameraController` surface: create on start, call `startCamera(withAudio:)`, stop and release on `stopCamera()`, and switch front/back via `AVCaptureDevice.Position`.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| DeepAR camera API verified against SDK DocC | PASS | Confirmed `CameraController(deepAR:)`, `startCamera(withAudio:)`, `stopCamera()`, and writable `position: AVCaptureDevice.Position`. |
| `./Scripts/lint.sh` | PASS | 0 violations. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | DeepAR imports remain confined to `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` | PASS | Device compile/link verification without signing. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` | PASS | iPhone 16 Pro simulator compile/link verification using the x86_64 DeepAR simulator slice. |
| `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/DeepARControllerBootstrapTests` | PASS | Bootstrap regression tests still pass after adding the camera lifecycle surface. |
| Physical iPhone deploy/run | BLOCKED | Connected device is visible, but Xcode has no account for team `84D222Q647` and no development provisioning profile for `app.grwmstudio.ios`. |

## Notes

- `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=00008150-00040D203A88401C' -allowProvisioningUpdates` failed before install with: Xcode has no account for team `84D222Q647` and no matching provisioning profile for `app.grwmstudio.ios`.
- No screenshot was captured for GRWM-103 because the live camera smoke requires a signed physical-device run.
- Once Xcode is signed into the Apple Developer account and the development profile is available, rerun the physical-device verification from the ticket: bootstrap, start camera, stop camera, switch back camera with `trackedFace == false`, then switch front camera.
