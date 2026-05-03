# 04 — Architecture

Reference document. Codex prompts cite specific subsections; come here to refresh context.

---

## 1. Stack

| Layer | Choice | Why |
|-------|--------|-----|
| Language | Swift 5.10+ (Swift 6 strict concurrency where stable) | Modern, statically typed, first-class on Apple platforms |
| UI framework | SwiftUI primary; UIKit `UIViewRepresentable` for the DeepAR `ARView` only | Fastest path on iOS 17+; keeps imperative camera code firewalled |
| State | `@Observable` (Observation framework, iOS 17+) | Better perf and ergonomics than `ObservableObject` |
| Concurrency | Swift Concurrency (`async`/`await`, `Task`, actors) | No Combine for new code; `@MainActor` on view models |
| Persistence | SwiftData | First-class iOS 17 ORM; lighter than Core Data; on-device only |
| Networking | `URLSession` + `Codable` | No Alamofire — too thin a need to justify a dep |
| Media | AVFoundation (read), DeepAR's built-in recording (write) | DeepAR captures the rendered output natively |
| IAP | StoreKit 2 (`Product.products(for:)`, `Transaction.updates`) | Modern API; no third-party receipt validators in MVP |
| Logging | OSLog with subsystem categories | Console.app filtering, no third-party crash reporter in MVP |
| DI | Plain Swift — `AppEnvironment` struct passed via `@Environment` | No Swinject/Resolver — over-engineering for this size |
| Testing | XCTest + Swift Testing where stable | Apple-native, zero deps |
| Linting | SwiftLint (strict) | Enforces conventions and catches force-unwraps |
| CI | GitHub Actions on macOS-15 runners | Free for private repos up to a quota; or migrate to Xcode Cloud later |

---

## 2. Module map

The single-target Xcode project organizes by **feature folder**, not by layer. See 02-FILE-STRUCTURE.md for the exhaustive list. The folders are:

`App` → `DesignSystem` → `DeepAR` → feature folders (`Onboarding`, `Mirror`, `Capture`, `Library`, `Locker`, `Profile`, `Feed`, `Commerce`, `Settings`, `Errors`) → infrastructure (`Persistence`, `Permissions`, `Analytics`, `Utilities`) → `Resources`.

**Dependency rules:**

