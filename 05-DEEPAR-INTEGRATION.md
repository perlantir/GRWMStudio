# 05 — DeepAR Integration

The most important file in this package after the prompt library. Get this right and the rest is plumbing. Get it wrong and you'll be debugging "why doesn't my lipstick change color" for weeks.

Source-of-truth docs (verified):

- Overview: `https://docs.deepar.ai/deepar-sdk/platforms/ios/overview`
- Getting started: `https://docs.deepar.ai/deepar-sdk/platforms/ios/getting-started`
- Runtime parameter API: `https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter`
- Free filter pack: shipped, located at `GRWMStudio/Resources/Effects/_source/Free.v1.3/`

---

## 1. SDK installation

**Choice: Swift Package Manager.**

```
URL:    https://github.com/DeepARSDK/swift-deepar
Rule:   "Up to Next Major Version" from latest tag at time of install
Linked: GRWMStudio target only (NOT test targets — DeepAR isn't a runtime dep of tests)
```

Backup options if SwiftPM has issues:

- CocoaPods: `pod 'DeepAR'` (run `pod install --repo-update` if it fails first time)
- Direct XCFramework download from `https://developer.deepar.ai/downloads`

All three deliver the same XCFramework binary.

### 1.1 License key

Per the docs, the bootstrap requires:

```swift
let deepAR = DeepAR()
deepAR.setLicenseKey("your_license_key_here")
```

The key is bound to the bundle ID (`app.grwmstudio.ios`) registered in the developer portal (see COMMANDS §2).

**Storage:** in `Config/Secrets.xcconfig` (gitignored), surfaced into Info.plist via `$(DEEPAR_LICENSE_KEY)`, read at runtime:

```swift
guard let key = Bundle.main.object(forInfoDictionaryKey: "DeepARLicenseKey") as? String,
      !key.isEmpty else {
    throw DeepARController.SetupError.missingLicenseKey
}
```

If the key is missing or wrong, `setLicenseKey` doesn't throw immediately — instead the SDK fails later. The `didInitialize` delegate either never fires or `recordingFailedWithError` fires. We handle both via the 8-second bootstrap timeout. License-related failures map to `ErrorVariant.license`.

### 1.2 Required Info.plist entries

Per the iOS getting-started docs:

```xml
<key>NSCameraUsageDescription</key>
<string>GRWM Studio uses your camera to show you the magic mirror.</string>

<key>NSMicrophoneUsageDescription</key>
<string>GRWM Studio records sound when you make a video so you can talk and sing along!</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>GRWM Studio adds saved looks to Photos only when you tap Save.</string>

<key>DeepARLicenseKey</key>
<string>$(DEEPAR_LICENSE_KEY)</string>
```

We do NOT include `NSPhotoLibraryUsageDescription` (read access). We only write captures to the library, never read user content from it.

---

## 2. The wrapper layer

**Constraint: only `GRWMStudio/DeepAR/*.swift` files import `DeepAR`.** Enforced by `Scripts/verify-deepar-isolation.sh` as a build phase.

### 2.1 Public surface (Swift-native, no DeepAR types leak)

```swift
@MainActor @Observable
public final class DeepARController {
    public enum State: Equatable {
        case uninitialized
        case initializing
        case ready
        case failed(reason: String)
    }
    public enum SetupError: LocalizedError {
        case missingLicenseKey, sdkInitTimeout, alreadyInitialized,
             effectLoadFailed(slot: EffectSlot, reason: String),
             recordingFailed(reason: String),
             captureFailed(reason: String)
    }

    // Observable state
    public private(set) var state: State = .uninitialized
    public private(set) var trackedFace: Bool = false
    public private(set) var loadedEffects: [EffectSlot: EffectFile.ID] = [:]
    public private(set) var isRecordingVideo: Bool = false
    public private(set) var recordingDuration: TimeInterval = 0

    // SwiftUI hosts this
    public var arView: UIView? { /* internal */ }

    // Lifecycle
    public func bootstrap(licenseKey: String) async throws
    public func startCamera(includeAudio: Bool) async throws
    public func stopCamera() async
    public func switchCamera(toFront: Bool) async throws

    // Effects
    public func loadEffect(_ effect: EffectFile, slot: EffectSlot) async throws
    public func clearEffect(slot: EffectSlot) async
    public func clearAllEffects() async

    // Runtime parameter changes
    public func setColor(_ color: UIColor, on parameter: EffectParameter) async
    public func setTexture(_ image: UIImage, on parameter: EffectParameter) async
    public func setBlendshape(_ value: Float, on parameter: EffectParameter) async
    public func setEnabled(_ enabled: Bool, on parameter: EffectParameter) async

    // Capture
    public func capturePhoto() async throws -> URL
    public func startVideoRecording(maxDuration: TimeInterval) async throws
    public func stopVideoRecording() async throws -> URL
}
```

