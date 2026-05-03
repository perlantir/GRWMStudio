# 02 — File Structure

The complete Xcode project layout for GRWM Studio. Every folder, every file, with one-line descriptions. This is reference — return here when a Codex prompt mentions a file by path and you want context.

## Repo root

```
grwm-studio-ios/
├── .github/
│   └── workflows/
│       └── ci.yml                       # GitHub Actions: build + test on PR
├── .gitignore
├── .swiftlint.yml                       # lint rules
├── README.md                             # human-facing repo readme
├── LICENSE                               # MIT or proprietary, your call
├── Config/
│   ├── Secrets.xcconfig                  # gitignored — license keys live here
│   ├── Secrets.example.xcconfig          # checked in — placeholder values
│   ├── Debug.xcconfig                    # debug-only flags
│   └── Release.xcconfig                  # release-only flags
├── GRWMStudio.xcodeproj/                 # Xcode project file
├── GRWMStudio/                           # the app target source
├── GRWMStudioTests/                      # unit tests
├── GRWMStudioUITests/                    # XCUITest UI tests
├── Scripts/
│   ├── lint.sh                           # SwiftLint runner
│   ├── verify-deepar-isolation.sh        # build-phase: enforce single import of DeepAR
│   └── bump-version.sh                   # marketing/build version bump helper
├── fastlane/                             # optional but recommended
│   ├── Fastfile
│   ├── Appfile
│   └── Matchfile
└── docs/
    ├── ARCHITECTURE.md                   # copy of 04 from this package
    ├── DEEPAR-INTEGRATION.md             # copy of 05
    └── PARAMETER-MAP-SHEET.md            # the artist publishes here
```

## App target source — `GRWMStudio/`