- `App` depends on everything (it's the composition root)
- `DesignSystem` depends only on Foundation, SwiftUI, UIKit (for haptics/sounds)
- `DeepAR/` is the only folder that imports `DeepAR`
- Feature folders may depend on `DesignSystem`, `DeepAR/` (the wrapper), and infrastructure
- Feature folders **do not** depend on each other except via `App`/`AppEnvironment`
- Infrastructure (`Persistence`, `Permissions`, etc.) depends only on Foundation/system frameworks
- A build-phase script (`Scripts/verify-deepar-isolation.sh`) fails the build if `import DeepAR` appears outside `GRWMStudio/DeepAR/`

If a feature needs to use another feature's data, it goes through `AppEnvironment`. That's the only cross-feature seam.

---

## 3. State management

### 3.1 ViewModels

Each non-trivial screen has a sibling `*ViewModel.swift`. Pattern:

```swift
@MainActor @Observable
final class MirrorViewModel {
    // Input state (user-driven)
    var selectedCategory: MakeupCategory = .skin
    var selectedShade: [MakeupCategory: MakeupShade.ID] = [:]
    var beforeAfterPosition: Double = 0.5

    // Derived state
    var isRecording: Bool = false
    var recordingDuration: TimeInterval = 0
    var faceTracked: Bool = true
    var hasUnsavedChanges: Bool = false

    // Dependencies
    private let deepAR: DeepARController
    private let captures: CaptureService
    private let entitlement: ProEntitlement
    private let analytics: any AnalyticsService

    init(deepAR: DeepARController, captures: CaptureService, entitlement: ProEntitlement, analytics: any AnalyticsService) {
        self.deepAR = deepAR
        self.captures = captures
        self.entitlement = entitlement
        self.analytics = analytics
    }

    // Inputs
    func selectCategory(_ category: MakeupCategory) async { /* ... */ }
    func selectShade(_ shade: MakeupShade, in category: MakeupCategory) async { /* ... */ }
    func startRecording() async throws { /* ... */ }
    func stopRecording() async throws { /* ... */ }
}
```

The View is a thin shell over the VM:

```swift
struct MirrorView: View {
    @State private var viewModel: MirrorViewModel
    init(env: AppEnvironment) {
        _viewModel = State(initialValue: MirrorViewModel(
            deepAR: env.deepAR, captures: env.captures,
            entitlement: env.proEntitlement, analytics: env.analytics
        ))
    }
    var body: some View { /* ... */ }
}
```

### 3.2 Coordinator

`RootCoordinator` owns top-level navigation:

```swift
@MainActor @Observable
final class RootCoordinator {
    enum Route: Hashable {
        case onboardingSplash
        case onboardingWelcome
        case onboardingParentInfo
        case onboardingPermissions
        case onboardingPermissionsDenied
        case app                          // tab bar shell
        case parentalGate(reason: GateReason)
        case paywall(source: PaywallSource)
        case error(ErrorVariant)
    }
    enum GateReason: Hashable { case paywall, externalLink(URL), deleteData }
    enum PaywallSource: Hashable { case proShade, lockerLimit, longRecording, settings }

    var route: Route = .onboardingSplash
    var presentedSheet: Sheet? = nil
    enum Sheet: Hashable { case shareCapture(URL), looksDetail(EffectFile.ID) }

    // ... transition methods (advanceFromSplash(), completeOnboarding(), etc.)
}
```

The `RootContainer` View switches on `coordinator.route` and renders the right top-level screen. Sheets are presented via `.sheet(item:)`.

For navigation **inside** a tab (e.g., Looks Library → Look Detail), each tab uses its own `NavigationStack` with a tab-local path. We don't put sub-tab nav into the coordinator — keeps the coordinator small.

### 3.3 Why no Redux / TCA / Verse

- App is small enough that `@Observable` covers it.
- Kids-category review is faster with fewer dependencies.
- Onboarding new engineers is faster.
- We can refactor to TCA in v2 if state grows out of hand.

---

## 4. Concurrency model

### 4.1 Actor isolation

- All view models: `@MainActor`
- `DeepARController`: `@MainActor` (the SDK requires main thread for most calls)
- `CaptureService`: not `@MainActor` — file IO runs in background tasks
- `FeedService`: not `@MainActor` — networking off-main
- `PermissionsService`: not `@MainActor` — system frameworks marshal as needed
- `StoreKitService`: not `@MainActor` — `Transaction.updates` AsyncStream runs in its own `Task`
- `EffectCatalog`: a value-type struct; no actor needed

### 4.2 Long-running tasks

Started in `RootCoordinator.init()`:

```swift
@MainActor
final class RootCoordinator {
    private var transactionListenerTask: Task<Void, Never>?

    init(env: AppEnvironment) {
        transactionListenerTask = Task { [storeKit = env.storeKit] in
            for await transaction in storeKit.transactionUpdates {
                await env.proEntitlement.handle(transaction)
            }
        }
    }
    deinit { transactionListenerTask?.cancel() }
}
```

### 4.3 Timeouts

Every async operation that touches the SDK or the network uses `withTimeout` (in `Utilities/Concurrency+Extensions.swift`):

```swift
func withTimeout<T>(_ duration: Duration, operation: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(for: duration)
            throw TimeoutError()
        }
        defer { group.cancelAll() }
        return try await group.next()!
    }
}
struct TimeoutError: Error {}
```

Default timeouts:

- DeepAR `bootstrap`: 8s
- DeepAR `switchEffect`: 4s
- DeepAR `changeParameter`: 1s (these should be near-instant)
- Photo capture: 4s
- Feed JSON fetch: 6s
- StoreKit product fetch: 10s

---

## 5. Persistence

### 5.1 SwiftData container

```swift
@MainActor
enum AppModelContainer {
    static let schema = Schema([
        SavedCapture.self,
        ProfileRecord.self,
        FavoriteLook.self,
    ])

    static let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        cloudKitDatabase: .none      // local-only; no iCloud sync in v1
    )

    static let container: ModelContainer = {
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
```

Inject via `.modelContainer(AppModelContainer.container)` on the root scene.

### 5.2 Models

```swift
@Model
final class SavedCapture {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var mediaPath: String          // relative to Documents/captures/
    var kindRaw: String            // "photo" or "video"
    var appliedLookID: String?     // nil if used per-category shades only
    var appliedShadesJSON: String  // [String: String] encoded — categoryID → shadeID
    var name: String
    var hearts: Int

    init(id: UUID = .init(), createdAt: Date = .now, mediaPath: String, kindRaw: String,
         appliedLookID: String? = nil, appliedShadesJSON: String = "{}", name: String, hearts: Int = 0) {
        self.id = id
        self.createdAt = createdAt
        self.mediaPath = mediaPath
        self.kindRaw = kindRaw
        self.appliedLookID = appliedLookID
        self.appliedShadesJSON = appliedShadesJSON
        self.name = name
        self.hearts = hearts
    }

    var kind: Kind { Kind(rawValue: kindRaw) ?? .photo }
    enum Kind: String { case photo, video }
}

@Model
final class ProfileRecord {
    @Attribute(.unique) var id: UUID = UUID()  // singleton — only one row exists
    var displayName: String
    var avatarKey: String                       // e.g. "avatar_07"
    var proSince: Date?
    var proExpires: Date?
    var streakDays: Int
    var lifetimeHearts: Int
    var parentEmailHashed: String?              // SHA256 of parent email — never raw, never transmitted in v1
    var createdAt: Date

    init(displayName: String = "Star",
         avatarKey: String = "avatar_01",
         createdAt: Date = .now) {
        self.displayName = displayName
        self.avatarKey = avatarKey
        self.streakDays = 0
        self.lifetimeHearts = 0
        self.createdAt = createdAt
    }
}

@Model
final class FavoriteLook {
    @Attribute(.unique) var lookID: String
    var favoritedAt: Date

    init(lookID: String, favoritedAt: Date = .now) {
        self.lookID = lookID
        self.favoritedAt = favoritedAt
    }
}
```

### 5.3 Capture file storage

Photos and videos are written to `~/Documents/captures/` with file names `<UUID>.jpg` or `<UUID>.mp4`. The SwiftData record stores only the relative path so that iCloud Drive backups + iOS device migrations keep the references valid.

Daily cleanup pass: `CaptureService.reconcile()` runs on app launch and:
1. Walks `Documents/captures/`
2. Finds files without a matching `SavedCapture` record (orphans) — deletes them
3. Finds `SavedCapture` records without a file (broken refs) — deletes the records

### 5.4 Migrations

Define a versioned schema in `Persistence/PersistenceMigrations.swift`. We start at `Version 1`. Future migrations declare `MigrationStage.lightweight(...)` or `.custom(...)` between versions.

For v1, no migrations are needed. The harness exists so v1.1 can add a column without scrambling.

---

## 6. COPPA & privacy

### 6.1 What we do NOT do

- We do **not** transmit any personally identifiable information off the device.
- We do **not** request the user's birthdate. (Made-for-Kids categorization handles age targeting.)
- We do **not** ask for the user's real name. The display name on the profile defaults to "Star" and the user can change it to whatever — there's no validation that it matches a real name.
- We do **not** include any third-party SDK that does behavioral tracking, advertising, or analytics in v1.
- We do **not** support sign-in with Apple / Google / Facebook in v1.
- We do **not** show ads.
- We do **not** allow the user to add or chat with other users.
- We do **not** transmit camera frames anywhere — DeepAR's processing is fully on-device.

### 6.2 What we DO collect

| Data | Where it lives | Transmitted? |
|------|---------------|--------------|
| Display name (string) | SwiftData `ProfileRecord.displayName` | Never |
| Avatar key (string) | SwiftData `ProfileRecord.avatarKey` | Never |
| Saved photos/videos | `Documents/captures/` | Only when the user explicitly taps Share |
| Pro entitlement state | StoreKit 2 (Apple's servers, not ours) | No GRWM server involved |
| Parent email — SHA256 hash, optional | SwiftData `ProfileRecord.parentEmailHashed` | Never in v1 |

The "parent email" optionally collected on the Parent Info onboarding screen is hashed locally before storage. **In v1 it is never transmitted.** The reason it's collected at all is to set up future verifiable parental consent if v2 ever adds account features. If you're shipping the app in regions where collecting any email — even hashed, even local-only — requires explicit parental consent (e.g., strict GDPR-K interpretations), make the field truly optional and add a "Skip" button that's identical in size to the "Continue" button. Both options are designed (see `DHParentInfo`).

### 6.3 Privacy manifest (`PrivacyInfo.xcprivacy`)

Required by App Store as of 2024. Declared in ticket GRWM-902. Skeleton:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyTracking</key>
  <false/>
  <key>NSPrivacyCollectedDataTypes</key>
  <array>
    <!-- We collect a display name (NSPrivacyCollectedDataTypeUserID, optional) and avatar choice -->
    <!-- Both are local-only and not linked to user identity; declare anyway: -->
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeOtherUserContent</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <false/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array><string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string></array>
    </dict>
  </array>
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>C617.1</string></array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryDiskSpace</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>E174.1</string></array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>CA92.1</string></array>
    </dict>
  </array>
  <key>NSPrivacyTrackingDomains</key>
  <array/>
</dict>
</plist>
```

DeepAR ships its own privacy manifest as part of the SDK; you don't restate its declarations.

### 6.4 App Store privacy questionnaire pre-fill

When submitting:

- Data collected: **No, we do not collect data from this app** *(if you decide not to count the local-only display name as "collected" — defensible since it's not transmitted; check with App Review's current interpretation)*.
- Tracking: **No.**

If App Review pushes back on "we don't collect data," fall back to declaring the display name and avatar under "User Content" (linked: No, tracking: No, purpose: App Functionality only).

### 6.5 Parental gate triggers

Anything that takes the kid out of the app or costs money goes through the parental gate:

- Tap "Get Pro" / paywall presentation
- Any external link tap (Privacy Policy, Terms, Support)
- Settings → Restore Purchases
- Settings → Delete My Data
- Sharing a capture (the share sheet itself isn't gated — Apple's share sheet handles its own confirmations — but the prompt that confirms "are you sure?" before the share sheet opens is parental-gate-style)

The gate is a math problem (single-digit addition, e.g., "What is 7 + 5?") with text input. If the kid can do single-digit addition, that's our signal a parent is probably present (or the kid is 8+). Three wrong answers in a row → 30-second cooldown. The press-and-hold fallback exists for accessibility and for parents whose kids would happily solve the math.

---

## 7. Networking

Minimal. Only two network surfaces:

### 7.1 StoreKit 2 (talks to Apple, no custom networking)

Wrapped in `Commerce/StoreKitService.swift`.

### 7.2 Feed JSON

```swift
struct FeedItem: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let publishedAt: Date
    let imageURL: URL?       // nil falls back to a per-category gradient
    let lookID: String?      // optional; tapping links to Looks Library if present
    let kind: Kind
    enum Kind: String, Codable { case look, tip, tutorial }
    let videoURL: URL?       // for kind == .tutorial
}

actor FeedService {
    private let session: URLSession
    private let remoteURL: URL
    private let bundledFallbackURL: URL

    func fetchFeed() async -> [FeedItem] {
        do {
            let (data, _) = try await session.data(from: remoteURL)
            return try JSONDecoder.feedDecoder.decode([FeedItem].self, from: data)
        } catch {
            // Fall back to bundled JSON
            guard let data = try? Data(contentsOf: bundledFallbackURL) else { return [] }
            return (try? JSONDecoder.feedDecoder.decode([FeedItem].self, from: data)) ?? []
        }
    }
}
```

The remote URL is a static CDN-hosted JSON file. **No analytics. No user identifiers in the request.** Just a plain GET. Cache for 1 hour via `URLCache`.

The bundled fallback (`Resources/Feed.bundled.json`) ships with the app and contains 5–10 items so the Feed is never empty even on first launch with no network.

---

## 8. Error handling

Every error reaches the user via one of the 9 designed `DHError` variants. The mapping is centralized in `Errors/ErrorVariant.swift`:

```swift
enum ErrorVariant: Equatable, Hashable {
    case camDenied
    case micDenied
    case photoDenied
    case license
    case effectFail(detail: String)
    case recFail(detail: String)
    case saveFail(detail: String)
    case noFace
    case lowStorage(freeMB: Int)
}

extension ErrorVariant {
    /// Headline shown on the error screen.
    var headline: String { /* ... */ }
    /// Body copy.
    var body: String { /* ... */ }
    /// Primary CTA label.
    var primaryCTA: String { /* ... */ }
    /// Secondary CTA label, if any.
    var secondaryCTA: String? { /* ... */ }
    /// Hero illustration / icon variant for DHError to render.
    var illustration: ErrorIllustration { /* ... */ }
}
```

All exact copy lives in `10-APPENDICES.md §B`. Codex prompts for each error view reference that copy verbatim — no improvisation.

Errors are presented two ways:

- **Full-screen error view** (the `DHError` design) — for failure states that block the user from continuing (camera denied, license invalid, low storage)
- **Inline toast or overlay** — for transient failures (one shade tap fails to apply, save flips back to the preview)

The 9 error views are all full-screen. Inline failures use a separate, lighter `DHToast` component (designed in the V01 mirror — the small "Showtime · 70%" pill is its visual relative).

---

## 9. Accessibility

### 9.1 VoiceOver

- Every interactive element has an `accessibilityLabel`. No exceptions.
- The mirror viewport has label "Live mirror with face tracking. Currently showing: \(activeLayers description)."
- Sticker decoration views are `.accessibilityHidden(true)`.
- The category chip bar uses `.accessibilityElement(children: .contain)` and announces position ("Skin, 1 of 7").
- Shade swatches announce "\(shadeName), \(category) shade" plus state "Selected" or "Pro — locked" when applicable.
- The big record button: "Record video. Double-tap to start."
- All errors announce headline + body on appearance.

### 9.2 Dynamic Type

- All body and caption text scales up to AX2.
- The chunky chip text caps at `xxLarge` because the chips visibly distort beyond that.
- Headlines use `.dynamicTypeSize(...DynamicTypeSize.accessibility2)` to limit upper bound.
- Layout adapts: when text grows, secondary actions can collapse into menus.

### 9.3 Reduce Motion

- The `FaceTrackingDots` pulse animation freezes at full opacity.
- Sticker bobbing animations halt.
- Splash progress bar still animates (it's progress, not decoration).
- Countdown still animates (it's information).

### 9.4 Reduce Transparency

The frosted glass overlays in the design (e.g., the audio level pill in the recording UI) become solid white when Reduce Transparency is on.

### 9.5 Color contrast

WCAG AA minimum. The pink-on-pink combinations in the design fail in places — the engineer adjusts to deeper pink (`DH.pinkDeep`) on text, never lighter. Run an audit pass in Phase 8 (ticket GRWM-803).

---

## 10. Logging

```swift
import OSLog

extension Logger {
    static let app       = Logger(subsystem: "app.grwmstudio.ios", category: "app")
    static let deepAR    = Logger(subsystem: "app.grwmstudio.ios", category: "deepar")
    static let mirror    = Logger(subsystem: "app.grwmstudio.ios", category: "mirror")
    static let capture   = Logger(subsystem: "app.grwmstudio.ios", category: "capture")
    static let storeKit  = Logger(subsystem: "app.grwmstudio.ios", category: "storekit")
    static let perms     = Logger(subsystem: "app.grwmstudio.ios", category: "permissions")
    static let persist   = Logger(subsystem: "app.grwmstudio.ios", category: "persistence")
    static let feed      = Logger(subsystem: "app.grwmstudio.ios", category: "feed")
}
```

Use `.debug`, `.info`, `.error`, `.fault` levels. Never log PII (display name is the borderline case — log only on `.debug`).

In Console.app, filter by `subsystem:app.grwmstudio.ios` to see only our logs.

No third-party crash reporter in v1. App Store Connect's Crashes pane and Xcode Organizer give us crash logs from production.

---

## 11. Build configuration

| Setting | Debug | Release |
|---------|-------|---------|
| `SWIFT_OPTIMIZATION_LEVEL` | `-Onone` | `-O` |
| `GCC_PREPROCESSOR_DEFINITIONS` | `DEBUG=1` | (none) |
| `SWIFT_TREAT_WARNINGS_AS_ERRORS` | `NO` | `YES` (after Phase 8) |
| `ENABLE_BITCODE` | `NO` | `NO` (Apple deprecated bitcode) |
| `IPHONEOS_DEPLOYMENT_TARGET` | `17.0` | `17.0` |
| `TARGETED_DEVICE_FAMILY` | `1` (iPhone) | `1` |
| Code signing | Automatic | Manual (via fastlane match) |

Per-feature compile-time flags (defined in `Debug.xcconfig` only):

- `GRWM_DEBUG_MENU` — enables the long-press-on-logo debug menu
- `GRWM_MOCK_STOREKIT` — uses the local StoreKit configuration file
- `GRWM_SKIP_ONBOARDING` — boots straight into the app (for fast dev iteration)

These are read in code via `#if DEBUG && canImport(Foundation)` and `ProcessInfo.processInfo.arguments.contains(...)` for UI test launch arguments.
