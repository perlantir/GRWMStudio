# GRWM-203 Verify

Status: PASS.

## Scope Verified

- Permissions screen renders three COPPA-safe rows: Camera, Microphone, Photos.
- Removed the JSX notification/friend-request row because it is out of scope and not compliant with the v1 Kids privacy strategy.
- Camera and microphone are required; Photos is optional.
- Permission rows show Allow, Asking..., Granted, and the disabled/enabled Continue state.
- Continue completes onboarding only after camera and microphone are granted.

## Automated Evidence

- `swiftlint.log` - PASS, 0 violations.
- `xcodebuild-build.log` - PASS, simulator build on iPhone 16 Pro iOS 18.3.1.

## Manual Smoke

- Reset simulator privacy for `app.grwmstudio.ios`.
- Launched app with Computer Use, tapped Welcome `Let's go!`, then Parent Info `Skip for now`.
- Verified Permissions screen layout and disabled Continue state.
- Tapped Camera Allow, accepted the system prompt, and saw Camera flip to `Granted ✓`.
- Tapped Microphone Allow, accepted the system prompt, and saw Microphone flip to `Granted ✓`.
- Verified Continue became active.
- Tapped Continue and reached the app placeholder.

## Screenshots

- `permissions-screen.png`
- `permissions-camera-prompt.png`
- `permissions-required-granted.png`