```
GRWMStudio/
├── App/
│   ├── GRWMStudioApp.swift               # @main entry. Hosts root scene.
│   ├── AppDelegate.swift                 # UIApplicationDelegate adapter (lifecycle, deep links)
│   ├── AppEnvironment.swift              # DI container — holds all services
│   ├── RootCoordinator.swift             # top-level navigation state machine
│   ├── RootContainer.swift               # SwiftUI view that switches on coordinator route
│   └── AppShell.swift                    # the tab-bar shell shown post-onboarding
│
├── DesignSystem/
│   ├── DH+Color.swift                    # Color(hex:) and UIColor(hex:) helpers
│   ├── DH+Tokens.swift                   # all design tokens (colors, fonts, radii, shadows)
│   ├── DH+ChunkyShadow.swift             # the two-layer plastic shadow ViewModifier
│   ├── DH+Fonts.swift                    # font registration + SwiftUI Font helpers
│   ├── DHButton.swift                    # the chunky plastic button (4 sizes × 5 kinds)
│   ├── DHCard.swift                      # plastic-stamped card container
│   ├── DHChip.swift                      # category/tag pill
│   ├── DHTabBar.swift                    # 5-tab bottom bar with FAB cutout
│   ├── DHHaptics.swift                   # haptics wrapper (respects Reduce Motion)
│   ├── DHSounds.swift                    # UI sound wrapper
│   ├── DHWallpaper.swift                 # repeating-stripe and gradient backgrounds
│   ├── PhoneShell/                       # DEBUG-only design preview chrome
│   │   ├── GPhoneShell.swift
│   │   ├── GStatusBar.swift
│   │   ├── GDynamicIsland.swift
│   │   └── GHomeIndicator.swift
│   └── Stickers/
│       ├── StickerHeart.swift            # SwiftUI Shape, fill+stroke configurable
│       ├── StickerStar.swift
│       ├── StickerSparkle.swift
│       ├── StickerFlower.swift
│       ├── StickerBow.swift
│       ├── GRWMLogo.swift                # composed view, .stack and .row layouts
│       └── FaceTrackingDots.swift        # animated landmark dot overlay
│
├── DeepAR/                               # the SDK firewall — only files here import DeepAR
│   ├── DeepARController.swift            # @MainActor wrapper. Public surface for the app.
│   ├── DeepARDelegateProxy.swift         # bridges DeepARDelegate Obj-C protocol to Swift
│   ├── DeepARView.swift                  # UIViewRepresentable that hosts the AR UIView
│   ├── EffectCatalog.swift               # parses Resources/Effects/manifest.json
│   ├── EffectFile.swift                  # value type: id, displayName, category, bundlePath, thumbnail
│   ├── EffectSlot.swift                  # enum: skin, base, eyes, brows, cheeks, lips, looks
│   ├── MakeupCategory.swift              # enum: skin, base, eyes, brows, cheeks, lips, looks (display order)
│   ├── MakeupShade.swift                 # value type: id, displayName, color, isPro, parameters
│   ├── EffectParameterMap.swift          # source-of-truth: category → effect node + uniform names
│   ├── EffectParameter.swift             # struct: nodeName, component, parameter
│   └── RecordingService.swift            # high-level photo/video API on top of DeepARController
│
├── Onboarding/
│   ├── SplashView.swift                  # screen 1 (DHSplash)
│   ├── WelcomeView.swift                 # screen 2 (DHWelcome)
│   ├── ParentInfoView.swift              # screen 3 (DHParentInfo)
│   ├── PermissionsView.swift             # screen 4 (DHPermissions)
│   ├── PermissionsDeniedView.swift       # screen 5 (DHPermissionsDenied)
│   ├── PermRow.swift                     # the row component used in PermissionsView
│   └── OnboardingState.swift             # tracks which step is current
│
├── Mirror/
│   ├── MirrorView.swift                  # screen 6 (V01Dreamhouse — the hero)
│   ├── MirrorViewModel.swift             # @Observable state owner
│   ├── MirrorViewport.swift              # the framed AR mirror box
│   ├── CategoryChipBar.swift             # the 7-chip horizontal scrolling bar
│   ├── ShadeRow.swift                    # the 5-gumball shade selector
│   ├── ShadeSwatch.swift                 # one gumball candy shade
│   ├── BeforeAfterSlider.swift           # the vertical scrubber
│   ├── MirrorTopBar.swift                # back, logo, share buttons
│   ├── MirrorBottomActionBar.swift       # save, big record button, reset
│   ├── MirrorCountdownView.swift         # screen 7 (DHMirrorCountdown)
│   ├── MirrorRecordingView.swift         # screen 8 (DHMirrorRecording)
│   ├── MirrorProGateOverlay.swift        # screen 9 (DHMirrorProGate)
│   └── ShadeProBadge.swift               # the lock pip on Pro shades
│
├── Capture/
│   ├── CaptureService.swift              # writes photos/videos to Documents/captures/
│   ├── CaptureRecord.swift               # in-memory record before SwiftData persistence
│   ├── PreviewIdleView.swift             # screen 10 (DHPreviewIdle)
│   ├── PreviewSavedView.swift            # screen 11 (DHPreviewSaved)
│   ├── SaveShareView.swift               # screen 12 (DHSaveShare)
│   └── ShareSheet.swift                  # UIActivityViewController wrapper
│
├── Library/                              # the Looks Library (preset full-face looks)
│   ├── LooksLibraryView.swift            # screen 13 (DHLooks)
│   ├── LooksLibraryViewModel.swift
│   ├── LookTile.swift                    # one tile in the grid
│   ├── LookFilterChip.swift              # filter chips (All, Faves, Cute, Bold...)
│   └── LookDetailView.swift              # screen 16 (DHLookDetail)
│
├── Locker/                               # saved captures (the "Looks Locker" tab)
│   ├── LockerView.swift                  # screen 17 (DHProfile-as-locker — see note below)
│   ├── LockerEmptyView.swift             # screen 14 (DHSavedEmpty)
│   ├── LockerAtLimitView.swift           # screen 15 (DHSavedAtLimit)
│   ├── LockerViewModel.swift
│   └── CaptureTile.swift                 # one saved capture in the locker grid
│
├── Profile/
│   ├── ProfileView.swift                 # screen 17 (DHProfile)
│   ├── ProfileViewModel.swift
│   ├── AvatarPickerView.swift            # modal: pick from built-in avatars
│   └── BadgeStrip.swift                  # achievements row
│
├── Feed/
│   ├── FeedView.swift                    # screen 18 (DHFeed)
│   ├── FeedItem.swift                    # value type
│   ├── FeedService.swift                 # GETs remote JSON, falls back to bundle
│   ├── FeedCard.swift                    # one card in the feed
│   └── TutorialView.swift                # screen 19 (DHTutorial), AVPlayer-based
│
├── Commerce/
│   ├── ParentalGateView.swift            # screen 20 (DHParentMathIdle) and 21 (wrong)
│   ├── ParentalGateHoldView.swift        # screen 22 (DHParentHold)
│   ├── ParentalGateService.swift         # generates challenges, validates answers, throttles
│   ├── PaywallView.swift                 # screen 23 (DHPaywall)
│   ├── PaywallViewModel.swift
│   ├── StoreKitService.swift             # wraps StoreKit 2 (products, purchase, restore)
│   ├── ProEntitlement.swift              # @Observable — single source of "is Pro?"
│   └── ProductCatalog.swift              # static product IDs and display metadata
│
├── Settings/
│   ├── SettingsView.swift                # screen 24 (DHSettings)
│   └── SettingsViewModel.swift
│
├── Errors/
│   ├── ErrorView.swift                   # parameterized — selects layout based on variant
│   ├── ErrorVariant.swift                # enum: 9 cases matching design (cam-denied, mic-denied, ...)
│   ├── CamDeniedView.swift               # screen 25 (DHError "cam-denied")
│   ├── MicDeniedView.swift               # screen 26 (DHError "mic-denied")
│   ├── PhotosDeniedView.swift            # screen 27 (DHError "photo-denied")
│   ├── LicenseLockedView.swift           # screen 28 (DHError "license")
│   ├── EffectFailedView.swift            # screen 29 (DHError "effect-fail")
│   ├── RecordingFailedView.swift         # screen 30 (DHError "rec-fail")
│   ├── SaveFailedView.swift              # screen 31 (DHError "save-fail")
│   ├── NoFaceView.swift                  # screen 32 (DHError "no-face")
│   └── LowStorageView.swift              # screen 33 (DHError "low-storage")
│
├── Persistence/
│   ├── AppModelContainer.swift           # SwiftData container setup
│   ├── SavedCapture.swift                # @Model — one Locker entry
│   ├── ProfileRecord.swift               # @Model — singleton profile
│   ├── FavoriteLook.swift                # @Model — favorited preset look
│   └── PersistenceMigrations.swift       # versioning hooks for schema changes
│
├── Permissions/
│   ├── PermissionsService.swift          # protocol
│   ├── DefaultPermissionsService.swift   # AVCaptureDevice + PHPhotoLibrary + UNUserNotificationCenter
│   └── AppPermissionStatus.swift         # enum: notDetermined, granted, denied, restricted
│
├── Analytics/
│   ├── AnalyticsService.swift            # protocol
│   ├── NoOpAnalyticsService.swift        # default
│   └── AnalyticsEvent.swift              # event taxonomy
│
├── Utilities/
│   ├── Result+Extensions.swift
│   ├── URL+Documents.swift               # convenience for Documents/captures/
│   ├── DiskSpace.swift                   # checks free space, drives low-storage error
│   ├── Logger+GRWM.swift                 # OSLog wrapper with categories
│   └── Concurrency+Extensions.swift      # Task.sleep helper, withTimeout helper
│
└── Resources/
    ├── Assets.xcassets/                  # AppIcon, color asset catalog (mirror of DH tokens)
    ├── Effects/                          # all .deepar files
    │   ├── manifest.json                 # source of truth — categories, effect IDs, shades
    │   ├── baseBeauty.deepar
    │   ├── look_bubblegumPop.deepar
    │   ├── look_sunsetCrush.deepar
    │   ├── look_mermaidTears.deepar
    │   ├── look_cherryGlaze.deepar
    │   ├── look_softDoll.deepar
    │   ├── look_discoBrat.deepar
    │   ├── look_legacy01.deepar          # from free pack (renamed from look1.deepar)
    │   ├── look_legacy02.deepar          # from free pack (renamed from look2.deepar)
    │   └── thumbnails/                   # 720×720 PNG per look
    │       ├── bubblegumPop.png
    │       └── ...
    ├── Fonts/
    │   ├── Fredoka-Regular.ttf
    │   ├── Fredoka-Medium.ttf
    │   ├── Fredoka-SemiBold.ttf
    │   ├── Fredoka-Bold.ttf
    │   ├── Quicksand-Regular.ttf
    │   ├── Quicksand-Medium.ttf
    │   ├── Quicksand-SemiBold.ttf
    │   └── Quicksand-Bold.ttf
    ├── Sounds/
    │   ├── tap.mp3
    │   ├── shutter.mp3
    │   ├── save_success.mp3
    │   ├── error.mp3
    │   ├── sparkle.mp3
    │   └── ...                           # ~20 short SFX
    ├── Avatars/                          # built-in avatar set, 12+ diverse kid avatars
    │   ├── avatar_01.png
    │   └── ...
    ├── Feed.bundled.json                 # offline fallback for Feed
    ├── Info.plist
    ├── PrivacyInfo.xcprivacy             # required for App Store
    └── LaunchScreen.storyboard           # required by iOS — minimal, just the brand color
```

