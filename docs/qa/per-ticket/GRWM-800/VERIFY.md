# GRWM-800 VERIFY

Date: 2026-05-04
Target: iOS Simulator
Ticket: GRWM-800 - Error shell + Cam-Denied variant

## What I verified

1. Cold launch with camera permission denied shows the full-screen cam-denied error shell.
2. Tapping `Open Settings` opens the app's Settings page in Simulator.
3. Tapping `I'll do it later` dismisses the error and returns to the disabled mirror state.
4. The error shell shows the `ERROR · CAM-DENIED` chip, radial hero, sticker, title/body copy, and dual CTA layout.

## Important simulator note

Reinstalling the app resets Simulator privacy state. To verify the denied path, camera permission had to be revoked after install:

```sh
xcrun simctl privacy booted revoke camera app.grwmstudio.ios
```

Without that step, the app only shows the in-screen yellow permission card for the `notDetermined` state.

## Screenshots

- `cam-denied-error.jpg` - full-screen error shell with camera denied
- `cam-denied-dismissed.jpg` - dismissed back to the disabled mirror state
- `open-settings.jpg` - Simulator Settings screen reached from the primary CTA

## Notes

- In the current app stack, the error shell is rendered from the root container as a full-screen overlay driven by `RootCoordinator.presentedError`.
- This produces the intended visible behavior for the shared error system and was the reliable path during live smoke testing.
