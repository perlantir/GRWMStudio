# 08 — TESTING PLAN

> Companion to 07-CODEX-PROMPTS.md tickets GRWM-900 through GRWM-906.

This document codifies the testing surfaces, tooling, gates, and the manual QA matrix.

---

## 1. Testing pyramid

```
                 ┌──────────────────┐
                 │   Manual QA      │  ~30 cases per build × 3 devices
                 │   matrix (906)   │
                 └──────────────────┘
              ┌─────────────────────────┐
              │  UI tests (XCUITest)    │  8 critical journeys
              │  — GRWM-901             │
              └─────────────────────────┘
        ┌──────────────────────────────────┐
        │   Snapshot tests (PointFree)     │  33 screens + 9 errors + 12 primitives
        │   — GRWM-857, GRWM-902           │
        └──────────────────────────────────┘
   ┌─────────────────────────────────────────────┐
   │   Performance tests (XCT metrics)           │  5 metrics, baselines locked
   │   — GRWM-854, GRWM-903                      │
   └─────────────────────────────────────────────┘
┌────────────────────────────────────────────────────┐
│   Unit tests (XCTest)                              │  ≥80% line coverage
│   — GRWM-900, plus per-feature tests inline        │
└────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────┐
│   Static checks                                    │  SwiftLint, build script audits
│   — GRWM-002, GRWM-953 (DeepAR isolation)          │
└────────────────────────────────────────────────────┘
```

The wide bottom matters. Static + unit tests catch ~80% of regressions cheaply; UI and snapshot tests guard the integration seams; manual QA is the final human gate before TestFlight.

---

## 2. Tooling stack

| Layer | Tool | Version | Where wired |
|---|---|---|---|
| Static lint | SwiftLint | 0.55+ | Build phase + pre-commit |
| Unit | XCTest | bundled | `GRWMStudioTests/` |
| Mocks | Hand-rolled protocol mocks | — | `GRWMStudioTests/Mocks/` |
| StoreKit | StoreKit Testing | bundled | `Configuration.storekit` |
| In-memory SwiftData | `ModelConfiguration(isStoredInMemoryOnly: true)` | iOS 17+ | per-test `ModelContainer` |
| UI | XCUITest | bundled | `GRWMStudioUITests/` |
| Snapshot | swift-snapshot-testing | 1.17+ | `GRWMStudioTests/SnapshotTestCase.swift` |
| Perf | XCT*Metric (Application/Memory/Clock/Signpost) | bundled | `GRWMStudioTests/PerformanceTests.swift` |
| Accessibility | XCUITest + custom audits | bundled | `GRWMStudioTests/AccessibilityTests.swift` |
| Crash/metrics (prod) | MetricKit | bundled | `GRWMStudio/Diagnostics/MetricSubscriber.swift` |
| Release | fastlane | latest | `fastlane/Fastfile` |

No Firebase. No Sentry. No Crashlytics. No Bugsnag. No third-party analytics. Kids category mandates this; we audit for it in CI (see §7).

---

## 3. Coverage gates

CI fails the PR if any of these regress:

| Gate | Threshold | Tool | File |
|---|---|---|---|
| Line coverage on `GRWMStudio/Mirror/` | ≥80% | xcresulttool | CI |
| Line coverage on `GRWMStudio/Capture/` | ≥80% | xcresulttool | CI |
| Line coverage on `GRWMStudio/Library/` | ≥80% | xcresulttool | CI |
| Line coverage on `GRWMStudio/Commerce/` | ≥80% | xcresulttool | CI |
| Snapshot tests | 100% match | swift-snapshot-testing | CI |
| Cold-start | ≤1.8s DEBUG, ≤1.2s Release | XCTApplicationLaunchMetric | CI |
| Mirror FPS | ≥58 fps (5s sample) | XCTOSSignpostMetric | CI on perf scheme |
| Memory peak | ≤220MB recording | XCTMemoryMetric | CI on perf scheme |
| Hardcoded strings audit | 0 hits | `Scripts/check-localization.sh` | Build phase + CI |
| DeepAR isolation audit | 0 violations | `Scripts/verify-deepar-isolation.sh` | Build phase + CI |
| SwiftLint | 0 errors | swiftlint | Build phase + CI |
| Contrast audit | 0 failures | `Scripts/audit-contrast.swift` | CI |
| Hit-target audit | 0 elements <44pt | XCUITest | CI |