### 2.2 The bootstrap sequence

Per the docs, the order is:

```
1. var deepAR = DeepAR()
2. deepAR.setLicenseKey("...")
3. deepAR.delegate = ... 
4. var cameraController = CameraController(deepAR: deepAR)
5. let arView = self.deepAR.createARView(withFrame: ...)
6. cameraController.startCamera(withAudio: true)
7. Wait for didInitialize delegate to fire
```

We split this:

- `bootstrap(licenseKey:)` does steps 1–3 and step 5, awaits step 7 via a continuation
- `startCamera(includeAudio:)` does steps 4 and 6

This separation lets the SwiftUI `DeepARView` begin showing the placeholder skeleton while bootstrap runs, then mount the real `arView` once `state == .ready`.

### 2.3 The delegate proxy

DeepAR's delegate is an Obj-C protocol. We bridge it to Swift via a private proxy:

```swift
final class DeepARDelegateProxy: NSObject, DeepARDelegate {
    weak var controller: DeepARController?
    init(controller: DeepARController) { self.controller = controller }

    // didInitialize → resume bootstrap continuation, set state = .ready
    func didInitialize() { /* hop to MainActor, update state */ }

    // faceVisiblityDidChange (sic — DeepAR's spelling) → trackedFace
    func faceVisiblityDidChange(_ faceVisible: Bool) { /* ... */ }

    // didStartVideoRecording → controller.isRecordingVideo = true
    func didStartVideoRecording() { /* ... */ }

    // didFinishVideoRecording(_:) → resume video continuation with the file path
    func didFinishVideoRecording(_ videoFilePath: String) { /* ... */ }

    // recordingFailedWithError(_:) → reject continuation
    func recordingFailedWithError(_ error: Error) { /* ... */ }

    // didTakeScreenshot(_:) → write to file, resume photo continuation
    func didTakeScreenshot(_ screenshot: UIImage) { /* ... */ }

    // ... implement every method DeepARDelegate declares as no-op or forwarding
}
```

**Important:** the exact method signatures for `DeepARDelegate` are version-dependent. When implementing `DeepAR/DeepARDelegateProxy.swift`, let Xcode autocomplete drive the protocol conformance — don't paste signatures from the docs without verifying. Codex prompts (GRWM-101, GRWM-103, GRWM-110) tell Codex to do this verification.

### 2.4 Slot model

DeepAR supports multiple simultaneous effects, each in a named slot. We use **one slot per category**:

```swift
public enum EffectSlot: String, CaseIterable, Sendable {
    case skin   = "slot_skin"     // baseBeauty foundation/smoothing
    case base   = "slot_base"     // LUT / color correction
    case eyes   = "slot_eyes"     // eyeshadow + eyeliner + lashes
    case brows  = "slot_brows"
    case cheeks = "slot_cheeks"
    case lips   = "slot_lips"
    case looks  = "slot_looks"    // full preset look — overrides per-category slots
}
```

**Layering rule:**

- When the user uses the per-category Mirror flow, slots `skin/base/eyes/brows/cheeks/lips` may all be loaded; `looks` is empty.
- When the user taps a preset Look in the Looks Library, we **clear all per-category slots** and load the preset into `looks`. This avoids stacking conflicts (a preset Look already has its own lipstick baked in, so an extra Lips slot would double up).
- When the user goes back to per-category editing after applying a preset, we clear `looks` and the per-category slots become editable again.