## Tests target — `GRWMStudioTests/`

```
GRWMStudioTests/
├── DesignSystem/
│   ├── DHTokensTests.swift               # color round-trip, shadow params
│   ├── DHPrimitivesTests.swift           # snapshot tests for button/card/chip
│   └── DHHapticsTests.swift              # respects Reduce Motion
├── DeepAR/
│   ├── EffectCatalogTests.swift          # manifest parsing, finds bundled effects
│   ├── EffectParameterMapTests.swift     # every category has a complete map
│   ├── DeepARControllerTests.swift       # state machine (uses MockDeepARSDK protocol)
│   └── RecordingServiceTests.swift
├── Permissions/
│   └── PermissionsServiceTests.swift     # uses MockPermissionsService
├── Persistence/
│   ├── SavedCaptureTests.swift           # CRUD on SwiftData model
│   ├── ProfileRecordTests.swift
│   └── FavoriteLookTests.swift
├── Capture/
│   └── CaptureServiceTests.swift         # disk write, cap enforcement
├── Commerce/
│   ├── ParentalGateServiceTests.swift    # math challenge generation, throttling
│   ├── StoreKitServiceTests.swift        # using StoreKit 2 testing framework
│   └── ProEntitlementTests.swift
├── Feed/
│   └── FeedServiceTests.swift            # remote JSON parsing, fallback to bundle
├── Onboarding/
│   └── OnboardingStateTests.swift
└── Mirror/
    └── MirrorViewModelTests.swift        # state transitions on shade taps
```

