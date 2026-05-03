# GRWM-403 Device Smoke License Notes

Date: 2026-05-03

## Scope

GRWM-403 adds the video recording flow and 15s cap. The simulator-side build and automated tests passed. Physical-device smoke was initially blocked because DeepAR rejected the bundled license on device; a later clean rebuild with a replacement key resolved the DeepAR license rejection.

## Device

- Device: iPhone
- Xcode destination id: `00008150-00040D203A88401C`
- devicectl/CoreDevice id: `907E2EE7-9C7B-5D0D-9EC0-32E69912287D`
- Bundle id: `app.grwmstudio.ios`
- Configuration: Debug

## Evidence

- `xcodebuild-device-build.log`: physical-device build succeeded.
- `devicectl-install.log`: app install succeeded.
- `devicectl-launch-appshell.log`: app launch succeeded.
- `devicectl-device-smoke-console.log`: runtime reaches DeepAR, then fails license validation.
- `xcodebuild-device-build-after-key.log`: rebuild after entering a replacement DeepAR key succeeded.
- `devicectl-install-after-key.log`: reinstall after entering a replacement DeepAR key succeeded.
- `devicectl-launch-after-key-console.log`: replacement key is bundled, but DeepAR still rejects it on device.
- `xcodebuild-device-clean-build-retry.log`: clean rebuild after final key retry succeeded.
- `devicectl-install-clean-retry.log`: clean-build reinstall succeeded.
- `devicectl-launch-clean-retry-console.log`: DeepAR initialized without the prior license rejection.

Observed console lines:

```text
DeepAR SDK (ios) version: v5.6.22
Licence check failed. Please check your license key.
```

Observed again after replacement-key rebuild/reinstall:

```text
DeepAR SDK (ios) version: v5.6.22
Licence check failed. Please check your license key.
```

Observed after the final clean rebuild/reinstall:

```text
DeepAR SDK (ios) version: v5.6.22
==> Face Tracking mode: XMG_NON_RIGID_FACE_REG2D_3D is activated
```

## Interpretation

The app is launching on the connected iPhone and a non-empty DeepAR key is bundled through `Config/Secrets.xcconfig`. Earlier replacement-key attempts still produced an SDK rejection, but the final clean rebuild/reinstall shows DeepAR face tracking activation and no `Licence check failed` line. The DeepAR license blocker appears resolved for the current installed Debug build.

Likely checks:

- DeepAR license is for iOS, not web/Android.
- DeepAR license bundle id is exactly `app.grwmstudio.ios`.
- License is active in the DeepAR portal.
- License is compatible with the bundled DeepAR SDK version, v5.6.22.

If the app UI still shows a "license" message, inspect the exact text. `License check needs attention.` maps to the DeepAR/license-invalid variant; `Studio Pro needs a grown-up.` maps to blocked Pro content/parent-gate behavior and is not the DeepAR SDK license.

## Remaining Manual Steps

Rerun the device smoke and verify:

- Open Mirror/Video without a license error.
- Press and hold the capture button.
- Confirm countdown starts and can be released/cancelled.
- Hold through countdown and confirm recording begins.
- Release during recording and confirm preview opens as a video asset.
- Hold past the free cap and confirm recording auto-stops at the configured cap.