This rule lives in `MirrorViewModel.applyLook(_:)` and `MirrorViewModel.clearAppliedLook()`.

### 2.5 Why one base effect file plus runtime parameters (not 50 separate effects)

The naive design: ship 50 `.deepar` files, one per "Pink lipstick", "Red lipstick", "Smokey eye in green", etc. Then `switchEffect` for each tap.

**Bad idea.** Reasons:

- Bundle bloat (each `.deepar` is 100KB–500KB+)
- Effect-load latency on every tap (~50–200ms — visibly laggy)
- Studio asset explosion (artist makes 50 files instead of 1 + parameter table)
- Memory pressure with 7 effects loaded at once

**Better:** one `baseBeauty.deepar` per category with parameterized materials, plus a small set of complete preset Looks. Tap → `changeParameter` → instant.

Per the docs, `changeParameter` supports four parameter types relevant to us:

| Parameter type | DeepAR call | Use case |
|----------------|------------|---------|
| Color (Vector4 RGBA, 0–1) | `changeParameter(_:component:parameter:vectorValue:)` | Lipstick color, eyeshadow color, blush color, brow tint |
| Texture (UIImage) | `changeParameter(_:component:parameter:image:)` | Foundation alpha mask, eyeliner shape swap, brow shape swap |
| Float (blendshape weight) | `changeParameter(_:component:parameter:floatValue:)` | If we ever add face-morph fun (e.g., "puff cheeks") |
| Bool (enabled) | `changeParameter(_:component:parameter:boolValue:)` with `parameter = "enabled"` | Toggle eyelashes on/off, toggle blush on/off |

The fifth parameter type, Vector3 (position/rotation/scale), we don't use in v1 — makeup doesn't move 3D objects.

---

## 3. The effect manifest

**File:** `GRWMStudio/Resources/Effects/manifest.json`

This is the **single source of truth** for what effects ship with the app. To add a new effect (when the larger filter pack arrives), the engineer adds the file + a manifest entry. **No code changes.**

### 3.1 Schema

```json
{
  "version": 1,
  "effects": {
    "skin": [
      {
        "id": "baseBeauty",
        "displayName": "Base Beauty",
        "file": "baseBeauty.deepar",
        "thumbnail": "thumbnails/baseBeauty.png",
        "isPro": false,
        "shades": [
          { "id": "fair",   "displayName": "Fair",   "color": "#FFE6D5", "isPro": false,
            "parameters": [
              { "kind": "color", "ref": "foundationColor", "rgba": [1.0, 0.902, 0.836, 0.7] }
            ]
          },
          { "id": "medium", "displayName": "Medium", "color": "#E8B89A", "isPro": false,
            "parameters": [
              { "kind": "color", "ref": "foundationColor", "rgba": [0.91, 0.722, 0.604, 0.7] }
            ]
          }
        ]
      }
    ],
    "base": [
      {
        "id": "noFilter",
        "displayName": "Au Naturel",
        "file": "baseBeauty.deepar",
        "thumbnail": "thumbnails/noFilter.png",
        "isPro": false,
        "shades": [
          { "id": "off",    "displayName": "Off",    "color": "#FFFFFF",
            "parameters": [{ "kind": "bool", "ref": "lutEnabled", "value": false }] },
          { "id": "bright", "displayName": "Bright", "color": "#FFE6F0",
            "parameters": [
              { "kind": "bool",    "ref": "lutEnabled", "value": true },
              { "kind": "texture", "ref": "lutTexture", "asset": "brightLUT" }
            ]
          }
        ]
      }
    ],
    "eyes":   [ /* eyeshadow styles, eyeliner styles, lash styles — each as an "effect" with shades */ ],
    "brows":  [ /* brow shape variants */ ],
    "cheeks": [ /* blush styles */ ],
    "lips":   [ /* lipstick finishes (matte, gloss, ombre) each with color shades */ ],
    "looks":  [
      {
        "id": "bubblegumPop",
        "displayName": "Bubblegum Pop",
        "file": "look_bubblegumPop.deepar",
        "thumbnail": "thumbnails/bubblegumPop.png",
        "tag": "CUTE",
        "hot": true,
        "isPro": false,
        "shades": []
      },
      {
        "id": "discoBrat",
        "displayName": "Disco Brat",
        "file": "look_discoBrat.deepar",
        "thumbnail": "thumbnails/discoBrat.png",
        "tag": "BOLD",
        "hot": true,
        "isPro": true,
        "shades": []
      }
    ]
  }
}
```

