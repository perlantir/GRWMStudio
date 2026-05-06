# GRWM-802 VERIFY

Date: 2026-05-04
Target: iOS Simulator
Ticket: GRWM-802 - Error variant: Photo-Denied

## What I verified

1. With Photos add-only permission revoked, opening Locker detail > Share and tapping `Camera Roll` presents the full-screen `.photoDenied` shell.
2. The shell shows the butter tone, `ERROR · PHOTO-DENIED` chip, framed-picture hero, and the expected CTA copy.
3. Tapping `Keep inside GRWM` dismisses the error and shows the in-screen confirmation toast `Saved to your Locker only`.
4. Tapping `Allow Photos` opens the app's Settings page in Simulator.
5. After re-granting Photos add-only permission, the same Save/Share flow saves successfully and the image appears inside the simulator Photos app.

## Commands used

```sh
xcrun simctl privacy booted revoke photos-add app.grwmstudio.ios
xcrun simctl privacy booted grant photos-add app.grwmstudio.ios
xcrun simctl launch booted app.grwmstudio.ios -GRWMDebugAppShell
xcrun simctl launch booted com.apple.mobileslideshow
```

## Screenshots

- `photo-denied-error.png` - full-screen photo-denied shell
- `photo-denied-locker-toast.png` - locker-only toast after the alt CTA
- `photo-denied-open-settings.png` - Simulator Settings page reached from the primary CTA
- `photo-saved-in-photos.png` - saved `Magic Mirror` image visible in the simulator Photos app

## Notes

- The live path also re-verified that Locker detail share now hands off correctly into `SaveShareView`.
- The Photos app showed a first-launch interstitial and notification prompt, but the saved `Magic Mirror` image was still visible in the Photos grid and Recent Days after permission was re-granted.