Threshold deviations >10% on perf metrics fail the job. Drift on coverage requires a justification comment + reviewer ack.

---

## 4. Unit test inventory (target)

### MirrorViewModelTests (~25 tests)
- Initial state is `.idle`
- `start()` transitions to `.live` on happy path
- `start()` transitions to `.failed(.license)` on bad license
- `start()` transitions to `.failed(.camDenied)` on cam denied
- `selectShade(_:)` for free shade applies correctly
- `selectShade(_:)` for Pro shade without entitlement → `.license` error
- `selectShade(_:)` for Pro shade with entitlement → applies
- `selectShade(_:)` when EffectCatalog throws → `.effectFail` error
- Switching category changes activeCategory
- No-face for <6s does not nudge
- No-face for ≥6s presents `.noFace` error
- Face re-detected before 6s cancels timer
- Backgrounding within 60s → no re-bootstrap on return
- Backgrounding >60s → re-bootstrap on return
- Recording without mic permission → `.micDenied`
- Recording with `forceNoAudio=true` skips mic check
- Recording disk pre-flight: <250MB → `.lowStorage`
- All 7 categories iterate without error
- Looks slot overrides per-category slots
- `retryLastEffect()` re-runs last successful shade
- `state.allowsNoFaceNudge` true only in `.live`
- Coordinator route on shade-blocked-pro
- Analytics event fired on shade-blocked-pro
- VoiceOver shade announcement string format
- Reduce Motion does not affect state machine

### PreviewViewModelTests (~15)
- Photo preview state initialized correctly
- Video preview state initialized with URL
- `saveToLocker()` happy path
- `saveToLocker()` on capacity exceeded → `.lowStorage`
- `saveToLocker()` on context fail → `.saveFail`
- `saveToPhotos()` with permission → success
- `saveToPhotos()` denied → `.photoDenied`
- `saveToPhotos()` notDetermined → request flow
- `discard()` deletes tmp file
- Tmp file cleanup on error
- Toast on photos-denied alt action
- Locker count increments after save
- Locker at-limit → `DHSavedAtLimit` route
- Share-sheet integration test (mocked UIActivityVC)
- File URL persists across app restart

### CaptureRepositoryTests (~12)
- Save photo → SavedCapture exists in store
- Save video → SavedCapture exists with .video kind
- File copied to Documents/captures/
- Capacity check at 50 captures
- Delete → record removed + file removed
- Delete on missing file → record still removed
- Migration from old schema (placeholder for future versions)
- Sort by createdAt descending
- Filter by lookId
- Pagination cursor (if implemented)
- In-memory ModelContainer fixture
- Concurrent saves serialize correctly

### EffectCatalogTests (~10)
- Manifest parses successfully
- All 7 categories present
- All shades have valid IDs
- Pro shades flagged correctly
- `applyShade(_:)` calls DeepAR with right slot/params
- `applyShade(_:)` looks slot clears per-category slots
- Per-category slot does not clear looks
- Shade lookup by ID
- Shade missing in manifest → throws `.notFound`
- `.deepar` file path resolves to bundle

### StoreServiceTests (~10) — uses StoreKit Testing
- Products load on init
- Monthly + yearly products both available
- Purchase flow → entitlement set
- Purchase cancelled → no entitlement
- Restore → entitlement re-applied
- Subscription expired → entitlement cleared
- Family sharing entitlement honored
- Refund → entitlement cleared
- Cold-start cache: entitlement persists across launches
- Network failure on product load → graceful fallback