### 3.2 Parameter "ref" values

`ref` is a key into `EffectParameterMap.swift` — a Swift enum that maps `ref` → the actual DeepAR `(nodeName, component, parameter)` triple. This indirection means:

- Designers/PMs can edit `manifest.json` without knowing DeepAR's internal node names
- If a Studio-side rename happens (e.g., `lipsMesh` → `lipsTrackingMesh`), one file changes (`EffectParameterMap.swift`), the manifest is untouched

### 3.3 Pro shades

`isPro: true` flags a shade as Studio Pro-locked. The shade still appears in the row (with a lock pip icon — `ShadeProBadge.swift`), and tapping it without an entitlement triggers the `MirrorProGateOverlay` (screen 9).

When a Pro shade is selected and the user has an active subscription, it applies normally. The `ProEntitlement` check happens in `MirrorViewModel.selectShade(...)` before the `DeepARController.setColor(...)` call.

---

## 4. The parameter map

**File:** `GRWMStudio/DeepAR/EffectParameterMap.swift`

```swift
public struct EffectParameter: Equatable, Hashable, Sendable {
    public let nodeName: String      // exact name from .deeparproj hierarchy
    public let component: String     // "MeshRenderer" for color/texture; "" for transform; "" for enabled
    public let parameter: String     // shader uniform name (e.g., "u_color", "s_texColor") or "enabled"
}

public enum EffectParameterMap {
    // -- Skin (foundation) --
    public static let foundationColor = EffectParameter(
        nodeName: "faceMesh",       component: "MeshRenderer", parameter: "u_color"
    )
    public static let foundationMask = EffectParameter(
        nodeName: "faceMesh",       component: "MeshRenderer", parameter: "s_texMask"
    )

    // -- Base (LUT) --
    public static let lutEnabled = EffectParameter(
        nodeName: "lutPostprocess", component: "",             parameter: "enabled"
    )
    public static let lutTexture = EffectParameter(
        nodeName: "lutPostprocess", component: "MeshRenderer", parameter: "s_texLut"
    )

    // -- Eyes --
    public static let eyeshadowColor   = EffectParameter(nodeName: "eyeshadowMesh", component: "MeshRenderer", parameter: "u_color")
    public static let eyeshadowMask    = EffectParameter(nodeName: "eyeshadowMesh", component: "MeshRenderer", parameter: "s_texMask")
    public static let eyelinerTexture  = EffectParameter(nodeName: "eyelinerMesh",  component: "MeshRenderer", parameter: "s_texColor")
    public static let eyelinerEnabled  = EffectParameter(nodeName: "eyelinerMesh",  component: "",             parameter: "enabled")
    public static let eyelashesTexture = EffectParameter(nodeName: "eyelashesMesh", component: "MeshRenderer", parameter: "s_texColor")
    public static let eyelashesEnabled = EffectParameter(nodeName: "eyelashesMesh", component: "",             parameter: "enabled")

    // -- Brows --
    public static let browColor   = EffectParameter(nodeName: "browMesh", component: "MeshRenderer", parameter: "u_color")
    public static let browTexture = EffectParameter(nodeName: "browMesh", component: "MeshRenderer", parameter: "s_texColor")
    public static let browEnabled = EffectParameter(nodeName: "browMesh", component: "",             parameter: "enabled")

    // -- Cheeks --
    public static let blushColor   = EffectParameter(nodeName: "blushMesh", component: "MeshRenderer", parameter: "u_color")
    public static let blushMask    = EffectParameter(nodeName: "blushMesh", component: "MeshRenderer", parameter: "s_texMask")
    public static let blushEnabled = EffectParameter(nodeName: "blushMesh", component: "",             parameter: "enabled")

    // -- Lips --
    public static let lipsColor   = EffectParameter(nodeName: "lipsMesh", component: "MeshRenderer", parameter: "u_color")
    public static let lipsTexture = EffectParameter(nodeName: "lipsMesh", component: "MeshRenderer", parameter: "s_texColor")
    public static let lipsEnabled = EffectParameter(nodeName: "lipsMesh", component: "",             parameter: "enabled")

    /// Resolves a manifest "ref" to an EffectParameter. Codex extends this dictionary as new
    /// refs are added in the manifest.
    public static func resolve(_ ref: String) -> EffectParameter? {
        let map: [String: EffectParameter] = [
            "foundationColor":    foundationColor,
            "foundationMask":     foundationMask,
            "lutEnabled":         lutEnabled,
            "lutTexture":         lutTexture,
            "eyeshadowColor":     eyeshadowColor,
            "eyeshadowMask":      eyeshadowMask,
            "eyelinerTexture":    eyelinerTexture,
            "eyelinerEnabled":    eyelinerEnabled,
            "eyelashesTexture":   eyelashesTexture,
            "eyelashesEnabled":   eyelashesEnabled,
            "browColor":          browColor,
            "browTexture":        browTexture,
            "browEnabled":        browEnabled,
            "blushColor":         blushColor,
            "blushMask":          blushMask,
            "blushEnabled":       blushEnabled,
            "lipsColor":          lipsColor,
            "lipsTexture":        lipsTexture,
            "lipsEnabled":        lipsEnabled,
        ]
        return map[ref]
    }
}
```