## UI tests target — `GRWMStudioUITests/`

```
GRWMStudioUITests/
├── HelloWorldUITests.swift               # smoke test: app launches, splash shows
├── OnboardingFlowTests.swift             # complete onboarding, accept all permissions
├── MirrorCoreLoopTests.swift             # apply Skin + Eyes + Lips, take photo, save
├── PaywallFlowTests.swift                # tap Pro shade → parental gate → paywall (sandbox purchase mocked)
├── LockerLimitTests.swift                # save 12 captures → see limit → tap Pro upsell
├── ErrorFlowTests.swift                  # deny camera permission → see CamDeniedView
├── AccessibilityTests.swift              # VoiceOver labels present on hero screens
└── Helpers/
    ├── XCUIElement+GRWM.swift            # convenience: tap by accessibilityIdentifier
    └── LaunchArguments.swift             # arg parsing: -uiTestMode, -mockStoreKit, etc.
```

## File count summary (rough)

- App / Coordinator: 6 files
- DesignSystem: 22 files (incl. 7 stickers + 4 phone shell + 11 primitives/tokens)
- DeepAR wrapper: 11 files
- Onboarding: 7 files (5 screens + 2 helpers)
- Mirror: 14 files (4 screens + 10 sub-components)
- Capture: 6 files
- Library + Locker: 11 files
- Profile: 4 files
- Feed: 5 files
- Commerce: 9 files
- Settings: 2 files
- Errors: 11 files (9 variant views + 2 shared)
- Persistence: 5 files
- Permissions: 3 files
- Analytics: 3 files
- Utilities: 5 files
- Resources: ~50 asset files
- Tests: ~25 test files
- UI Tests: ~10 test files

**Total Swift source files ≈ 145.** Resource assets ~50. ~75 Codex tickets to build all of this.

## Conventions

- **One type per file.** No file holds two top-level structs/classes.
- **File name matches the type name.** `MirrorView.swift` contains `struct MirrorView`. Helper types used only inside one screen go in the same file as that screen if <50 lines, otherwise their own file.
- **No `final class` for value-type-able things.** Use `struct` everywhere except where reference semantics or `@Observable` is required.
- **`@Observable` for view models.** No `ObservableObject`.
- **Access control:** `internal` (default) for cross-feature shared types; `private` for view-internal; `public` only on the top-level app target if we ever extract a framework (we don't, in v1).
- **No third-party imports** outside `DeepAR` and `SwiftLint`.
- **Imports in alphabetical order at top of each file.** Lint-enforced.
- **`// MARK: - Section` headers** in every file with more than one logical section.
- **No abbreviations in identifiers.** `viewModel` not `vm`. `controller` not `ctrl`. Exception: `id`, `url`, `ar`, `sdk`.
