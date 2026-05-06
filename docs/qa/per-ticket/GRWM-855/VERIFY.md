# GRWM-855 VERIFY

## Scope

Empty states, skeleton loaders, and copy polish:

- `DHSkeleton` shimmer primitive added
- `DHSpinner` replaces system spinners
- Feed, Locker, and Looks Library loading/empty states polished
- Copy audit removes harsh failure language from the touched surfaces
- DEBUG-only QA launch flags added to freeze or force states for manual verification

## Static checks

- `xcodegen generate` — PASS
- `swiftlint --strict --config .swiftlint.yml` — PASS
- `bash Scripts/verify-deepar-isolation.sh` — PASS
- `rg -n "ProgressView\\(" GRWMStudio --glob '*.swift'` — PASS (0 production hits)

## Focused tests

Command:

```sh
xcodebuild test -scheme GRWMStudio -destination 'id=FC58B5F0-CE16-415B-AE8C-1C42B1184EE3' CODE_SIGNING_ALLOWED=NO \
  -only-testing:GRWMStudioTests/SettingsPreferencesTests \
  -only-testing:GRWMStudioTests/MirrorViewModelTests \
  -only-testing:GRWMStudioTests/MirrorLifecycleViewModelTests \
  -only-testing:GRWMStudioTests/RootCoordinatorTests
```

Result:

- 23 tests executed
- 0 failures
- xcresult: `/Users/perlantir/Library/Developer/Xcode/DerivedData/GRWMStudio-gaekqbidenxyijcvejwmtvkrtuoa/Logs/Test/Test-GRWMStudio-2026.05.05_00-24-03--0500.xcresult`

## Manual simulator smoke

Simulator:

- iPhone 16, iOS 18.3
- Simulator app opened visually and driven with Computer Use

### Verified states

1. Feed empty state
   - Launch args: `-GRWMDebugStartFeed -GRWMDebugEmptyFeed -GRWMDebugSlowLoadingStates`
   - Observed: branded empty card, kid-safe copy, visible `Try again` CTA, no system spinner
   - Artifact: [feed-empty-stable.png](/Users/perlantir/Projects/GRWM%20Studio/docs/qa/per-ticket/GRWM-855/feed-empty-stable.png)

2. Feed loading state
   - Launch args: `-GRWMDebugStartFeed -GRWMDebugFreezeFeedLoading`
   - Observed: 4 mosaic-style shimmer placeholders, no `ProgressView`
   - Artifact: [feed-loading-frozen.png](/Users/perlantir/Projects/GRWM%20Studio/docs/qa/per-ticket/GRWM-855/feed-loading-frozen.png)

3. Locker empty state
   - Launch args: `-GRWMDebugStartLocker -GRWMDebugEmptyLocker -GRWMDebugSlowLoadingStates`
   - Observed: empty locker presentation with zeroed counts and no harsh copy
   - Artifact: [locker-empty-stable.png](/Users/perlantir/Projects/GRWM%20Studio/docs/qa/per-ticket/GRWM-855/locker-empty-stable.png)

4. Locker loading state
   - Launch args: `-GRWMDebugStartLocker -GRWMDebugFreezeLockerLoading`
   - Observed: skeleton hero + 6 card placeholders with shimmer
   - Artifact: [locker-loading-frozen.png](/Users/perlantir/Projects/GRWM%20Studio/docs/qa/per-ticket/GRWM-855/locker-loading-frozen.png)

5. Looks empty state
   - Launch args: `-GRWMDebugStartLooks -GRWMDebugEmptyLooks -GRWMDebugSlowLoadingStates`
   - Observed: branded empty card with sticker hero and “No looks yet” copy
   - Artifact: [looks-empty-stable.png](/Users/perlantir/Projects/GRWM%20Studio/docs/qa/per-ticket/GRWM-855/looks-empty-stable.png)

6. Looks loading state
   - Launch args: `-GRWMDebugStartLooks -GRWMDebugFreezeLooksLoading`
   - Observed: 6 placeholder look cards with shimmer
   - Artifact: [looks-loading-frozen.png](/Users/perlantir/Projects/GRWM%20Studio/docs/qa/per-ticket/GRWM-855/looks-loading-frozen.png)

7. Branded loading spinner
   - Launch args: `-GRWMDebugDeepARViewInitializing`
   - Observed: chunky pink ring + sparkle over “Warming up the magic...”
   - Artifact: [deepar-initializing-spinner.jpg](/Users/perlantir/Projects/GRWM%20Studio/docs/qa/per-ticket/GRWM-855/deepar-initializing-spinner.jpg)

## Notes

- The freeze/force launch flags used above are DEBUG-only QA hooks. They are not reachable in Release builds.
- I used those hooks because the normal 180ms loading transitions are too fast and too timing-sensitive for reliable screenshot capture in Simulator.
- I did not add any new third-party SDK usage.
