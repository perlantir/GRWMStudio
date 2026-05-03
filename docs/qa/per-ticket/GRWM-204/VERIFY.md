# GRWM-204 Verify

Status: PASS.

## Scope Verified

- Denied-camera route renders the friendly `WE NEED YOUR CAMERA` recovery screen.
- Primary CTA opens iOS Settings.
- Secondary CTA remains available for retry.
- Returning from Settings after camera is granted advances automatically.

## Automated Evidence

- `swiftlint.log` - PASS, 0 violations.
- `xcodebuild-build.log` - PASS, simulator build on iPhone 16 Pro iOS 18.3.1.

## Manual Smoke

- Installed the current build on iPhone 16 Pro simulator.
- Launched with DEBUG `-GRWMDebugOnboardingFlow` to test onboarding without deleting app data.
- Reset simulator camera privacy for `app.grwmstudio.ios`.
- Walked Welcome -> Parent Info -> Permissions.
- Tapped Camera Allow, then tapped `Don't Allow` in the system prompt.
- Verified app routed to Permissions Denied.
- Tapped Open Settings and verified iOS Settings opened.
- Granted camera via simulator privacy control and returned to the app.
- Verified scene active re-check advanced to app placeholder because microphone was already granted.

## Screenshots

- `permissions-denied-screen.png`
- `open-settings.png`