### PermissionsServiceTests (~12)
- Camera notDetermined → request flow
- Camera authorized → allow
- Camera denied → block
- Mic same matrix
- Photos add-only same matrix
- Notification opt-in (not in v1, scaffolded only)
- Status changes broadcast via Combine publisher
- Re-request after denial routes to Settings
- Restricted (parental controls) → block, surface in error chip
- Multiple subscribers receive same status
- Permission state cached for one launch
- Background → foreground re-checks status

### SettingsServiceTests (~8)
- Default values: sound on, haptics on
- Toggle persists across launches
- Reset onboarding clears flag
- Manage subscription deep link constructed correctly
- Restore purchases triggers StoreService
- Locker capacity exposed
- Privacy/terms URLs constructed
- About info: version + build number

Total: ~92 unit tests, runtime <30s on M2.

---

## 5. UI test journeys (XCUITest)

Tests use mocked DeepAR (`UITEST_MOCK_DEEPAR=1`) and accelerated timers (`UITEST_OVERRIDE_RECORD_DURATION=3`).

### Journey 1: First-run end-to-end
1. Launch fresh
2. DHSplash → DHWelcome (continue)
3. DHParentInfo (enter email, continue)
4. DHPermissions (allow camera, mic, photos)
5. AppShell → Mirror tab visible
6. Select Skin category → Honey shade applied
7. Tap capture FAB → preview screen
8. Tap "Save to Locker" → confirmation toast
9. Tap Locker tab → 1 item visible
10. Locker count = 1

### Journey 2: Returning user, all categories
1. Launch (onboarding complete)
2. Mirror immediately
3. Iterate Skin → Base → Eyes → Brows → Cheeks → Lips → Looks
4. Each category: select 1st shade, verify applied
5. No errors

### Journey 3: Pro shade gate
1. Mirror, free user
2. Tap Pro shade (sparkle icon)
3. License error appears
4. Tap "See Pro Looks" → paywall
5. Close paywall → mirror
6. Verify free shade still active

### Journey 4: Video recording
1. Mirror live
2. Press-and-hold capture FAB
3. Countdown 3-2-1
4. Recording overlay appears
5. After 3s (mocked), preview shows
6. Tap "Save to Locker"
7. Locker shows 1 video

### Journey 5: Permissions denied
1. Launch with camera denied (UITest setting)
2. Onboarding → Permissions screen
3. Tap "Allow Camera" → iOS denies
4. DHPermissionsDenied screen
5. Continue without camera → mirror tab disabled state
6. Tap mirror tab → cam-denied error

### Journey 6: Pro look from library
1. Looks Library
2. Tap Pro look
3. Look detail
4. "Get Pro" CTA
5. Paywall opens
6. Close → return to look detail (still Pro-locked)

### Journey 7: Locker delete
1. Locker with 3 items
2. Swipe row 1 → delete button
3. Tap delete → confirmation
4. Confirm → row removed, count = 2
5. Pull-to-refresh → still 2

### Journey 8: Settings sound toggle
1. Settings tab
2. Sound toggle → off
3. Mirror tab
4. Tap shade → no audio (verified via MockDHAudio counter)

Each journey has:
- Page-Object helpers (`MirrorPage`, `LockerPage`, etc.)
- Setup that resets state via `UITEST_RESET_ONBOARDING`
- Teardown that captures screenshot on failure
- Expected runtime <45s each

Total UI test runtime: ~6 minutes on M2.

---

## 6. Snapshot test inventory (swift-snapshot-testing)

### Screens (33)
DHSplash, DHWelcome, DHParentInfo, DHPermissions, DHPermissionsDenied, DHMirror_Skin, DHMirror_Base, DHMirror_Eyes, DHMirror_Brows, DHMirror_Cheeks, DHMirror_Lips, DHMirror_Looks, DHMirrorCountdown, DHMirrorRecording, DHMirrorProGate, DHPreviewIdle_Photo, DHPreviewIdle_Video, DHPreviewSaved, DHSaveShare, DHLooks_Library, DHLookDetail, DHTutorial, DHSavedEmpty, DHSavedAtLimit, DHLockerGrid, DHLockerDetail, DHProfile, DHFeed, DHParentMath, DHParentHold, DHPaywall, DHSettings, DHError_Combined (renders all 9)

