# GRWM-854 VERIFY

Date: 2026-05-04

## Scope

Performance pass for:
- 720p DeepAR preview configuration
- 12-item LRU effect texture cache
- background retention / warm resume path
- launch and DeepAR signposts
- profiling helper script
- background thumbnail loading for look artwork

## Static / automated verification

Passed:

```bash
xcodegen generate
swiftlint --strict --config .swiftlint.yml
bash Scripts/verify-deepar-isolation.sh
xcodebuild test -scheme GRWMStudio \
  -destination 'id=FC58B5F0-CE16-415B-AE8C-1C42B1184EE3' \
  CODE_SIGNING_ALLOWED=NO \
  -only-testing:GRWMStudioTests/EffectTextureCacheTests \
  -only-testing:GRWMStudioTests/DeepARControllerBootstrapTests \
  -only-testing:GRWMStudioTests/MirrorViewModelTests \
  -only-testing:GRWMStudioTests/MirrorLifecycleViewModelTests
```

Observed results:
- SwiftLint: pass
- DeepAR isolation audit: pass
- Focused test slice: 23 tests executed, 0 failures
- New lifecycle coverage proves:
  - quick foreground resumes without re-bootstrap
  - cache survives quick return
  - timeout background path clears cache and re-bootstraps on next foreground
- Bootstrap coverage proves preview resolution is set to `1280x720`

xcresult:
- `/Users/perlantir/Library/Developer/Xcode/DerivedData/GRWMStudio-gaekqbidenxyijcvejwmtvkrtuoa/Logs/Test/Test-GRWMStudio-2026.05.04_22-45-50--0500.xcresult`

## Manual simulator smoke

Simulator:
- `iPhone 16 (18.3.1)` `FC58B5F0-CE16-415B-AE8C-1C42B1184EE3`

Manual steps:
1. Launched app normally with `xcrun simctl launch booted app.grwmstudio.ios`
2. Confirmed no-face error screen renders
3. Tapped `Got it`
4. Confirmed mirror placeholder surface renders and responds

Artifacts:
- `/Users/perlantir/Projects/GRWM Studio/docs/qa/per-ticket/GRWM-854/simulator-grwm-854-normal-launch.png`
- `/Users/perlantir/Projects/GRWM Studio/docs/qa/per-ticket/GRWM-854/simulator-grwm-854-after-gotit.png`

Observed:
- Normal launch paints correctly
- No-face screen renders with expected kid-safe copy and CTA
- Mirror placeholder surface opens after dismissing the error

## Profiling artifacts

Artifacts created:
- `/Users/perlantir/Projects/GRWM Studio/docs/qa/per-ticket/GRWM-854/time-profiler.trace`
- `/Users/perlantir/Projects/GRWM Studio/docs/qa/per-ticket/GRWM-854/time-profiler-seeded.trace`

Notes:
- Both trace bundles were written to disk
- In this local environment, `xcrun xctrace record --launch ...` leaves the simulator app on a black first-frame state even though a normal `simctl launch` paints correctly
- Because of that instrumentation quirk, I did not record trustworthy cold-start / FPS / memory numbers from these traces yet

Related screenshots documenting the profiler-launch issue:
- `/Users/perlantir/Projects/GRWM Studio/docs/qa/per-ticket/GRWM-854/simulator-grwm-854-launch-delayed.png`
- `/Users/perlantir/Projects/GRWM Studio/docs/qa/per-ticket/GRWM-854/simulator-grwm-854-seeded-profile-launch.png`

## Acceptance status

Confirmed:
- DeepAR preview configured to `1280x720`
- Effect texture cache limited to 12 entries with LRU eviction
- Effect cache survives quick background/foreground in covered lifecycle tests
- Background timeout clears retained resources and re-bootstrap path works in covered lifecycle tests
- Look thumbnails no longer synchronously load `UIImage(named:)` in view bodies
- Launch / DeepAR / shade signposts are present in code

Not fully confirmed yet in this environment:
- cold-start `<= 1.8s` Debug / `<= 1.2s` Release on `iPhone 12 mini`
- sustained `58-60fps`
- memory peak `<= 220MB` during recording and `<= 180MB` idle
- no-main-thread sync I/O proven from a trustworthy Instruments run

Reason:
- `iPhone 12 mini` runtime is not installed locally
- `xctrace --launch` is producing a black-screen launch path here, so the current traces are not trustworthy for those numeric claims

## Follow-up

Before phase signoff, rerun the profiling pass on either:
- an installed `iPhone 12 mini` simulator runtime, or
- a connected real iPhone with the same signposts enabled

The current code changes are in place and covered, but the numeric performance gates still need a trustworthy measurement pass.
