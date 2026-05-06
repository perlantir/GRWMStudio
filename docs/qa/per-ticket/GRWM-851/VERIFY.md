# GRWM-851 VERIFY

Date: 2026-05-04
Target: iOS Simulator
Ticket: GRWM-851 - Haptics pass (DHHaptics)

## What I verified

1. Settings now exposes separate `Sounds` and `Haptics` rows under `LOOK & FEEL`.
2. `SettingsPreferences` preserves backward compatibility with the old combined `dh.soundsHaptics` key while writing the new split keys:
   - `dh.sound.enabled`
   - `dh.haptics.enabled`
3. The app now routes key interactions through `DHHaptics.shared.fire(...)`, including buttons, chips, toggle rows, tab interactions, countdown ticks, capture actions, error appearance, save success, and parental gate outcomes.
4. The haptics service no-ops when Reduce Motion is on or when haptics are disabled by settings.
5. The generator objects are retained and re-used instead of being re-created at each callsite.

## Automated checks

All checks below passed:

```sh
swiftlint --strict --config .swiftlint.yml
bash Scripts/verify-deepar-isolation.sh
xcodegen generate
xcodebuild test -scheme GRWMStudio -destination 'id=FC58B5F0-CE16-415B-AE8C-1C42B1184EE3' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/Settings/SettingsPreferencesTests -only-testing:GRWMStudioTests/CountdownOverlayTests -only-testing:GRWMStudioTests/Mirror/MirrorCaptureViewModelTests
xcodebuild test -scheme GRWMStudio -destination 'id=FC58B5F0-CE16-415B-AE8C-1C42B1184EE3' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioUITests/SettingsPolishUITests -resultBundlePath build/GRWM-851.xcresult
```

Focused unit tests:

- `SettingsPreferencesTests`
- `CountdownOverlayTests`
- `MirrorCaptureViewModelTests`

UI smoke:

- `SettingsPolishUITests/testSettingsLookAndFeelRows`

## Screenshots

- `settings-look-and-feel.png` - UI-test screenshot showing the `LOOK & FEEL` section framing and the new split rows in the tested flow
- `settings-screen.png` - simulator screenshot of the live Settings surface during manual smoke

Artifacts live in:

- `docs/qa/per-ticket/GRWM-851/settings-look-and-feel.png`
- `docs/qa/per-ticket/GRWM-851/settings-screen.png`
- `build/GRWM-851.xcresult`

## Manual smoke

I visually opened Simulator, launched the app, navigated to Locker, and opened Settings. The app surface reached the new Settings layout successfully and the UI-test assertions confirmed both `Sounds` and `Haptics` are present and hittable.

## Boundaries

- I can verify the routing and gating logic from code, tests, and simulator UI flow.
- I cannot independently feel physical-device haptics from the simulator, so the tactile quality itself still needs a real iPhone pass.
- The exported UI-test screenshot frames the top of the `LOOK & FEEL` section clearly, but it does not show the entire section in one image. The passing test assertions are the stronger proof for row presence.