### Error variants (9)
camDenied, micDenied, photoDenied, license, effectFail, recFail, saveFail, noFace, lowStorage

### DH primitives (12)
DHButton (4 sizes × 5 kinds = 20 variants in 1 grid snapshot)
DHCard (3 variants)
DHChip (selected, unselected, with sticker)
DHTabBar (all 5 tab states)
DHWallpaper (3 backgrounds)
StickerHeart, StickerSparkle, StickerStar, StickerFlower, StickerCrown
DHSpinner
DHSkeleton (3 shapes)
DHCountdown (3-2-1)
DHRecordingTimer (mid-record)
DHToast (saved/photoOnly/error)
DHSection + DHRow

All snapshots at iPhone 16, light mode, AX0. Reference PNGs committed via Git LFS.

---

## 7. Static audits (Scripts/)

These run at build phase + in CI, fail fast:

```bash
Scripts/verify-deepar-isolation.sh     # Only DeepARController.swift may import DeepAR
Scripts/check-localization.sh          # No hardcoded user-facing strings
Scripts/audit-third-party-sdks.sh      # Only DeepAR + system frameworks
Scripts/audit-tracking-strings.sh      # No "Sentry", "Crashlytics", "Bugsnag", "Firebase"
Scripts/audit-contrast.swift           # All DH color pairs WCAG AA
Scripts/audit-hardcoded-colors.sh      # No raw hex in views (must use DH.* tokens)
Scripts/audit-hardcoded-fonts.sh       # No raw .system(size:) in views
```

Example `audit-third-party-sdks.sh`:

```bash
#!/bin/bash
ALLOWED="^(Foundation|SwiftUI|UIKit|AVFoundation|StoreKit|SwiftData|Photos|CoreImage|OSLog|MetricKit|DeepAR|Combine|UserNotifications|XCTest|Testing)$"
HITS=$(grep -rh "^import " GRWMStudio --include="*.swift" \
        | sort -u \
        | sed 's/import //' \
        | grep -vE "$ALLOWED" || true)
if [ -n "$HITS" ]; then
    echo "❌ Disallowed import(s) found:"
    echo "$HITS"
    exit 1
fi
echo "✅ Imports clean"
```

---

## 8. Manual QA matrix

Run before each TestFlight build. Filled checklist saved as `docs/qa/CHECKLISTS/v{N}.md` and signed.

### Devices
| Device | iOS | Why |
|---|---|---|
| iPhone 12 mini | 17.x | Smallest viewport, slowest target hardware |
| iPhone 14 | 18.x | Mid-range typical |
| iPhone 16 Pro Max | 18.x | Largest viewport, latest hardware |

