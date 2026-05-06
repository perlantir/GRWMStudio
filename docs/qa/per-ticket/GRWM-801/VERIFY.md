# GRWM-801 VERIFY

Date: 2026-05-04
Target: iOS Simulator
Ticket: GRWM-801 - Error variant: Mic-Denied

## What I verified

1. With microphone permission revoked, switching to Video and tapping record presents the full-screen `.micDenied` shell.
2. The shell shows the lavender tone, `ERROR · MIC-DENIED` chip, microphone emoji hero, and the expected CTA copy.
3. Tapping `Record without sound` dismisses the error and starts recording immediately with the recording HUD visible.
4. Tapping `Turn on Microphone` opens the app's Settings page in Simulator.

## Commands used

```sh
xcrun simctl privacy booted revoke microphone app.grwmstudio.ios
xcrun simctl launch booted app.grwmstudio.ios -GRWMDebugAppShell
```

## Screenshots

- `mic-denied-error.png` - full-screen mic-denied shell
- `mic-denied-record-without-audio.png` - recording started after taking the alt CTA
- `mic-denied-open-settings.png` - Simulator Settings page reached from the primary CTA

## Notes

- The manual smoke was driven through the actual capture flow in Simulator, not by forcing coordinator state.
- The recording preview in this simulator placeholder path does not prove audio absence at waveform level, but it does prove the fallback branch starts recording without re-surfacing the mic error.