### 4.1 Where the actual node names come from

**Critical:** every `nodeName` in the map above is a placeholder until verified against the real `.deeparproj` files.

The **actual** names live in:
- `GRWMStudio/Resources/Effects/_source/Free.v1.3/baseBeauty.deeparproj/effect.json` — every node and material in the project
- The Studio project hierarchy — open in DeepAR Studio to inspect
- For any custom shaders, `http://sdk.developer.deepar.ai/examples/shaders.zip` — each shader folder contains a JSON with the uniform names

**Process for filling the map** (ticket GRWM-105 owns this):

1. Open `effect.json` (it's plain JSON):
   ```bash
   jq '.[] | select(.type == "Node") | .name' \
     GRWMStudio/Resources/Effects/_source/Free.v1.3/baseBeauty.deeparproj/effect.json
   ```
2. List every node in the hierarchy. Match expected slots (face mesh, eye mesh, lips mesh, etc.).
3. For each material, find the shader. Look up the uniform names in the shader bundle. The free pack uses standard shaders: `Unlit Texture & Color`, `Unlit Color`, `Unlit Texture`, `Beauty`. Their uniforms:
   - `u_color` (Vector4) — RGBA tint
   - `s_texColor` (sampler2D) — diffuse texture
   - `s_texMask` (sampler2D) — alpha mask (for Beauty shader)
4. Update `EffectParameterMap.swift` with the verified names.
5. Run `xcodebuild test -only-testing:GRWMStudioTests/EffectParameterMapTests` — this test loads every shipped `.deepar`, attempts each parameter on each, and reports which combinations fail. (See `08-TESTING-PLAN.md §3.2`.)

When the larger filter pack arrives:

1. Inspect its `.deeparproj` files the same way
2. Add new constants to `EffectParameterMap` for any new node/parameter combinations
3. Update the `resolve(_:)` dictionary
4. Add manifest entries that reference the new `ref` strings
5. Run the tests

---

## 5. The catalog

**File:** `GRWMStudio/DeepAR/EffectCatalog.swift`

```swift
public actor EffectCatalog {
    public static let shared = EffectCatalog()
    private init() {}

    private var cache: ManifestRoot?

    public func load() async throws -> ManifestRoot {
        if let cache { return cache }
        guard let url = Bundle.main.url(forResource: "manifest", withExtension: "json", subdirectory: "Effects") else {
            throw CatalogError.manifestMissing
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(ManifestRoot.self, from: data)
        try decoded.validate()                  // throws if any parameter ref doesn't resolve
        cache = decoded
        return decoded
    }

    public func effects(for category: MakeupCategory) async throws -> [EffectFile] {
        try await load().effects[category.id] ?? []
    }

    public func effect(byID id: EffectFile.ID) async throws -> EffectFile? {
        for effects in try await load().effects.values {
            if let match = effects.first(where: { $0.id == id }) {
                return match
            }
        }
        return nil
    }
}

public struct ManifestRoot: Decodable, Sendable {
    public let version: Int
    public let effects: [String: [EffectFile]]   // key is MakeupCategory.id

    public func validate() throws {
        for (_, list) in effects {
            for effect in list {
                for shade in effect.shades {
                    for param in shade.parameters {
                        guard EffectParameterMap.resolve(param.ref) != nil else {
                            throw CatalogError.unresolvedParameterRef(param.ref)
                        }
                    }
                }
            }
        }
    }
}

public struct EffectFile: Decodable, Identifiable, Hashable, Sendable {
    public let id: String
    public let displayName: String
    public let file: String                  // relative to Resources/Effects/
    public let thumbnail: String             // relative to Resources/Effects/
    public let isPro: Bool
    public let shades: [MakeupShade]
    public let tag: String?                  // optional, for Looks
    public let hot: Bool?                    // optional, for Looks

    public func bundleURL() throws -> URL {
        let stem = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        guard let url = Bundle.main.url(forResource: stem, withExtension: ext, subdirectory: "Effects") else {
            throw CatalogError.fileMissing(file)
        }
        return url
    }
}

public struct MakeupShade: Decodable, Identifiable, Hashable, Sendable {
    public let id: String
    public let displayName: String
    public let color: String                 // hex
    public let isPro: Bool?
    public let parameters: [ParameterChange]

    public struct ParameterChange: Decodable, Hashable, Sendable {
        public enum Kind: String, Decodable, Sendable { case color, texture, blendshape, bool }
        public let kind: Kind
        public let ref: String
        public let rgba: [Double]?           // for kind == .color
        public let asset: String?            // for kind == .texture (asset catalog name)
        public let value: Double?            // for kind == .blendshape (Float) or .bool (treated as 0/1)
    }
}

public enum CatalogError: LocalizedError {
    case manifestMissing
    case fileMissing(String)
    case unresolvedParameterRef(String)
}
```

### 5.1 Wiring at app start

```swift
// In GRWMStudioApp.init() or the first Task on RootContainer.onAppear:
Task {
    do {
        _ = try await EffectCatalog.shared.load()
    } catch {
        Logger.deepAR.error("Catalog load failed: \(error.localizedDescription)")
        // Route to ErrorVariant.effectFail
    }
}
```

The catalog is loaded once at app launch. View models query it via `AppEnvironment.catalog`.

---

## 6. The MirrorViewModel flow

The hero flow lives in `MirrorViewModel`. Annotated end-to-end:

```swift
@MainActor @Observable
final class MirrorViewModel {
    var selectedCategory: MakeupCategory = .skin
    var activeShades: [MakeupCategory: MakeupShade.ID] = [:]
    var activeLook: EffectFile.ID? = nil
    var availableEffects: [MakeupCategory: [EffectFile]] = [:]   // populated from catalog

    private let deepAR: DeepARController
    private let catalog: EffectCatalog
    private let entitlement: ProEntitlement

    func selectCategory(_ category: MakeupCategory) async {
        selectedCategory = category
        if availableEffects[category] == nil {
            availableEffects[category] = (try? await catalog.effects(for: category)) ?? []
        }
    }

    func selectShade(_ shade: MakeupShade, in category: MakeupCategory) async {
        // 1. Check entitlement gate
        if shade.isPro == true, !entitlement.isPro {
            // Surface the Pro gate overlay; don't apply the shade
            // The View observes a separate `proGateForShade` state to drive the overlay
            return
        }

        // 2. If a preset Look is currently applied, clear it first
        if activeLook != nil {
            await clearAppliedLook()
        }

        // 3. Make sure the right effect file is loaded into this category's slot
        let effect = availableEffects[category]?.first { $0.shades.contains(shade) }
        guard let effect else { return }
        if loadedEffect(in: category.slot) != effect.id {
            try? await deepAR.loadEffect(effect, slot: category.slot)
        }

        // 4. Apply each parameter from the shade
        for change in shade.parameters {
            guard let param = EffectParameterMap.resolve(change.ref) else { continue }
            switch change.kind {
            case .color:
                guard let rgba = change.rgba, rgba.count == 4 else { break }
                let color = UIColor(red: CGFloat(rgba[0]), green: CGFloat(rgba[1]),
                                    blue: CGFloat(rgba[2]), alpha: CGFloat(rgba[3]))
                await deepAR.setColor(color, on: param)
            case .texture:
                guard let assetName = change.asset, let img = UIImage(named: assetName) else { break }
                await deepAR.setTexture(img, on: param)
            case .blendshape:
                guard let v = change.value else { break }
                await deepAR.setBlendshape(Float(v), on: param)
            case .bool:
                guard let v = change.value else { break }
                await deepAR.setEnabled(v >= 0.5, on: param)
            }
        }

        // 5. Persist the active shade so reopening the mirror keeps state
        activeShades[category] = shade.id
    }

    func applyLook(_ look: EffectFile) async throws {
        // 1. Clear all per-category slots
        for category in MakeupCategory.allCases where category != .looks {
            await deepAR.clearEffect(slot: category.slot)
        }
        // 2. Load the look into the .looks slot
        try await deepAR.loadEffect(look, slot: .looks)
        // 3. Update state
        activeLook = look.id
        activeShades = [:]
    }

    func clearAppliedLook() async {
        await deepAR.clearEffect(slot: .looks)
        activeLook = nil
    }
}
```

---

## 7. Recording

### 7.1 Photo capture

```swift
// In DeepARController:
public func capturePhoto() async throws -> URL {
    return try await withCheckedThrowingContinuation { cont in
        photoContinuation = cont
        deepAR?.takeScreenshot()    // delegate's didTakeScreenshot fires async
    }
}

// In DeepARDelegateProxy:
func didTakeScreenshot(_ screenshot: UIImage) {
    Task { @MainActor in
        guard let c = controller else { return }
        do {
            let url = try CaptureService.writeImage(screenshot)
            c.photoContinuation?.resume(returning: url)
        } catch {
            c.photoContinuation?.resume(throwing: error)
        }
        c.photoContinuation = nil
    }
}
```

### 7.2 Video capture

DeepAR's iOS SDK ships built-in video recording. Per the overview docs:

> Screenshot and video recording API is available out-of-the-box.

```swift
public func startVideoRecording(maxDuration: TimeInterval) async throws {
    guard !isRecordingVideo else { return }
    deepAR?.startVideoRecording(withOutputWidth: 720, outputHeight: 1280)
    // Wait for didStartVideoRecording delegate
    // ... auto-stop timer for maxDuration
    isRecordingVideo = true
    recordingStartedAt = Date()
}

public func stopVideoRecording() async throws -> URL {
    isRecordingVideo = false
    return try await withCheckedThrowingContinuation { cont in
        videoContinuation = cont
        deepAR?.finishVideoRecording()
    }
}

// In delegate:
func didFinishVideoRecording(_ videoFilePath: String) {
    let src = URL(fileURLWithPath: videoFilePath)
    let dst = CaptureService.documentsCapturesURL.appendingPathComponent("\(UUID()).mp4")
    try? FileManager.default.moveItem(at: src, to: dst)
    Task { @MainActor in
        controller?.videoContinuation?.resume(returning: dst)
        controller?.videoContinuation = nil
    }
}
```

**Note on exact API:** the method names and signatures (`startVideoRecording(withOutputWidth:outputHeight:)`, `finishVideoRecording()`, `takeScreenshot()`) are the canonical names per the SDK. Verify exact spelling via Xcode autocomplete when implementing — Codex prompts (GRWM-110, GRWM-111) include this verification step.

### 7.3 Free vs Pro recording duration

```swift
public extension MirrorViewModel {
    var maxRecordingDuration: TimeInterval {
        entitlement.isPro ? 300 : 30        // 5 minutes Pro / 30 seconds free
    }
}
```

When a free user holds the record button past 30s, the recording auto-stops and the preview screen shows the recorded clip. We don't surprise them with a "recording cut off" error — the recording UI shows a countdown ("0:14 left" pill, designed) so the truncation is expected.

---

## 8. Lifecycle (background/foreground)

```swift
// In RootContainer:
.onChange(of: scenePhase) { _, newPhase in
    Task {
        switch newPhase {
        case .background, .inactive:
            await env.deepAR.stopCamera()
        case .active:
            if env.deepAR.state == .ready {
                try? await env.deepAR.startCamera(includeAudio: true)
            }
        @unknown default: break
        }
    }
}
```

If a recording is in progress when the app backgrounds, we call `stopVideoRecording()` and save the partial clip. Don't try to keep recording in the background — DeepAR's pipeline assumes foreground.

---

## 9. Failure → error variant mapping

| DeepAR failure | UI variant | View file |
|---------------|-----------|----------|
| `setLicenseKey` rejected (8s timeout from `bootstrap`) | `.license` | `LicenseLockedView.swift` |
| `didInitialize` never fires (timeout) | `.license` (most likely cause) | same |
| `switchEffect` throws or times out | `.effectFail(detail:)` | `EffectFailedView.swift` |
| `startCamera` throws | `.camDenied` | `CamDeniedView.swift` |
| Permission system: camera denied | `.camDenied` | same |
| Permission system: mic denied (when starting video) | `.micDenied` | `MicDeniedView.swift` |
| Photo library write rejected | `.photoDenied` | `PhotosDeniedView.swift` |
| `recordingFailedWithError` | `.recFail(detail:)` | `RecordingFailedView.swift` |
| Photo capture continuation throws / file write fails | `.saveFail(detail:)` | `SaveFailedView.swift` |
| `faceVisiblityDidChange(false)` for >3s while in mirror | `.noFace` | `NoFaceView.swift` (overlay, not full screen) |
| Free disk <50MB OR Locker at limit | `.lowStorage(freeMB:)` | `LowStorageView.swift` |

The `noFace` variant is special: it's an overlay on the mirror, not a full-screen takeover. The user can keep adjusting the camera to bring their face into view without losing context.

---

## 10. Performance budget

Validate in Phase 8 (ticket GRWM-806) on iPhone 12 mini (lowest supported device).

| Metric | Target | How to measure |
|--------|--------|---------------|
| App launch to splash | <800ms cold | XCTest `launchPerformance` |
| Splash to Mirror first frame | <2s including DeepAR bootstrap | Instruments Time Profiler |
| Frame rate (1 effect loaded) | 60fps | Instruments Core Animation |
| Frame rate (4 effects loaded — Skin + Eyes + Cheeks + Lips) | ≥45fps | Same |
| Effect switch latency (`switchEffect`) | <300ms | Instrument `os_signpost` around the call |
| Shade tap to visual change (`changeParameter`) | <80ms | Same |
| Memory at idle (no effects) | <120MB | Instruments Allocations |
| Memory with 4 effects loaded | <250MB | Same |
| Battery drain in mirror (60s) | <2% on iPhone 12 mini at 100% start | Instruments Energy |

If we miss frame rate on iPhone 12 mini with 4+ effects loaded, the mitigation is: combine eyeshadow+eyeliner+lashes into a single `eyes.deepar` file (eliminating one slot), rather than dropping device support.

---

## 11. SDK versioning

Pin to a specific tag in `Package.resolved`. Don't auto-bump. When DeepAR releases a new version:

1. Read the changelog: `https://docs.deepar.ai/deepar-sdk/platforms/ios/changelog`
2. Bump in Xcode (File > Packages > Update to Latest Package Versions)
3. Build and run all tests — especially `EffectParameterMapTests` and `MirrorCoreLoopTests`
4. Test on a physical device — face tracking quality regressions don't always show in simulator
5. Smoke-test all 7 categories and at least 2 preset Looks
6. Commit the new `Package.resolved` only after all the above pass