### Conditions
| Axis | Values |
|---|---|
| Network | Offline · 3G (Network Link Conditioner) · Wifi |
| Battery | Normal · Low Power Mode |
| Background app refresh | On · Off |
| Locale | English (en-US) · French (fr) · Japanese (ja) · Hindi (hi) — English fallback expected |
| Time zone | UTC · America/Los_Angeles · Asia/Tokyo |
| Dark mode | Always light (we don't support dark) — verify forced light |
| Dynamic type | Default · AX2 |
| Reduce motion | Off · On |
| VoiceOver | Off · On (sample 5 screens) |

### Scenarios (per device)

#### Cold start
- [ ] Time-to-first-frame ≤2s (subjective; precise gate in GRWM-903)
- [ ] No flash of unstyled content
- [ ] Splash transitions smoothly

#### Onboarding (5 screens)
- [ ] Welcome — sticker animation visible
- [ ] Parent info — email validation works (rejects invalid)
- [ ] Permissions — all 3 toggle correctly
- [ ] Permissions denied — error variant shown
- [ ] Tab bar appears after completion

#### Mirror (7 categories)
- [ ] Skin — 3 shades tested
- [ ] Base — 3 shades tested
- [ ] Eyes — eyeshadow + liner + lashes
- [ ] Brows — color + texture
- [ ] Cheeks — 2 shades
- [ ] Lips — 3 shades
- [ ] Looks — 2 full looks (override per-category)

#### Capture
- [ ] Photo capture
- [ ] Video 5s
- [ ] Video 15s (max)
- [ ] Cancel during countdown
- [ ] Cancel during recording

#### Library / Locker
- [ ] Save photo → locker
- [ ] Save video → locker
- [ ] Locker count increments
- [ ] Delete locker entry
- [ ] At-limit (50) shows DHSavedAtLimit
- [ ] Detail view of saved item
- [ ] Looks Library scrolls smoothly

#### Errors (9 variants — trigger via Settings → Developer in DEBUG, or manually)
- [ ] cam-denied
- [ ] mic-denied
- [ ] photo-denied
- [ ] license
- [ ] effect-fail
- [ ] rec-fail
- [ ] save-fail
- [ ] no-face
- [ ] low-storage

#### Commerce
- [ ] Pro shade tap → license error → paywall
- [ ] Parent gate (math) — correct answer
- [ ] Parent gate — wrong answer 3x → cooldown
- [ ] Parent gate (hold) — full hold succeeds
- [ ] Parent gate (hold) — early release fails
- [ ] Subscribe monthly via sandbox tester
- [ ] Subscribe yearly via sandbox tester
- [ ] Restore on second device
- [ ] Manage subscription deep link
- [ ] Cancel subscription → entitlement clears

#### Settings
- [ ] Sound toggle persists
- [ ] Haptics toggle persists
- [ ] Reset onboarding works (DEBUG)
- [ ] Manage subscription opens iOS settings
- [ ] About shows version + build

#### Stress
- [ ] 50 background/foreground cycles in mirror — no leak
- [ ] 100 photos — disk usage stable
- [ ] 20 videos — old tmp files cleaned
- [ ] All 50+ shades in 5 min — FPS stable
- [ ] 30 tab switches — clean transitions
- [ ] 24h idle on device — no crash

#### Battery
- [ ] 30 min active mirror use ≤8% battery drain on iPhone 14
- [ ] Low Power Mode → still functional (FPS may drop, no crash)

### Sign-off

```
Tester: ________
Date: ________
Build: ________
P0 bugs found: ________
P1 bugs found: ________
P2/P3 bugs found: ________
Sign-off: ☐ Pass to TestFlight   ☐ Block — fix required
```

---

## 9. CI workflow integration

`.github/workflows/ci.yml` runs on every PR and on `main`:

```yaml
name: CI
on: [pull_request, push]
jobs:
  build-and-test:
    runs-on: macos-14
    strategy:
      matrix:
        device: ["iPhone 16", "iPhone 12 mini"]
    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true
      - name: Select Xcode 16
        run: sudo xcode-select -s /Applications/Xcode_16.0.app
      - name: Static audits
        run: |
          Scripts/verify-deepar-isolation.sh
          Scripts/check-localization.sh
          Scripts/audit-third-party-sdks.sh
          Scripts/audit-tracking-strings.sh
          Scripts/audit-hardcoded-colors.sh
          Scripts/audit-hardcoded-fonts.sh
          swift Scripts/audit-contrast.swift
      - name: SwiftLint
        run: swiftlint --strict
      - name: Build
        run: xcodebuild -scheme GRWMStudio -destination "platform=iOS Simulator,name=${{ matrix.device }}" build | xcbeautify
      - name: Unit tests
        run: xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=${{ matrix.device }}" -only-testing:GRWMStudioTests -enableCodeCoverage YES | xcbeautify
      - name: Coverage gate
        run: Scripts/check-coverage.sh 80 Mirror Capture Library Commerce
      - name: Snapshot tests
        run: xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=${{ matrix.device }}" -only-testing:GRWMStudioTests/ScreenSnapshotTests -only-testing:GRWMStudioTests/ErrorSnapshotTests | xcbeautify
      - name: UI tests
        run: xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=${{ matrix.device }}" -only-testing:GRWMStudioUITests/CriticalJourneysUITests | xcbeautify
      - name: Performance tests
        if: matrix.device == 'iPhone 12 mini'
        run: xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=iPhone 12 mini" -only-testing:GRWMStudioTests/PerformanceTests | xcbeautify
      - name: Accessibility tests
        run: xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=${{ matrix.device }}" -only-testing:GRWMStudioTests/AccessibilityTests | xcbeautify
      - name: Upload diffs on failure
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: failure-diffs-${{ matrix.device }}
          path: '**/FailureDiff*.png'
```

---

## 10. Test data and fixtures

### Fixture files (`GRWMStudioTests/Fixtures/`)
- `manifest_test.json` — minimal effect catalog (3 shades per category)
- `face_a.png`, `face_b.png` — sample faces for DEBUG `loadImage(forFaceTrack:)` path
- `Configuration.storekit` — StoreKit Testing config with both products
- `MockEffect.deepar` — empty .deepar file for testing load paths

### Test doubles
All ViewModels accept `AppEnv` which is a struct of protocol-backed services. `AppEnv.mock(...)` returns a fully mocked env for tests.

```swift
struct AppEnv {
    let coordinator: AppCoordinating
    let deepAR: DeepARControlling
    let effectCatalog: EffectCataloging
    let entitlements: EntitlementsProviding
    let permissions: PermissionsProviding
    let captures: CaptureRepositoryType
    let store: StoreServiceType
    let analytics: AnalyticsLogging
    let recording: RecordingServiceType
    let coordinator: AppCoordinating

    static func mock(...) -> AppEnv { ... }
}
```

Every protocol has a `Mock*` implementation in `GRWMStudioTests/Mocks/` with overridable behaviors (`shouldThrow`, `lastApplied`, `callCount`, etc.).

---

## 11. Flake mitigation

UI tests are inherently flaky. Mitigations:

1. **Mock DeepAR fully in UI tests.** No real camera/license calls.
2. **Override timers.** `UITEST_OVERRIDE_RECORD_DURATION=3` short-circuits 15s.
3. **Disable network.** `UITEST_NO_NETWORK=1` makes Feed serve bundled fallback.
4. **Reset state aggressively.** Each test boots with `UITEST_RESET_ONBOARDING=1`.
5. **Wait on conditions, not sleeps.** Page-Object helpers use `XCTWaiter` with explicit element predicates.
6. **`Scripts/test-flake.sh`** runs each UI test 50× nightly; any non-deterministic test gets quarantined and triaged.
7. **No `.sleep` in tests.** Replaced with `expectation(description:)` + `wait(for:timeout:)`.

Snapshot test mitigations:
- Pinned simulator runtime (CI always uses iOS 18.0 on iPhone 16).
- Pinned trait collection (`UITraitCollection(userInterfaceStyle: .light)`).
- Antialiasing rendered consistently via `UIGraphicsImageRenderer` defaults.
- Diff tolerance: 0% — pixel-exact required.

---

## 12. Test runtime budget

| Suite | Target time | Frequency |
|---|---|---|
| Static audits | <30s | every commit (pre-commit + CI) |
| SwiftLint | <20s | every commit |
| Build | <90s | every commit |
| Unit tests | <30s | every commit |
| Snapshot tests (33 + 9 + 12) | <45s | every commit |
| UI tests (8 journeys) | <6 min | every PR + main |
| Perf tests | <3 min | every PR + main on iPhone 12 mini matrix only |
| A11y tests | <2 min | every PR + main |

Total CI time per matrix entry: ~13 min. With 2 matrix entries: ~26 min. Acceptable.

---

## 13. Bug taxonomy

| Severity | Definition | Action |
|---|---|---|
| **P0** | Crash, data loss, paywall broken, kids-category violation | Block ship; fix immediately |
| **P1** | Critical user journey broken (cannot capture, save, or pay) | Block ship; fix in current build |
| **P2** | Polish issue (animation glitch, copy typo, off-by-1pt) | Fix in next build |
| **P3** | Edge case, low-impact (unusual device combo, AX edge) | Backlog |

P0 + P1 = 0 before TestFlight. P0 + P1 + P2 = 0 before public release.

---

End 08-TESTING-PLAN.md
