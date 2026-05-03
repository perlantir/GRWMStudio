# 07 — Codex Prompts

The build itself. Run these tickets top-to-bottom, in order. Each ticket has:

- **Goal** — one sentence
- **Prereqs** — tickets that must land first
- **Files** — what gets created or edited
- **Acceptance criteria** — testable list. Don't merge a ticket until every one is true.
- **Prompt** — copy-paste this into Codex. Self-contained.

If a prompt produces something fundamentally wrong, use the Codex fix-up template in **10-APPENDICES.md §C**. Don't move on with broken work — later tickets assume earlier ones landed correctly.

---

## Phase index

| Phase | Range | Working days | What ships |
|------|------|------|------|
| 0 — Bootstrap | GRWM-001 to GRWM-010 | 3 | Empty Xcode project, design tokens, primitives, app shell |
| 1 — DeepAR foundation | GRWM-100 to GRWM-110 | 4 | Wrapper, catalog, parameter map, recording service |
| 2 — Onboarding | GRWM-200 to GRWM-205 | 3 | All 5 onboarding screens + router |
| 3 — Mirror & capture | GRWM-300 to GRWM-315 | 8 | Hero mirror flow + 4 mirror screens + capture services |
| 4 — Capture, preview, save | GRWM-400 to GRWM-405 | 3 | Preview + save & share flow (3 screens) |
| 5 — Library + Locker | GRWM-500 to GRWM-510 | 4 | Looks Library + Locker + Look Detail (5 screens) |
| 6 — Profile + Feed + Tutorial | GRWM-600 to GRWM-605 | 3 | 3 screens, Feed networking, tutorial player |
| 7 — Commerce | GRWM-700 to GRWM-710 | 4 | Parental gate + Paywall + StoreKit + entitlement (5 screens) |
| 8 — Settings | GRWM-750 to GRWM-751 | 1 | Settings screen + service |
| 9 — Errors | GRWM-800 to GRWM-808 | 2 | All 9 error variants, individually |
| 10 — Polish | GRWM-850 to GRWM-857 | 4 | A11y, haptics, sounds, animations, performance |
| 11 — Testing | GRWM-900 to GRWM-906 | 3 | Unit/UI/snapshot/perf/a11y test passes |
| 12 — Launch | GRWM-950 to GRWM-957 | 3 | Privacy manifest, App Store, kids review prep |

**~111 tickets. ~42 working days for one engineer driving Codex full-time.**

---

# Phase 0 — Bootstrap

The skeleton: Xcode project, design tokens, primitive components, the phone shell, app environment, splash. By end of phase the app launches to a blank pink screen with the GRWM logo splash.

---

## GRWM-001 — Initialize the Xcode project

**Goal:** Create the `GRWMStudio.xcodeproj` and verify it builds against an iOS 17 simulator.

**Prereqs:** §1 (env), §3 (Apple developer setup), §4.1–4.3 (repo skeleton) of 03-COMMANDS.md.

**Files:**
- `GRWMStudio.xcodeproj/project.pbxproj`
- `GRWMStudio/App/GRWMStudioApp.swift`
- `GRWMStudio/App/AppDelegate.swift`
- `GRWMStudio/Resources/Info.plist`
- `GRWMStudio/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `GRWMStudio/Resources/LaunchScreen.storyboard`
- All `*.xcconfig` files wired into the project

**Acceptance criteria:**
- [ ] `xcodebuild build -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' | xcbeautify` exits 0
- [ ] App launches in simulator and shows a white screen (not the default "Hello, world!")
- [ ] Bundle ID is `app.grwmstudio.ios` exactly
- [ ] Deployment target is iOS 17.0
- [ ] Targeted device family is iPhone only (not iPad)
- [ ] Supported orientations: portrait only
- [ ] Light mode only (Info.plist `UIUserInterfaceStyle = Light`)
- [ ] `Config/Debug.xcconfig` and `Config/Release.xcconfig` are wired into the project's debug + release build configurations
- [ ] All required Info.plist privacy strings exist (Camera, Microphone, PhotoLibraryAdd) with the placeholder copy from 05-DEEPAR-INTEGRATION.md §1.2
- [ ] `DeepARLicenseKey` exists in Info.plist with value `$(DEEPAR_LICENSE_KEY)`
- [ ] No warnings, no errors

**Prompt:**

````
Create a new iOS app Xcode project named GRWMStudio. Use these exact settings:

- Bundle Identifier: app.grwmstudio.ios
- Organization: GRWM Studio
- Interface: SwiftUI
- Language: Swift
- Storage: None (we'll add SwiftData later)
- Include Tests: Yes
- iOS Deployment Target: 17.0
- Targeted device families: iPhone only
- Supported orientations: portrait only
- User interface style: Light mode only

The repo already has this directory structure (do not recreate it):
- GRWMStudio/App/
- GRWMStudio/DesignSystem/ (and subdirs)
- GRWMStudio/DeepAR/
- GRWMStudio/Resources/
- GRWMStudio/Resources/Assets.xcassets/
- GRWMStudioTests/
- GRWMStudioUITests/
- Config/{Debug,Release,Secrets,Secrets.example}.xcconfig

Replace the default ContentView.swift with a minimal placeholder. Move GRWMStudioApp.swift to GRWMStudio/App/. Move Info.plist to GRWMStudio/Resources/. Move the asset catalog to GRWMStudio/Resources/Assets.xcassets/. Move LaunchScreen.storyboard to GRWMStudio/Resources/.

Wire the existing Config/Debug.xcconfig as the Debug build configuration's xcconfig, and Config/Release.xcconfig as Release. Both already #include Secrets.xcconfig which defines DEEPAR_LICENSE_KEY.

Set these Info.plist keys:
- NSCameraUsageDescription = "GRWM Studio uses your camera to show you the magic mirror."
- NSMicrophoneUsageDescription = "GRWM Studio records sound when you make a video so you can talk and sing along!"
- NSPhotoLibraryAddUsageDescription = "GRWM Studio adds saved looks to Photos only when you tap Save."
- DeepARLicenseKey = $(DEEPAR_LICENSE_KEY)
- UIRequiresFullScreen = YES
- UISupportedInterfaceOrientations = (UIInterfaceOrientationPortrait only)
- UIUserInterfaceStyle = Light
- UILaunchStoryboardName = LaunchScreen

Create a minimal LaunchScreen.storyboard with a solid background color #FFE5F2 (DH.pinkPaper) — no text, no images, just the color.

Create a placeholder GRWMStudio/App/AppDelegate.swift conforming to UIApplicationDelegate as a UIApplicationDelegateAdaptor for our SwiftUI app. It should be empty for now (we'll add lifecycle code in later tickets).

In GRWMStudioApp.swift, the body should render a Color(red: 1.0, green: 0.898, blue: 0.949) (placeholder pink) — we'll replace with the real splash in GRWM-010.

After creation, run:
xcodebuild build -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'

Confirm the build succeeds with zero warnings and zero errors. The project should launch in simulator and show a solid pink screen.
````

---

## GRWM-002 — Add SwiftLint as a build phase

**Goal:** SwiftLint runs automatically on every build; lint failures break the build.

**Prereqs:** GRWM-001.

**Files:**
- `Scripts/lint.sh` (already exists from §4.3 of 03-COMMANDS.md)
- A new "Run Script" build phase on the GRWMStudio target

**Acceptance criteria:**
- [ ] Building the GRWMStudio target invokes SwiftLint via `Scripts/lint.sh`
- [ ] Adding a deliberate lint violation (e.g., `let x = 1; let x = 2` force-unwrap) fails the build
- [ ] The CI workflow already calls `Scripts/lint.sh` (added in §4.7 — verify it still works)
- [ ] The `.swiftlint.yml` from §4.3 is at the repo root and being honored

**Prompt:**

````
Add a "Run Script" build phase to the GRWMStudio target that runs SwiftLint.

The build phase should be named "SwiftLint" and run BEFORE the "Compile Sources" phase.

The script should be:

if which swiftlint > /dev/null; then
  swiftlint --strict --config "${SRCROOT}/.swiftlint.yml"
else
  echo "warning: SwiftLint not installed. brew install swiftlint"
fi

The phase should NOT be marked as "Based on dependency analysis" (we want it to run every build).

Add ${SRCROOT}/.swiftlint.yml to the input files list of the build phase.

Verify by:
1. Building — should run SwiftLint as part of build output
2. Adding `let x = "" as String!` (force-unwrap on optional cast) somewhere in GRWMStudioApp.swift — should fail the build
3. Reverting that change — build should pass again
````

---

## GRWM-003 — Design tokens and color palette

**Goal:** Implement the full DH design token namespace from 06-DESIGN-SYSTEM.md §2.

**Prereqs:** GRWM-001.

**Files:**
- `GRWMStudio/DesignSystem/DH+Color.swift`
- `GRWMStudio/DesignSystem/DH+Tokens.swift`
- `GRWMStudio/Resources/Assets.xcassets/Colors/` (asset catalog mirrors of every token)
- `GRWMStudioTests/DesignSystem/DHTokensTests.swift`

**Acceptance criteria:**
- [ ] All 13 color tokens exist as `static let` on `DH` (or sub-types like `DH.Color`)
- [ ] Each token's hex value matches the table in 06-DESIGN-SYSTEM.md §2 exactly
- [ ] `DH.pink == Color(hex: 0xFF3DA5)` etc. — verified by unit tests
- [ ] Each color also exists as a named asset in `Assets.xcassets/Colors/` (e.g., "DH/pink") so designers can reference them in storyboards
- [ ] `Color(hex:)` and `UIColor(hex:)` initializers handle both 6-digit (RRGGBB) and 8-digit (RRGGBBAA) values
- [ ] Radii constants exist on `DH.Radius` (chip 17, card 24, bigCard 32, viewport 36, viewportInner 28, swatch 24, tile 22)
- [ ] Spacing constants exist on `DH.Spacing` (hPad 18, sectionGap 18, itemGap 12, tightGap 8)

**Prompt:**

````
Create the design tokens for GRWM Studio's V01 Dreamhouse Plastic visual language.

CREATE: GRWMStudio/DesignSystem/DH+Color.swift

Provide hex initializers for both Color and UIColor:

import SwiftUI
import UIKit

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex & 0xFF0000) >> 16) / 255
        let g = Double((hex & 0x00FF00) >> 8) / 255
        let b = Double(hex & 0x0000FF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255
        let b = CGFloat(hex & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

CREATE: GRWMStudio/DesignSystem/DH+Tokens.swift

Define a namespace `DH` with all design tokens. The 13 color tokens, with these EXACT hex values:

- pink: 0xFF3DA5
- pinkDeep: 0xD4127B
- pinkLight: 0xFFB8DC
- pinkPaper: 0xFFE5F2
- cream: 0xFFF6FA
- butter: 0xFFD66B
- butterDeep: 0xC99B1F
- lavender: 0xC9A8FF
- lavenderDeep: 0x7A53C9
- mint: 0xA8E8C8
- ink: 0x3A0E25
- recRed: 0xFF2D5A
- recRedDeep: 0xB41540

Structure:

enum DH {
    static let pink       = Color(hex: 0xFF3DA5)
    static let pinkDeep   = Color(hex: 0xD4127B)
    // ... etc

    enum Radius {
        static let chip:          CGFloat = 17
        static let card:          CGFloat = 24
        static let bigCard:       CGFloat = 32
        static let viewport:      CGFloat = 36
        static let viewportInner: CGFloat = 28
        static let swatch:        CGFloat = 24
        static let tile:          CGFloat = 22
    }

    enum Spacing {
        static let hPad:       CGFloat = 18
        static let sectionGap: CGFloat = 18
        static let itemGap:    CGFloat = 12
        static let tightGap:   CGFloat = 8
    }
}

ALSO CREATE: Asset catalog Color sets at GRWMStudio/Resources/Assets.xcassets/Colors/DH/{pink,pinkDeep,...}.colorset/Contents.json — one per token. Use the sRGB values matching the hex.

CREATE: GRWMStudioTests/DesignSystem/DHTokensTests.swift

Write tests that:
1. Verify each token's RGB values round-trip correctly (e.g., DH.pink decomposes to (1.0, 0.239, 0.647) within tolerance 0.01)
2. Verify radii values match the spec
3. Verify hex initializer handles edge cases (0x000000 → black, 0xFFFFFF → white)

Use XCTest. Run xcodebuild test -only-testing:GRWMStudioTests/DHTokensTests and confirm all tests pass.
````

---

## GRWM-004 — Chunky shadow modifier

**Goal:** Implement the signature two-layer "plastic stamp" shadow as a reusable ViewModifier.

**Prereqs:** GRWM-003.

**Files:**
- `GRWMStudio/DesignSystem/DH+ChunkyShadow.swift`

**Acceptance criteria:**
- [ ] `DH.ChunkyShadow` struct exists with `solidColor`, `solidOffset`, `blurColor`, `blurRadius`, `blurY` properties
- [ ] Three preset sizes: `DH.ChunkyShadow.sm`, `.md`, `.lg` matching the table in 06-DESIGN-SYSTEM.md §4
- [ ] `View.chunkyShadow(_:)` modifier applies the effect
- [ ] A separate `chunkyShadowedRect(cornerRadius:size:fillColor:shadowColor:)` helper exists for shapes (since the modifier-on-arbitrary-content approach has limits)
- [ ] SwiftUI `#Preview` shows three rectangles, one per size, on a `pinkPaper` background

**Prompt:**

````
Create GRWMStudio/DesignSystem/DH+ChunkyShadow.swift implementing the signature "plastic stamp" two-layer shadow used throughout the V01 Dreamhouse Plastic design language.

The shadow has TWO layers:
1. A SOLID OFFSET BLOCK — same shape and size as the foreground element, offset down by 3-6pt, in a "deep" color
2. A SOFT BLUR — wider drop shadow, 25-40% alpha of the deep color

Define the preset sizes (matching 06-DESIGN-SYSTEM.md §4):

extension DH {
    struct ChunkyShadow {
        let solidColor: Color
        let solidOffset: CGFloat
        let blurColor: Color
        let blurRadius: CGFloat
        let blurY: CGFloat

        static func sm(deep: Color = DH.pinkDeep) -> Self {
            .init(solidColor: deep, solidOffset: 3,
                  blurColor: deep.opacity(0.35), blurRadius: 10, blurY: 5)
        }
        static func md(deep: Color = DH.pinkDeep) -> Self {
            .init(solidColor: deep, solidOffset: 4,
                  blurColor: deep.opacity(0.35), blurRadius: 14, blurY: 7)
        }
        static func lg(deep: Color = DH.pinkDeep) -> Self {
            .init(solidColor: deep, solidOffset: 6,
                  blurColor: deep.opacity(0.40), blurRadius: 26, blurY: 12)
        }
    }
}

For shape-based use (which is the common case — DHButton, DHCard, DHChip), the implementation uses a ZStack:

extension View {
    func chunkyShadow(_ shadow: DH.ChunkyShadow, shape: some Shape = RoundedRectangle(cornerRadius: 24)) -> some View {
        ZStack {
            shape
                .fill(shadow.solidColor)
                .offset(y: shadow.solidOffset)
            self
        }
        .shadow(color: shadow.blurColor, radius: shadow.blurRadius, x: 0, y: shadow.blurY)
    }
}

ALSO provide a static helper for the most common case — a chunky-shadowed filled rounded rect:

extension DH {
    @ViewBuilder
    static func chunkyShadowedRect(
        cornerRadius: CGFloat,
        size: ChunkyShadow,
        fillColor: Color,
        deepColor: Color
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(deepColor)
                .offset(y: size.solidOffset)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fillColor)
        }
        .shadow(color: deepColor.opacity(0.35), radius: size.blurRadius, x: 0, y: size.blurY)
    }
}

Include a #Preview showing three buttons (one each for sm/md/lg) on a DH.pinkPaper background. Include a fourth preview demonstrating the modifier on a generic Image.
````

---

## GRWM-005 — Fonts: Fredoka and Quicksand

**Goal:** Register both font families and provide the `DH.font(_:)` API for the type scale.

**Prereqs:** GRWM-003.

**Files:**
- `GRWMStudio/Resources/Fonts/Fredoka-Regular.ttf` (and Medium, SemiBold, Bold)
- `GRWMStudio/Resources/Fonts/Quicksand-Regular.ttf` (and Medium, SemiBold, Bold)
- `GRWMStudio/DesignSystem/DH+Fonts.swift`
- `GRWMStudio/Resources/Info.plist` (UIAppFonts entry)

**Acceptance criteria:**
- [ ] All 8 TTF files (4 Fredoka + 4 Quicksand) are added to the Xcode target with "Copy if needed" and "Add to GRWMStudio target" checked
- [ ] `Info.plist` has `UIAppFonts` array listing all 8 font filenames
- [ ] Defensive runtime registration via `CTFontManagerRegisterGraphicsFont` runs in `AppDelegate.application(_:didFinishLaunchingWithOptions:)` — registers any fonts not picked up via Info.plist
- [ ] `DH.font(.display1)` returns a Fredoka-Bold 96pt Font
- [ ] All 10 type styles from 06-DESIGN-SYSTEM.md §3.1 are implemented
- [ ] A preview shows all 10 styles rendering with the correct fonts (no system font fallback)

**Prompt:**

````
Set up font handling for GRWM Studio.

PRECONDITION: The user has already downloaded the Fredoka and Quicksand TTF files from Google Fonts and placed them at GRWMStudio/Resources/Fonts/. If these files don't exist, fail this ticket and tell the user to:
  1. Download Fredoka from https://fonts.google.com/specimen/Fredoka (Static fonts, weights 400/500/600/700)
  2. Download Quicksand from https://fonts.google.com/specimen/Quicksand (Static fonts, weights 500/600/700)
  3. Place TTFs at GRWMStudio/Resources/Fonts/ named exactly: Fredoka-Regular.ttf, Fredoka-Medium.ttf, Fredoka-SemiBold.ttf, Fredoka-Bold.ttf, Quicksand-Medium.ttf, Quicksand-SemiBold.ttf, Quicksand-Bold.ttf, Quicksand-Regular.ttf

Add all TTF files to the GRWMStudio target's "Copy Bundle Resources" build phase.

UPDATE Info.plist: Add a UIAppFonts array key listing all 8 font filenames.

CREATE GRWMStudio/DesignSystem/DH+Fonts.swift:

import SwiftUI
import CoreText

extension DH {
    enum TypeStyle: String, CaseIterable {
        case display1, display2, display3, headline
        case body, bodyEmphasis, caption, microLabel
        case buttonSmall, buttonLarge
    }

    static func font(_ style: TypeStyle) -> Font {
        switch style {
        case .display1:     return .custom("Fredoka-Bold", size: 96)
        case .display2:     return .custom("Fredoka-Bold", size: 48)
        case .display3:     return .custom("Fredoka-Bold", size: 32)
        case .headline:     return .custom("Fredoka-Bold", size: 22)
        case .body:         return .custom("Quicksand-Medium", size: 14)
        case .bodyEmphasis: return .custom("Quicksand-Bold", size: 14)
        case .caption:      return .custom("Fredoka-SemiBold", size: 11)
        case .microLabel:   return .custom("Fredoka-SemiBold", size: 9)
        case .buttonSmall:  return .custom("Fredoka-Bold", size: 12)
        case .buttonLarge:  return .custom("Fredoka-Bold", size: 18)
        }
    }

    /// Tracking values per style. Apply via .tracking(_:) modifier.
    static func tracking(_ style: TypeStyle) -> CGFloat {
        switch style {
        case .display1, .display2, .display3:    return -0.02 * style.size
        case .headline:                          return -0.01 * style.size
        case .body, .buttonSmall, .buttonLarge:  return 0
        case .bodyEmphasis:                      return 0.02 * style.size
        case .caption:                           return 0.16 * style.size
        case .microLabel:                        return 0.32 * style.size
        }
    }
}

extension DH.TypeStyle {
    var size: CGFloat {
        switch self {
        case .display1: return 96
        case .display2: return 48
        case .display3: return 32
        case .headline: return 22
        case .body, .bodyEmphasis: return 14
        case .caption: return 11
        case .microLabel: return 9
        case .buttonSmall: return 12
        case .buttonLarge: return 18
        }
    }
}

ALSO add a defensive runtime font registration in GRWMStudio/App/AppDelegate.swift:

func application(_ application: UIApplication, didFinishLaunchingWithOptions ...) -> Bool {
    registerFontsIfNeeded()
    return true
}

private func registerFontsIfNeeded() {
    let fontNames = ["Fredoka-Regular", "Fredoka-Medium", "Fredoka-SemiBold", "Fredoka-Bold",
                     "Quicksand-Regular", "Quicksand-Medium", "Quicksand-SemiBold", "Quicksand-Bold"]
    for name in fontNames {
        guard UIFont(name: name, size: 12) == nil,
              let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
    }
}

Add a #Preview to DH+Fonts.swift showing all 10 type styles, each labeled, on a DH.pinkPaper background. Confirm visually that the custom font is rendering (Fredoka has a very distinctive friendly rounded shape — if you see a system font, registration failed).
````

---

## GRWM-006 — Sticker primitives

**Goal:** Implement the 5 sticker SVG primitives + GRWMLogo.

**Prereqs:** GRWM-005.

**Files:**
- `GRWMStudio/DesignSystem/Stickers/StickerHeart.swift`
- `GRWMStudio/DesignSystem/Stickers/StickerStar.swift`
- `GRWMStudio/DesignSystem/Stickers/StickerSparkle.swift`
- `GRWMStudio/DesignSystem/Stickers/StickerFlower.swift`
- `GRWMStudio/DesignSystem/Stickers/StickerBow.swift`
- `GRWMStudio/DesignSystem/Stickers/GRWMLogo.swift`

**Acceptance criteria:**
- [ ] All 5 stickers render as SwiftUI `Shape`s, accepting `size`, `fill`, `stroke`, `strokeWidth` parameters
- [ ] `StickerHeart` matches the SVG path in `docs/design-source/v3/grwm-shared.jsx` exactly
- [ ] `GRWMLogo` accepts a `layout` parameter (`.stack` or `.row`) and renders matching the JSX `<Logo size="xl" stacked />` and `<Logo size="md" />` variants
- [ ] Each sticker has a `.stickerBob()` modifier that applies a 6pt vertical translation, easeInOut, 2s duration, autoreverse, infinite — and respects `accessibilityReduceMotion`
- [ ] All 5 stickers are `accessibilityHidden(true)` by default (decorative)
- [ ] `#Preview` shows all 5 stickers + both logo variants on `DH.pinkPaper`

**Prompt:**

````
Create the 5 sticker primitives + GRWMLogo for GRWM Studio.

REFERENCE: docs/design-source/v3/grwm-shared.jsx — that file defines the exact SVG paths and the GRWMLogo composition. Mirror them faithfully.

CREATE: GRWMStudio/DesignSystem/Stickers/StickerHeart.swift

import SwiftUI

struct StickerHeart: View {
    var size: CGFloat = 32
    var fill: Color = DH.pink
    var stroke: Color = .white
    var strokeWidth: CGFloat = 2.5

    var body: some View {
        // SVG path from grwm-shared.jsx (the heart icon):
        // M16 28S2 19 2 11a6 6 0 0111-3 6 6 0 0111 3c0 8-14 17-14 17z
        // Translate this to a SwiftUI Path. The viewBox is 0 0 32 32.
        Heart()
            .fill(fill)
            .overlay(Heart().stroke(stroke, lineWidth: strokeWidth))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    private struct Heart: Shape {
        func path(in rect: CGRect) -> Path {
            // Translate SVG path commands to Path moveTo/curveTo, scaled to rect
            // Use rect.width/32 and rect.height/32 as scale factors
            // ... [implement faithful translation]
        }
    }
}

CREATE the other 4 stickers using the same pattern, with these paths:

- StickerStar: M16 2l4 9 10 1-7 7 2 10-9-5-9 5 2-10-7-7 10-1z
  Default fill: DH.butter, stroke: white, strokeWidth: 2.5
- StickerSparkle: M12 2l2 7 7 2-7 2-2 7-2-7-7-2 7-2z
  Default fill: white, stroke: none
- StickerFlower: 8 outer petals (each a small ellipse) + center circle
  Default petals: DH.pink, center: DH.butter, stroke white 2pt
- StickerBow: 2 triangles + center ellipse — refer to grwm-shared.jsx
  Default fill: DH.pinkLight, stroke: white, strokeWidth: 2

CREATE: GRWMStudio/DesignSystem/Stickers/GRWMLogo.swift

This is a composed view, not a single Shape. The text is "GRWM" with the heart in the upper right corner, and a "STUDIO" subtitle below or beside.

struct GRWMLogo: View {
    enum Layout { case stack, row }
    enum Size { case sm, md, lg, xl }

    var layout: Layout = .stack
    var size: Size = .lg

    var body: some View {
        switch layout {
        case .stack:
            VStack(spacing: stackSpacing) {
                grwmText
                studioSubtitle
            }
        case .row:
            HStack(spacing: rowSpacing) {
                grwmText
                studioSubtitle
            }
        }
    }

    private var grwmText: some View {
        ZStack(alignment: .topTrailing) {
            // The "GRWM" text uses a layered fill+stroke trick:
            // fill = DH.pink, but with a thick white outline (-webkit-text-stroke 4px white in CSS)
            // SwiftUI doesn't have text stroke directly, so:
            // Layer 1: Text("GRWM").foregroundStyle(.white) drawn slightly bigger via .tracking + .font scaled, behind
            // Layer 2: Text("GRWM").foregroundStyle(DH.pink) on top
            // Drop shadow: 0 7px 0 DH.pinkDeep (stamp), 0 12px 22px DH.pinkDeep.opacity(0.4) (blur)
            //
            // Implementation hint: use a ZStack with the white "stroked" layer behind, scaled up via
            // scaleEffect or by using a thicker font weight; or use TextRenderer (iOS 18) for true stroking.
            //
            // For iOS 17 compatibility, use the ZStack trick:
            ZStack {
                Text("GRWM")
                    .font(grwmFont)
                    .foregroundStyle(.white)
                    .offset(x: -1, y: -1)
                Text("GRWM")
                    .font(grwmFont)
                    .foregroundStyle(.white)
                    .offset(x: 1, y: -1)
                Text("GRWM")
                    .font(grwmFont)
                    .foregroundStyle(.white)
                    .offset(x: -1, y: 1)
                Text("GRWM")
                    .font(grwmFont)
                    .foregroundStyle(.white)
                    .offset(x: 1, y: 1)
                Text("GRWM")
                    .font(grwmFont)
                    .foregroundStyle(DH.pink)
            }
            .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 7)
            .shadow(color: DH.pinkDeep.opacity(0.4), radius: 22, x: 0, y: 12)
            
            StickerHeart(size: heartSize, fill: DH.butter)
                .offset(x: heartSize * 0.3, y: -heartSize * 0.3)
        }
    }

    private var studioSubtitle: some View {
        Text("STUDIO")
            .font(studioFont)
            .tracking(studioTracking)
            .foregroundStyle(DH.pinkDeep)
    }

    // ... computed font sizes per Size case
}

Sticker bob animation: in StickerHeart (and reusable), add:

extension View {
    func stickerBob(amplitude: CGFloat = 6, period: Double = 2.0) -> some View {
        modifier(StickerBobModifier(amplitude: amplitude, period: period))
    }
}

struct StickerBobModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animating = false
    let amplitude: CGFloat
    let period: Double

    func body(content: Content) -> some View {
        content
            .offset(y: animating && !reduceMotion ? -amplitude : 0)
            .onAppear {
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: period).repeatForever(autoreverses: true)) {
                        animating = true
                    }
                }
            }
    }
}

Add #Preview rendering all 5 stickers and both GRWMLogo layouts on a DH.pinkPaper background.

ACCEPTANCE: visually compare the rendered SwiftUI to the JSX output (use the existing get_ready_with_me-2.zip preview HTML or render the JSX in a browser). The shapes should be visually indistinguishable.
````

---

## GRWM-007 — DH primitives: DHButton, DHCard, DHChip

**Goal:** Implement the three reusable plastic-toy components.

**Prereqs:** GRWM-004, GRWM-005.

**Files:**
- `GRWMStudio/DesignSystem/DHButton.swift`
- `GRWMStudio/DesignSystem/DHCard.swift`
- `GRWMStudio/DesignSystem/DHChip.swift`

**Acceptance criteria:**
- [ ] `DHButton` supports 4 sizes (sm, md, lg, xl) × 5 kinds (primary, white, butter, lavender, ghost) = 20 visual variants
- [ ] All sizes match the dimensions in 06-DESIGN-SYSTEM.md §8.1
- [ ] `DHButton` press animation: scale 0.97 + translate +2pt for 100ms, then bounce back. `DHHaptics.tapMedium()` fires on tap.
- [ ] `DHButton` supports leading/trailing icons (`AnyView`) and `isFullWidth` flag
- [ ] `DHCard<Content>` supports custom `bg`, `deep`, `cornerRadius`, `padding`, content closure
- [ ] `DHChip` supports `selected: Bool`, leading icon, height 34, radius 17. Selected pops up 1pt.
- [ ] All three components have `#Preview`s showing all variants
- [ ] All meet 44pt minimum tap target (DHChip's 34pt height is OK because the chip's hit-target is expanded with `.contentShape(Rectangle())` to 44pt)

**Prompt:**

````
Implement the three core DH primitive components.

REFERENCE: 06-DESIGN-SYSTEM.md §8 (component table) and docs/design-source/v3/grwm-shared.jsx (CSS in the React source).

CREATE: GRWMStudio/DesignSystem/DHButton.swift

struct DHButton: View {
    let title: String
    var kind: Kind = .primary
    var size: Size = .md
    var leadingIcon: AnyView? = nil
    var trailingIcon: AnyView? = nil
    var isFullWidth: Bool = false
    let action: () -> Void

    enum Size { case sm, md, lg, xl
        var height: CGFloat { switch self { case .sm: 36; case .md: 46; case .lg: 56; case .xl: 64 } }
        var hPad: CGFloat { switch self { case .sm: 14; case .md: 18; case .lg: 22; case .xl: 28 } }
        var fontStyle: DH.TypeStyle { switch self { case .sm, .md: .buttonSmall; case .lg, .xl: .buttonLarge } }
        var radius: CGFloat { height / 2 }
    }
    enum Kind { case primary, white, butter, lavender, ghost
        var bg: Color {
            switch self {
            case .primary: DH.pink
            case .white: .white
            case .butter: DH.butter
            case .lavender: DH.lavender
            case .ghost: .white.opacity(0.55)
            }
        }
        var fg: Color {
            switch self {
            case .primary, .lavender: .white
            case .white, .ghost: DH.pinkDeep
            case .butter: DH.ink
            }
        }
        var deep: Color {
            switch self {
            case .primary: DH.pinkDeep
            case .white: DH.pink
            case .butter: DH.butterDeep
            case .lavender: DH.lavenderDeep
            case .ghost: DH.pinkDeep.opacity(0.25)
            }
        }
    }

    @State private var pressed = false

    var body: some View {
        Button {
            DHHaptics.tapMedium()
            action()
        } label: {
            HStack(spacing: 8) {
                if let leadingIcon { leadingIcon }
                Text(title)
                    .font(DH.font(size.fontStyle))
                    .tracking(DH.tracking(size.fontStyle))
                    .foregroundStyle(kind.fg)
                if let trailingIcon { trailingIcon }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.hPad)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: size.radius)
                        .fill(kind.deep)
                        .offset(y: 4)
                    RoundedRectangle(cornerRadius: size.radius)
                        .fill(kind.bg)
                }
                .shadow(color: kind.deep.opacity(0.35), radius: 14, x: 0, y: 7)
            }
            .scaleEffect(pressed ? 0.97 : 1)
            .offset(y: pressed ? 2 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}

#Preview { /* a 4×5 grid of all size×kind combinations on a DH.pinkPaper background */ }

CREATE: GRWMStudio/DesignSystem/DHCard.swift

struct DHCard<Content: View>: View {
    var bg: Color = .white
    var deep: Color = DH.pink
    var cornerRadius: CGFloat = DH.Radius.card
    var padding: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius).fill(deep).offset(y: 4)
                    RoundedRectangle(cornerRadius: cornerRadius).fill(bg)
                }
                .shadow(color: deep.opacity(0.35), radius: 14, x: 0, y: 7)
            }
    }
}

CREATE: GRWMStudio/DesignSystem/DHChip.swift

struct DHChip: View {
    let title: String
    var selected: Bool = false
    var leadingIcon: AnyView? = nil
    let action: () -> Void

    var body: some View {
        Button {
            DHHaptics.tap()
            action()
        } label: {
            HStack(spacing: 6) {
                if let leadingIcon { leadingIcon }
                Text(title)
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.pinkDeep)
            }
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background {
                if selected {
                    ZStack {
                        Capsule().fill(DH.pink).offset(y: 3)
                        Capsule().fill(.white)
                    }
                    .shadow(color: DH.pink.opacity(0.35), radius: 8, x: 0, y: 4)
                } else {
                    Capsule().fill(.white.opacity(0.55))
                }
            }
            .offset(y: selected ? -1 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selected)
            .contentShape(Rectangle().inset(by: -8))   // expand hit target to 44pt+
        }
        .buttonStyle(.plain)
    }
}

For now, DHHaptics is referenced but not yet implemented — provide a stub that no-ops:

enum DHHaptics {
    static func tap() {}
    static func tapMedium() {}
}

(GRWM-851 will replace this stub with the real implementation.)

#Preview each component showing all variants. Run xcodebuild build and visually verify in Previews canvas.
````

---

## GRWM-008 — DHWallpaper backgrounds

**Goal:** Implement the diagonal stripes and gradient wallpaper components.

**Prereqs:** GRWM-003.

**Files:**
- `GRWMStudio/DesignSystem/DHWallpaper.swift`

**Acceptance criteria:**
- [ ] `DHWallpaperStripes` renders 45° stripes via `Canvas` (not overlapping shapes), matching the CSS `repeating-linear-gradient(45deg, #FFE5F2 0 24px, #FFF6FA 24px 48px)`
- [ ] `DHWallpaperGradient` renders a linear gradient from `pinkPaper` to `cream`
- [ ] `DHWallpaperRadial` renders a radial gradient for the mirror viewport (per 06-DESIGN-SYSTEM.md §6.3)
- [ ] All three accept opacity / customization parameters
- [ ] `#Preview` shows all three side-by-side

**Prompt:**

````
Create GRWMStudio/DesignSystem/DHWallpaper.swift implementing the three wallpaper backgrounds used throughout the V01 Dreamhouse Plastic design.

1. DHWallpaperStripes: 45° diagonal stripes via Canvas. CSS reference:
   background: repeating-linear-gradient(45deg, #FFE5F2 0 24px, #FFF6FA 24px 48px)
   opacity: 0.7

   struct DHWallpaperStripes: View {
       var primary: Color = DH.pinkPaper
       var secondary: Color = DH.cream
       var stripeWidth: CGFloat = 24
       var opacity: Double = 0.7
       var body: some View {
           Canvas { ctx, size in
               // Fill primary entirely first
               ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(primary))
               // Draw secondary stripes at 45°
               // The diagonal of size.width × size.height is sqrt(w² + h²)
               // Stripes have width stripeWidth, separated by stripeWidth (so period = 2*stripeWidth)
               // Easiest: rotate the context, draw vertical bands, untransform
               ctx.translateBy(x: 0, y: 0)
               ctx.rotate(by: .degrees(45))
               let diag = sqrt(size.width * size.width + size.height * size.height)
               var x: CGFloat = -diag
               while x < diag {
                   let band = Path(CGRect(x: x + stripeWidth, y: -diag, width: stripeWidth, height: 2*diag))
                   ctx.fill(band, with: .color(secondary))
                   x += 2 * stripeWidth
               }
           }
           .opacity(opacity)
           .ignoresSafeArea()
       }
   }

2. DHWallpaperGradient: simple linear gradient.

   struct DHWallpaperGradient: View {
       var top: Color = DH.pinkPaper
       var bottom: Color = DH.cream
       var body: some View {
           LinearGradient(
               gradient: Gradient(stops: [
                   .init(color: top, location: 0),
                   .init(color: bottom, location: 0.6),
                   .init(color: bottom, location: 1.0)
               ]),
               startPoint: .top, endPoint: .bottom
           )
           .ignoresSafeArea()
       }
   }

3. DHWallpaperRadial: radial gradient for mirror viewport interior.

   struct DHWallpaperRadial: View {
       var inner: Color = Color(hex: 0xFFE0EE)
       var outer: Color = Color(hex: 0xFFB3D9)
       var endRadius: CGFloat = 240
       var body: some View {
           RadialGradient(
               gradient: Gradient(colors: [inner, outer]),
               center: .center,
               startRadius: 0, endRadius: endRadius
           )
       }
   }

#Preview rendering all three side-by-side in a HStack with labels.
````

---

## GRWM-009 — App environment + RootCoordinator

**Goal:** Build the dependency container and the top-level routing state machine.

**Prereqs:** GRWM-003, GRWM-007.

**Files:**
- `GRWMStudio/App/AppEnvironment.swift`
- `GRWMStudio/App/RootCoordinator.swift`
- `GRWMStudio/App/RootContainer.swift`
- `GRWMStudio/App/GRWMStudioApp.swift` (update)

**Acceptance criteria:**
- [ ] `AppEnvironment` is a `final class` (not a struct because services hold state) holding placeholders for: `deepAR`, `catalog`, `captures`, `permissions`, `storeKit`, `proEntitlement`, `analytics`, `feed`, `parentalGate`. For now most are stubs/protocols with no-op implementations.
- [ ] `RootCoordinator` is `@MainActor @Observable` with the `Route` enum from 04-ARCHITECTURE.md §3.2
- [ ] `RootContainer` is a SwiftUI view that switches on `coordinator.route` and renders a placeholder Text view for each route (real screens wired in later tickets)
- [ ] `GRWMStudioApp` instantiates `AppEnvironment` once, passes to `RootContainer` via `@Environment(\.appEnvironment)`
- [ ] Compile-clean

**Prompt:**

````
Build the dependency container and routing scaffold.

CREATE: GRWMStudio/App/AppEnvironment.swift

@MainActor
final class AppEnvironment {
    // Placeholder protocols — real implementations come in later tickets.
    let permissions: any PermissionsService
    let analytics: any AnalyticsService
    // ... other services as protocols, with stub conformances for now

    init(
        permissions: any PermissionsService = StubPermissionsService(),
        analytics: any AnalyticsService = NoOpAnalyticsService()
    ) {
        self.permissions = permissions
        self.analytics = analytics
    }
}

protocol PermissionsService: Sendable { /* empty for now */ }
struct StubPermissionsService: PermissionsService {}

protocol AnalyticsService: Sendable {
    func track(_ event: String, properties: [String: Any]?)
}
struct NoOpAnalyticsService: AnalyticsService {
    func track(_ event: String, properties: [String: Any]?) {}
}

extension EnvironmentValues {
    @Entry var appEnvironment: AppEnvironment = AppEnvironment()
}

CREATE: GRWMStudio/App/RootCoordinator.swift

@MainActor @Observable
final class RootCoordinator {
    enum Route: Hashable {
        case onboardingSplash
        case onboardingWelcome
        case onboardingParentInfo
        case onboardingPermissions
        case onboardingPermissionsDenied
        case app
        case parentalGate(reason: GateReason)
        case paywall(source: PaywallSource)
        case error(ErrorVariant)
    }
    enum GateReason: Hashable { case paywall, externalLink(URL), deleteData }
    enum PaywallSource: Hashable { case proShade, lockerLimit, longRecording, settings }
    enum ErrorVariant: Hashable {
        case camDenied, micDenied, photoDenied, license,
             effectFail, recFail, saveFail, noFace, lowStorage
    }

    var route: Route = .onboardingSplash

    func advanceFromSplash() { route = .onboardingWelcome }
    func showWelcome() { route = .onboardingWelcome }
    func showParentInfo() { route = .onboardingParentInfo }
    func showPermissions() { route = .onboardingPermissions }
    func showPermissionsDenied() { route = .onboardingPermissionsDenied }
    func enterApp() { route = .app }
    func presentParentalGate(reason: GateReason) { route = .parentalGate(reason: reason) }
    func presentPaywall(source: PaywallSource) { route = .paywall(source: source) }
    func presentError(_ variant: ErrorVariant) { route = .error(variant) }
}

extension EnvironmentValues {
    @Entry var rootCoordinator: RootCoordinator = RootCoordinator()
}

CREATE: GRWMStudio/App/RootContainer.swift

struct RootContainer: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator

    var body: some View {
        ZStack {
            DHWallpaperGradient()
            switch coordinator.route {
            case .onboardingSplash:        Text("Splash placeholder").font(DH.font(.headline))
            case .onboardingWelcome:       Text("Welcome placeholder").font(DH.font(.headline))
            case .onboardingParentInfo:    Text("Parent Info placeholder").font(DH.font(.headline))
            case .onboardingPermissions:   Text("Permissions placeholder").font(DH.font(.headline))
            case .onboardingPermissionsDenied: Text("Permissions Denied placeholder").font(DH.font(.headline))
            case .app:                     Text("App placeholder").font(DH.font(.headline))
            case .parentalGate(let reason): Text("Parental Gate: \(String(describing: reason))").font(DH.font(.headline))
            case .paywall(let source):     Text("Paywall: \(String(describing: source))").font(DH.font(.headline))
            case .error(let variant):      Text("Error: \(String(describing: variant))").font(DH.font(.headline))
            }
        }
        .preferredColorScheme(.light)
    }
}

UPDATE: GRWMStudio/App/GRWMStudioApp.swift

@main
struct GRWMStudioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var environment = AppEnvironment()
    @State private var coordinator = RootCoordinator()

    var body: some Scene {
        WindowGroup {
            RootContainer()
                .environment(\.appEnvironment, environment)
                .environment(\.rootCoordinator, coordinator)
        }
    }
}

Build and run. Should show "Splash placeholder" on a pink gradient background. Tap should not navigate (no logic yet).
````

---

## GRWM-010 — Splash screen (DHSplash)

**Goal:** Implement the first onboarding screen — DHSplash — pixel-faithful to `dh-screens-1.jsx`.

**Prereqs:** GRWM-006, GRWM-008, GRWM-009.

**Files:**
- `GRWMStudio/Onboarding/SplashView.swift`
- `GRWMStudio/App/RootContainer.swift` (update to render SplashView for `.onboardingSplash`)

**Acceptance criteria:**
- [ ] Layout matches the `DHSplash` JSX exactly: stripes background at 0.7 opacity, decorative stickers (heart top-right, star bottom-left, sparkle middle-right), GRWMLogo `.stack` size `.xl` centered, "Loading magic..." caption, plastic-toy progress bar 4pt tall × ~200pt wide animating left-to-right
- [ ] Stickers `bob` animation runs (respecting Reduce Motion)
- [ ] Progress bar fills 0→100% over 1.5s linear
- [ ] After progress completes + 300ms hold, calls `coordinator.advanceFromSplash()`
- [ ] No interactive elements (it's a load screen)
- [ ] Route updates to `.onboardingWelcome` after animation
- [ ] VoiceOver: announces "GRWM Studio. Loading." on appear

**Prompt:**

````
Implement the splash screen exactly matching the DHSplash component in docs/design-source/v3/dh-screens-1.jsx.

Open dh-screens-1.jsx and find the export for DHSplash. The structure (paraphrased):

<div style={{ background: 'pink stripes wallpaper', position: 'relative' }}>
  <StickerHeart top-right />
  <StickerStar bottom-left />
  <StickerSparkle middle-right />
  <div centered>
    <GRWMLogo stacked size="xl" />
    <p caption>Loading magic...</p>
    <div progressBar />
  </div>
</div>

CREATE: GRWMStudio/Onboarding/SplashView.swift

struct SplashView: View {
    @Environment(\.rootCoordinator) private var coordinator
    @State private var progress: CGFloat = 0
    @State private var hasAdvanced = false

    var body: some View {
        ZStack {
            DHWallpaperStripes()
                .ignoresSafeArea()

            // Decorative stickers
            StickerHeart(size: 36, fill: DH.pink)
                .stickerBob()
                .position(x: 320, y: 100)
                .accessibilityHidden(true)
            StickerStar(size: 40, fill: DH.butter)
                .stickerBob(amplitude: 5, period: 2.4)
                .position(x: 60, y: 720)
                .accessibilityHidden(true)
            StickerSparkle(size: 22, fill: .white)
                .stickerBob(amplitude: 4, period: 1.8)
                .position(x: 340, y: 460)
                .accessibilityHidden(true)

            VStack(spacing: 24) {
                Spacer()

                GRWMLogo(layout: .stack, size: .xl)
                    .accessibilityLabel("GRWM Studio")

                Text("Loading magic...")
                    .font(DH.font(.bodyEmphasis))
                    .tracking(DH.tracking(.bodyEmphasis))
                    .foregroundStyle(DH.pinkDeep.opacity(0.85))

                // Plastic-toy progress bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.5))
                        .frame(width: 220, height: 8)
                    Capsule()
                        .fill(DH.pink)
                        .frame(width: 220 * progress, height: 8)
                        .shadow(color: DH.pinkDeep.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 8)

                Spacer()
                Spacer()
            }
            .accessibilityElement(children: .contain)
        }
        .preferredColorScheme(.light)
        .onAppear { startSplash() }
        .accessibilityLabel("GRWM Studio. Loading.")
    }

    private func startSplash() {
        guard !hasAdvanced else { return }
        withAnimation(.linear(duration: 1.5)) {
            progress = 1
        }
        Task {
            try? await Task.sleep(for: .milliseconds(1800))
            await MainActor.run {
                if !hasAdvanced {
                    hasAdvanced = true
                    coordinator.advanceFromSplash()
                }
            }
        }
    }
}

#Preview { SplashView().environment(\.rootCoordinator, RootCoordinator()) }

UPDATE GRWMStudio/App/RootContainer.swift — replace the `.onboardingSplash` placeholder text with `SplashView()`.

After this lands, build and run. The app should:
1. Launch
2. Show stripes background with bobbing stickers
3. Show GRWM logo with progress bar filling 0→100% over 1.5s
4. After ~2s total, advance to the welcome placeholder

If the timing feels off, tweak the Task.sleep duration to 1800ms (300ms after the 1500ms animation).
````

---

# Phase 1 — DeepAR foundation

The SDK wrapper. By end of phase, `DeepARController` is initialized with the license key, `arView` mounts in a `UIViewRepresentable`, and the manifest+catalog load successfully at app launch.

---

## GRWM-100 — Add DeepAR via SwiftPM

**Goal:** DeepAR SDK is a buildable dependency; importing `DeepAR` works in the `GRWMStudio/DeepAR/` folder only.

**Prereqs:** GRWM-001. License key from §2 of 03-COMMANDS.md must be in `Config/Secrets.xcconfig`.

**Files:**
- `GRWMStudio.xcodeproj/project.pbxproj` (Swift package dependency added)
- `Package.resolved`

**Acceptance criteria:**
- [ ] `https://github.com/DeepARSDK/swift-deepar` added as a Swift package dependency
- [ ] Pinned to "Up to Next Major Version" from the latest stable tag
- [ ] DeepAR is linked to the GRWMStudio target (NOT to GRWMStudioTests or GRWMStudioUITests)
- [ ] `Package.resolved` is committed to git
- [ ] `import DeepAR` compiles in a temporary Swift file inside `GRWMStudio/DeepAR/` (delete the temp file after verification)
- [ ] `Scripts/verify-deepar-isolation.sh` passes
- [ ] App still builds cleanly

**Prompt:**

````
Add the DeepAR iOS SDK as a Swift Package dependency.

In Xcode:
1. File > Add Package Dependencies
2. Enter URL: https://github.com/DeepARSDK/swift-deepar
3. Dependency Rule: Up to Next Major Version, starting from the latest stable tag
4. Select "Add Package"
5. When prompted, link the DeepAR product to the GRWMStudio target ONLY (NOT to GRWMStudioTests or GRWMStudioUITests)

After the package resolves:

1. Commit Package.resolved to git
2. Create a temporary file at GRWMStudio/DeepAR/_smoketest.swift containing:

   import DeepAR
   import Foundation

   /// Temporary smoke test — confirms DeepAR is importable. Delete this file after verification.
   enum _DeepARSmokeTest {
       static func _check() -> String { String(describing: DeepAR.self) }
   }

3. Build the project — if `import DeepAR` compiles, the integration is wired correctly
4. Run ./Scripts/verify-deepar-isolation.sh — should pass (the smoketest is inside DeepAR/ which is allowed)
5. Delete GRWMStudio/DeepAR/_smoketest.swift
6. Commit with message: "[GRWM-100] Add DeepAR SDK via SwiftPM"

If the package fails to resolve:
- Verify your network can reach github.com
- Try File > Packages > Reset Package Caches
- As a fallback, add via CocoaPods: create a Podfile at the repo root with `pod 'DeepAR'`, run `pod install --repo-update`, and use the resulting GRWMStudio.xcworkspace going forward.
````

---

## GRWM-101 — DeepARController skeleton + DeepARDelegateProxy

**Goal:** Build the public API surface of `DeepARController` and the delegate proxy, with no real SDK calls yet — just the state machine and the protocol bridging.

**Prereqs:** GRWM-100.

**Files:**
- `GRWMStudio/DeepAR/DeepARController.swift`
- `GRWMStudio/DeepAR/DeepARDelegateProxy.swift`
- `GRWMStudio/DeepAR/EffectSlot.swift`
- `GRWMStudio/DeepAR/MakeupCategory.swift`
- `GRWMStudio/DeepAR/EffectFile.swift`
- `GRWMStudio/DeepAR/MakeupShade.swift`

**Acceptance criteria:**
- [ ] `DeepARController` is `@MainActor @Observable final class` with the public surface defined in 05-DEEPAR-INTEGRATION.md §2.1
- [ ] All async lifecycle methods are declared but throw `SetupError.notImplementedYet` for now
- [ ] `DeepARDelegateProxy` is a private class implementing the DeepARDelegate protocol with empty methods (autocomplete via Xcode to get the exact signatures)
- [ ] `EffectSlot`, `MakeupCategory`, `EffectFile`, `MakeupShade` are defined per 05-DEEPAR-INTEGRATION.md §2.4 and §5
- [ ] Compile-clean; no unit tests yet

**Prompt:**

````
Build the public API surface of DeepARController and the delegate proxy. No real SDK behavior yet — just the structure and state machine.

Reference: 05-DEEPAR-INTEGRATION.md §2 (Wrapper layer) and §2.4 (Slot model). Mirror those signatures exactly.

CREATE: GRWMStudio/DeepAR/EffectSlot.swift

public enum EffectSlot: String, CaseIterable, Sendable {
    case skin   = "slot_skin"
    case base   = "slot_base"
    case eyes   = "slot_eyes"
    case brows  = "slot_brows"
    case cheeks = "slot_cheeks"
    case lips   = "slot_lips"
    case looks  = "slot_looks"
}

CREATE: GRWMStudio/DeepAR/MakeupCategory.swift

public enum MakeupCategory: String, CaseIterable, Identifiable, Sendable, Hashable {
    case skin, base, eyes, brows, cheeks, lips, looks
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .skin:   return "Skin"
        case .base:   return "Base"
        case .eyes:   return "Eyes"
        case .brows:  return "Brows"
        case .cheeks: return "Cheeks"
        case .lips:   return "Lips"
        case .looks:  return "Looks"
        }
    }
    public var slot: EffectSlot {
        switch self {
        case .skin: .skin; case .base: .base; case .eyes: .eyes
        case .brows: .brows; case .cheeks: .cheeks; case .lips: .lips
        case .looks: .looks
        }
    }
}

CREATE: GRWMStudio/DeepAR/EffectFile.swift and MakeupShade.swift — exactly as defined in 05-DEEPAR-INTEGRATION.md §5 (the Catalog section).

CREATE: GRWMStudio/DeepAR/DeepARController.swift

import DeepAR
import SwiftUI
import OSLog

@MainActor @Observable
public final class DeepARController {
    public enum State: Equatable {
        case uninitialized, initializing, ready, failed(reason: String)
    }
    public enum SetupError: LocalizedError {
        case missingLicenseKey, sdkInitTimeout, alreadyInitialized
        case effectLoadFailed(slot: EffectSlot, reason: String)
        case recordingFailed(reason: String)
        case captureFailed(reason: String)
        case notImplementedYet
        public var errorDescription: String? {
            switch self {
            case .missingLicenseKey:           "Missing DeepAR license key in Info.plist"
            case .sdkInitTimeout:              "DeepAR SDK didn't initialize within timeout"
            case .alreadyInitialized:          "DeepAR is already initialized"
            case .effectLoadFailed(_, let r):  "Effect load failed: \(r)"
            case .recordingFailed(let r):      "Recording failed: \(r)"
            case .captureFailed(let r):        "Capture failed: \(r)"
            case .notImplementedYet:           "Not implemented yet (will land in a later ticket)"
            }
        }
    }

    public private(set) var state: State = .uninitialized
    public private(set) var trackedFace: Bool = false
    public private(set) var loadedEffects: [EffectSlot: EffectFile.ID] = [:]
    public private(set) var isRecordingVideo: Bool = false
    public private(set) var recordingDuration: TimeInterval = 0

    public var arView: UIView? { _arView }

    // Internal references — set by the delegate proxy
    var _deepAR: DeepAR?
    var _arView: UIView?
    var _delegateProxy: DeepARDelegateProxy?

    // Continuations for async bridging — set when bootstrapping/recording
    var bootstrapContinuation: CheckedContinuation<Void, Error>?
    var photoContinuation: CheckedContinuation<URL, Error>?
    var videoContinuation: CheckedContinuation<URL, Error>?

    public init() {}

    public func bootstrap(licenseKey: String) async throws {
        throw SetupError.notImplementedYet  // GRWM-102 fills this in
    }

    public func startCamera(includeAudio: Bool) async throws {
        throw SetupError.notImplementedYet  // GRWM-103
    }

    public func stopCamera() async {
        // GRWM-103
    }

    public func switchCamera(toFront: Bool) async throws {
        throw SetupError.notImplementedYet  // GRWM-103
    }

    public func loadEffect(_ effect: EffectFile, slot: EffectSlot) async throws {
        throw SetupError.notImplementedYet  // GRWM-104
    }

    public func clearEffect(slot: EffectSlot) async {
        // GRWM-104
    }

    public func clearAllEffects() async {
        for slot in EffectSlot.allCases { await clearEffect(slot: slot) }
    }

    public func setColor(_ color: UIColor, on parameter: EffectParameter) async {
        // GRWM-106
    }

    public func setTexture(_ image: UIImage, on parameter: EffectParameter) async {
        // GRWM-106
    }

    public func setBlendshape(_ value: Float, on parameter: EffectParameter) async {
        // GRWM-106
    }

    public func setEnabled(_ enabled: Bool, on parameter: EffectParameter) async {
        // GRWM-106
    }

    public func capturePhoto() async throws -> URL {
        throw SetupError.notImplementedYet  // GRWM-110
    }

    public func startVideoRecording(maxDuration: TimeInterval) async throws {
        throw SetupError.notImplementedYet  // GRWM-110
    }

    public func stopVideoRecording() async throws -> URL {
        throw SetupError.notImplementedYet  // GRWM-110
    }
}

CREATE: GRWMStudio/DeepAR/DeepARDelegateProxy.swift

import DeepAR
import UIKit

final class DeepARDelegateProxy: NSObject, DeepARDelegate {
    weak var controller: DeepARController?

    init(controller: DeepARController) {
        self.controller = controller
        super.init()
    }

    // Implement every method in the DeepARDelegate protocol as a no-op or with a minimal forward.
    // CRITICAL: Use Xcode autocomplete to discover the EXACT method signatures. The DeepARDelegate
    // protocol is Obj-C, so signatures may differ slightly across SDK versions. Common methods
    // include:
    //
    //   func didInitialize()
    //   func didFinishShutdown()
    //   func faceVisiblityDidChange(_ faceVisible: Bool)         // note: "Visiblity" - SDK typo
    //   func didTakeScreenshot(_ screenshot: UIImage)
    //   func didStartVideoRecording()
    //   func didFinishVideoRecording(_ videoFilePath: String)
    //   func recordingFailedWithError(_ error: Error)
    //   func didFinishPreparingForVideoRecording()
    //   func didSwitchEffect(_ slot: String)
    //   func didFinishLoadingEffect(_ slot: String)
    //   func didFinishCleaningUpEffectAtSlot(_ slot: String)
    //
    // For now, implement each as an empty {} body. Later tickets (102, 103, 110) will add the
    // real Continuation resumes.

    func didInitialize() {
        Logger.deepAR.info("DeepAR didInitialize")
    }

    func faceVisiblityDidChange(_ faceVisible: Bool) {
        Task { @MainActor in
            controller?.trackedFace = faceVisible
        }
    }

    // ... [implement remaining required protocol methods as empty bodies; rely on Xcode's
    //      "Add Protocol Stubs" suggestion to fill in any required methods]
}

Build. The project should compile but no DeepAR functionality is exercised yet.

Run ./Scripts/verify-deepar-isolation.sh — should pass.
````

---

## GRWM-102 — DeepARController.bootstrap()

**Goal:** The bootstrap method actually creates a `DeepAR` instance, calls `setLicenseKey`, attaches the delegate, creates the AR view, and waits for `didInitialize` (with 8s timeout).

**Prereqs:** GRWM-101.

**Files:**
- `GRWMStudio/DeepAR/DeepARController.swift` (update)
- `GRWMStudio/DeepAR/DeepARDelegateProxy.swift` (update `didInitialize`)
- `GRWMStudio/Utilities/Concurrency+Extensions.swift` (`withTimeout`)

**Acceptance criteria:**
- [ ] `bootstrap(licenseKey:)` reads the key from Info.plist if not passed (helper exists), creates `DeepAR`, calls `setLicenseKey`, attaches delegate, calls `createARView(withFrame: .zero)`, sets `state = .initializing`, awaits `didInitialize` via `CheckedContinuation`
- [ ] Bootstrap times out after 8 seconds → throws `SetupError.sdkInitTimeout` and sets `state = .failed(reason:)`
- [ ] On success: `state = .ready`, `_arView` is non-nil, `_deepAR` is non-nil
- [ ] Calling `bootstrap` twice throws `.alreadyInitialized`
- [ ] If license key is missing or empty: throws `.missingLicenseKey` immediately
- [ ] Unit test (using a minimal protocol-substitution mock) verifies the state transitions

**Prompt:**

````
Implement DeepARController.bootstrap(licenseKey:).

CREATE: GRWMStudio/Utilities/Concurrency+Extensions.swift

import Foundation

struct TimeoutError: LocalizedError {
    var errorDescription: String? { "Operation timed out" }
}

func withTimeout<T: Sendable>(
    _ duration: Duration,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(for: duration)
            throw TimeoutError()
        }
        defer { group.cancelAll() }
        let first = try await group.next()
        guard let result = first else { throw TimeoutError() }
        return result
    }
}

UPDATE: GRWMStudio/DeepAR/DeepARController.swift

Replace the throw notImplementedYet body of bootstrap(licenseKey:) with:

public func bootstrap(licenseKey: String) async throws {
    if state != .uninitialized {
        throw SetupError.alreadyInitialized
    }
    guard !licenseKey.isEmpty else {
        state = .failed(reason: "Missing license key")
        throw SetupError.missingLicenseKey
    }
    state = .initializing
    Logger.deepAR.info("Bootstrapping DeepAR")

    do {
        try await withTimeout(.seconds(8)) { [weak self] in
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                Task { @MainActor in
                    guard let self else { cont.resume(); return }
                    self.bootstrapContinuation = cont
                    let deepAR = DeepAR()
                    deepAR.setLicenseKey(licenseKey)
                    let proxy = DeepARDelegateProxy(controller: self)
                    deepAR.delegate = proxy
                    self._deepAR = deepAR
                    self._delegateProxy = proxy
                    // Create AR view with placeholder frame; SwiftUI host re-sizes via UIViewRepresentable
                    self._arView = deepAR.createARView(withFrame: CGRect(x: 0, y: 0, width: 1, height: 1))
                    // Wait for didInitialize delegate to resume the continuation.
                }
            }
        }
        state = .ready
        Logger.deepAR.info("DeepAR bootstrap complete (state: ready)")
    } catch is TimeoutError {
        state = .failed(reason: "SDK init timeout")
        bootstrapContinuation = nil
        throw SetupError.sdkInitTimeout
    } catch {
        state = .failed(reason: error.localizedDescription)
        bootstrapContinuation = nil
        throw error
    }
}

ALSO add a helper for license key reading:

extension DeepARController {
    public static func licenseKeyFromInfoPlist() -> String {
        Bundle.main.object(forInfoDictionaryKey: "DeepARLicenseKey") as? String ?? ""
    }
}

UPDATE: GRWMStudio/DeepAR/DeepARDelegateProxy.swift — make didInitialize resume the continuation:

func didInitialize() {
    Logger.deepAR.info("DeepAR didInitialize")
    Task { @MainActor in
        guard let c = controller else { return }
        c.bootstrapContinuation?.resume()
        c.bootstrapContinuation = nil
    }
}

ALSO add a basic OSLog category in GRWMStudio/Utilities/Logger+GRWM.swift:

import OSLog

extension Logger {
    static let app      = Logger(subsystem: "app.grwmstudio.ios", category: "app")
    static let deepAR   = Logger(subsystem: "app.grwmstudio.ios", category: "deepar")
    static let mirror   = Logger(subsystem: "app.grwmstudio.ios", category: "mirror")
    static let capture  = Logger(subsystem: "app.grwmstudio.ios", category: "capture")
    static let perms    = Logger(subsystem: "app.grwmstudio.ios", category: "permissions")
    static let persist  = Logger(subsystem: "app.grwmstudio.ios", category: "persistence")
    static let storeKit = Logger(subsystem: "app.grwmstudio.ios", category: "storekit")
    static let feed     = Logger(subsystem: "app.grwmstudio.ios", category: "feed")
}

VERIFY ON DEVICE: this needs a real device to fully test. Run on a physical iPhone with the license key set in Secrets.xcconfig. From a temporary debug button, call:

Task {
    let key = DeepARController.licenseKeyFromInfoPlist()
    do {
        try await env.deepAR.bootstrap(licenseKey: key)
        Logger.deepAR.info("Bootstrap success!")
    } catch {
        Logger.deepAR.error("Bootstrap failed: \(error)")
    }
}

Watch the OSLog console for "DeepAR didInitialize" followed by "Bootstrap success!". If you see "SDK init timeout", check:
- License key matches bundle ID exactly in the DeepAR portal
- Secrets.xcconfig is wired into the build configuration
- Bundle ID in the Xcode project is exactly app.grwmstudio.ios
````

---

## GRWM-103 — Camera lifecycle (start/stop/switch)

**Goal:** `startCamera(includeAudio:)`, `stopCamera()`, `switchCamera(toFront:)` work.

**Prereqs:** GRWM-102.

**Files:**
- `GRWMStudio/DeepAR/DeepARController.swift` (update)

**Acceptance criteria:**
- [ ] `startCamera(includeAudio:)` creates a `CameraController(deepAR:)`, calls `startCamera(withAudio:)`, completes synchronously (camera frames flow without blocking)
- [ ] `stopCamera()` calls the SDK's stop method and releases the camera controller
- [ ] `switchCamera(toFront:)` flips between front/back. Back camera disables face tracking gracefully (DeepAR handles this internally — verify `trackedFace = false` while back camera is active)
- [ ] Calling startCamera before bootstrap throws `.alreadyInitialized` (or specific error)
- [ ] Tested on physical device: camera preview shows in the AR view after startCamera

**Prompt:**

````
Implement camera lifecycle methods on DeepARController.

The DeepAR SDK requires a CameraController instance to drive camera frames into the AR pipeline. Per the docs:

import DeepAR

let cameraController = CameraController(deepAR: deepAR)
cameraController.startCamera(withAudio: true)
// later:
cameraController.stopCamera()

The exact API may differ slightly between SDK versions. Use Xcode autocomplete to confirm the method names. Common variants seen in DeepAR docs:
- CameraController(deepAR:)
- startCamera(withAudio:)
- stopCamera()
- switchCamera() OR setCameraDevice(_:) (front/back toggle)

UPDATE GRWMStudio/DeepAR/DeepARController.swift:

Add an internal CameraController reference:

private var _cameraController: CameraController?

Replace startCamera implementation:

public func startCamera(includeAudio: Bool) async throws {
    guard state == .ready else {
        throw SetupError.recordingFailed(reason: "DeepAR not ready")
    }
    guard let deepAR = _deepAR else {
        throw SetupError.recordingFailed(reason: "Missing DeepAR instance")
    }
    if _cameraController == nil {
        _cameraController = CameraController(deepAR: deepAR)
    }
    _cameraController?.startCamera(withAudio: includeAudio)
    Logger.deepAR.info("Camera started (audio: \(includeAudio))")
}

public func stopCamera() async {
    _cameraController?.stopCamera()
    Logger.deepAR.info("Camera stopped")
}

public func switchCamera(toFront: Bool) async throws {
    // The exact toggle method depends on SDK version. Most likely:
    //   _cameraController?.position = toFront ? .front : .back
    // Or:
    //   _cameraController?.switchCamera()
    // Use whichever the SDK provides. If the SDK only offers a generic toggle, store
    // a Bool to track current state.
    //
    // After the switch, reset trackedFace to false; the delegate will fire
    // faceVisiblityDidChange when face detection re-establishes.
    Task { @MainActor in self.trackedFace = false }
    // ... [implement using SDK's actual API — Xcode autocomplete]
}

VERIFY: On a physical device:
1. Bootstrap DeepAR (GRWM-102 path)
2. Call startCamera(includeAudio: true)
3. Mount _arView in a temporary UIViewRepresentable (we'll formalize this in GRWM-107)
4. Confirm: live camera preview shows, your face draws the red landmark dots that DeepAR debug-renders by default (these don't show in production — they're an internal SDK debug overlay that disappears when the first effect loads)
5. Call stopCamera() — preview freezes
6. Call switchCamera(toFront: false) — back camera. trackedFace is false (no face tracking on back camera).
7. Call switchCamera(toFront: true) again — preview flips back, face dots re-appear
````

---

## GRWM-104 — Effect loading and clearing per slot

**Goal:** `loadEffect` and `clearEffect` work; multiple effects can be loaded simultaneously into different slots.

**Prereqs:** GRWM-103.

**Files:**
- `GRWMStudio/DeepAR/DeepARController.swift` (update)

**Acceptance criteria:**
- [ ] `loadEffect(_, slot:)` resolves the effect's bundle URL via `effect.bundleURL()`, calls `deepAR.switchEffect(withSlot:path:)` with the slot's raw value, awaits `didLoadEffectAtSlot` confirmation via continuation (4s timeout), updates `loadedEffects[slot]`
- [ ] `clearEffect(slot:)` calls `deepAR.switchEffect(withSlot: rawValue, path: nil)` (or whatever the empty-effect API is), removes from `loadedEffects`
- [ ] Loading two effects into different slots simultaneously works (e.g., Skin into `slot_skin` AND Lips into `slot_lips`)
- [ ] Loading a new effect into a slot that already has one replaces it (verify on device by switching from `eyeshadow_pink` to `eyeshadow_blue`)
- [ ] Verified on device: loading `baseBeauty.deepar` shows the foundation/smoothing effect
- [ ] Failure: timeout or error from delegate sets `state = ` not affected (only the load fails, controller stays ready), throws `.effectLoadFailed`

**Prompt:**

````
Implement effect loading on DeepARController.

The DeepAR SDK supports multiple simultaneous effects via slots. Per the docs:

deepAR.switchEffect(withSlot: "slot_lips", path: pathToEffectFile)

Slot names are arbitrary strings — we use the EffectSlot.rawValue from GRWM-101.

UPDATE GRWMStudio/DeepAR/DeepARController.swift — add slot-keyed continuations:

private var loadEffectContinuations: [EffectSlot: CheckedContinuation<Void, Error>] = [:]

Replace loadEffect implementation:

public func loadEffect(_ effect: EffectFile, slot: EffectSlot) async throws {
    guard state == .ready else {
        throw SetupError.effectLoadFailed(slot: slot, reason: "DeepAR not ready")
    }
    let url = try effect.bundleURL()
    Logger.deepAR.info("Loading effect \(effect.id) into \(slot.rawValue)")

    do {
        try await withTimeout(.seconds(4)) { [weak self] in
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                Task { @MainActor in
                    guard let self else { cont.resume(); return }
                    if let existing = self.loadEffectContinuations[slot] {
                        existing.resume(throwing: SetupError.effectLoadFailed(slot: slot, reason: "Cancelled by new load"))
                    }
                    self.loadEffectContinuations[slot] = cont
                    self._deepAR?.switchEffect(withSlot: slot.rawValue, path: url.path)
                }
            }
        }
        loadedEffects[slot] = effect.id
    } catch is TimeoutError {
        loadEffectContinuations[slot] = nil
        throw SetupError.effectLoadFailed(slot: slot, reason: "Timeout")
    } catch {
        loadEffectContinuations[slot] = nil
        throw error
    }
}

Replace clearEffect:

public func clearEffect(slot: EffectSlot) async {
    Logger.deepAR.info("Clearing effect from \(slot.rawValue)")
    _deepAR?.switchEffect(withSlot: slot.rawValue, path: nil)
    loadedEffects[slot] = nil
    // Some SDK versions also fire didFinishCleaningUpEffectAtSlot — we don't await it because
    // unloads are fire-and-forget for our purposes.
}

UPDATE GRWMStudio/DeepAR/DeepARDelegateProxy.swift — implement load completion:

// The exact method name depends on SDK version. Likely candidates:
//   func didFinishLoadingEffect(_ slot: String)
//   func didSwitchEffect(_ slot: String)
//
// One of them fires after switchEffect completes. Resume the continuation.

func didFinishLoadingEffect(_ slot: String) {
    Logger.deepAR.info("didFinishLoadingEffect: \(slot)")
    guard let effectSlot = EffectSlot(rawValue: slot) else { return }
    Task { @MainActor in
        guard let c = controller else { return }
        c.loadEffectContinuations[effectSlot]?.resume()
        c.loadEffectContinuations[effectSlot] = nil
    }
}

// Optional but recommended: also implement an error handler if the SDK provides one
// (e.g., didFailToLoadEffect or similar). If it exists, resume with .effectLoadFailed.

VERIFY ON DEVICE:
1. Bootstrap and start camera (GRWM-102/103 paths)
2. Load baseBeauty.deepar into .skin slot:
   try await env.deepAR.loadEffect(baseBeautyEffect, slot: .skin)
3. Confirm visible smoothing effect on your face in the preview
4. Load look_legacy01.deepar into .looks slot — observe combined effect
5. Clear the .skin slot — smoothing disappears, look remains
6. Clear .looks — clean preview
````

---

## GRWM-105 — EffectParameterMap

**Goal:** Implement `EffectParameter` and `EffectParameterMap` per 05-DEEPAR-INTEGRATION.md §4 with all the placeholder node names. Verify against `baseBeauty.deeparproj`.

**Prereqs:** GRWM-101.

**Files:**
- `GRWMStudio/DeepAR/EffectParameter.swift`
- `GRWMStudio/DeepAR/EffectParameterMap.swift`
- `docs/PARAMETER-MAP-SHEET.md` (created in this ticket)

**Acceptance criteria:**
- [ ] `EffectParameter` struct exists with `nodeName`, `component`, `parameter`
- [ ] `EffectParameterMap` enum has every constant listed in 05-DEEPAR-INTEGRATION.md §4
- [ ] `EffectParameterMap.resolve(_:)` dictionary maps every documented `ref` string
- [ ] `docs/PARAMETER-MAP-SHEET.md` is created summarizing all node names + parameters in a human-readable table for the artist
- [ ] Placeholder node names are flagged with `// VERIFY` comments
- [ ] Codex inspects `GRWMStudio/Resources/Effects/_source/Free.v1.3/baseBeauty.deeparproj/effect.json` and reports any node names that don't match the placeholders. (Actual replacement happens in GRWM-106 verification.)

**Prompt:**

````
Implement EffectParameter and EffectParameterMap.

CREATE GRWMStudio/DeepAR/EffectParameter.swift:

import Foundation

public struct EffectParameter: Equatable, Hashable, Sendable {
    public let nodeName: String
    public let component: String
    public let parameter: String

    public init(nodeName: String, component: String, parameter: String) {
        self.nodeName = nodeName
        self.component = component
        self.parameter = parameter
    }
}

CREATE GRWMStudio/DeepAR/EffectParameterMap.swift exactly per 05-DEEPAR-INTEGRATION.md §4. Mark every node name with a comment:

// VERIFY: Confirm node name "faceMesh" exists in baseBeauty.deeparproj/effect.json hierarchy.

The full set of constants and the resolve(_:) dictionary follow from §4.

TASK 2 — Verify against the actual project:

Inspect GRWMStudio/Resources/Effects/_source/Free.v1.3/baseBeauty.deeparproj/effect.json. Run:

   jq '.[] | select(.type == "Node") | .name' GRWMStudio/Resources/Effects/_source/Free.v1.3/baseBeauty.deeparproj/effect.json

(Or read the JSON file directly and list all "name" fields under "Node" entries.)

For each placeholder node name in EffectParameterMap (faceMesh, lutPostprocess, eyeshadowMesh, eyelinerMesh, eyelashesMesh, browMesh, blushMesh, lipsMesh):

- If the actual project has an exactly-matching node, leave the placeholder as-is and remove the // VERIFY comment for that constant.
- If the actual project has a node with a DIFFERENT name that serves the same purpose (e.g., "faceMesh" vs "Face Mesh" vs "skinMesh"), update the placeholder to the actual name.
- If the actual project doesn't have the node at all, leave the placeholder, keep the // VERIFY comment, and add a TODO note that ticket GRWM-106 will need to verify on device.

The free pack may not have all the nodes we expect (it lacks blush and brows entirely, per the changelog). Mark blushMesh and browMesh as "// VERIFY: Not in free pack — comes from larger pack".

TASK 3 — Generate the Parameter Map Sheet:

CREATE docs/PARAMETER-MAP-SHEET.md — a human-readable table for the artist who maintains the .deeparproj files. It should look like:

# DeepAR Parameter Map Sheet

This table is the contract between the iOS app and the DeepAR Studio project files. The app uses these EXACT node names and shader uniform names to apply runtime parameter changes (color, texture, enable/disable). When you rename or remove a node, the app breaks.

## Skin (foundation)
| Node name        | Component      | Parameter (uniform) | Type     | What it does               |
|------------------|----------------|---------------------|----------|----------------------------|
| faceMesh         | MeshRenderer   | u_color             | Vector4  | Foundation tint RGBA       |
| faceMesh         | MeshRenderer   | s_texMask           | Texture  | Foundation alpha mask      |

## Base (LUT)
| Node name        | Component      | Parameter           | Type     | What it does               |
|------------------|----------------|---------------------|----------|----------------------------|
| lutPostprocess   | (none)         | enabled             | Bool     | LUT toggle                 |
| lutPostprocess   | MeshRenderer   | s_texLut            | Texture  | LUT texture                |

... [continue for Eyes, Brows, Cheeks, Lips]

## Looks (preset full-face)
Looks effects are self-contained — no runtime parameters. Switching to a Look effect replaces all per-category effects.

## Versioning
- Version 1: Initial map (this document)
- When the artist publishes a new effect file with new nodes/parameters, increment the manifest version in GRWMStudio/Resources/Effects/manifest.json AND add new constants to EffectParameterMap.swift AND update this sheet.

Build & verify: xcodebuild build should succeed. The // VERIFY comments are tracked in the codebase as TODOs for the engineer to resolve when the larger filter pack arrives.
````

---

## GRWM-106 — Runtime parameter API

**Goal:** Implement `setColor`, `setTexture`, `setBlendshape`, `setEnabled` on `DeepARController` using DeepAR's `changeParameter` API.

**Prereqs:** GRWM-104, GRWM-105.

**Files:**
- `GRWMStudio/DeepAR/DeepARController.swift` (update)

**Acceptance criteria:**
- [ ] `setColor` calls `deepAR.changeParameter(_, component:, parameter:, vectorValue:)` with a Vector4 (per https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter)
- [ ] `setTexture` calls `deepAR.changeParameter(_, component:, parameter:, image:)` with a UIImage
- [ ] `setBlendshape` calls `deepAR.changeParameter(_, component:, parameter:, floatValue:)`
- [ ] `setEnabled` calls `deepAR.changeParameter(_, component:, parameter:, boolValue:)` (DeepAR's bool variant)
- [ ] Each method logs at .debug level with the (nodeName, component, parameter) and the value being set
- [ ] No-ops gracefully if `_deepAR` is nil or `state != .ready` (logs at .info)
- [ ] On-device verification: changing lipstick color via setColor visibly recolors the lips in the preview within ~80ms

**Prompt:**

````
Implement the runtime parameter mutation API on DeepARController.

DeepAR's API per https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter accepts four parameter types. The exact method signatures depend on SDK version; use Xcode autocomplete to confirm. Common signatures:

  deepAR.changeParameter(_ gameObject: String, component: String, parameter: String, vectorValue: Vector4)
  deepAR.changeParameter(_ gameObject: String, component: String, parameter: String, image: UIImage)
  deepAR.changeParameter(_ gameObject: String, component: String, parameter: String, floatValue: Float)
  deepAR.changeParameter(_ gameObject: String, component: String, parameter: String, boolValue: Bool)

NOTE: Some SDK versions use `Vector4` from the DeepAR module directly; others expose it as `simd_float4`. Use whatever the autocomplete provides. If neither is available, the SDK may expose a single overload that takes Float values (x, y, z, w).

UPDATE GRWMStudio/DeepAR/DeepARController.swift:

public func setColor(_ color: UIColor, on parameter: EffectParameter) async {
    guard state == .ready, let deepAR = _deepAR else {
        Logger.deepAR.info("setColor skipped (not ready)")
        return
    }
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    Logger.deepAR.debug("setColor \(parameter.nodeName).\(parameter.parameter) = (\(r), \(g), \(b), \(a))")

    // Use whatever Vector4 type DeepAR exposes. If the SDK's API takes a Vector4 directly:
    //   let vec = Vector4(x: Float(r), y: Float(g), z: Float(b), w: Float(a))
    //   deepAR.changeParameter(parameter.nodeName, component: parameter.component, parameter: parameter.parameter, vectorValue: vec)
    //
    // If the SDK takes 4 floats:
    //   deepAR.changeParameter(parameter.nodeName, component: parameter.component, parameter: parameter.parameter, x: Float(r), y: Float(g), z: Float(b), w: Float(a))
    //
    // If neither pattern works, check the SDK header: typically there's a "vector4" suffix on the method name.
    //
    // After implementing, build to verify. The actual call is a one-liner.

    deepAR.changeParameter(parameter.nodeName,
                           component: parameter.component,
                           parameter: parameter.parameter,
                           vectorValue: Vector4(x: Float(r), y: Float(g), z: Float(b), w: Float(a)))
}

public func setTexture(_ image: UIImage, on parameter: EffectParameter) async {
    guard state == .ready, let deepAR = _deepAR else {
        Logger.deepAR.info("setTexture skipped (not ready)")
        return
    }
    Logger.deepAR.debug("setTexture \(parameter.nodeName).\(parameter.parameter) = UIImage(\(image.size))")
    deepAR.changeParameter(parameter.nodeName,
                           component: parameter.component,
                           parameter: parameter.parameter,
                           image: image)
}

public func setBlendshape(_ value: Float, on parameter: EffectParameter) async {
    guard state == .ready, let deepAR = _deepAR else { return }
    Logger.deepAR.debug("setBlendshape \(parameter.parameter) = \(value)")
    deepAR.changeParameter(parameter.nodeName,
                           component: parameter.component,
                           parameter: parameter.parameter,
                           floatValue: value)
}

public func setEnabled(_ enabled: Bool, on parameter: EffectParameter) async {
    guard state == .ready, let deepAR = _deepAR else { return }
    Logger.deepAR.debug("setEnabled \(parameter.nodeName).\(parameter.parameter) = \(enabled)")
    deepAR.changeParameter(parameter.nodeName,
                           component: parameter.component,
                           parameter: parameter.parameter,
                           boolValue: enabled)
}

ON-DEVICE VERIFICATION:

1. Bootstrap, start camera, load baseBeauty.deepar into .skin slot
2. Build a temporary debug button that calls:

   await env.deepAR.setColor(UIColor.red, on: EffectParameterMap.lipsColor)

3. Confirm: lips visibly turn red within ~80ms

4. If nothing changes, the most likely causes are:
   a) Wrong node name in EffectParameterMap — verify against baseBeauty.deeparproj/effect.json
   b) Wrong component name — try "MeshRenderer" with capitals exactly
   c) Wrong parameter name — try "u_color" (most shaders use this) or "color" (some custom shaders)
   d) The free pack's baseBeauty.deepar may not have a separate lips mesh — see PARAMETER-MAP-SHEET.md
   e) The shader doesn't actually have a u_color uniform — inspect the shader bundle

5. Iterate on EffectParameterMap node/parameter names until the color change is visible.

6. Once lipsColor works, verify each of the others (foundationColor, eyeshadowColor, etc.) systematically. Document any that DON'T work in PARAMETER-MAP-SHEET.md as "// PENDING — needs larger pack".
````

---

## GRWM-107 — DeepARView SwiftUI representable

**Goal:** Mount the DeepAR `arView` (a `UIView`) inside SwiftUI via `UIViewRepresentable`.

**Prereqs:** GRWM-102.

**Files:**
- `GRWMStudio/DeepAR/DeepARView.swift`

**Acceptance criteria:**
- [ ] `DeepARView` is a `UIViewRepresentable` that takes a `DeepARController` and mounts its `arView`
- [ ] When `controller.state` transitions through `.uninitialized → .initializing → .ready`, the view shows: pink placeholder → loading spinner over pink → live AR view
- [ ] The view respects parent layout (no fixed size)
- [ ] Calling `bootstrap` then mounting `DeepARView` shows the live preview within ~2 seconds on a real device
- [ ] In the simulator (where DeepAR can't run), shows a placeholder "Magic Mirror" graphic without crashing

**Prompt:**

````
Build the SwiftUI host for DeepAR's UIView.

CREATE GRWMStudio/DeepAR/DeepARView.swift:

import SwiftUI
import UIKit

struct DeepARView: UIViewRepresentable {
    let controller: DeepARController

    func makeUIView(context: Context) -> DeepARContainerView {
        DeepARContainerView(controller: controller)
    }

    func updateUIView(_ uiView: DeepARContainerView, context: Context) {
        uiView.refresh()
    }
}

final class DeepARContainerView: UIView {
    private let controller: DeepARController
    private weak var hostedARView: UIView?
    private let placeholder = UIView()
    private let placeholderLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init(controller: DeepARController) {
        self.controller = controller
        super.init(frame: .zero)
        backgroundColor = UIColor(red: 1.0, green: 0.898, blue: 0.949, alpha: 1) // DH.pinkPaper
        clipsToBounds = true
        layer.cornerRadius = 28 // DH.Radius.viewportInner

        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.backgroundColor = .clear
        addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.topAnchor.constraint(equalTo: topAnchor),
            placeholder.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholder.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeholder.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "✨ Magic Mirror"
        placeholderLabel.textColor = UIColor(red: 0.831, green: 0.071, blue: 0.482, alpha: 1)
        placeholderLabel.font = UIFont(name: "Fredoka-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        placeholder.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholder.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: placeholder.centerYAnchor),
        ])

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor(red: 0.831, green: 0.071, blue: 0.482, alpha: 1)
        placeholder.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: placeholder.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: placeholderLabel.topAnchor, constant: -12),
        ])

        refresh()
    }

    required init?(coder: NSCoder) { nil }

    func refresh() {
        switch controller.state {
        case .uninitialized:
            placeholderLabel.text = "✨ Magic Mirror"
            activityIndicator.stopAnimating()
            placeholder.isHidden = false
            hostedARView?.removeFromSuperview()
            hostedARView = nil
        case .initializing:
            placeholderLabel.text = "Warming up the magic..."
            activityIndicator.startAnimating()
            placeholder.isHidden = false
            hostedARView?.removeFromSuperview()
            hostedARView = nil
        case .ready:
            activityIndicator.stopAnimating()
            placeholder.isHidden = true
            mountARViewIfNeeded()
        case .failed(let reason):
            placeholderLabel.text = "Error: \(reason)"
            activityIndicator.stopAnimating()
            placeholder.isHidden = false
            hostedARView?.removeFromSuperview()
            hostedARView = nil
        }
    }

    private func mountARViewIfNeeded() {
        guard hostedARView == nil, let arView = controller.arView else { return }
        arView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arView)
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: topAnchor),
            arView.leadingAnchor.constraint(equalTo: leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        hostedARView = arView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hostedARView?.frame = bounds
    }
}

#Preview { DeepARView(controller: DeepARController()).frame(width: 350, height: 460) }

In Previews, the controller is uninitialized → placeholder shows. On device, after bootstrap finishes, the live preview takes over.

VERIFY ON DEVICE: build and run. From a temporary debug screen:
1. Show DeepARView(controller: env.deepAR) at frame ~340×440
2. Initially: pink placeholder with "✨ Magic Mirror"
3. Trigger bootstrap → "Warming up the magic..." with spinner
4. After ~2s: live front-camera preview fills the box
````

---

## GRWM-108 — EffectCatalog + manifest.json

**Goal:** Build the catalog, write a starter manifest.json with the free pack's effects, validate at app launch.

**Prereqs:** GRWM-105.

**Files:**
- `GRWMStudio/DeepAR/EffectCatalog.swift`
- `GRWMStudio/Resources/Effects/manifest.json`
- `GRWMStudio/Resources/Effects/thumbnails/*.png` (placeholder thumbnails)
- `GRWMStudioTests/DeepAR/EffectCatalogTests.swift`

**Acceptance criteria:**
- [ ] `EffectCatalog` actor exists per 05-DEEPAR-INTEGRATION.md §5
- [ ] `manifest.json` validates (jq parses it)
- [ ] `manifest.json` contains entries for: `baseBeauty` (skin) with 5 shades; `noFilter`/`bright` (base); 1 starter eyeshadow with 5 colors; 1 starter eyeliner; 1 starter lip color set with 5 shades; 2 looks (`look_legacy01`, `look_legacy02`)
- [ ] Pro shades: at least 1 per shade row marked `isPro: true` so the Pro gate has something to gate
- [ ] `EffectCatalog.shared.load()` succeeds at app launch (run as a `.task` modifier on RootContainer)
- [ ] Validation: every `parameters[].ref` resolves via `EffectParameterMap.resolve(_:)`. Test verifies this.
- [ ] Unit tests pass: `EffectCatalogTests` validates manifest shape, file presence, parameter ref resolution

**Prompt:**

````
Implement the effect catalog and create the starter manifest.

CREATE GRWMStudio/DeepAR/EffectCatalog.swift exactly per 05-DEEPAR-INTEGRATION.md §5 (EffectCatalog, ManifestRoot, EffectFile, MakeupShade, CatalogError types).

CREATE GRWMStudio/Resources/Effects/manifest.json with this content (adapt as needed if effect files are named differently):

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
          { "id": "off",    "displayName": "Off",    "color": "#FFFFFF", "isPro": false,
            "parameters": [{ "kind": "color", "ref": "foundationColor", "rgba": [1.0, 1.0, 1.0, 0.0] }] },
          { "id": "fair",   "displayName": "Fair",   "color": "#FFE6D5", "isPro": false,
            "parameters": [{ "kind": "color", "ref": "foundationColor", "rgba": [1.0, 0.902, 0.836, 0.7] }] },
          { "id": "light",  "displayName": "Light",  "color": "#F4D0AC", "isPro": false,
            "parameters": [{ "kind": "color", "ref": "foundationColor", "rgba": [0.957, 0.816, 0.675, 0.7] }] },
          { "id": "medium", "displayName": "Medium", "color": "#E8B89A", "isPro": false,
            "parameters": [{ "kind": "color", "ref": "foundationColor", "rgba": [0.91, 0.722, 0.604, 0.7] }] },
          { "id": "tan",    "displayName": "Tan",    "color": "#C58E70", "isPro": true,
            "parameters": [{ "kind": "color", "ref": "foundationColor", "rgba": [0.773, 0.557, 0.439, 0.7] }] }
        ]
      }
    ],
    "base": [
      {
        "id": "filter",
        "displayName": "Filter",
        "file": "baseBeauty.deepar",
        "thumbnail": "thumbnails/filter.png",
        "isPro": false,
        "shades": [
          { "id": "off",    "displayName": "Off",    "color": "#FFFFFF", "isPro": false,
            "parameters": [{ "kind": "bool", "ref": "lutEnabled", "value": 0 }] },
          { "id": "warm",   "displayName": "Warm",   "color": "#FFD9B0", "isPro": false,
            "parameters": [{ "kind": "bool", "ref": "lutEnabled", "value": 1 }] },
          { "id": "cool",   "displayName": "Cool",   "color": "#B0D5FF", "isPro": false,
            "parameters": [{ "kind": "bool", "ref": "lutEnabled", "value": 1 }] },
          { "id": "bright", "displayName": "Bright", "color": "#FFE6F0", "isPro": false,
            "parameters": [{ "kind": "bool", "ref": "lutEnabled", "value": 1 }] },
          { "id": "vivid",  "displayName": "Vivid",  "color": "#FF6FA0", "isPro": true,
            "parameters": [{ "kind": "bool", "ref": "lutEnabled", "value": 1 }] }
        ]
      }
    ],
    "eyes": [
      {
        "id": "shadow",
        "displayName": "Shadow",
        "file": "baseBeauty.deepar",
        "thumbnail": "thumbnails/shadow.png",
        "isPro": false,
        "shades": [
          { "id": "off",    "displayName": "Off",    "color": "#FFFFFF", "isPro": false,
            "parameters": [{ "kind": "bool", "ref": "eyelinerEnabled", "value": 0 }] },
          { "id": "rose",   "displayName": "Rose",   "color": "#FF8FB8", "isPro": false,
            "parameters": [
              { "kind": "color", "ref": "eyeshadowColor", "rgba": [1.0, 0.561, 0.722, 1.0] },
              { "kind": "bool",  "ref": "eyelinerEnabled", "value": 1 }
            ]},
          { "id": "lilac",  "displayName": "Lilac",  "color": "#C9A8FF", "isPro": false,
            "parameters": [
              { "kind": "color", "ref": "eyeshadowColor", "rgba": [0.788, 0.659, 1.0, 1.0] },
              { "kind": "bool",  "ref": "eyelinerEnabled", "value": 1 }
            ]},
          { "id": "gold",   "displayName": "Gold",   "color": "#FFD66B", "isPro": false,
            "parameters": [
              { "kind": "color", "ref": "eyeshadowColor", "rgba": [1.0, 0.839, 0.42, 1.0] },
              { "kind": "bool",  "ref": "eyelinerEnabled", "value": 1 }
            ]},
          { "id": "smoke",  "displayName": "Smoke",  "color": "#3A3A4A", "isPro": true,
            "parameters": [
              { "kind": "color", "ref": "eyeshadowColor", "rgba": [0.227, 0.227, 0.29, 1.0] },
              { "kind": "bool",  "ref": "eyelinerEnabled", "value": 1 }
            ]}
        ]
      }
    ],
    "brows": [
      {
        "id": "brows-placeholder",
        "displayName": "Brows",
        "file": "baseBeauty.deepar",
        "thumbnail": "thumbnails/brows.png",
        "isPro": false,
        "shades": [
          { "id": "off",   "displayName": "Off",   "color": "#FFFFFF", "isPro": false,
            "parameters": [{ "kind": "bool", "ref": "browEnabled", "value": 0 }] }
        ]
      }
    ],
    "cheeks": [
      {
        "id": "cheeks-placeholder",
        "displayName": "Cheeks",
        "file": "baseBeauty.deepar",
        "thumbnail": "thumbnails/cheeks.png",
        "isPro": false,
        "shades": [
          { "id": "off",   "displayName": "Off",   "color": "#FFFFFF", "isPro": false,
            "parameters": [{ "kind": "bool", "ref": "blushEnabled", "value": 0 }] }
        ]
      }
    ],
    "lips": [
      {
        "id": "lipstick",
        "displayName": "Lipstick",
        "file": "baseBeauty.deepar",
        "thumbnail": "thumbnails/lipstick.png",
        "isPro": false,
        "shades": [
          { "id": "off",       "displayName": "Off",       "color": "#FFFFFF", "isPro": false,
            "parameters": [{ "kind": "bool", "ref": "lipsEnabled", "value": 0 }] },
          { "id": "bubblegum", "displayName": "Bubblegum", "color": "#FF3DA5", "isPro": false,
            "parameters": [
              { "kind": "color", "ref": "lipsColor", "rgba": [1.0, 0.239, 0.647, 0.95] },
              { "kind": "bool",  "ref": "lipsEnabled", "value": 1 }
            ]},
          { "id": "berry",     "displayName": "Berry",     "color": "#A12454", "isPro": false,
            "parameters": [
              { "kind": "color", "ref": "lipsColor", "rgba": [0.631, 0.141, 0.329, 0.95] },
              { "kind": "bool",  "ref": "lipsEnabled", "value": 1 }
            ]},
          { "id": "showtime",  "displayName": "Showtime",  "color": "#FF2D5A", "isPro": false,
            "parameters": [
              { "kind": "color", "ref": "lipsColor", "rgba": [1.0, 0.176, 0.353, 0.95] },
              { "kind": "bool",  "ref": "lipsEnabled", "value": 1 }
            ]},
          { "id": "vamp",      "displayName": "Vamp",      "color": "#5A0A2A", "isPro": true,
            "parameters": [
              { "kind": "color", "ref": "lipsColor", "rgba": [0.353, 0.039, 0.165, 0.95] },
              { "kind": "bool",  "ref": "lipsEnabled", "value": 1 }
            ]}
        ]
      }
    ],
    "looks": [
      {
        "id": "legacy01",
        "displayName": "Bubblegum",
        "file": "look_legacy01.deepar",
        "thumbnail": "thumbnails/legacy01.png",
        "tag": "CUTE",
        "hot": true,
        "isPro": false,
        "shades": []
      },
      {
        "id": "legacy02",
        "displayName": "Showtime",
        "file": "look_legacy02.deepar",
        "thumbnail": "thumbnails/legacy02.png",
        "tag": "BOLD",
        "hot": true,
        "isPro": false,
        "shades": []
      }
    ]
  }
}

CREATE placeholder thumbnails: 720×720 PNG files at GRWMStudio/Resources/Effects/thumbnails/{baseBeauty,filter,shadow,brows,cheeks,lipstick,legacy01,legacy02}.png. For now they can be solid-color squares matching the shade row colors. Real thumbnails replace these in a later asset pass.

WIRE catalog load at app launch. UPDATE GRWMStudio/App/RootContainer.swift to add:

.task {
    do {
        _ = try await EffectCatalog.shared.load()
        Logger.deepAR.info("Effect catalog loaded")
    } catch {
        Logger.deepAR.error("Catalog load failed: \(error.localizedDescription)")
        coordinator.presentError(.effectFail)  // for now; we'll refine in GRWM-803
    }
}

CREATE GRWMStudioTests/DeepAR/EffectCatalogTests.swift:

import XCTest
@testable import GRWMStudio

final class EffectCatalogTests: XCTestCase {
    func testManifestLoads() async throws {
        let root = try await EffectCatalog.shared.load()
        XCTAssertEqual(root.version, 1)
        XCTAssertNotNil(root.effects[MakeupCategory.skin.id])
    }

    func testAllCategoriesHaveAtLeastOneEffect() async throws {
        let root = try await EffectCatalog.shared.load()
        for category in MakeupCategory.allCases {
            let effects = root.effects[category.id] ?? []
            XCTAssertFalse(effects.isEmpty, "Missing effects for category \(category.id)")
        }
    }

    func testEveryParameterRefResolves() async throws {
        let root = try await EffectCatalog.shared.load()
        for (_, effects) in root.effects {
            for effect in effects {
                for shade in effect.shades {
                    for param in shade.parameters {
                        XCTAssertNotNil(EffectParameterMap.resolve(param.ref),
                                        "Unresolved ref: \(param.ref) in shade \(shade.id)")
                    }
                }
            }
        }
    }

    func testEffectFilesExist() async throws {
        let root = try await EffectCatalog.shared.load()
        for (_, effects) in root.effects {
            for effect in effects {
                XCTAssertNoThrow(try effect.bundleURL(),
                                 "Missing bundle file: \(effect.file)")
            }
        }
    }
}

Run xcodebuild test -only-testing:GRWMStudioTests/EffectCatalogTests — all four tests should pass.
````

---

## GRWM-109 — Permissions service

**Goal:** Real `PermissionsService` wraps AVCaptureDevice + PHPhotoLibrary + UNUserNotificationCenter. Replaces the stub from GRWM-009.

**Prereqs:** GRWM-009.

**Files:**
- `GRWMStudio/Permissions/PermissionsService.swift` (replace protocol)
- `GRWMStudio/Permissions/DefaultPermissionsService.swift`
- `GRWMStudio/Permissions/AppPermissionStatus.swift`
- `GRWMStudio/App/AppEnvironment.swift` (update to use real impl)
- `GRWMStudioTests/Permissions/PermissionsServiceTests.swift`

**Acceptance criteria:**
- [ ] `AppPermissionStatus` enum: `notDetermined`, `granted`, `denied`, `restricted`
- [ ] `PermissionsService` protocol async methods: `cameraStatus()`, `requestCamera() async -> AppPermissionStatus`, same for `mic`/`photos`/`notifications`
- [ ] `DefaultPermissionsService` implements with real system frameworks
- [ ] All requests are `@MainActor` and use modern async/await wrappers
- [ ] Unit tests use `MockPermissionsService` (different file, in tests target) verifying logic that depends on permission states

**Prompt:**

````
Implement the real Permissions service.

CREATE GRWMStudio/Permissions/AppPermissionStatus.swift:

public enum AppPermissionStatus: String, Sendable, Equatable {
    case notDetermined, granted, denied, restricted
}

REPLACE GRWMStudio/Permissions/PermissionsService.swift:

import AVFoundation
import Photos
import UserNotifications

public protocol PermissionsService: Sendable {
    func cameraStatus() async -> AppPermissionStatus
    func requestCamera() async -> AppPermissionStatus

    func micStatus() async -> AppPermissionStatus
    func requestMic() async -> AppPermissionStatus

    func photosAddStatus() async -> AppPermissionStatus
    func requestPhotosAdd() async -> AppPermissionStatus

    func notificationsStatus() async -> AppPermissionStatus
    func requestNotifications() async -> AppPermissionStatus
}

CREATE GRWMStudio/Permissions/DefaultPermissionsService.swift:

import AVFoundation
import Photos
import UserNotifications

public struct DefaultPermissionsService: PermissionsService {
    public init() {}

    public func cameraStatus() async -> AppPermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: return .notDetermined
        case .authorized:    return .granted
        case .denied:        return .denied
        case .restricted:    return .restricted
        @unknown default:    return .denied
        }
    }

    public func requestCamera() async -> AppPermissionStatus {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted ? .granted : .denied
    }

    public func micStatus() async -> AppPermissionStatus {
        switch AVAudioApplication.shared.recordPermission {
        case .undetermined: return .notDetermined
        case .granted:      return .granted
        case .denied:       return .denied
        @unknown default:   return .denied
        }
    }

    public func requestMic() async -> AppPermissionStatus {
        let granted = await AVAudioApplication.requestRecordPermission()
        return granted ? .granted : .denied
    }

    public func photosAddStatus() async -> AppPermissionStatus {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .notDetermined: return .notDetermined
        case .authorized:    return .granted
        case .limited:       return .granted
        case .denied:        return .denied
        case .restricted:    return .restricted
        @unknown default:    return .denied
        }
    }

    public func requestPhotosAdd() async -> AppPermissionStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        switch status {
        case .authorized, .limited: return .granted
        case .denied:               return .denied
        case .restricted:           return .restricted
        case .notDetermined:        return .notDetermined
        @unknown default:           return .denied
        }
    }

    public func notificationsStatus() async -> AppPermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .authorized, .provisional, .ephemeral: return .granted
        case .denied: return .denied
        @unknown default: return .denied
        }
    }

    public func requestNotifications() async -> AppPermissionStatus {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted ? .granted : .denied
        } catch {
            return .denied
        }
    }
}

UPDATE GRWMStudio/App/AppEnvironment.swift to use DefaultPermissionsService() as the default. Remove the StubPermissionsService.

CREATE GRWMStudioTests/Permissions/PermissionsServiceTests.swift with a MockPermissionsService:

final class MockPermissionsService: PermissionsService {
    var camera: AppPermissionStatus = .notDetermined
    var mic: AppPermissionStatus = .notDetermined
    var photos: AppPermissionStatus = .notDetermined
    var notifications: AppPermissionStatus = .notDetermined
    var requestedCamera = false, requestedMic = false, requestedPhotos = false, requestedNotifs = false

    func cameraStatus() async -> AppPermissionStatus { camera }
    func requestCamera() async -> AppPermissionStatus {
        requestedCamera = true
        if camera == .notDetermined { camera = .granted }
        return camera
    }
    // ... etc for other methods
}

Add a few tests to verify the mock behaves correctly. Real-impl tests run only on device; we don't include them in CI.
````

---

## GRWM-110 — RecordingService (photos + videos)

**Goal:** High-level photo/video API atop `DeepARController`, writing to `Documents/captures/`.

**Prereqs:** GRWM-104, GRWM-106, GRWM-107.

**Files:**
- `GRWMStudio/DeepAR/RecordingService.swift`
- `GRWMStudio/Capture/CaptureService.swift`
- `GRWMStudio/Utilities/URL+Documents.swift`
- `GRWMStudio/DeepAR/DeepARController.swift` (update — capturePhoto/startVideoRecording/stopVideoRecording)
- `GRWMStudio/DeepAR/DeepARDelegateProxy.swift` (update — didTakeScreenshot, didStartVideoRecording, didFinishVideoRecording, recordingFailedWithError)

**Acceptance criteria:**
- [ ] `URL.documentsCapturesURL` returns `Documents/captures/`, creating the directory if missing
- [ ] `CaptureService.writeImage(_:)` writes a JPEG (quality 0.92) to a UUID filename, returns the URL
- [ ] `DeepARController.capturePhoto()` triggers `takeScreenshot()`, awaits `didTakeScreenshot` delegate, writes to disk, returns URL (4s timeout)
- [ ] `DeepARController.startVideoRecording(maxDuration:)` calls `startVideoRecording(withOutputWidth:outputHeight:)` (720×1280), starts a Timer that auto-stops at maxDuration, sets `isRecordingVideo = true`
- [ ] `DeepARController.stopVideoRecording()` calls `finishVideoRecording()`, awaits delegate, moves the temp file to `Documents/captures/<UUID>.mp4`, returns URL
- [ ] `RecordingService` exposes `takePhoto() async throws -> URL` and `startVideo(maxDuration:onTick:) → stopVideo()` API
- [ ] All errors map to the right `ErrorVariant` (recFail, saveFail)

**Prompt:**

````
Implement photo and video capture end-to-end.

CREATE GRWMStudio/Utilities/URL+Documents.swift:

extension URL {
    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static var documentsCapturesURL: URL {
        let url = documentsURL.appendingPathComponent("captures", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
}

CREATE GRWMStudio/Capture/CaptureService.swift:

import UIKit

public actor CaptureService {
    public init() {}

    @discardableResult
    public static func writeImage(_ image: UIImage) throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.92) else {
            throw NSError(domain: "CaptureService", code: 1, userInfo: [NSLocalizedDescriptionKey: "JPEG encoding failed"])
        }
        let url = URL.documentsCapturesURL.appendingPathComponent("\(UUID()).jpg")
        try data.write(to: url, options: .atomic)
        return url
    }

    @discardableResult
    public static func moveVideo(from sourcePath: String) throws -> URL {
        let src = URL(fileURLWithPath: sourcePath)
        let dst = URL.documentsCapturesURL.appendingPathComponent("\(UUID()).mp4")
        try FileManager.default.moveItem(at: src, to: dst)
        return dst
    }
}

UPDATE GRWMStudio/DeepAR/DeepARController.swift — replace photo/video stubs:

public func capturePhoto() async throws -> URL {
    guard state == .ready, let deepAR = _deepAR else {
        throw SetupError.captureFailed(reason: "DeepAR not ready")
    }
    return try await withTimeout(.seconds(4)) { [weak self] in
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<URL, Error>) in
            Task { @MainActor in
                guard let self else {
                    cont.resume(throwing: SetupError.captureFailed(reason: "Controller deallocated"))
                    return
                }
                self.photoContinuation = cont
                deepAR.takeScreenshot()  // triggers didTakeScreenshot delegate
            }
        }
    }
}

public func startVideoRecording(maxDuration: TimeInterval) async throws {
    guard state == .ready, let deepAR = _deepAR else {
        throw SetupError.recordingFailed(reason: "DeepAR not ready")
    }
    guard !isRecordingVideo else { return }
    deepAR.startVideoRecording(withOutputWidth: 720, outputHeight: 1280)
    isRecordingVideo = true
    recordingDuration = 0
    Logger.deepAR.info("Started video recording (max: \(maxDuration)s)")

    // Auto-stop timer
    Task { [weak self] in
        let start = Date()
        while let self, self.isRecordingVideo {
            try? await Task.sleep(for: .milliseconds(100))
            await MainActor.run {
                self.recordingDuration = Date().timeIntervalSince(start)
            }
            if Date().timeIntervalSince(start) >= maxDuration {
                _ = try? await self?.stopVideoRecording()
                break
            }
        }
    }
}

public func stopVideoRecording() async throws -> URL {
    guard isRecordingVideo, let deepAR = _deepAR else {
        throw SetupError.recordingFailed(reason: "Not recording")
    }
    return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<URL, Error>) in
        Task { @MainActor in
            self.videoContinuation = cont
            deepAR.finishVideoRecording()
        }
    }
}

UPDATE GRWMStudio/DeepAR/DeepARDelegateProxy.swift — wire delegates:

func didTakeScreenshot(_ screenshot: UIImage) {
    Logger.deepAR.info("didTakeScreenshot")
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

func didStartVideoRecording() {
    Logger.deepAR.info("didStartVideoRecording")
}

func didFinishVideoRecording(_ videoFilePath: String) {
    Logger.deepAR.info("didFinishVideoRecording: \(videoFilePath)")
    Task { @MainActor in
        guard let c = controller else { return }
        c.isRecordingVideo = false
        do {
            let url = try CaptureService.moveVideo(from: videoFilePath)
            c.videoContinuation?.resume(returning: url)
        } catch {
            c.videoContinuation?.resume(throwing: error)
        }
        c.videoContinuation = nil
    }
}

func recordingFailedWithError(_ error: Error) {
    Logger.deepAR.error("recordingFailedWithError: \(error.localizedDescription)")
    Task { @MainActor in
        guard let c = controller else { return }
        c.isRecordingVideo = false
        c.videoContinuation?.resume(throwing:
            DeepARController.SetupError.recordingFailed(reason: error.localizedDescription))
        c.videoContinuation = nil
        c.photoContinuation?.resume(throwing:
            DeepARController.SetupError.captureFailed(reason: error.localizedDescription))
        c.photoContinuation = nil
    }
}

CREATE GRWMStudio/DeepAR/RecordingService.swift — a thin facade:

@MainActor
public final class RecordingService {
    private let controller: DeepARController
    public init(controller: DeepARController) { self.controller = controller }

    public func takePhoto() async throws -> URL {
        try await controller.capturePhoto()
    }

    public func startVideo(maxDuration: TimeInterval) async throws {
        try await controller.startVideoRecording(maxDuration: maxDuration)
    }

    public func stopVideo() async throws -> URL {
        try await controller.stopVideoRecording()
    }
}

ON-DEVICE VERIFY:
1. Bootstrap, start camera, load baseBeauty
2. Tap a debug "📸 Photo" button → calls capturePhoto()
3. Confirm: file exists at Documents/captures/<UUID>.jpg, ~2-5MB, openable in Photos app via share sheet
4. Tap "🎥 Start" → recording → tap "⏹ Stop" 5s later → file exists at <UUID>.mp4, plays back correctly with audio
5. Verify auto-stop: start a recording with maxDuration: 3 → after 3s, isRecordingVideo flips false and a video file is saved
````

---


# Phase 2 — Onboarding (5 screens)

The 5 onboarding screens, each its own ticket, plus the router. By end of phase: launch the app cold → splash → welcome → parent info → permissions → enter app shell.

---

## GRWM-200 — Onboarding state + router

**Goal:** `OnboardingState` tracks completion; the coordinator advances through screens correctly.

**Prereqs:** GRWM-009.

**Files:**
- `GRWMStudio/Onboarding/OnboardingState.swift`
- `GRWMStudio/App/RootCoordinator.swift` (extend with onboarding-aware transitions)
- `GRWMStudio/App/AppEnvironment.swift` (inject OnboardingState)
- `GRWMStudio/Persistence/ProfileRecord.swift` (placeholder if not yet created — used to detect "first launch")

**Acceptance criteria:**
- [ ] `OnboardingState` is `@MainActor @Observable` with `hasCompletedOnboarding: Bool` (UserDefaults-backed under key `dh_onboarding_complete`)
- [ ] On `RootContainer.task`, if `state.hasCompletedOnboarding == true`, skip to `.app`; otherwise start at `.onboardingSplash`
- [ ] `coordinator.completeOnboarding()` sets the flag to true and routes to `.app`
- [ ] Each onboarding screen's "next" calls a specific coordinator method (`showWelcome()`, `showParentInfo()`, `showPermissions()`, `enterApp()`)

**Prompt:**

````
Build the onboarding state machine.

CREATE GRWMStudio/Onboarding/OnboardingState.swift:

import SwiftUI

@MainActor @Observable
final class OnboardingState {
    private let defaults = UserDefaults.standard
    private let completionKey = "dh_onboarding_complete"

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: completionKey) }
        set { defaults.set(newValue, forKey: completionKey) }
    }

    func reset() { defaults.removeObject(forKey: completionKey) }
}

UPDATE AppEnvironment to hold the OnboardingState:

@MainActor
final class AppEnvironment {
    let permissions: any PermissionsService
    let analytics: any AnalyticsService
    let onboarding: OnboardingState

    init(...) {
        self.onboarding = OnboardingState()
        // ...
    }
}

UPDATE GRWMStudio/App/RootCoordinator.swift — add `completeOnboarding()`:

func completeOnboarding(env: AppEnvironment) {
    env.onboarding.hasCompletedOnboarding = true
    route = .app
}

UPDATE GRWMStudio/App/RootContainer.swift — on first appearance, route to .app if onboarding already complete:

.task {
    if env.onboarding.hasCompletedOnboarding {
        coordinator.route = .app
    }
    _ = try? await EffectCatalog.shared.load()
}

Add a DEBUG-only button somewhere in app shell or settings to call `env.onboarding.reset()` so testers can re-run onboarding. (Real reset path lands in GRWM-750 Settings.)
````

---

## GRWM-201 — Welcome screen (DHWelcome)

**Goal:** Implement screen 2 — Welcome — pixel-faithful to `DHWelcome` in `dh-screens-1.jsx`.

**Prereqs:** GRWM-200, GRWM-007.

**Files:**
- `GRWMStudio/Onboarding/WelcomeView.swift`
- `GRWMStudio/App/RootContainer.swift` (update)

**Acceptance criteria:**
- [ ] Layout matches DHWelcome: stripe wallpaper, decorative stickers, GRWMLogo `.stack` `.lg`, headline "READY TO PLAY?", body copy "Welcome to your magic makeup studio! ✨", primary DHButton xl "Let's Go!" with sparkle icon
- [ ] Button taps `coordinator.showParentInfo()`
- [ ] All copy matches the JSX verbatim
- [ ] VoiceOver labels for every interactive element
- [ ] `#Preview` renders correctly

**Prompt:**

````
Implement the Welcome onboarding screen exactly matching DHWelcome in docs/design-source/v3/dh-screens-1.jsx.

Open dh-screens-1.jsx and find the export for DHWelcome. Mirror its structure and copy exactly.

CREATE GRWMStudio/Onboarding/WelcomeView.swift:

struct WelcomeView: View {
    @Environment(\.rootCoordinator) private var coordinator

    var body: some View {
        ZStack {
            DHWallpaperStripes().ignoresSafeArea()

            // Decorative stickers — positions per the JSX
            StickerHeart(size: 32, fill: DH.pink).stickerBob()
                .position(x: 50, y: 100).accessibilityHidden(true)
            StickerStar(size: 36, fill: DH.butter).stickerBob(amplitude: 5, period: 2.4)
                .position(x: 340, y: 140).accessibilityHidden(true)
            StickerSparkle(size: 18, fill: .white).stickerBob(amplitude: 3, period: 1.8)
                .position(x: 70, y: 600).accessibilityHidden(true)

            VStack(spacing: 28) {
                Spacer()
                GRWMLogo(layout: .stack, size: .lg).accessibilityLabel("GRWM Studio")

                VStack(spacing: 12) {
                    Text("READY TO PLAY?")
                        .font(DH.font(.display3))
                        .foregroundStyle(DH.pinkDeep)
                        .tracking(DH.tracking(.display3))
                        .multilineTextAlignment(.center)

                    Text("Welcome to your magic makeup studio! ✨")
                        .font(DH.font(.body))
                        .foregroundStyle(DH.pinkDeep.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                DHButton(
                    title: "Let's Go!",
                    kind: .primary,
                    size: .xl,
                    leadingIcon: AnyView(StickerSparkle(size: 22, fill: .white)),
                    isFullWidth: false
                ) {
                    coordinator.showParentInfo()
                }
                .padding(.horizontal, 40)

                Spacer()
                Spacer()
            }
        }
        .preferredColorScheme(.light)
        .accessibilityElement(children: .contain)
    }
}

UPDATE RootContainer to render WelcomeView for case .onboardingWelcome.

VERIFY: Open the JSX file in a browser preview, run the app on device, switch screens side-by-side, confirm visual match.
````

---

## GRWM-202 — Parent Info screen (DHParentInfo)

**Goal:** Screen 3 — collect optional parent email + display name. Both stored locally only.

**Prereqs:** GRWM-201.

**Files:**
- `GRWMStudio/Onboarding/ParentInfoView.swift`
- `GRWMStudio/Persistence/ProfileRecord.swift` (real implementation if not yet)
- `GRWMStudio/App/RootContainer.swift` (update)
- `GRWMStudio/Persistence/AppModelContainer.swift` (SwiftData container)

**Acceptance criteria:**
- [ ] Matches `DHParentInfo` in `dh-screens-6.jsx`
- [ ] Two text fields: "Star name" (required, default "Star"), "Parent's email — optional"
- [ ] "Continue" button (DHButton primary xl, full width) writes a `ProfileRecord` to SwiftData (display name + SHA256 of email if provided), then `coordinator.showPermissions()`
- [ ] "Skip" button (DHButton ghost xl) skips to permissions without saving email
- [ ] Email field validates with `.emailAddress` keyboard, autocorrect off, lowercased
- [ ] If field is filled but invalid format, "Continue" stays enabled but doesn't store the email (adds a small inline warning instead)
- [ ] All copy matches JSX verbatim including the privacy disclosure text

**Prompt:**

````
Implement the ParentInfo onboarding screen matching DHParentInfo in dh-screens-6.jsx.

PRECONDITION — set up SwiftData persistence:

CREATE GRWMStudio/Persistence/ProfileRecord.swift exactly per 04-ARCHITECTURE.md §5.2 (the ProfileRecord @Model definition).

CREATE GRWMStudio/Persistence/AppModelContainer.swift exactly per 04-ARCHITECTURE.md §5.1.

UPDATE GRWMStudioApp.swift body to attach the model container:

WindowGroup {
    RootContainer()
        .environment(\.appEnvironment, environment)
        .environment(\.rootCoordinator, coordinator)
        .modelContainer(AppModelContainer.container)
}

CREATE GRWMStudio/Onboarding/ParentInfoView.swift:

import SwiftUI
import SwiftData
import CryptoKit

struct ParentInfoView: View {
    @Environment(\.rootCoordinator) private var coordinator
    @Environment(\.modelContext) private var modelContext
    @State private var displayName: String = "Star"
    @State private var parentEmail: String = ""
    @State private var emailLooksInvalid: Bool = false
    @FocusState private var focusedField: Field?
    enum Field { case name, email }

    var body: some View {
        ZStack {
            DHWallpaperGradient().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 60)

                Text("HEY THERE,\nSUPERSTAR!")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)
                    .multilineTextAlignment(.leading)

                Text("Tell us your star name and a grown-up's email — we'll keep them safe right on this device.")
                    .font(DH.font(.body))
                    .foregroundStyle(DH.pinkDeep.opacity(0.85))
                    .padding(.bottom, 8)

                DHCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("STAR NAME")
                            .font(DH.font(.caption))
                            .tracking(DH.tracking(.caption))
                            .foregroundStyle(DH.pinkDeep)

                        TextField("", text: $displayName)
                            .font(DH.font(.headline))
                            .foregroundStyle(DH.pinkDeep)
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .background(DH.pinkPaper)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .focused($focusedField, equals: .name)
                            .accessibilityLabel("Star name")
                    }
                }

                DHCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GROWN-UP'S EMAIL — OPTIONAL")
                            .font(DH.font(.caption))
                            .tracking(DH.tracking(.caption))
                            .foregroundStyle(DH.pinkDeep)

                        TextField("parent@example.com", text: $parentEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(DH.font(.body))
                            .foregroundStyle(DH.pinkDeep)
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .background(DH.pinkPaper)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .focused($focusedField, equals: .email)
                            .accessibilityLabel("Parent's email, optional")
                            .onChange(of: parentEmail) { _, new in
                                emailLooksInvalid = !new.isEmpty && !looksLikeEmail(new)
                            }

                        if emailLooksInvalid {
                            Text("Hmm, that doesn't look like an email — we'll skip it.")
                                .font(DH.font(.caption))
                                .foregroundStyle(DH.recRed)
                        }

                        Text("Stays on this device. Never shared.")
                            .font(DH.font(.caption))
                            .tracking(DH.tracking(.caption))
                            .foregroundStyle(DH.pinkDeep.opacity(0.6))
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    DHButton(title: "Continue", kind: .primary, size: .xl, isFullWidth: true) {
                        save()
                        coordinator.showPermissions()
                    }
                    DHButton(title: "Skip for now", kind: .ghost, size: .lg, isFullWidth: true) {
                        coordinator.showPermissions()
                    }
                }
            }
            .padding(.horizontal, DH.Spacing.hPad)
            .padding(.bottom, 36)
        }
        .preferredColorScheme(.light)
    }

    private func looksLikeEmail(_ s: String) -> Bool {
        s.contains("@") && s.contains(".") && s.count >= 5
    }

    private func save() {
        // Try to fetch an existing ProfileRecord; create if missing
        let descriptor = FetchDescriptor<ProfileRecord>()
        let existing = (try? modelContext.fetch(descriptor))?.first
        let record = existing ?? ProfileRecord(displayName: displayName)
        record.displayName = displayName.trimmingCharacters(in: .whitespaces).isEmpty ? "Star" : displayName

        if !parentEmail.isEmpty && looksLikeEmail(parentEmail) {
            // Hash with SHA256 — local-only storage
            let hash = SHA256.hash(data: Data(parentEmail.lowercased().utf8))
            record.parentEmailHashed = hash.compactMap { String(format: "%02x", $0) }.joined()
        }

        if existing == nil { modelContext.insert(record) }
        try? modelContext.save()
    }
}

UPDATE RootContainer.body to render ParentInfoView for `.onboardingParentInfo`.
````

---

## GRWM-203 — Permissions ask screen (DHPermissions)

**Goal:** Screen 4 — show 3 permission rows, request each on tap, advance when camera+mic granted.

**Prereqs:** GRWM-202, GRWM-109.

**Files:**
- `GRWMStudio/Onboarding/PermissionsView.swift`
- `GRWMStudio/Onboarding/PermRow.swift`
- `GRWMStudio/App/RootContainer.swift` (update)

**Acceptance criteria:**
- [ ] Matches `DHPermissions` in `dh-screens-2.jsx`: 3 rows (Camera, Microphone, Photos) with icon, label, status pill, and "Allow" button
- [ ] Each "Allow" button calls the corresponding `PermissionsService.request*()`
- [ ] Status pill updates live: "Asking..." → "Granted ✓" / "Denied ✗"
- [ ] When camera AND mic are granted, the bottom "Continue" button enables
- [ ] If camera OR mic is denied, "Continue" stays disabled and a "If you change your mind, open Settings" link appears
- [ ] Continue → `coordinator.completeOnboarding(env:)`
- [ ] If user denies camera, route to PermissionsDeniedView via `coordinator.showPermissionsDenied()`

**Prompt:**

````
Implement the Permissions onboarding screen matching DHPermissions in dh-screens-2.jsx.

CREATE GRWMStudio/Onboarding/PermRow.swift — a reusable row component:

struct PermRow: View {
    let title: String
    let description: String
    let iconSystemName: String
    let status: AppPermissionStatus
    let isRequesting: Bool
    let onAllow: () -> Void

    var body: some View {
        DHCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(DH.pinkPaper)
                        .frame(width: 56, height: 56)
                    Image(systemName: iconSystemName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(DH.pinkDeep)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(DH.font(.headline)).foregroundStyle(DH.pinkDeep)
                    Text(description).font(DH.font(.body)).foregroundStyle(DH.pinkDeep.opacity(0.7))
                }

                Spacer()

                statusBadge
            }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .notDetermined:
            DHButton(title: "Allow", kind: .primary, size: .sm, action: onAllow)
        case .granted:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                Text("Granted")
            }
            .font(DH.font(.caption)).foregroundStyle(DH.pinkDeep)
            .padding(.horizontal, 12).frame(height: 32)
            .background(Capsule().fill(DH.mint))
        case .denied, .restricted:
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle.fill")
                Text(status == .restricted ? "Restricted" : "Denied")
            }
            .font(DH.font(.caption)).foregroundStyle(.white)
            .padding(.horizontal, 12).frame(height: 32)
            .background(Capsule().fill(DH.recRed))
        }
    }
}

CREATE GRWMStudio/Onboarding/PermissionsView.swift:

struct PermissionsView: View {
    @Environment(\.rootCoordinator) private var coordinator
    @Environment(\.appEnvironment) private var env

    @State private var camera: AppPermissionStatus = .notDetermined
    @State private var mic: AppPermissionStatus = .notDetermined
    @State private var photos: AppPermissionStatus = .notDetermined

    var body: some View {
        ZStack {
            DHWallpaperGradient().ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 60)

                Text("LET'S TURN ON\nTHE MAGIC")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)

                Text("We need a few things to make the magic mirror work. We'll only use them while you're playing.")
                    .font(DH.font(.body))
                    .foregroundStyle(DH.pinkDeep.opacity(0.85))

                VStack(spacing: 12) {
                    PermRow(
                        title: "Camera",
                        description: "So you can see yourself in the mirror.",
                        iconSystemName: "camera.fill",
                        status: camera,
                        isRequesting: false
                    ) {
                        Task { camera = await env.permissions.requestCamera() }
                    }
                    PermRow(
                        title: "Microphone",
                        description: "So we can hear you in your videos.",
                        iconSystemName: "mic.fill",
                        status: mic,
                        isRequesting: false
                    ) {
                        Task { mic = await env.permissions.requestMic() }
                    }
                    PermRow(
                        title: "Photos",
                        description: "So we can save your looks to your phone.",
                        iconSystemName: "photo.fill",
                        status: photos,
                        isRequesting: false
                    ) {
                        Task { photos = await env.permissions.requestPhotosAdd() }
                    }
                }

                Spacer()

                if (camera == .denied || mic == .denied) {
                    Text("If you change your mind, you can turn these on in Settings.")
                        .font(DH.font(.caption))
                        .foregroundStyle(DH.pinkDeep.opacity(0.7))
                }

                DHButton(
                    title: "Continue",
                    kind: .primary,
                    size: .xl,
                    isFullWidth: true
                ) {
                    if camera == .granted && mic == .granted {
                        coordinator.completeOnboarding(env: env)
                    } else if camera == .denied {
                        coordinator.showPermissionsDenied()
                    }
                }
                .opacity((camera == .granted && mic == .granted) ? 1 : 0.5)
                .disabled(!(camera == .granted && mic == .granted))
            }
            .padding(.horizontal, DH.Spacing.hPad)
            .padding(.bottom, 36)
        }
        .task {
            camera = await env.permissions.cameraStatus()
            mic = await env.permissions.micStatus()
            photos = await env.permissions.photosAddStatus()
        }
        .preferredColorScheme(.light)
    }
}

UPDATE RootContainer to render PermissionsView for `.onboardingPermissions`.

VERIFY ON DEVICE:
1. Reset app's permissions: Settings > GRWM Studio > toggle each permission off
2. Run app, complete welcome+parent-info, reach permissions
3. Tap "Allow" on Camera → system prompt appears → tap Allow → status flips to "Granted"
4. Repeat for Mic and Photos
5. Once camera+mic granted, "Continue" becomes active
6. Tap Continue → app shell appears
````

---

## GRWM-204 — Permissions denied screen (DHPermissionsDenied)

**Goal:** Screen 5 — fallback when user denies camera. Shows "Open Settings" CTA.

**Prereqs:** GRWM-203.

**Files:**
- `GRWMStudio/Onboarding/PermissionsDeniedView.swift`
- `GRWMStudio/App/RootContainer.swift` (update)

**Acceptance criteria:**
- [ ] Matches `DHPermissionsDenied` in `dh-screens-6.jsx`
- [ ] Sad camera illustration, "WE NEED YOUR CAMERA" headline, body explanation
- [ ] Primary CTA "Open Settings" → opens `UIApplication.openSettingsURLString`
- [ ] Secondary "Try again" → re-asks via `permissions.requestCamera()`. If `.granted` → completeOnboarding. Else stays here.
- [ ] When user returns from Settings (via `.onChange(of: scenePhase)` or `.task`), re-checks status; if granted, advance

**Prompt:**

````
Implement DHPermissionsDenied from dh-screens-6.jsx.

CREATE GRWMStudio/Onboarding/PermissionsDeniedView.swift:

struct PermissionsDeniedView: View {
    @Environment(\.rootCoordinator) private var coordinator
    @Environment(\.appEnvironment) private var env
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            DHWallpaperGradient().ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Sad camera illustration — chunky pink camera with a frown
                ZStack {
                    Circle()
                        .fill(DH.pinkPaper)
                        .frame(width: 180, height: 180)
                        .chunkyShadow(.md(deep: DH.pink), shape: Circle())

                    Image(systemName: "camera.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(DH.pinkDeep)

                    // Sad face overlay
                    Image(systemName: "face.smiling")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundStyle(DH.recRed)
                        .rotationEffect(.degrees(180))
                        .offset(y: 56)
                }
                .accessibilityHidden(true)

                Text("WE NEED YOUR CAMERA")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)
                    .multilineTextAlignment(.center)

                Text("Without the camera, the magic mirror can't work. Please turn it on in Settings — we'll be right here when you get back!")
                    .font(DH.font(.body))
                    .foregroundStyle(DH.pinkDeep.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 12) {
                    DHButton(title: "Open Settings", kind: .primary, size: .xl, isFullWidth: true) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    DHButton(title: "Try again", kind: .ghost, size: .lg, isFullWidth: true) {
                        Task {
                            let status = await env.permissions.requestCamera()
                            if status == .granted {
                                let mic = await env.permissions.requestMic()
                                if mic == .granted {
                                    coordinator.completeOnboarding(env: env)
                                } else {
                                    coordinator.showPermissions()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, DH.Spacing.hPad)
                .padding(.bottom, 36)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    let status = await env.permissions.cameraStatus()
                    if status == .granted {
                        let mic = await env.permissions.micStatus()
                        if mic == .granted {
                            coordinator.completeOnboarding(env: env)
                        } else {
                            coordinator.showPermissions()
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

UPDATE RootContainer to render PermissionsDeniedView for `.onboardingPermissionsDenied`.

VERIFY:
1. Run with all permissions denied (Settings > GRWM Studio > Camera off)
2. Complete onboarding to permissions screen, tap Allow on Camera, system prompt → tap Don't Allow
3. Coordinator routes to PermissionsDenied screen
4. Tap "Open Settings" → opens iOS Settings app for GRWM Studio
5. Re-enable Camera, return to app
6. App detects active scenePhase + granted status, advances automatically
````

---

## GRWM-205 — App shell with tab bar

**Goal:** After onboarding, the app shell with the 5-tab DHTabBar shows. Each tab renders a placeholder for now.

**Prereqs:** GRWM-200, GRWM-007 (DHTabBar).

**Files:**
- `GRWMStudio/App/AppShell.swift`
- `GRWMStudio/App/RootContainer.swift` (update — render AppShell for .app)

**Acceptance criteria:**
- [ ] AppShell uses `TabView` with 5 tabs: Mirror, Looks, FAB (center), Feed, Locker
- [ ] DHTabBar floats over the tab content per the design
- [ ] Each tab content is a placeholder Text view (real content in later phases)
- [ ] FAB tap routes to Mirror with a "create new" intent (set a flag on the env that MirrorView reads)
- [ ] Selected tab persists across app relaunches (UserDefaults)

**Prompt:**

````
Build the AppShell with the 5-tab bar.

CREATE GRWMStudio/App/AppShell.swift:

import SwiftUI

struct AppShell: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator
    @State private var selected: DHTab = .mirror

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                DHWallpaperGradient().ignoresSafeArea()
                Group {
                    switch selected {
                    case .mirror:  Text("Mirror Tab — wired in GRWM-300").font(DH.font(.headline))
                    case .looks:   Text("Looks Library — wired in GRWM-500").font(DH.font(.headline))
                    case .fab:     EmptyView()  // FAB doesn't render content; it triggers nav
                    case .feed:    Text("Feed — wired in GRWM-602").font(DH.font(.headline))
                    case .locker:  Text("Locker — wired in GRWM-503").font(DH.font(.headline))
                    }
                }
            }

            DHTabBar(selected: $selected, onFABTap: {
                // FAB always routes to mirror with "fresh" intent
                selected = .mirror
                // We'll set an env flag here when needed in Phase 3
            })
            .padding(.horizontal, 14)
            .padding(.bottom, 18)
        }
        .preferredColorScheme(.light)
        .onChange(of: selected) { _, new in
            UserDefaults.standard.set(new.rawValue, forKey: "dh_last_tab")
        }
        .onAppear {
            if let raw = UserDefaults.standard.string(forKey: "dh_last_tab"),
               let tab = DHTab(rawValue: raw), tab != .fab {
                selected = tab
            }
        }
    }
}

UPDATE RootContainer body for `.app` case:

case .app: AppShell()

VERIFY: complete onboarding once. Confirm app shell appears with all 5 tabs. Tap Mirror, Looks, Feed, Locker — each shows the placeholder text. Tap FAB — selected tab returns to Mirror.
````

---

---

# Phase 3 — Mirror & filters (GRWM-300 – GRWM-315)

This is the heart of the app. Every screen here is wired to `DeepARController` and `EffectCatalog` from Phase 1. Reference design: `docs/design-source/v3/v01-mirror.jsx` (the full V01 Dreamhouse mirror). Reference the secondary mirror states in `docs/design-source/v3/screens-6.jsx` (countdown / recording / pro gate).

---

## GRWM-300 — MirrorView shell + DeepARView mount

**Goal:** The Mirror tab renders the live AR camera filling the safe area with the V01 Dreamhouse chrome (top status pills, side ornaments, bottom rail spacer). No filter UI yet — just the camera with a transparent passthrough.

**Prereqs:** GRWM-107 (DeepARView), GRWM-108 (EffectCatalog), GRWM-205 (AppShell).

**Files:**
- `GRWMStudio/Mirror/MirrorView.swift`
- `GRWMStudio/Mirror/MirrorChrome.swift`
- `GRWMStudio/App/AppShell.swift` (update — render `MirrorView()` for `.mirror`)

**Acceptance criteria:**
- [ ] `MirrorView` lays out exactly like the camera region in `docs/design-source/v3/v01-mirror.jsx` lines that show the AR feed inside the GPhone — full-bleed feed clipped to a 28pt corner radius, with a 6pt white border ring.
- [ ] Top chrome: a chunky pink "GRWM" wordmark left, a heart sticker right (use `GRWMLogo` and `StickerHeart` from DH primitives).
- [ ] Bottom of the camera region leaves a 220pt pad for the upcoming filter rail and capture FAB.
- [ ] Camera starts the moment the view appears and stops when the view disappears (use `.task { await vm.start() }` and `.onDisappear { vm.pause() }`).
- [ ] If permissions are not yet granted, MirrorView shows the chunky "Tap to allow camera 💕" placeholder (DHCard with butter background) and routes to `OnboardingPermissionsView` on tap. No system prompt is triggered before user tap.

**Prompt:**

````
Build the MirrorView shell with live DeepAR camera.

CONTEXT:
- DeepARView SwiftUI representable exists from GRWM-107
- DeepARController and EffectCatalog exist from prior tickets
- MirrorViewModel does NOT exist yet — this ticket is shell only; create a placeholder VM with just `start()` / `pause()` / `state` so MirrorView compiles. Real VM lands in GRWM-301.
- Design reference: docs/design-source/v3/v01-mirror.jsx, focus on the GPhone body containing the camera frame + top wordmark + heart sticker.

CREATE GRWMStudio/Mirror/MirrorView.swift:

import SwiftUI

struct MirrorView: View {
    @State private var vm = MirrorViewModel()
    @Environment(\.appEnvironment) private var env

    var body: some View {
        ZStack(alignment: .top) {
            DHWallpaperGradient().ignoresSafeArea()

            VStack(spacing: 0) {
                MirrorChrome.top()
                    .padding(.horizontal, 18)
                    .padding(.top, 8)

                cameraRegion
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                Spacer(minLength: 220) // Reserved for filter rail + FAB (Phase 3 + 4)
            }
        }
        .task { await vm.start(env: env) }
        .onDisappear { vm.pause() }
    }

    @ViewBuilder
    private var cameraRegion: some View {
        switch vm.state {
        case .needsPermission:
            DHCard(color: DH.butter) {
                Text("Tap to allow camera 💕")
                    .font(DH.font(.headline))
                    .foregroundStyle(DH.ink)
                    .padding(40)
            }
            .onTapGesture { /* coordinator route to permissions */ }
        case .running, .starting:
            DeepARView(controller: vm.controller)
                .aspectRatio(3.0/4.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(.white, lineWidth: 6)
                )
                .shadow(color: DH.pinkDeep.opacity(0.35), radius: 0, x: 0, y: 7)
        case .failed(let reason):
            // Will be replaced in GRWM-315
            DHCard(color: DH.cream) {
                Text("Mirror error: \(reason)")
                    .font(DH.font(.body))
            }
        }
    }
}

CREATE GRWMStudio/Mirror/MirrorChrome.swift with `top()` returning HStack { GRWMLogo; Spacer; StickerHeart }.

UPDATE AppShell — replace the placeholder `Text("Mirror Tab — wired in GRWM-300")` with `MirrorView()`.

VERIFY:
1. Cold launch with permissions granted → camera feed appears within 1.5s, framed by white ring + chunky pink shadow
2. Pull tab away to Looks → camera audibly stops (CameraController.stopCamera in console log via OSLog)
3. Return to tab → camera restarts
4. Wipe permissions → chunky butter card "Tap to allow camera 💕" shows; tapping it calls coordinator (verify via os_log breadcrumb only — full route lands in GRWM-301)
````

---

## GRWM-301 — MirrorViewModel + state machine

**Goal:** Replace the placeholder VM with the real `@Observable` MirrorViewModel that owns DeepARController, current shade selection per slot, no-face state, and exposes async actions for filter selection.

**Prereqs:** GRWM-300, GRWM-105 (EffectParameterMap), GRWM-106 (Runtime parameter API), GRWM-108 (EffectCatalog).

**Files:**
- `GRWMStudio/Mirror/MirrorViewModel.swift`
- `GRWMStudio/Mirror/MirrorState.swift`
- `GRWMStudio/Mirror/SlotSelection.swift`

**Acceptance criteria:**
- [ ] State enum has cases: `.idle`, `.starting`, `.running`, `.needsPermission`, `.failed(ErrorVariant)`.
- [ ] `selections: [EffectSlot: SlotSelection]` is the source of truth; `SlotSelection` carries `effectID: String?`, `shade: Shade?`, `isPro: Bool`.
- [ ] `selectShade(in: EffectSlot, shade:)` is `@MainActor async`. It (a) checks Pro entitlement; (b) loads effect file via EffectCatalog if not loaded for this slot; (c) applies parameters via DeepARController; (d) updates `selections[slot]`.
- [ ] When the user picks a `.looks` preset, all other slots are virtually overridden — VM clears `selections[other]` and loads the looks effect into the looks slot, which has texture priority.
- [ ] `clear(slot:)` removes selection and unloads effect from that slot via `DeepARController.clearSlot`.
- [ ] `isFaceDetected: Bool` updates from DeepARDelegateProxy.faceVisibilityChanged stream.
- [ ] All controller calls happen on `@MainActor`; networking (catalog fetch) happens off-main.

**Prompt:**

````
Build the real MirrorViewModel.

CONTEXT:
- EffectCatalog (actor) returns local URLs for .deepar files keyed by effect ID
- DeepARController has bootstrap, loadEffect(slot:url:), changeParameter, clearSlot, capturePhoto, startVideo, stopVideo
- DeepARDelegateProxy publishes faceVisibilityChanged via AsyncStream
- Pro entitlement is read from env.entitlements (already wired in GRWM-009)

CREATE GRWMStudio/Mirror/MirrorState.swift:

enum MirrorState: Equatable {
    case idle
    case starting
    case running
    case needsPermission
    case failed(ErrorVariant)
}

CREATE GRWMStudio/Mirror/SlotSelection.swift:

struct SlotSelection: Equatable, Sendable {
    let effectID: String
    let shade: Shade
    let isPro: Bool
}

CREATE GRWMStudio/Mirror/MirrorViewModel.swift:

import Foundation
import Observation
import os

@Observable @MainActor
final class MirrorViewModel {
    let controller: DeepARController
    let catalog: EffectCatalog
    private var env: AppEnvironment!
    private var faceTask: Task<Void, Never>?
    private let log = Logger(subsystem: "app.grwmstudio.ios", category: "Mirror")

    private(set) var state: MirrorState = .idle
    private(set) var selections: [EffectSlot: SlotSelection] = [:]
    private(set) var isFaceDetected: Bool = false
    private(set) var lastError: ErrorVariant?

    init(controller: DeepARController = .shared, catalog: EffectCatalog = .shared) {
        self.controller = controller
        self.catalog = catalog
    }

    func start(env: AppEnvironment) async {
        self.env = env
        state = .starting
        guard env.permissions.camera == .granted else { state = .needsPermission; return }
        do {
            try await controller.bootstrap(licenseKey: env.deepARLicenseKey)
            try await controller.startCamera()
            state = .running
            faceTask = Task { [weak self] in
                guard let self else { return }
                for await visible in await self.controller.faceVisibilityStream {
                    self.isFaceDetected = visible
                }
            }
        } catch {
            log.error("bootstrap failed: \(error.localizedDescription)")
            state = .failed(.effectFail) // Distinguish: license vs effect-fail in GRWM-302
            lastError = .effectFail
        }
    }

    func pause() {
        faceTask?.cancel()
        Task { try? await controller.stopCamera() }
    }

    func selectShade(in slot: EffectSlot, shade: Shade) async {
        if shade.isPro && !env.entitlements.hasPro {
            lastError = .license
            return
        }
        do {
            // Looks preset overrides others
            if slot == .looks {
                for other in EffectSlot.allCases where other != .looks {
                    selections.removeValue(forKey: other)
                    try await controller.clearSlot(other)
                }
            }
            let effectID = shade.effectID
            if selections[slot]?.effectID != effectID {
                let url = try await catalog.url(for: effectID)
                try await controller.loadEffect(slot: slot, url: url)
            }
            try await applyShadeParameters(shade, slot: slot)
            selections[slot] = SlotSelection(effectID: effectID, shade: shade, isPro: shade.isPro)
        } catch {
            log.error("selectShade failed: \(error.localizedDescription)")
            lastError = .effectFail
        }
    }

    func clear(slot: EffectSlot) async {
        do {
            try await controller.clearSlot(slot)
            selections.removeValue(forKey: slot)
        } catch {
            log.error("clear slot failed: \(error.localizedDescription)")
        }
    }

    private func applyShadeParameters(_ shade: Shade, slot: EffectSlot) async throws {
        for param in shade.parameters {
            switch param.value {
            case .color(let rgba):
                try await controller.setColor(ref: param.ref, rgba: rgba)
            case .texture(let assetName):
                guard let img = UIImage(named: assetName) else { throw EffectError.missingTexture(assetName) }
                try await controller.setTexture(ref: param.ref, image: img)
            case .blendshape(let f):
                try await controller.setBlendshape(ref: param.ref, value: f)
            case .enabled(let b):
                try await controller.setEnabled(ref: param.ref, on: b)
            }
        }
    }
}

UPDATE MirrorView to use the real VM. Remove the placeholder.

VERIFY:
1. Cold launch with camera granted → state transitions idle→starting→running within 1.8s
2. Faceless camera → isFaceDetected=false (will surface in GRWM-313)
3. Calling vm.selectShade(.lips, shade: rubyRed) (from a debug menu — wire it up temporarily) applies a red lip color overlay live
4. Switching to a Looks preset clears Eyes/Lips/Cheeks/Brows shade selections
5. clear(.lips) restores natural lips
````

---

## GRWM-302 — License flow + bootstrap error variants

**Goal:** Distinguish bootstrap errors (license vs network vs unknown) and route them to the correct ErrorVariant. The DeepAR license must come from `Config/Secrets.xcconfig` (loaded as a build-time Info.plist key), not hardcoded.

**Prereqs:** GRWM-100 (DeepAR install), GRWM-301 (MirrorViewModel).

**Files:**
- `GRWMStudio/DeepAR/DeepARLicense.swift`
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — use license + variant mapping)

**Acceptance criteria:**
- [ ] `DeepARLicense.key` reads from Info.plist key `DEEPAR_LICENSE_KEY` (which xcconfig populates at build time).
- [ ] If the key is missing or empty, the VM fails with `state = .failed(.licenseInvalid)` and a clear OSLog message; the app does not crash.
- [ ] Bootstrap timeout (8s) → `state = .failed(.effectFail)` (treat as effect/load failure visually).
- [ ] Successful bootstrap is silent.

**Prompt:**

````
Add license loading and bootstrap error mapping.

CREATE GRWMStudio/DeepAR/DeepARLicense.swift:

enum DeepARLicense {
    enum LoadError: Error { case missing, empty }
    static func key() throws -> String {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "DEEPAR_LICENSE_KEY") as? String else {
            throw LoadError.missing
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw LoadError.empty }
        return trimmed
    }
}

UPDATE Info.plist (via Xcode project edit, not raw plist mutation) to include
$(DEEPAR_LICENSE_KEY) referenced from Config/Secrets.xcconfig.

UPDATE MirrorViewModel.start():

func start(env: AppEnvironment) async {
    self.env = env
    state = .starting
    guard env.permissions.camera == .granted else { state = .needsPermission; return }
    let licenseKey: String
    do { licenseKey = try DeepARLicense.key() }
    catch {
        log.error("license missing or empty")
        state = .failed(.licenseInvalid)
        return
    }
    do {
        try await withTimeout(seconds: 8) {
            try await self.controller.bootstrap(licenseKey: licenseKey)
        }
        try await controller.startCamera()
        state = .running
        // ... face stream as before
    } catch is TimeoutError {
        state = .failed(.effectFail)
    } catch {
        state = .failed(.effectFail)
    }
}

ADD .licenseInvalid case to ErrorVariant enum if not already present (it should map to the 'license' variant from screens-8.jsx — but reserve a separate case for "license missing at bootstrap" vs "Pro shade tapped" so error copy can differ).

VERIFY:
1. Build with empty DEEPAR_LICENSE_KEY → app launches, mirror tab shows .failed(.licenseInvalid)
2. Build with valid key → mirror runs normally
3. Simulate slow bootstrap by adding `try await Task.sleep(for: .seconds(10))` inside controller.bootstrap → state moves to .failed(.effectFail) after 8s
````

---

## GRWM-303 — Filter rail UI (category strip)

**Goal:** Build the bottom filter rail showing the 7 categories as chunky chips: Skin, Base, Eyes, Brows, Cheeks, Lips, Looks. Selecting a category opens its shade picker (next ticket). The rail anchors above the capture FAB.

**Prereqs:** GRWM-300, GRWM-002 (DH primitives — DHChip).

**Files:**
- `GRWMStudio/Mirror/FilterRailView.swift`
- `GRWMStudio/Mirror/FilterCategory.swift`
- `GRWMStudio/Mirror/MirrorView.swift` (update — embed FilterRailView)

**Acceptance criteria:**
- [ ] 7 chips horizontally scrollable, each with the category emoji + label per the design (see `docs/design-source/v3/v01-mirror.jsx` filter strip section — chips with category emoji, white card, deep pink shadow).
- [ ] Selected chip swells to 1.06× scale and gets DH.pinkDeep solid background, white text.
- [ ] Tapping a category sets `vm.activeCategory = .skin` (etc.) — the actual shade picker opens via GRWM-304.
- [ ] Looks chip has a tiny gold star sticker overlapping its top-right corner (always-visible affordance).
- [ ] VoiceOver labels: `"Skin filter category, button"`, etc. Selection trait when active.

**Prompt:**

````
Build the FilterRailView.

CREATE GRWMStudio/Mirror/FilterCategory.swift:

enum FilterCategory: String, CaseIterable, Identifiable {
    case skin, base, eyes, brows, cheeks, lips, looks
    var id: String { rawValue }
    var label: String {
        switch self {
        case .skin: "Skin"; case .base: "Base"; case .eyes: "Eyes"
        case .brows: "Brows"; case .cheeks: "Cheeks"; case .lips: "Lips"
        case .looks: "Looks"
        }
    }
    var emoji: String {
        switch self {
        case .skin: "✨"; case .base: "🪞"; case .eyes: "👁️"
        case .brows: "🪞"; case .cheeks: "🌸"; case .lips: "💋"
        case .looks: "💖"
        }
    }
    var slot: EffectSlot {
        switch self {
        case .skin: .skin; case .base: .base; case .eyes: .eyes
        case .brows: .brows; case .cheeks: .cheeks; case .lips: .lips
        case .looks: .looks
        }
    }
}

CREATE GRWMStudio/Mirror/FilterRailView.swift:

struct FilterRailView: View {
    @Bindable var vm: MirrorViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FilterCategory.allCases) { cat in
                    chip(for: cat)
                }
            }
            .padding(.horizontal, 14)
        }
        .frame(height: 64)
    }

    private func chip(for cat: FilterCategory) -> some View {
        let active = vm.activeCategory == cat
        return Button {
            withAnimation(.bouncy(duration: 0.22)) { vm.activeCategory = cat }
            DHHaptics.light()
        } label: {
            HStack(spacing: 6) {
                Text(cat.emoji).font(.system(size: 18))
                Text(cat.label)
                    .font(DH.font(.chip))
                    .foregroundStyle(active ? .white : DH.ink)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(active ? DH.pinkDeep : .white)
            )
            .overlay(alignment: .topTrailing) {
                if cat == .looks {
                    StickerStar(size: 14, fill: DH.butter)
                        .offset(x: 4, y: -4)
                }
            }
            .scaleEffect(active ? 1.06 : 1)
            .dhShadow(color: active ? DH.pinkDeep : DH.pink, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(cat.label) filter category")
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}

UPDATE MirrorViewModel — add `var activeCategory: FilterCategory? = nil` (Observable).

UPDATE MirrorView to overlay FilterRailView at the bottom safe area, above where the capture FAB will land.

VERIFY:
1. Rail scrolls horizontally and snaps naturally
2. Tapping any chip plays the chunky-light haptic
3. Selected chip swells with bouncy animation
4. Looks chip always shows the gold star
5. VoiceOver reads "Skin filter category, button" and announces selection trait correctly
````

---

## GRWM-304 — Skin filter shade picker

**Goal:** When the Skin category is active, a shade tray slides up from the rail with 6–8 skin tone chips (round swatches with name labels). Tapping a swatch applies the skin smoothing/foundation tint via DeepAR.

**Prereqs:** GRWM-303, GRWM-301 (selectShade), GRWM-105 (EffectParameterMap with foundationColor ref).

**Files:**
- `GRWMStudio/Mirror/Shade.swift`
- `GRWMStudio/Mirror/Shades+Skin.swift`
- `GRWMStudio/Mirror/ShadeTrayView.swift`
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — `var activeTraySlot` and tray state)

**Acceptance criteria:**
- [ ] `Shade` struct: `id`, `name`, `swatchColor: Color`, `effectID: String`, `parameters: [EffectParam]`, `isPro: Bool`.
- [ ] `Shades.skin` returns 6 hardcoded inclusive skin tones (Fair, Light, Medium, Tan, Deep, Rich) — naming choice is data-driven, not Pro-locked, all FREE.
- [ ] Tray slides up with bouncy animation (0.32s) anchored above the FilterRail.
- [ ] Tapping a swatch calls `vm.selectShade(.skin, shade:)`, swatch swells + checkmark badge appears.
- [ ] An "X" reset chip on the far left of the tray clears the slot (`vm.clear(slot: .skin)`).
- [ ] Latency from tap → visible change ≤ 80ms on iPhone 12 mini (the Phase 11 perf tests will verify; here just hand-test).

**Prompt:**

````
Build the Skin shade tray.

CREATE GRWMStudio/Mirror/Shade.swift:

struct Shade: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let swatchColor: Color
    let effectID: String
    let parameters: [EffectParam]
    let isPro: Bool
}

struct EffectParam: Hashable, Sendable {
    let ref: String
    let value: ParamValue
}

enum ParamValue: Hashable, Sendable {
    case color(RGBA)
    case texture(String)
    case blendshape(Float)
    case enabled(Bool)
}

CREATE GRWMStudio/Mirror/Shades+Skin.swift:

extension Shade {
    static let skinShades: [Shade] = [
        Shade(id: "skin.fair",   name: "Fair",   swatchColor: Color(hex: 0xFAD9C8),
              effectID: "baseBeauty",
              parameters: [EffectParam(ref: "foundationColor", value: .color(.init(0.98,0.85,0.78,1)))],
              isPro: false),
        Shade(id: "skin.light",  name: "Light",  swatchColor: Color(hex: 0xEFC0A4), effectID: "baseBeauty",
              parameters: [EffectParam(ref: "foundationColor", value: .color(.init(0.93,0.75,0.64,1)))], isPro: false),
        Shade(id: "skin.medium", name: "Medium", swatchColor: Color(hex: 0xCB956E), effectID: "baseBeauty",
              parameters: [EffectParam(ref: "foundationColor", value: .color(.init(0.79,0.58,0.43,1)))], isPro: false),
        Shade(id: "skin.tan",    name: "Tan",    swatchColor: Color(hex: 0xA4724B), effectID: "baseBeauty",
              parameters: [EffectParam(ref: "foundationColor", value: .color(.init(0.64,0.45,0.29,1)))], isPro: false),
        Shade(id: "skin.deep",   name: "Deep",   swatchColor: Color(hex: 0x6F4326), effectID: "baseBeauty",
              parameters: [EffectParam(ref: "foundationColor", value: .color(.init(0.43,0.26,0.15,1)))], isPro: false),
        Shade(id: "skin.rich",   name: "Rich",   swatchColor: Color(hex: 0x42221A), effectID: "baseBeauty",
              parameters: [EffectParam(ref: "foundationColor", value: .color(.init(0.26,0.13,0.10,1)))], isPro: false),
    ]
}

CREATE GRWMStudio/Mirror/ShadeTrayView.swift:

struct ShadeTrayView: View {
    let category: FilterCategory
    let shades: [Shade]
    let selectedID: String?
    let onSelect: (Shade) -> Void
    let onClear: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                clearChip
                ForEach(shades) { s in
                    swatch(s)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.92))
                .dhShadow(color: DH.pink, y: 5)
        )
        .padding(.horizontal, 12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var clearChip: some View {
        Button(action: { onClear(); DHHaptics.light() }) {
            ZStack {
                Circle().fill(DH.cream).frame(width: 56, height: 56)
                Image(systemName: "xmark").font(.system(size: 22, weight: .heavy)).foregroundStyle(DH.pinkDeep)
            }
            .dhShadow(color: DH.pink, y: 4)
        }
        .accessibilityLabel("Clear \(category.label) filter")
    }

    private func swatch(_ s: Shade) -> some View {
        let active = s.id == selectedID
        return Button(action: { onSelect(s); DHHaptics.medium() }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle().fill(s.swatchColor).frame(width: 56, height: 56)
                        .overlay(Circle().strokeBorder(.white, lineWidth: 4))
                    if active { Image(systemName: "checkmark").font(.system(size: 22, weight: .heavy)).foregroundStyle(.white) }
                }
                .scaleEffect(active ? 1.1 : 1)
                .dhShadow(color: DH.pinkDeep, y: 4)
                Text(s.name).font(DH.font(.chip)).foregroundStyle(DH.ink)
            }
        }
        .accessibilityLabel("\(s.name) \(category.label) shade\(s.isPro ? ", Pro" : "")")
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}

UPDATE MirrorView — overlay ShadeTrayView when vm.activeCategory == .skin, animate with .bouncy.

VERIFY:
1. Tap Skin chip → tray slides up
2. Tap "Medium" → swatch swells with check, foundation tint visible on face within ~80ms
3. Tap clear (X) → swatch returns to no-check, foundation cleared
4. Switch to Lips → Skin tray dismisses, Lips tray prepared (will be empty until GRWM-309)
````

---

## GRWM-305 — Base shade picker (foundation finish + LUT)

**Goal:** Base category controls foundation finish (matte/dewy/satin) and overall LUT (color grade). 4 chips: None, Soft, Glow, Glam. Each toggles a LUT and finish blendshape.

**Prereqs:** GRWM-304 (tray pattern).

**Files:**
- `GRWMStudio/Mirror/Shades+Base.swift`
- `GRWMStudio/Mirror/MirrorViewModel.swift` (already supports — just data add)

**Acceptance criteria:**
- [ ] 4 base shades: `base.none` (clears LUT), `base.soft` (subtle LUT), `base.glow` (warm dewy), `base.glam` (cool matte).
- [ ] All 4 are FREE.
- [ ] `base.none` is the implicit default — when tray opens with no selection, it appears active.
- [ ] Tapping `base.none` is identical to Clear (just a friendlier chip).
- [ ] Each shade applies `lutEnabled: true/false` + `lutTexture: "lut_X.png"` parameter values.

**Prompt:**

````
Build Base shade data.

CREATE GRWMStudio/Mirror/Shades+Base.swift:

extension Shade {
    static let baseShades: [Shade] = [
        Shade(id: "base.none", name: "None", swatchColor: DH.cream, effectID: "baseBeauty",
              parameters: [EffectParam(ref: "lutEnabled", value: .enabled(false))],
              isPro: false),
        Shade(id: "base.soft", name: "Soft", swatchColor: DH.pinkLight, effectID: "baseBeauty",
              parameters: [
                EffectParam(ref: "lutEnabled", value: .enabled(true)),
                EffectParam(ref: "lutTexture", value: .texture("lut_soft"))
              ], isPro: false),
        Shade(id: "base.glow", name: "Glow", swatchColor: DH.butter, effectID: "baseBeauty",
              parameters: [
                EffectParam(ref: "lutEnabled", value: .enabled(true)),
                EffectParam(ref: "lutTexture", value: .texture("lut_glow"))
              ], isPro: false),
        Shade(id: "base.glam", name: "Glam", swatchColor: DH.lavender, effectID: "baseBeauty",
              parameters: [
                EffectParam(ref: "lutEnabled", value: .enabled(true)),
                EffectParam(ref: "lutTexture", value: .texture("lut_glam"))
              ], isPro: false),
    ]
}

UPDATE MirrorView — when vm.activeCategory == .base, render ShadeTrayView with Shade.baseShades, default selection = "base.none" if vm.selections[.base] is nil.

ADD lut_soft.png, lut_glow.png, lut_glam.png to Resources/Effects/luts/. These are 32x1 LUT strips. If the larger filter pack ships with named LUTs, swap to those filenames in the manifest later — keep these placeholders for free-pack-only build.

VERIFY:
1. Open Base tray → shows 4 chips, "None" active by default
2. Tap Glow → warm tint visible across feed
3. Tap None → tint clears, chip returns to active
4. Switch from Glow→Glam → smooth crossfade (DeepAR handles internally)
````

---

## GRWM-306 — Eyes filter sub-rail (eyeshadow / liner / lashes)

**Goal:** Eyes is special — it has 3 sub-categories (eyeshadow, eyeliner, eyelashes). The tray shows a small inner segmented control above the swatches.

**Prereqs:** GRWM-304.

**Files:**
- `GRWMStudio/Mirror/Shades+Eyes.swift`
- `GRWMStudio/Mirror/EyesTrayView.swift`
- `GRWMStudio/Mirror/MirrorViewModel.swift` (add `eyesSubCategory: EyesSubCategory`)

**Acceptance criteria:**
- [ ] 3 sub-tabs: Shadow / Liner / Lashes.
- [ ] Shadow has 6 colors (pink, purple, gold, teal, brown, blue) all FREE.
- [ ] Liner has 4 styles (none, classic, winged, double-flick) — none + classic FREE; winged + double-flick PRO.
- [ ] Lashes has 4 styles (none, natural, doll, drama) — none + natural FREE; doll + drama PRO.
- [ ] Pro shades show a gold lock badge over the swatch.
- [ ] All 3 sub-categories share the `.eyes` slot — switching sub-category does NOT clear the others (they're additive parameters on the same effect).

**Prompt:**

````
Build the Eyes sub-rail tray.

CREATE GRWMStudio/Mirror/Shades+Eyes.swift with three arrays:
- Shade.eyeshadowShades (6 colors, FREE; ref: eyeshadowColor + eyeshadowMask)
- Shade.eyelinerShades (4: none/classic/winged/double-flick; ref: eyelinerTexture + eyelinerEnabled; last 2 isPro=true)
- Shade.eyelashShades (4: none/natural/doll/drama; ref: eyelashesTexture + eyelashesEnabled; last 2 isPro=true)

Each non-"none" shade carries an "enabled" param of true; "none" shades carry enabled=false to turn off the layer without unloading the whole effect.

CREATE GRWMStudio/Mirror/EyesTrayView.swift wrapping ShadeTrayView with a top sub-tab strip:

struct EyesTrayView: View {
    @Bindable var vm: MirrorViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(EyesSubCategory.allCases, id: \.self) { sub in
                    subTab(sub)
                }
            }
            .padding(.horizontal, 18)

            ShadeTrayView(
                category: .eyes,
                shades: shades(for: vm.eyesSubCategory),
                selectedID: vm.selections[.eyes]?.shade.id,
                onSelect: { Task { await vm.selectShade(in: .eyes, shade: $0) } },
                onClear: { Task { await vm.clear(slot: .eyes) } }
            )
        }
    }

    private func subTab(_ sub: EyesSubCategory) -> some View {
        let active = vm.eyesSubCategory == sub
        return Button { withAnimation(.snappy) { vm.eyesSubCategory = sub } } label: {
            Text(sub.label)
                .font(DH.font(.chip))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(
                    Capsule().fill(active ? DH.pinkDeep : .white)
                )
                .foregroundStyle(active ? .white : DH.ink)
                .dhShadow(color: DH.pink, y: 3)
        }
    }

    private func shades(for sub: EyesSubCategory) -> [Shade] {
        switch sub {
        case .shadow: Shade.eyeshadowShades
        case .liner: Shade.eyelinerShades
        case .lashes: Shade.eyelashShades
        }
    }
}

ADD enum EyesSubCategory: String, CaseIterable { case shadow, liner, lashes; var label: String { ... } }

ADD a small gold lock badge to the swatch in ShadeTrayView when shade.isPro is true. Use StickerStar tinted DH.butter overlapped at top-right of the swatch circle.

VERIFY:
1. Eyes tray opens → 3 sub-tabs visible, Shadow active
2. Tap Liner sub-tab → 4 chips appear (none/classic/winged/double-flick), winged + double-flick show gold lock
3. Tap winged (no Pro) → routes to Pro paywall (will be wired in GRWM-705); for now just verify lastError == .license is set
4. Tap classic → liner appears on face, eyeshadow from prior tap still visible (additive)
````

---

## GRWM-307 — Brows filter

**Goal:** Brows category controls brow color and shape. 5 colors (blonde, brown, dark-brown, black, soft-pink) + 2 shapes (natural, bold). All FREE in the free pack since brows aren't in the free Beauty Pack — until the larger pack ships, this category shows an "Available soon ✨" empty state if the brows effect isn't in the manifest.

**Prereqs:** GRWM-304, GRWM-108 (EffectCatalog).

**Files:**
- `GRWMStudio/Mirror/Shades+Brows.swift`
- `GRWMStudio/Mirror/EmptyShadeTrayView.swift`

**Acceptance criteria:**
- [ ] If `EffectCatalog.contains("brows")` returns true, show the full brow tray.
- [ ] If not, show a chunky butter card "Brows coming soon ✨ — your bigger pack will unlock these!" with a sparkle sticker.
- [ ] When the larger pack drops in, no code change needed — manifest entry alone unlocks the tray.
- [ ] Brow color shades carry parameters `browColor` (RGBA) + `browTexture` (one of natural/bold) + `browEnabled: true`.

**Prompt:**

````
Build Brows shade data with empty-state fallback.

CREATE GRWMStudio/Mirror/Shades+Brows.swift with Shade.browShades (5 colors x natural shape default = 5 entries; bold shape is a separate "browsBold" sub-toggle for v2).

CREATE GRWMStudio/Mirror/EmptyShadeTrayView.swift:

struct EmptyShadeTrayView: View {
    let category: FilterCategory
    let message: String

    var body: some View {
        DHCard(color: DH.butter, deep: DH.pinkDeep) {
            HStack(spacing: 10) {
                StickerSparkle(size: 22, fill: DH.pinkDeep)
                Text(message)
                    .font(DH.font(.body))
                    .foregroundStyle(DH.ink)
                Spacer()
            }
            .padding(14)
        }
        .padding(.horizontal, 14)
    }
}

UPDATE MirrorView — when vm.activeCategory == .brows:
  if EffectCatalog.shared.containsSync(effectID: "brows")
    -> ShadeTrayView with Shade.browShades
  else
    -> EmptyShadeTrayView(category: .brows, message: "Brows coming soon ✨ — your bigger pack will unlock these!")

ADD `func containsSync(effectID:) -> Bool` to EffectCatalog (reads in-memory manifest snapshot, non-async).

VERIFY:
1. With current free pack (no brows in manifest) → Brows tray shows the butter empty-state card
2. Add a stub brows entry to manifest.json (effectID: "brows") + a placeholder file → tray shows 5 color swatches
3. Switch back manifest → empty state returns
````

---

## GRWM-308 — Cheeks filter (blush)

**Goal:** Cheeks category for blush. Same fallback pattern as Brows — free pack lacks Cheeks, so show empty state until larger pack arrives. 5 blush shades planned: pink, peach, coral, mauve, berry.

**Prereqs:** GRWM-307 pattern.

**Files:**
- `GRWMStudio/Mirror/Shades+Cheeks.swift`

**Acceptance criteria:**
- [ ] If manifest contains `blush` effect → show 5 blush swatches.
- [ ] Otherwise → "Blush coming soon ✨" empty state.
- [ ] Cheek shade params: `blushColor`, `blushMask` (texture), `blushEnabled`.

**Prompt:**

````
Build Cheeks shade data, mirroring the GRWM-307 fallback pattern.

CREATE GRWMStudio/Mirror/Shades+Cheeks.swift with Shade.cheekShades:
[
  cheek.pink (PINK, RGBA 1.0,0.7,0.78,0.6),
  cheek.peach (PEACH, RGBA 1.0,0.78,0.6,0.6),
  cheek.coral (CORAL, RGBA 1.0,0.6,0.55,0.65),
  cheek.mauve (MAUVE, RGBA 0.85,0.55,0.7,0.6),
  cheek.berry (BERRY, RGBA 0.7,0.3,0.45,0.65),
]

All FREE. Effect ID: "blush". Params: blushColor + blushMask:"blush_mask" + blushEnabled:true.

UPDATE MirrorView fallback logic for .cheeks slot identical to .brows.

VERIFY: Cheeks chip → empty state in current free build.
````

---

## GRWM-309 — Lips filter

**Goal:** Lips category — 8 lipstick shades, mix of free and Pro. Free pack does include lips, so this tray works out of the box.

**Prereqs:** GRWM-304, free pack lips assets present.

**Files:**
- `GRWMStudio/Mirror/Shades+Lips.swift`

**Acceptance criteria:**
- [ ] 8 shades: classic-red (FREE), petal-pink (FREE), nude (FREE), berry (FREE), coral (FREE), plum (PRO), neon-pink (PRO), disco-brat (PRO — must match the 'license' error variant copy).
- [ ] Each shade swatchColor matches its lipstick color closely.
- [ ] Tapping disco-brat (Pro) on a non-Pro account routes to paywall.
- [ ] Effect ID: `lips`. Params: `lipsColor` (RGBA) + `lipsTexture` (finish: matte/gloss/glitter) + `lipsEnabled`.

**Prompt:**

````
Build Lips shade data.

CREATE GRWMStudio/Mirror/Shades+Lips.swift:

extension Shade {
    static let lipShades: [Shade] = [
        // FREE
        Shade(id: "lip.classic-red", name: "Classic Red", swatchColor: Color(hex: 0xCE1F3A), effectID: "lips",
              parameters: [
                EffectParam(ref: "lipsColor", value: .color(.init(0.81,0.12,0.23,1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_matte")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
              ], isPro: false),
        Shade(id: "lip.petal-pink", name: "Petal Pink", swatchColor: Color(hex: 0xFF8BB8), effectID: "lips",
              parameters: [
                EffectParam(ref: "lipsColor", value: .color(.init(1.0,0.55,0.72,0.95))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_gloss")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
              ], isPro: false),
        Shade(id: "lip.nude", name: "Nude", swatchColor: Color(hex: 0xC79A82), effectID: "lips",
              parameters: [
                EffectParam(ref: "lipsColor", value: .color(.init(0.78,0.60,0.51,0.85))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_satin")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
              ], isPro: false),
        Shade(id: "lip.berry", name: "Berry", swatchColor: Color(hex: 0x8C2A4C), effectID: "lips",
              parameters: [
                EffectParam(ref: "lipsColor", value: .color(.init(0.55,0.16,0.30,1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_matte")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
              ], isPro: false),
        Shade(id: "lip.coral", name: "Coral", swatchColor: Color(hex: 0xFF6F5A), effectID: "lips",
              parameters: [
                EffectParam(ref: "lipsColor", value: .color(.init(1.0,0.43,0.35,0.95))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_satin")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
              ], isPro: false),
        // PRO
        Shade(id: "lip.plum", name: "Plum", swatchColor: Color(hex: 0x4B1640), effectID: "lips",
              parameters: [
                EffectParam(ref: "lipsColor", value: .color(.init(0.29,0.09,0.25,1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_matte")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
              ], isPro: true),
        Shade(id: "lip.neon-pink", name: "Neon Pink", swatchColor: Color(hex: 0xFF1E8E), effectID: "lips",
              parameters: [
                EffectParam(ref: "lipsColor", value: .color(.init(1.0,0.12,0.55,1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_gloss")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
              ], isPro: true),
        Shade(id: "lip.disco-brat", name: "Disco Brat", swatchColor: Color(hex: 0xC09BFF), effectID: "lips",
              parameters: [
                EffectParam(ref: "lipsColor", value: .color(.init(0.75,0.61,1.0,1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_glitter")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
              ], isPro: true),
    ]
}

UPDATE MirrorView for .lips slot to render ShadeTrayView with Shade.lipShades.

VERIFY:
1. Lips tray shows 8 swatches; last 3 have gold lock badge
2. Tap Petal Pink → applied within ~80ms
3. Tap Disco Brat (no Pro) → vm.lastError == .license; coordinator queues paywall
4. With Pro entitlement (debug toggle in DEBUG menu), tap Disco Brat → applied
````

---

## GRWM-310 — Looks preset selector (full-face)

**Goal:** The 7th category. Looks are full-face presets (foundation + lips + eyes + cheeks + brows in one .deepar file). Selecting a Look loads it into the `.looks` slot, which has texture priority over individual category slots (already wired in MirrorViewModel from GRWM-301). 4 free + 4 Pro looks.

**Prereqs:** GRWM-301 (looks-overrides logic), GRWM-303 (filter rail).

**Files:**
- `GRWMStudio/Mirror/Looks.swift`
- `GRWMStudio/Mirror/LooksTrayView.swift`

**Acceptance criteria:**
- [ ] 8 looks: "Sunday Best" (FREE), "School Day" (FREE), "Birthday Glam" (FREE), "Sleepover" (FREE), "Pop Star" (PRO), "Disco Princess" (PRO), "Garden Party" (PRO), "Time Warp" (PRO).
- [ ] LooksTrayView shows looks as larger 100×120 cards (not circular swatches) — each card has a preview thumbnail + name + Pro badge if applicable.
- [ ] Tapping a Look loads its .deepar file (e.g. `look1.deepar`, `look2.deepar` from free pack).
- [ ] Selecting a Look does NOT clear the rail's per-category state visually — but the live face shows the Look's overrides. When the user later picks a per-category shade, it switches them out of Looks mode (clear .looks slot, restore per-category).

**Prompt:**

````
Build the Looks preset tray.

CREATE GRWMStudio/Mirror/Looks.swift:

struct LookPreset: Identifiable, Hashable {
    let id: String
    let name: String
    let thumbnailAsset: String
    let effectID: String
    let isPro: Bool
}

enum Looks {
    static let all: [LookPreset] = [
        LookPreset(id: "look.sunday-best",      name: "Sunday Best",     thumbnailAsset: "look_thumb_sunday",  effectID: "look1", isPro: false),
        LookPreset(id: "look.school-day",       name: "School Day",      thumbnailAsset: "look_thumb_school",  effectID: "look2", isPro: false),
        LookPreset(id: "look.birthday-glam",    name: "Birthday Glam",   thumbnailAsset: "look_thumb_bday",    effectID: "look3", isPro: false),
        LookPreset(id: "look.sleepover",        name: "Sleepover",       thumbnailAsset: "look_thumb_sleep",   effectID: "look4", isPro: false),
        LookPreset(id: "look.pop-star",         name: "Pop Star",        thumbnailAsset: "look_thumb_pop",     effectID: "look_pro1", isPro: true),
        LookPreset(id: "look.disco-princess",   name: "Disco Princess",  thumbnailAsset: "look_thumb_disco",   effectID: "look_pro2", isPro: true),
        LookPreset(id: "look.garden-party",     name: "Garden Party",    thumbnailAsset: "look_thumb_garden",  effectID: "look_pro3", isPro: true),
        LookPreset(id: "look.time-warp",        name: "Time Warp",       thumbnailAsset: "look_thumb_warp",    effectID: "look_pro4", isPro: true),
    ]
}

NOTE: free pack ships look1+look2 only. Other 6 effectIDs will resolve via the manifest from the larger pack OR fall back to a "Coming soon" overlay on the card if EffectCatalog can't resolve the effectID.

CREATE GRWMStudio/Mirror/LooksTrayView.swift — horizontal ScrollView of 100×120 cards, each:
- white card, br=20, deep pink chunky shadow
- Image(asset thumbnailAsset) clipped to top half
- bottom strip with name in Fredoka 13pt
- if isPro: gold star at top-right
- if catalog can't resolve effectID: dim opacity + "Soon ✨" sticker

Tapping a card: vm.selectLook(_ look: LookPreset). VM method:
  func selectLook(_ look: LookPreset) async {
    if look.isPro && !env.entitlements.hasPro { lastError = .license; return }
    guard catalog.containsSync(effectID: look.effectID) else { return }
    await selectShade(in: .looks, shade: Shade(id: look.id, name: look.name, swatchColor: .clear, effectID: look.effectID, parameters: [], isPro: look.isPro))
  }

When user taps a per-category chip AFTER a Look is loaded, MirrorView shows a confirmation chip "Switch out of \(look.name)?" with a tiny "Yes, mix it" / "Stay in look" pair. On Yes → vm.clear(slot: .looks).

VERIFY:
1. Looks tray opens → 8 cards visible, last 4 with gold star, last 6 dimmed with "Soon ✨" if not in manifest
2. Tap Sunday Best → look1.deepar loads, full face transformation visible
3. Switch back to Skin chip while Look is active → "Switch out of Sunday Best?" chip appears
4. Confirm Yes → looks slot cleared, skin tray opens normally
````

---

## GRWM-311 — Reset/clear all per category and "Reset everything"

**Goal:** Add a small reset button on each tray (already exists per-category from GRWM-304) and a global "Reset everything" pull-tab in the top-right of the mirror chrome.

**Prereqs:** GRWM-300, GRWM-301.

**Files:**
- `GRWMStudio/Mirror/MirrorChrome.swift` (update — add reset pull tab)
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — `func resetAll() async`)

**Acceptance criteria:**
- [ ] Top-right of mirror chrome shows a small white circle button with a "↻" icon, deep pink shadow.
- [ ] Tapping it bounces the icon and calls `vm.resetAll()`.
- [ ] `resetAll()` clears every slot, removes all selections, dismisses any open tray.
- [ ] Heavy haptic on reset.

**Prompt:**

````
Add the global reset affordance.

UPDATE MirrorChrome.top() to include the reset button on the right side, alongside the StickerHeart:

HStack {
    GRWMLogo()
    Spacer()
    StickerHeart(size: 26, fill: DH.pinkDeep)
    Button { Task { await vm.resetAll() } } label: {
        Image(systemName: "arrow.counterclockwise")
            .font(.system(size: 18, weight: .heavy))
            .foregroundStyle(DH.pinkDeep)
            .frame(width: 42, height: 42)
            .background(Circle().fill(.white))
            .dhShadow(color: DH.pink, y: 4)
    }
    .accessibilityLabel("Reset everything")
}

NOTE: MirrorChrome will need a binding/closure to the VM. Pass vm as parameter.

UPDATE MirrorViewModel:

func resetAll() async {
    DHHaptics.heavy()
    for slot in EffectSlot.allCases {
        try? await controller.clearSlot(slot)
    }
    selections.removeAll()
    activeCategory = nil
    eyesSubCategory = .shadow
}

VERIFY:
1. Apply Skin + Lips + Eyes shades → tap reset → all clear within ~150ms, haptic fires, trays dismiss
2. Apply a Look → reset clears it the same way
3. With camera off (failed state), reset button does not crash
````

---

## GRWM-312 — Pro-locked shade tap → Paywall handoff

**Goal:** When a non-Pro user taps a Pro shade, the app routes to the Paywall (GRWM-705) via the parent gate. This ticket handles the handoff: VM signals `.license` error → MirrorView observes → routes through coordinator.

**Prereqs:** GRWM-309 (Lips with Pro shades), Coordinator from GRWM-009.

**Files:**
- `GRWMStudio/Mirror/MirrorView.swift` (update — observe lastError)
- `GRWMStudio/App/RootCoordinator.swift` (update — add `.parentGate(intent: .paywall)` route)

**Acceptance criteria:**
- [ ] When `vm.lastError == .license`, MirrorView calls `coordinator.startParentGate(intent: .paywall)` and resets `vm.lastError = nil`.
- [ ] The parent gate flow (math challenge) lives in Phase 7 — for now, just show a placeholder full-screen sheet with a "Parent gate placeholder — wired in GRWM-700" message and a Done button.
- [ ] After parent gate completion (placeholder always succeeds), navigate to placeholder Paywall view (full screen, "Paywall — wired in GRWM-705").
- [ ] If the user dismisses the paywall, vm.activeCategory remains where it was; the Pro shade is NOT applied.

**Prompt:**

````
Wire the Pro-shade → Paywall handoff.

UPDATE RootCoordinator:

enum ParentGateIntent { case paywall, settings, deletion }

@Observable @MainActor
final class RootCoordinator {
    private(set) var route: AppRoute = .splash
    func startParentGate(intent: ParentGateIntent) {
        route = .parentGate(intent: intent)
    }
    func paywallShown() { route = .paywall }
    // ...
}

UPDATE MirrorView:

.onChange(of: vm.lastError) { _, new in
    if new == .license {
        coordinator.startParentGate(intent: .paywall)
        vm.lastError = nil
    }
}

UPDATE RootContainer to route:
case .parentGate(let intent):
    PlaceholderParentGateView(intent: intent, onComplete: {
        switch intent {
        case .paywall: coordinator.paywallShown()
        default: coordinator.dismissOverlay()
        }
    })
case .paywall:
    PlaceholderPaywallView(onDismiss: { coordinator.dismissOverlay() })

VERIFY:
1. Tap Disco Brat without Pro → parent gate placeholder appears, tap Done → paywall placeholder appears
2. Dismiss paywall → returns to mirror, no Pro shade applied
3. With debug Pro entitlement on → Disco Brat applies directly, no gate
````

---

## GRWM-313 — No-face indicator overlay

**Goal:** When DeepAR reports `faceVisibilityChanged: false` for >1.5s, show the chunky "Move into the light, or come a little closer 👀" card overlay (variant `no-face` from screens-8.jsx) inline on the camera region — NOT as a full error screen, just a subtle floating tip.

**Prereqs:** GRWM-301 (isFaceDetected stream).

**Files:**
- `GRWMStudio/Mirror/NoFaceTipView.swift`
- `GRWMStudio/Mirror/MirrorView.swift` (update — overlay)

**Acceptance criteria:**
- [ ] After 1.5s of no-face, the tip card fades in over the upper-third of the camera region (with chunky pink shadow + lavender accent).
- [ ] When face returns, card fades out within 200ms.
- [ ] Card never blocks the filter rail or capture FAB.
- [ ] VoiceOver announces the tip when it appears (politeness: announcement).

**Prompt:**

````
Build the no-face tip overlay.

CREATE GRWMStudio/Mirror/NoFaceTipView.swift:

struct NoFaceTipView: View {
    var body: some View {
        DHCard(color: .white, deep: DH.pink) {
            HStack(spacing: 10) {
                StickerSparkle(size: 22, fill: DH.pink)
                VStack(alignment: .leading, spacing: 2) {
                    Text("I can't see your face!")
                        .font(DH.font(.cardTitle))
                        .foregroundStyle(DH.ink)
                    Text("Move into the light, or come a little closer.")
                        .font(DH.font(.body))
                        .foregroundStyle(DH.ink.opacity(0.7))
                }
                Spacer()
            }
            .padding(14)
        }
        .padding(.horizontal, 24)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}

UPDATE MirrorView with debounce:

@State private var showNoFaceTip: Bool = false
@State private var noFaceWorkItem: DispatchWorkItem?

cameraRegion.overlay(alignment: .top) {
    if showNoFaceTip { NoFaceTipView().transition(.opacity.combined(with: .move(edge: .top))) }
}
.onChange(of: vm.isFaceDetected) { _, visible in
    noFaceWorkItem?.cancel()
    if visible {
        withAnimation { showNoFaceTip = false }
    } else {
        let item = DispatchWorkItem { withAnimation { showNoFaceTip = true } }
        noFaceWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: item)
    }
}

VERIFY:
1. Cover camera lens with hand for 2s → tip appears
2. Uncover → tip disappears within 200ms
3. Quick face wave (in/out within 1s) → tip never appears (1.5s debounce)
4. With VoiceOver enabled, tip is announced when it appears
````

---

## GRWM-314 — Camera flip + flash control

**Goal:** Two small controls at the bottom-left of the mirror chrome: "Flip" (front/back camera toggle) and "Flash" (front-flash white screen overlay since iPhone front cameras lack physical flash).

**Prereqs:** GRWM-103 (camera lifecycle), GRWM-300 (mirror shell).

**Files:**
- `GRWMStudio/Mirror/MirrorBottomControls.swift`
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — `flipCamera()`, `toggleFlash()`)
- `GRWMStudio/DeepAR/DeepARController.swift` (update — `switchCamera()`)

**Acceptance criteria:**
- [ ] Flip button: white circle, "🔄" or chevron icon, tapping calls DeepAR's `switchCameraType` (front/back). Default front.
- [ ] Flash button: when enabled, overlays a white 50%-opacity layer over the entire screen (only matters during photo capture — applied at the moment of shutter via the recording service).
- [ ] Flash icon: lightning bolt; lit yellow when on.
- [ ] Both controls hide while recording video.

**Prompt:**

````
Build the camera flip + flash controls.

UPDATE DeepARController:

func switchCamera() async throws {
    guard let cam = cameraController else { throw ARError.notReady }
    await MainActor.run {
        cam.position = (cam.position == .front) ? .back : .front
    }
}

UPDATE MirrorViewModel:

var cameraIsFront: Bool = true
var flashEnabled: Bool = false

func flipCamera() async {
    cameraIsFront.toggle()
    DHHaptics.light()
    try? await controller.switchCamera()
}

func toggleFlash() {
    flashEnabled.toggle()
    DHHaptics.light()
}

CREATE GRWMStudio/Mirror/MirrorBottomControls.swift:

struct MirrorBottomControls: View {
    @Bindable var vm: MirrorViewModel
    var body: some View {
        HStack(spacing: 12) {
            ControlButton(systemName: "arrow.triangle.2.circlepath.camera",
                          tint: DH.pinkDeep) {
                Task { await vm.flipCamera() }
            }
            .accessibilityLabel("Flip camera")

            ControlButton(systemName: vm.flashEnabled ? "bolt.fill" : "bolt",
                          tint: vm.flashEnabled ? DH.butter : DH.pinkDeep) {
                vm.toggleFlash()
            }
            .accessibilityLabel(vm.flashEnabled ? "Flash on" : "Flash off")
            Spacer()
        }
        .padding(.horizontal, 18)
    }
}

private struct ControlButton: View {
    let systemName: String
    let tint: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.white))
                .dhShadow(color: DH.pink, y: 4)
        }
    }
}

UPDATE MirrorView — render MirrorBottomControls just above the FilterRail. Hide when vm.isRecording (will be set in GRWM-403).

VERIFY:
1. Tap flip → camera switches, controller logs camera position change
2. Front camera default after relaunch
3. Tap flash → bolt fills yellow
4. Start a recording (debug-trigger for now) → both controls hide
````

---

## GRWM-315 — Effect failure handling + recovery

**Goal:** If `EffectCatalog.url(for:)` throws (file missing, decode fail) or DeepARController.loadEffect throws, surface the chunky `effect-fail` error variant inline on the camera region — NOT a full-screen takeover. Provide a "Try again" CTA that retries the load. After 3 fails in a row, escalate to a full-screen DHError.

**Prereqs:** GRWM-301 (selectShade), GRWM-104 (loadEffect).

**Files:**
- `GRWMStudio/Mirror/EffectFailureBanner.swift`
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — retry counter + retry method)

**Acceptance criteria:**
- [ ] On effect load fail, a chunky mint banner slides down from the top of the camera region with the variant copy ("That sparkle didn't load…").
- [ ] Banner auto-dismisses after 4s OR on tap of "Try again".
- [ ] "Try again" retries the last selectShade call.
- [ ] After 3 consecutive failures within 60s, route to full-screen `DHErrorView(variant: .effectFail)` (Phase 9 builds the screen — for now an empty stub).
- [ ] Counter resets on any success.

**Prompt:**

````
Build effect failure handling.

UPDATE MirrorViewModel:

private var lastSelection: (slot: EffectSlot, shade: Shade)?
private var failureCount: Int = 0
private var failureWindowStart: Date?

func selectShade(in slot: EffectSlot, shade: Shade) async {
    lastSelection = (slot, shade)
    // ... existing logic
    do {
        // existing try block from GRWM-301
        failureCount = 0
        failureWindowStart = nil
    } catch {
        recordEffectFailure()
        log.error("selectShade failed: \(error.localizedDescription)")
        lastError = .effectFail
    }
}

func retryLastSelection() async {
    guard let last = lastSelection else { return }
    await selectShade(in: last.slot, shade: last.shade)
}

private func recordEffectFailure() {
    let now = Date()
    if let start = failureWindowStart, now.timeIntervalSince(start) <= 60 {
        failureCount += 1
    } else {
        failureCount = 1
        failureWindowStart = now
    }
    if failureCount >= 3 {
        state = .failed(.effectFail)
    }
}

CREATE GRWMStudio/Mirror/EffectFailureBanner.swift:

struct EffectFailureBanner: View {
    let onRetry: () -> Void
    let onDismiss: () -> Void
    var body: some View {
        DHCard(color: DH.mint, deep: Color(hex: 0x5DBD8E)) {
            HStack(spacing: 10) {
                StickerSparkle(size: 22, fill: Color(hex: 0x5DBD8E))
                VStack(alignment: .leading, spacing: 2) {
                    Text("That sparkle didn't load")
                        .font(DH.font(.cardTitle))
                        .foregroundStyle(DH.ink)
                    Text("Tap to try again.")
                        .font(DH.font(.bodySmall))
                        .foregroundStyle(DH.ink.opacity(0.7))
                }
                Spacer()
                DHButton(kind: .ghost, size: .sm, label: "Try again", action: onRetry)
            }
            .padding(12)
        }
        .padding(.horizontal, 18)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { onDismiss() }
        }
    }
}

UPDATE MirrorView — overlay the banner at top of cameraRegion when vm.lastError == .effectFail and state is still .running. When state is .failed(.effectFail) (3+ fails), MirrorView delegates to RootContainer to show full-screen error (Phase 9).

VERIFY:
1. Manually break manifest entry for "lips" effect → tap a lip shade → banner appears
2. Tap "Try again" → re-attempt, second fail → banner re-appears
3. Three fails within 60s → state moves to .failed(.effectFail), full-screen kicks in
4. After 1+ minute pause and a successful selection, counter resets
````

---

# Phase 4 — Capture flow (GRWM-400 – GRWM-405)

The bottom-center FAB is the capture trigger. Tap = photo. Long-press = video (up to 15s, with 3-2-1 countdown for video). Reference designs: `docs/design-source/v3/screens-6.jsx` (DHMirrorCountdown, DHMirrorRecording, DHMirrorProGate).

---

## GRWM-400 — Capture FAB + state machine

**Goal:** The chunky pink FAB renders at the bottom-center of the mirror, between the filter rail and the home indicator. It owns three states: idle (full-circle pink), recording (red square pulsing), and disabled (gray). Tap and long-press are distinct gestures.

**Prereqs:** GRWM-300 (mirror shell), GRWM-301 (vm).

**Files:**
- `GRWMStudio/Capture/CaptureFAB.swift`
- `GRWMStudio/Capture/CaptureMode.swift`
- `GRWMStudio/Mirror/MirrorView.swift` (update — embed CaptureFAB)

**Acceptance criteria:**
- [ ] FAB is 88pt circle, deep-pink fill with chunky white inner ring (4pt) and 8pt-deep solid drop shadow.
- [ ] Idle: pink. Recording: rounded square red, 1Hz scale pulse 1.0↔0.94.
- [ ] Tap (≤0.3s press) → emits `.photoCapture` event; long-press (>0.3s press, then release) → emits `.videoCapture(duration:)` event with elapsed press time clamped to 15s.
- [ ] During press, ring fills clockwise indicating progress to 15s.
- [ ] Disabled state if camera not running.

**Prompt:**

````
Build the CaptureFAB.

CREATE GRWMStudio/Capture/CaptureMode.swift:

enum CaptureMode {
    case idle
    case photoFiring        // brief 100ms flash state
    case videoCountdown     // 3-2-1 before recording
    case videoRecording(secondsElapsed: Double)
    case disabled
}

CREATE GRWMStudio/Capture/CaptureFAB.swift:

struct CaptureFAB: View {
    let mode: CaptureMode
    let onTap: () -> Void
    let onLongPressBegan: () -> Void
    let onLongPressEnded: () -> Void

    @State private var pressStart: Date?
    private let maxDuration: Double = 15

    var body: some View {
        ZStack {
            shape
            progressRing
        }
        .frame(width: 88, height: 88)
        .scaleEffect(pulseScale)
        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)
        .gesture(combinedGesture)
        .accessibilityLabel(accessibilityLabel)
    }

    private var shape: some View {
        switch mode {
        case .idle, .disabled:
            return AnyView(Circle()
                .fill(mode == .disabled ? DH.cream : DH.pinkDeep)
                .overlay(Circle().strokeBorder(.white, lineWidth: 4))
                .dhShadow(color: DH.pinkDeep, y: 8))
        case .photoFiring:
            return AnyView(Circle().fill(.white)
                .overlay(Circle().strokeBorder(DH.pinkDeep, lineWidth: 4))
                .dhShadow(color: DH.pinkDeep, y: 8))
        case .videoCountdown, .videoRecording:
            return AnyView(RoundedRectangle(cornerRadius: 16)
                .fill(DH.recRed)
                .frame(width: 56, height: 56)
                .padding(16)
                .background(Circle().strokeBorder(.white, lineWidth: 4))
                .dhShadow(color: DH.recRed, y: 8))
        }
    }

    private var progressRing: some View {
        Group {
            if case .videoRecording(let secs) = mode {
                Circle()
                    .trim(from: 0, to: CGFloat(min(secs / maxDuration, 1)))
                    .stroke(DH.butter, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 92, height: 92)
            }
        }
    }

    private var isRecording: Bool {
        if case .videoRecording = mode { return true }
        return false
    }
    private var pulseScale: CGFloat { isRecording ? 0.94 : 1.0 }

    private var combinedGesture: some Gesture {
        let press = LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in onLongPressBegan() }
        let drag = DragGesture(minimumDistance: 0)
            .onEnded { _ in
                if let start = pressStart, Date().timeIntervalSince(start) < 0.3 {
                    onTap()
                } else {
                    onLongPressEnded()
                }
                pressStart = nil
            }
            .onChanged { _ in if pressStart == nil { pressStart = Date() } }
        return SimultaneousGesture(press, drag)
    }

    private var accessibilityLabel: String {
        switch mode {
        case .idle: "Capture. Tap for photo, hold for video"
        case .videoRecording: "Recording video, release to stop"
        case .photoFiring: "Capturing photo"
        case .videoCountdown: "Get ready, recording starts in a moment"
        case .disabled: "Capture button disabled"
        }
    }
}

UPDATE MirrorView — overlay CaptureFAB centered above the home indicator, calling vm.onCaptureTap / vm.onCaptureLongPressBegan / vm.onCaptureLongPressEnded (stub these on the VM; real wiring lands in GRWM-401/403).

VERIFY:
1. Quick tap → fires photo event (log a breadcrumb)
2. Long press → fires long-press began
3. Release after 5s → fires long-press ended
4. While recording, FAB shows red rounded square pulsing
5. Progress ring fills to 1/3 at 5s of a 15s window
````

---

## GRWM-401 — Photo capture flow

**Goal:** Tapping the FAB captures a photo via DeepAR's screenshot API. The photo includes all current effects baked in. Show a 100ms white flash overlay over the camera region. Hand the resulting `UIImage` to the Preview screen.

**Prereqs:** GRWM-400, GRWM-110 (RecordingService).

**Files:**
- `GRWMStudio/Capture/PhotoCaptureCoordinator.swift`
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — `func capturePhoto() async`)
- `GRWMStudio/DeepAR/RecordingService.swift` (update — implement `takeScreenshot()`)

**Acceptance criteria:**
- [ ] `vm.capturePhoto()` calls `RecordingService.takeScreenshot()` which calls DeepAR's `takeScreenshot` and yields a UIImage.
- [ ] On success, MirrorView shows a brief white flash (100ms) and routes to `PreviewView(asset: .photo(image))`.
- [ ] Shutter sound plays (use `Sounds.shutter`).
- [ ] Heavy haptic.
- [ ] On failure, the chunky `rec-fail` banner appears instead.

**Prompt:**

````
Implement photo capture.

UPDATE GRWMStudio/DeepAR/RecordingService.swift:

extension RecordingService {
    func takeScreenshot() async throws -> UIImage {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<UIImage, Error>) in
            // DeepAR delivers screenshot via delegate didTakeScreenshot(_ image: UIImage).
            // We bridge it via a per-call continuation stored on the delegate proxy.
            self.pendingScreenshot = cont
            self.deepAR.takeScreenshot()
        }
    }
}

UPDATE DeepARDelegateProxy:

func didTakeScreenshot(_ image: UIImage) {
    let cont = self.recordingService.pendingScreenshot
    self.recordingService.pendingScreenshot = nil
    cont?.resume(returning: image)
}

UPDATE MirrorViewModel:

@MainActor func capturePhoto() async {
    guard state == .running else { return }
    DHHaptics.heavy()
    Sounds.shutter.play()
    do {
        let img = try await withTimeout(seconds: 4) {
            try await self.recordingService.takeScreenshot()
        }
        // Show flash via MirrorView state, then route to preview
        env.coordinator.showPreview(asset: .photo(img))
    } catch {
        log.error("photo capture failed: \(error.localizedDescription)")
        lastError = .recFail
    }
}

UPDATE MirrorView — onCaptureTap = vm.capturePhoto. Render a flash overlay:

@State private var flashing = false
.overlay(flashing ? Color.white.ignoresSafeArea() : nil)
.onChange(of: vm.captureMode) { _, new in
    if case .photoFiring = new {
        flashing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { flashing = false }
    }
}

VERIFY:
1. Tap FAB → flash, shutter sound, heavy haptic, routes to PreviewView with rendered image (will show a placeholder until GRWM-500)
2. Image contains all currently applied filters (verify by applying lipstick + checking screenshot)
3. With timeout simulated, error banner appears
````

---

## GRWM-402 — Countdown screen (DHMirrorCountdown)

**Goal:** Before video recording, a 3-2-1 countdown overlays the mirror. Reference design: `docs/design-source/v3/screens-6.jsx` → `DHMirrorCountdown`.

**Prereqs:** GRWM-400, GRWM-403 (will use this).

**Files:**
- `GRWMStudio/Capture/CountdownOverlay.swift`

**Acceptance criteria:**
- [ ] Big chunky number 3 → 2 → 1 → "Go!" centered over the camera region, 1s per step.
- [ ] Each step bounces in (scale 0.6 → 1.1 → 1.0) and out.
- [ ] Background dim 30%.
- [ ] Tone-up sound on each tick.
- [ ] Cancel possible by tapping anywhere outside the number.
- [ ] On "Go!", calls `onComplete()`.

**Prompt:**

````
Build CountdownOverlay matching docs/design-source/v3/screens-6.jsx DHMirrorCountdown.

CREATE GRWMStudio/Capture/CountdownOverlay.swift:

struct CountdownOverlay: View {
    let onComplete: () -> Void
    let onCancel: () -> Void

    @State private var step: Int = 3
    @State private var visible: Bool = true

    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
                .onTapGesture { onCancel() }

            Text(stepLabel)
                .font(.system(size: 180, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 8)
                .scaleEffect(visible ? 1.0 : 0.6)
                .opacity(visible ? 1 : 0)
                .animation(.bouncy(duration: 0.4), value: step)
        }
        .task { await runCountdown() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Countdown to recording: \(stepLabel)")
    }

    private var stepLabel: String { step == 0 ? "Go!" : "\(step)" }

    private func runCountdown() async {
        for s in stride(from: 3, through: 0, by: -1) {
            step = s
            Sounds.countdownTick.play()
            DHHaptics.medium()
            try? await Task.sleep(for: .seconds(1))
        }
        onComplete()
    }
}

ADD Sounds.countdownTick to the sound effects list (Resources/Sounds/countdown_tick.m4a).

VERIFY:
1. Show CountdownOverlay → counts 3, 2, 1, Go! → onComplete fires after ~4s
2. Tap during countdown → onCancel fires immediately, no completion
3. Each tick plays sound + medium haptic
4. Animations bouncy and chunky-feeling
````

---

## GRWM-403 — Video recording flow + 15s limit

**Goal:** Long-press FAB triggers countdown → recording starts. Auto-stops at 15s. User can release early to stop. Recording writes an MP4 to a tmp file via DeepAR's recording API. Free tier limit: 8 seconds. Pro tier: 15 seconds. Free users hit the recordingProGate (next ticket) at 8s.

**Prereqs:** GRWM-400, GRWM-402, GRWM-110 (RecordingService).

**Files:**
- `GRWMStudio/Capture/VideoRecordingCoordinator.swift`
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — `startVideoFlow`, `stopVideoFlow`)
- `GRWMStudio/DeepAR/RecordingService.swift` (update — implement startVideoRecording / stopVideoRecording)

**Acceptance criteria:**
- [ ] Long-press began → captureMode = .videoCountdown → CountdownOverlay shows → on complete, recording starts.
- [ ] During recording, captureMode = .videoRecording(secondsElapsed:) updated every 100ms via a Timer.
- [ ] At 8s for non-Pro, recording stops gracefully and shows the Pro gate (next ticket).
- [ ] At 15s for Pro, auto-stop and route to PreviewView.
- [ ] Long-press release before auto-stop → also stops + routes to preview.
- [ ] Output URL is a temp `.mp4` file in `NSTemporaryDirectory()`.
- [ ] All filter overlays remain applied during recording.

**Prompt:**

````
Implement video recording.

UPDATE GRWMStudio/DeepAR/RecordingService.swift:

private(set) var currentVideoURL: URL?
private var pendingFinishContinuation: CheckedContinuation<URL, Error>?

func startVideoRecording() async throws -> URL {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("rec_\(UUID().uuidString).mp4")
    self.currentVideoURL = url
    let outputSize = CGSize(width: 720, height: 1280)
    deepAR.startVideoRecording(withOutputWidth: Int32(outputSize.width),
                               outputHeight: Int32(outputSize.height),
                               outputURL: url)
    return url
}

func finishVideoRecording() async throws -> URL {
    return try await withCheckedThrowingContinuation { cont in
        self.pendingFinishContinuation = cont
        deepAR.finishVideoRecording()
    }
}

UPDATE DeepARDelegateProxy.didFinishVideoRecording(_ filePath: String):
    let url = URL(fileURLWithPath: filePath)
    let cont = recordingService.pendingFinishContinuation
    recordingService.pendingFinishContinuation = nil
    cont?.resume(returning: url)

UPDATE DeepARDelegateProxy.recordingFailedWithError(_ error: Error):
    recordingService.pendingFinishContinuation?.resume(throwing: error)
    recordingService.pendingFinishContinuation = nil

UPDATE MirrorViewModel:

private var recordingTimer: Timer?
private var recordingStart: Date?

func longPressBegan() {
    Task { await beginVideoFlow() }
}

func longPressEnded() {
    Task { await endVideoFlow(force: false) }
}

@MainActor private func beginVideoFlow() async {
    guard state == .running, captureMode == .idle else { return }
    captureMode = .videoCountdown
}

@MainActor func videoCountdownComplete() async {
    do {
        let url = try await recordingService.startVideoRecording()
        recordingStart = Date()
        captureMode = .videoRecording(secondsElapsed: 0)
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in await self?.tick() }
        }
    } catch {
        captureMode = .idle
        lastError = .recFail
    }
}

@MainActor private func tick() async {
    guard let start = recordingStart else { return }
    let elapsed = Date().timeIntervalSince(start)
    let cap: Double = env.entitlements.hasPro ? 15.0 : 8.0
    if elapsed >= cap {
        await endVideoFlow(force: true)
        if !env.entitlements.hasPro {
            env.coordinator.showRecordingProGate()
        }
        return
    }
    captureMode = .videoRecording(secondsElapsed: elapsed)
}

@MainActor func endVideoFlow(force: Bool) async {
    recordingTimer?.invalidate()
    recordingTimer = nil
    guard case .videoRecording = captureMode else {
        if captureMode == .videoCountdown { captureMode = .idle }
        return
    }
    do {
        let url = try await recordingService.finishVideoRecording()
        captureMode = .idle
        env.coordinator.showPreview(asset: .video(url))
    } catch {
        captureMode = .idle
        lastError = .recFail
    }
}

UPDATE MirrorView — when captureMode == .videoCountdown, overlay CountdownOverlay
  - onComplete: Task { await vm.videoCountdownComplete() }
  - onCancel: vm.captureMode = .idle

VERIFY:
1. Long-press FAB for 6s → countdown plays, recording starts, release at 6s → auto-stop, preview shows ~3s clip
2. Hold for 10s as non-Pro → recording auto-stops at 8s, ProGate sheet shows
3. Hold for 12s as Pro (debug) → recording continues to 12s, stops on release, preview shows clip
4. Hold past 15s → auto-stop at 15s
5. Tap mid-countdown → cancels, returns to idle
````

---

## GRWM-404 — Recording UI overlay (DHMirrorRecording)

**Goal:** During recording, overlay the chunky red "REC" pill at the top of the camera region with elapsed time, and a stop-X chip below the FAB. Reference: `docs/design-source/v3/screens-6.jsx` → `DHMirrorRecording`.

**Prereqs:** GRWM-403.

**Files:**
- `GRWMStudio/Capture/RecordingOverlay.swift`
- `GRWMStudio/Mirror/MirrorView.swift` (update — embed overlay during recording)

**Acceptance criteria:**
- [ ] Top-left pill: red dot + "REC" + "0:00 / 0:08" (or "/0:15" for Pro), Fredoka 14pt, white text on red rounded rect with chunky shadow.
- [ ] Pill pulses (1Hz, scale 1.0↔1.05).
- [ ] Counter updates 10x/sec.
- [ ] Filter rail and bottom controls hidden during recording.
- [ ] When time is approaching cap (last 2s), counter color shifts to butter yellow.

**Prompt:**

````
Build RecordingOverlay matching docs/design-source/v3/screens-6.jsx DHMirrorRecording.

CREATE GRWMStudio/Capture/RecordingOverlay.swift:

struct RecordingOverlay: View {
    let secondsElapsed: Double
    let cap: Double

    var body: some View {
        VStack {
            HStack {
                pill
                Spacer()
            }
            .padding(.horizontal, 18).padding(.top, 16)
            Spacer()
        }
    }

    private var pill: some View {
        HStack(spacing: 8) {
            Circle().fill(.white).frame(width: 12, height: 12)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 0.5).repeatForever(), value: secondsElapsed)
            Text("REC")
                .font(DH.font(.chip))
                .foregroundStyle(.white)
            Text(timeString)
                .font(DH.font(.chipMono))
                .foregroundStyle(approachingCap ? DH.butter : .white)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Capsule().fill(DH.recRed))
        .dhShadow(color: Color(hex: 0x9E0E1F), y: 5)
    }

    private var pulseScale: CGFloat { 1.0 + 0.05 * sin(secondsElapsed * 2 * .pi) }
    private var approachingCap: Bool { (cap - secondsElapsed) <= 2.0 }
    private var timeString: String {
        let cur = String(format: "0:%02d", Int(secondsElapsed))
        let cap = String(format: "0:%02d", Int(cap))
        return "\(cur) / \(cap)"
    }
}

UPDATE MirrorView — when captureMode is .videoRecording, overlay RecordingOverlay and hide MirrorBottomControls + FilterRailView. Keep CaptureFAB visible (in its red square state from GRWM-400).

VERIFY:
1. Start recording → REC pill appears top-left, counter increments 0:00→0:01→…
2. At 0:06 of 0:08 → counter turns butter yellow
3. During recording, filter rail + flip/flash hidden
4. Stop → overlay disappears
````

---

## GRWM-405 — Pro recording gate (DHMirrorProGate)

**Goal:** When non-Pro hits the 8s recording cap, show the chunky "Want longer videos?" sheet matching `docs/design-source/v3/screens-6.jsx` → `DHMirrorProGate`. Routes to parent gate → paywall on CTA, or back to preview with the 8s clip on dismiss.

**Prereqs:** GRWM-403 (8s cap), GRWM-312 (parent gate handoff pattern).

**Files:**
- `GRWMStudio/Capture/RecordingProGate.swift`
- `GRWMStudio/App/RootCoordinator.swift` (update — `showRecordingProGate(clipURL:)`)

**Acceptance criteria:**
- [ ] Sheet design matches DHMirrorProGate: chunky pink sheet from bottom, large "✨ Want 15-second videos?" headline, sticker, two CTAs ("Unlock with Pro" primary + "Save 8-sec clip" ghost).
- [ ] "Unlock with Pro" → coordinator.startParentGate(intent: .paywall).
- [ ] "Save 8-sec clip" → routes to PreviewView with the existing recorded clip URL.
- [ ] Backdrop tap dismisses to "Save 8-sec clip" path.

**Prompt:**

````
Build the RecordingProGate sheet.

CREATE GRWMStudio/Capture/RecordingProGate.swift matching docs/design-source/v3/screens-6.jsx DHMirrorProGate exactly:

struct RecordingProGate: View {
    let clipURL: URL
    let onSavePartial: () -> Void
    let onUnlockPro: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.45).ignoresSafeArea()
                .onTapGesture { onSavePartial() }

            VStack(spacing: 18) {
                StickerStar(size: 36, fill: DH.butter).padding(.top, 8)

                Text("Want 15-second videos? ✨")
                    .font(DH.font(.titleM))
                    .foregroundStyle(DH.ink)
                    .multilineTextAlignment(.center)

                Text("Studio Pro unlocks longer videos, all the looks, and zero ads.")
                    .font(DH.font(.body))
                    .foregroundStyle(DH.ink.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(spacing: 10) {
                    DHButton(kind: .primary, size: .xl, label: "Unlock with Pro", icon: "sparkles", action: onUnlockPro)
                        .frame(maxWidth: .infinity)
                    DHButton(kind: .ghost, size: .lg, label: "Save my 8-sec clip", action: onSavePartial)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }
            .padding(.top, 22)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32)
                    .fill(DH.pinkPaper)
                    .dhShadow(color: DH.pinkDeep, y: -6)
            )
            .transition(.move(edge: .bottom))
        }
    }
}

UPDATE RootCoordinator with `showRecordingProGate(clipURL:)` route. RootContainer renders RecordingProGate over the mirror.

UPDATE MirrorViewModel.tick() — at 8s cap for non-Pro, after endVideoFlow(force: true), capture the clip URL via the coordinator path and pass it to showRecordingProGate.

Update MirrorViewModel to receive the URL back:

@MainActor func endVideoFlow(force: Bool) async -> URL? {
    // ... existing
    return clipURL
}

VERIFY:
1. Non-Pro records past 8s → recording stops, ProGate sheet slides up with the clip URL captured
2. Tap "Save my 8-sec clip" → preview opens with the 8s video
3. Tap "Unlock with Pro" → parent gate → paywall flow
4. Tap backdrop → same as save partial
5. Sheet matches the V01 chunky pink aesthetic exactly
````

---


# Phase 5 — Library, Preview & Locker (GRWM-500 – GRWM-510)

After capture, the user previews the asset and decides to keep, share, or trash. The Locker is the saved-captures grid (3-up). The Looks Library is the curated catalog of full-face presets. Reference designs:

- `docs/design-source/v3/screens-7.jsx` → DHPreviewIdle, DHPreviewSaved, DHSavedEmpty, DHSavedAtLimit
- `docs/design-source/v3/screens-4.jsx` → DHSaveShare
- `docs/design-source/v3/screens-3.jsx` → DHLooks
- `docs/design-source/v3/screens-5.jsx` → DHLookDetail, DHTutorial

---

## GRWM-500 — Preview screen idle (DHPreviewIdle)

**Goal:** After capture, full-screen preview of the photo or video. Reference: `docs/design-source/v3/screens-7.jsx` → DHPreviewIdle. Two CTAs at the bottom: "Save to Locker" (primary) + "Share" (ghost). Top-left back button (returns to mirror, discards).

**Prereqs:** GRWM-401, GRWM-403.

**Files:**
- `GRWMStudio/Library/PreviewView.swift`
- `GRWMStudio/Library/CapturedAsset.swift`
- `GRWMStudio/Library/PreviewViewModel.swift`

**Acceptance criteria:**
- [ ] Layout exactly matches DHPreviewIdle: full-bleed asset on top, chunky CTAs at bottom, back X top-left, looks-tag chip top-right showing the active look name (or "Custom mix" if no look loaded).
- [ ] For video: native AVPlayer with autoplay loop, muted by default, tap-to-unmute.
- [ ] For photo: zoomable Image (pinch + double-tap).
- [ ] Back button → `coordinator.dismissPreview()` → returns to mirror, captureMode resets to idle.

**Prompt:**

````
Build PreviewView matching docs/design-source/v3/screens-7.jsx DHPreviewIdle.

CREATE GRWMStudio/Library/CapturedAsset.swift:

enum CapturedAsset: Hashable {
    case photo(UIImage)
    case video(URL)

    var isVideo: Bool {
        if case .video = self { return true } else { return false }
    }
}

CREATE GRWMStudio/Library/PreviewViewModel.swift:

@Observable @MainActor
final class PreviewViewModel {
    let asset: CapturedAsset
    let lookName: String?
    private(set) var isMuted: Bool = true
    init(asset: CapturedAsset, lookName: String?) { self.asset = asset; self.lookName = lookName }
    func toggleMute() { isMuted.toggle() }
}

CREATE GRWMStudio/Library/PreviewView.swift:

struct PreviewView: View {
    let asset: CapturedAsset
    let lookName: String?
    let onSave: () async -> Void
    let onShare: () -> Void
    let onDiscard: () -> Void

    @State private var vm: PreviewViewModel
    @State private var saving = false

    init(asset: CapturedAsset, lookName: String?, onSave: @escaping () async -> Void, onShare: @escaping () -> Void, onDiscard: @escaping () -> Void) {
        self.asset = asset
        self.lookName = lookName
        self.onSave = onSave
        self.onShare = onShare
        self.onDiscard = onDiscard
        self._vm = State(initialValue: PreviewViewModel(asset: asset, lookName: lookName))
    }

    var body: some View {
        ZStack(alignment: .top) {
            assetView.ignoresSafeArea()
            topChrome
            bottomActions
        }
    }

    @ViewBuilder
    private var assetView: some View {
        switch asset {
        case .photo(let img):
            ZoomableImage(image: img)
        case .video(let url):
            LoopingVideoPlayer(url: url, isMuted: vm.isMuted)
                .onTapGesture { vm.toggleMute() }
        }
    }

    private var topChrome: some View {
        HStack {
            backButton
            Spacer()
            if let look = lookName {
                lookTagChip(look)
            }
        }
        .padding(.horizontal, 18).padding(.top, 16)
    }

    private var backButton: some View {
        Button(action: onDiscard) {
            Image(systemName: "xmark").font(.system(size: 18, weight: .heavy))
                .foregroundStyle(DH.pinkDeep)
                .frame(width: 42, height: 42)
                .background(Circle().fill(.white))
                .dhShadow(color: DH.pink, y: 4)
        }
        .accessibilityLabel("Discard preview and return to mirror")
    }

    private func lookTagChip(_ name: String) -> some View {
        HStack(spacing: 6) {
            StickerStar(size: 14, fill: DH.butter)
            Text(name).font(DH.font(.chip)).foregroundStyle(DH.ink)
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(Capsule().fill(.white))
        .dhShadow(color: DH.pink, y: 4)
    }

    private var bottomActions: some View {
        VStack { Spacer()
            HStack(spacing: 10) {
                DHButton(kind: .primary, size: .xl, label: saving ? "Saving…" : "Save to Locker", icon: "heart.fill") {
                    guard !saving else { return }
                    saving = true
                    Task { await onSave(); saving = false }
                }
                .frame(maxWidth: .infinity)
                DHButton(kind: .ghost, size: .xl, label: "Share", icon: "square.and.arrow.up", action: onShare)
                    .frame(width: 110)
            }
            .padding(.horizontal, 18).padding(.bottom, 28)
        }
    }
}

ADD ZoomableImage helper (UIScrollView wrapper) and LoopingVideoPlayer (AVPlayerLayer subclass wrapping AVPlayer with looping).

VERIFY:
1. Capture photo → preview shows; pinch zooms; double-tap zoom in; back X discards
2. Capture video → preview loops muted; tap unmutes
3. With lipstick + Sunday Best look applied, preview shows the look name chip
4. With custom mix (no Look loaded), chip reads "Custom mix"
````

---

## GRWM-501 — Save to Locker (DHPreviewSaved confirmation)

**Goal:** Save action persists the asset to disk + a SwiftData `SavedCapture` record. Show a chunky "Saved!" confetti overlay (matching DHPreviewSaved). Then dismiss to mirror with a celebratory sound.

**Prereqs:** GRWM-500, GRWM-04 schema (SavedCapture).

**Files:**
- `GRWMStudio/Library/CaptureSaveService.swift`
- `GRWMStudio/Library/SavedConfetti.swift`
- `GRWMStudio/App/RootCoordinator.swift` (update — `dismissPreviewSaved`)

**Acceptance criteria:**
- [ ] Photos: convert UIImage to JPEG (quality 0.92), write to `Documents/captures/<uuid>.jpg`.
- [ ] Videos: copy from temp URL to `Documents/captures/<uuid>.mp4`.
- [ ] Insert `SavedCapture` SwiftData record with kind, filename, createdAt, lookName, shadeIDs.
- [ ] On save success, show `SavedConfetti` overlay 1.2s (chunky stickers floating up + "Saved! 💖" text).
- [ ] On save failure → `save-fail` banner inline; preview stays open.

**Prompt:**

````
Build save service + confetti overlay.

CREATE GRWMStudio/Library/CaptureSaveService.swift:

@MainActor
final class CaptureSaveService {
    private let modelContext: ModelContext
    init(_ ctx: ModelContext) { self.modelContext = ctx }

    func save(asset: CapturedAsset, lookName: String?, shadeIDs: [String]) async throws -> SavedCapture {
        let id = UUID()
        let dir = try captureDirectory()
        let url: URL
        let kind: SavedCaptureKind

        switch asset {
        case .photo(let img):
            url = dir.appendingPathComponent("\(id.uuidString).jpg")
            guard let data = img.jpegData(compressionQuality: 0.92) else { throw SaveError.encode }
            try data.write(to: url, options: .atomic)
            kind = .photo
        case .video(let src):
            url = dir.appendingPathComponent("\(id.uuidString).mp4")
            try FileManager.default.copyItem(at: src, to: url)
            kind = .video
        }

        let record = SavedCapture(id: id, kind: kind, filename: url.lastPathComponent, createdAt: .now, lookName: lookName, shadeIDs: shadeIDs)
        modelContext.insert(record)
        try modelContext.save()
        return record
    }

    private func captureDirectory() throws -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("captures", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
}

enum SaveError: Error { case encode }

CREATE GRWMStudio/Library/SavedConfetti.swift:

struct SavedConfetti: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        ZStack {
            Color.white.opacity(0.6).ignoresSafeArea()
            ForEach(0..<12, id: \.self) { i in
                StickerHeart(size: 28, fill: i.isMultiple(of: 2) ? DH.pinkDeep : DH.butter)
                    .offset(x: CGFloat.random(in: -120...120), y: -200 * phase + CGFloat.random(in: -40...40))
                    .opacity(1 - phase)
                    .rotationEffect(.degrees(Double(i) * 30 + Double(phase) * 90))
            }
            VStack(spacing: 8) {
                Text("Saved! 💖")
                    .font(DH.font(.titleL))
                    .foregroundStyle(DH.pinkDeep)
                    .scaleEffect(1 + 0.1 * phase)
                StickerStar(size: 32, fill: DH.butter)
            }
        }
        .task {
            withAnimation(.easeOut(duration: 1.2)) { phase = 1 }
            Sounds.confetti.play()
            DHHaptics.success()
        }
    }
}

UPDATE PreviewView's onSave to call CaptureSaveService → on success, route to dismissPreviewSaved which shows SavedConfetti for 1.2s then returns to mirror. On failure, show inline save-fail banner.

VERIFY:
1. Photo + Save → confetti, sound, success haptic, mirror returns
2. Video + Save → file present in Documents/captures, SwiftData record exists
3. Disk full simulated → save fails, save-fail banner appears, preview persists
4. Locker grid (built next) reflects new saves
````

---

## GRWM-502 — Locker grid

**Goal:** Locker tab renders saved captures as a 3-column grid of chunky cards. Each card: thumbnail (auto-generated), look-name chip, hold-to-delete affordance. Reference: locker is the bottom-rightmost tab.

**Prereqs:** GRWM-501.

**Files:**
- `GRWMStudio/Locker/LockerView.swift`
- `GRWMStudio/Locker/LockerCardView.swift`
- `GRWMStudio/Locker/LockerViewModel.swift`

**Acceptance criteria:**
- [ ] Grid is `LazyVGrid` with 3 columns, 12pt spacing.
- [ ] Cards are square, br=20, white, chunky pink shadow.
- [ ] Photo thumbnail: load from disk via async loader; cache via NSCache.
- [ ] Video thumbnail: AVAsset.copyCGImage at 0.5s; cache.
- [ ] Card has a tiny "▶" chip if video, top-right.
- [ ] Tapping a card opens a fullscreen `LockerDetailView` (next ticket).
- [ ] Long-press → bouncy delete confirmation menu.
- [ ] Empty state: render `LockerEmptyView` (next ticket).
- [ ] At-limit state (50 captures): render alongside grid (top banner) — see GRWM-504.

**Prompt:**

````
Build LockerView grid.

CREATE GRWMStudio/Locker/LockerViewModel.swift:

@Observable @MainActor
final class LockerViewModel {
    private(set) var captures: [SavedCapture] = []
    private let modelContext: ModelContext

    init(_ ctx: ModelContext) { self.modelContext = ctx }

    func reload() {
        let descriptor = FetchDescriptor<SavedCapture>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        captures = (try? modelContext.fetch(descriptor)) ?? []
    }

    func delete(_ capture: SavedCapture) {
        modelContext.delete(capture)
        try? modelContext.save()
        // Remove file
        let url = captureURL(capture)
        try? FileManager.default.removeItem(at: url)
        reload()
    }

    func captureURL(_ c: SavedCapture) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("captures").appendingPathComponent(c.filename)
    }

    var isAtLimit: Bool { captures.count >= 50 }
}

CREATE GRWMStudio/Locker/LockerCardView.swift:

struct LockerCardView: View {
    let capture: SavedCapture
    let url: URL
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var thumbnail: UIImage?

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .dhShadow(color: DH.pink, y: 5)
                if let img = thumbnail {
                    Image(uiImage: img).resizable().scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    DHWallpaperGradient().clipShape(RoundedRectangle(cornerRadius: 20))
                }
                if capture.kind == .video {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12, weight: .heavy)).foregroundStyle(.white)
                        .padding(6)
                        .background(Circle().fill(DH.pinkDeep))
                        .padding(6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
                if let look = capture.lookName {
                    HStack {
                        Text(look)
                            .font(DH.font(.chipSmall))
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(.white.opacity(0.92)))
                        Spacer()
                    }
                    .padding(8)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .task { thumbnail = await ThumbnailLoader.load(url: url, kind: capture.kind) }
    }
}

ADD ThumbnailLoader actor with NSCache.

CREATE GRWMStudio/Locker/LockerView.swift:

struct LockerView: View {
    @Environment(\.modelContext) private var ctx
    @State private var vm: LockerViewModel?
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]
    var body: some View {
        ZStack {
            DHWallpaperGradient().ignoresSafeArea()
            if let vm {
                if vm.captures.isEmpty {
                    LockerEmptyView()
                } else {
                    ScrollView {
                        if vm.isAtLimit { LockerAtLimitBanner().padding() }
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(vm.captures) { c in
                                LockerCardView(capture: c, url: vm.captureURL(c),
                                              onTap: { /* GRWM-507 */ },
                                              onDelete: { vm.delete(c) })
                            }
                        }
                        .padding(.horizontal, 14).padding(.top, 80) // top bar pad
                    }
                }
            }
        }
        .task {
            if vm == nil { vm = LockerViewModel(ctx) }
            vm?.reload()
        }
    }
}

UPDATE AppShell — when selected == .locker, render LockerView().

VERIFY:
1. With 0 captures → empty state shows
2. Capture 3 photos → grid shows 3 cards in reverse-chrono order
3. Long-press a card → context menu with Delete
4. Delete → file gone from disk, record gone from SwiftData, grid reloads
5. Card tap routes to LockerDetailView placeholder
````

---

## GRWM-503 — Locker empty state (DHSavedEmpty)

**Goal:** When the user has zero saved captures, show the chunky empty state with sticker, headline, copy, and CTA back to mirror. Reference: `docs/design-source/v3/screens-7.jsx` → DHSavedEmpty.

**Prereqs:** GRWM-502.

**Files:**
- `GRWMStudio/Locker/LockerEmptyView.swift`

**Acceptance criteria:**
- [ ] Layout matches DHSavedEmpty: huge sticker (heart in butter circle), "Your Locker is feeling empty" headline (Fredoka heavy 24), warm subcopy, primary CTA "Make your first look ✨".
- [ ] Tapping CTA selects the Mirror tab.

**Prompt:**

````
Build LockerEmptyView matching docs/design-source/v3/screens-7.jsx DHSavedEmpty.

CREATE GRWMStudio/Locker/LockerEmptyView.swift:

struct LockerEmptyView: View {
    @Environment(\.appShellSelector) private var setTab

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().fill(DH.butter).frame(width: 160, height: 160)
                    .dhShadow(color: Color(hex: 0xC99B1F), y: 8)
                StickerHeart(size: 80, fill: DH.pinkDeep)
                    .rotationEffect(.degrees(-10))
            }

            Text("Your Locker is feeling empty")
                .font(DH.font(.titleL))
                .foregroundStyle(DH.ink)
                .multilineTextAlignment(.center)

            Text("Save your fave looks here so you can wear them again, share them, or dream up new ones.")
                .font(DH.font(.body))
                .foregroundStyle(DH.ink.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            DHButton(kind: .primary, size: .xl, label: "Make your first look ✨", icon: "sparkles") {
                setTab(.mirror)
            }
            .padding(.horizontal, 30)
            .padding(.top, 6)
        }
    }
}

ADD an Environment key `appShellSelector: (DHTab) -> Void` so child views can change the tab.

VERIFY: with no captures → empty state shows. Tap CTA → tab switches to mirror.
````

---

## GRWM-504 — Locker at-limit (DHSavedAtLimit)

**Goal:** When the user reaches 50 captures, show a chunky butter banner at the top of the Locker grid: "Locker's almost full ✨ — delete some to keep saving!" Reference: `docs/design-source/v3/screens-7.jsx` → DHSavedAtLimit.

**Prereqs:** GRWM-502.

**Files:**
- `GRWMStudio/Locker/LockerAtLimitBanner.swift`
- `GRWMStudio/Library/CaptureSaveService.swift` (update — reject saves at 50)

**Acceptance criteria:**
- [ ] Banner: butter card, sticker, copy "Locker's almost full ✨", "Delete some to keep saving!"
- [ ] Banner above the grid when count >= 50.
- [ ] CaptureSaveService throws `SaveError.atLimit` when count is already 50.
- [ ] At save-time (preview), if atLimit → show full-screen DHSavedAtLimit (a stronger version of the banner).

**Prompt:**

````
Build LockerAtLimitBanner + at-limit save behavior matching docs/design-source/v3/screens-7.jsx DHSavedAtLimit.

CREATE GRWMStudio/Locker/LockerAtLimitBanner.swift:

struct LockerAtLimitBanner: View {
    var body: some View {
        DHCard(color: DH.butter, deep: Color(hex: 0xC99B1F)) {
            HStack(spacing: 10) {
                StickerStar(size: 22, fill: DH.pinkDeep)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Locker's almost full ✨")
                        .font(DH.font(.cardTitle))
                        .foregroundStyle(DH.ink)
                    Text("Delete some looks to keep saving!")
                        .font(DH.font(.bodySmall))
                        .foregroundStyle(DH.ink.opacity(0.7))
                }
                Spacer()
            }
            .padding(14)
        }
    }
}

UPDATE CaptureSaveService:

func save(...) async throws -> SavedCapture {
    let count = try modelContext.fetchCount(FetchDescriptor<SavedCapture>())
    if count >= 50 { throw SaveError.atLimit }
    // ... existing save logic
}

enum SaveError: Error { case encode, atLimit }

UPDATE PreviewView onSave catch — if SaveError.atLimit, show a full-screen LockerAtLimitFullScreen (a bigger version with delete CTA going to Locker).

VERIFY:
1. Seed SwiftData with 50 captures → Locker shows the at-limit banner
2. Try to save a new capture → save fails with atLimit, full-screen at-limit message appears
3. Delete one capture → saving works again
````

---

## GRWM-505 — Save/Share screen (DHSaveShare)

**Goal:** A dedicated post-save screen that lets the user choose where to share, with chunky social action chips (Camera Roll, Messages, Email, More) plus stickers. Reference: `docs/design-source/v3/screens-4.jsx` → DHSaveShare.

**Prereqs:** GRWM-501.

**Files:**
- `GRWMStudio/Library/SaveShareView.swift`

**Acceptance criteria:**
- [ ] Layout matches DHSaveShare: top sticker confetti, asset thumbnail card, 4 chunky action buttons in a 2×2 grid, "Done" ghost button at bottom.
- [ ] Camera Roll → photo: PHPhotoLibrary saveImage; video: PHPhotoLibrary saveVideo. Requires PhotoLibrary permission (handle photo-denied via the permission service).
- [ ] Messages / Email → UIActivityViewController with the asset URL/Image (system share sheet preserves the choice).
- [ ] More → standard UIActivityViewController.
- [ ] Done → dismisses to mirror or locker depending on origin.

**Prompt:**

````
Build SaveShareView matching docs/design-source/v3/screens-4.jsx DHSaveShare.

CREATE GRWMStudio/Library/SaveShareView.swift with:

struct SaveShareView: View {
    let capture: SavedCapture
    let captureURL: URL
    let onDone: () -> Void

    @State private var error: ErrorVariant?
    @State private var sharingItem: ShareItem?

    var body: some View {
        ZStack {
            DHWallpaperGradient().ignoresSafeArea()
            VStack(spacing: 18) {
                ZStack {
                    StickerHeart(size: 28, fill: DH.pinkDeep).offset(x: -120, y: -10)
                    StickerStar(size: 24, fill: DH.butter).offset(x: 110, y: -20)
                    StickerSparkle(size: 22, fill: DH.lavender).offset(x: 0, y: -32)

                    Text("All saved! ✨")
                        .font(DH.font(.titleL))
                        .foregroundStyle(DH.pinkDeep)
                }
                .padding(.top, 70)

                thumbnailCard

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    actionButton("Camera Roll", icon: "photo.on.rectangle", color: DH.pink, action: saveToCameraRoll)
                    actionButton("Messages", icon: "message.fill", color: DH.butter, action: { share(via: .messages) })
                    actionButton("Email", icon: "envelope.fill", color: DH.lavender, action: { share(via: .email) })
                    actionButton("More", icon: "ellipsis", color: DH.mint, action: { share(via: .activity) })
                }
                .padding(.horizontal, 18)

                DHButton(kind: .ghost, size: .xl, label: "Done", action: onDone)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 18)

                Spacer()
            }
        }
        .sheet(item: $sharingItem) { item in
            ActivityShareSheet(items: item.items)
        }
        .alert(item: $error) { v in /* ... */ }
    }

    // ... helpers
}

ADD: PhotoLibrarySaver utility and ActivityShareSheet (UIViewControllerRepresentable wrapping UIActivityViewController).

VERIFY:
1. From PreviewSaved → Share → SaveShareView opens, asset card visible
2. Camera Roll button: with permission → saves, success haptic; without permission → photo-denied error variant routed
3. Messages → share sheet opens with image/video
4. Email → email composer with attachment
5. Done returns to wherever opened (preview or locker)
````

---

## GRWM-506 — Share sheet integration & permissions

**Goal:** Add the `PHPhotoLibrary` save flow with proper permission gating. If `addOnly` is denied, route to the chunky `photo-denied` error variant.

**Prereqs:** GRWM-505, GRWM-109 (PermissionsService).

**Files:**
- `GRWMStudio/Library/PhotoLibrarySaver.swift`
- `GRWMStudio/Permissions/PermissionsService.swift` (update — addPhotoLibrary handlers)

**Acceptance criteria:**
- [ ] Photos add-only permission requested via `PHPhotoLibrary.requestAuthorization(for: .addOnly)` exactly when user taps "Camera Roll" — never preemptively.
- [ ] On denial → `photo-denied` error variant.
- [ ] On success → save image or video to camera roll.
- [ ] Privacy strings: NSPhotoLibraryAddUsageDescription = "GRWM Studio adds your saved looks to your camera roll when you tap Save."

**Prompt:**

````
Implement PhotoLibrarySaver + permission flow.

CREATE GRWMStudio/Library/PhotoLibrarySaver.swift:

import Photos

enum PhotoLibrarySaver {
    static func save(_ asset: CapturedAsset, fileURL: URL?) async throws {
        let status = await requestAddOnlyAuth()
        guard status == .authorized || status == .limited else {
            throw PermissionError.photoDenied
        }
        try await PHPhotoLibrary.shared().performChanges {
            switch asset {
            case .photo(let img):
                PHAssetChangeRequest.creationRequestForAsset(from: img)
            case .video(let url):
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }
        }
    }

    private static func requestAddOnlyAuth() async -> PHAuthorizationStatus {
        await withCheckedContinuation { cont in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                cont.resume(returning: status)
            }
        }
    }
}

enum PermissionError: Error { case photoDenied, microphoneDenied, cameraDenied }

UPDATE SaveShareView.saveToCameraRoll:

func saveToCameraRoll() {
    Task {
        do {
            try await PhotoLibrarySaver.save(asset, fileURL: captureURL)
            DHHaptics.success()
            Sounds.confetti.play()
        } catch PermissionError.photoDenied {
            error = .photoDenied
        } catch {
            error = .saveFail
        }
    }
}

VERIFY:
1. Fresh install → tap Camera Roll → system sheet appears, allow → image saved + success haptic
2. Deny on system sheet → photo-denied error variant
3. Restrict in iOS settings to "Selected" → still saves (limited mode is acceptable)
4. Photo Library entry visible in iOS Settings > Privacy
````

---

## GRWM-507 — Locker detail view + delete flow

**Goal:** Tapping a Locker card opens a fullscreen detail view of the asset, with sharing actions and delete. Photo: zoomable; video: native AVKit player.

**Prereqs:** GRWM-502.

**Files:**
- `GRWMStudio/Locker/LockerDetailView.swift`

**Acceptance criteria:**
- [ ] Full-screen sheet from below.
- [ ] Top-right "Share" + "Trash" chunky icons.
- [ ] Trash → confirmation chip "Delete this look?" with Yes/Keep buttons. Yes → deletes, dismisses.
- [ ] Share → opens SaveShareView with this capture.
- [ ] Bottom strip shows look name + creation date.

**Prompt:**

````
Build LockerDetailView.

CREATE GRWMStudio/Locker/LockerDetailView.swift:

struct LockerDetailView: View {
    let capture: SavedCapture
    let url: URL
    let onShare: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void

    @State private var confirmingDelete = false

    var body: some View {
        ZStack(alignment: .top) {
            assetView.ignoresSafeArea()

            HStack {
                CircleButton(systemName: "xmark", action: onDismiss).accessibilityLabel("Close")
                Spacer()
                CircleButton(systemName: "square.and.arrow.up", action: onShare).accessibilityLabel("Share")
                CircleButton(systemName: "trash", tint: DH.recRed) {
                    confirmingDelete = true
                }.accessibilityLabel("Delete")
            }
            .padding(18)

            VStack {
                Spacer()
                detailFooter
            }

            if confirmingDelete { deleteConfirmation }
        }
    }

    @ViewBuilder
    private var assetView: some View {
        if capture.kind == .video {
            LoopingVideoPlayer(url: url, isMuted: false)
        } else if let img = UIImage(contentsOfFile: url.path) {
            ZoomableImage(image: img)
        } else {
            DHWallpaperGradient()
        }
    }

    private var detailFooter: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(capture.lookName ?? "Custom mix")
                    .font(DH.font(.cardTitle))
                    .foregroundStyle(.white)
                Text(capture.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(DH.font(.bodySmall))
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
        }
        .padding(18)
        .background(LinearGradient(colors: [.clear, .black.opacity(0.5)], startPoint: .top, endPoint: .bottom))
    }

    private var deleteConfirmation: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { confirmingDelete = false }
            DHCard(color: .white, deep: DH.recRed) {
                VStack(spacing: 14) {
                    Text("Delete this look?")
                        .font(DH.font(.titleM)).foregroundStyle(DH.ink)
                    HStack(spacing: 10) {
                        DHButton(kind: .ghost, size: .lg, label: "Keep") { confirmingDelete = false }
                        DHButton(kind: .destructive, size: .lg, label: "Delete", action: {
                            onDelete()
                            confirmingDelete = false
                        })
                    }
                }
                .padding(20)
            }
            .padding(36)
        }
    }
}

UPDATE LockerView — onTap of card opens LockerDetailView via .fullScreenCover.

VERIFY:
1. Tap card → detail view opens
2. Delete → confirmation appears, Keep dismisses, Delete removes file + record
3. Share → SaveShareView appears with this capture
4. For video, plays automatically with audio
````

---

## GRWM-508 — SwiftData persistence + migrations

**Goal:** Solidify the SwiftData schema for SavedCapture, FavoriteLook, ProfileRecord. Add a v1 migration plan in case schema changes in v2.

**Prereqs:** GRWM-04 (architecture).

**Files:**
- `GRWMStudio/Persistence/Schema.swift`
- `GRWMStudio/Persistence/PersistenceContainer.swift`
- `GRWMStudio/Persistence/SchemaMigrations.swift`

**Acceptance criteria:**
- [ ] All `@Model` classes live in Persistence/, conform to `Identifiable, Hashable`.
- [ ] `SavedCapture`: id, kind, filename, createdAt, lookName?, shadeIDs (encoded as `[String]`).
- [ ] `FavoriteLook`: id, lookID, addedAt.
- [ ] `ProfileRecord`: id, displayName, avatarSeed, parentEmailHash (SHA256), createdAt.
- [ ] Container creates with `schema: Schema(versionedSchema: V1.self)` and `migrationPlan: GRWMMigrationPlan.self`.
- [ ] `GRWMMigrationPlan` is empty in v1 but the structure is in place.

**Prompt:**

````
Build the SwiftData schema container.

CREATE GRWMStudio/Persistence/Schema.swift:

import SwiftData

enum SavedCaptureKind: String, Codable { case photo, video }

@Model
final class SavedCapture {
    @Attribute(.unique) var id: UUID
    var kindRaw: String
    var filename: String
    var createdAt: Date
    var lookName: String?
    var shadeIDsCSV: String

    var kind: SavedCaptureKind { SavedCaptureKind(rawValue: kindRaw) ?? .photo }
    var shadeIDs: [String] { shadeIDsCSV.split(separator: ",").map(String.init) }

    init(id: UUID, kind: SavedCaptureKind, filename: String, createdAt: Date, lookName: String?, shadeIDs: [String]) {
        self.id = id
        self.kindRaw = kind.rawValue
        self.filename = filename
        self.createdAt = createdAt
        self.lookName = lookName
        self.shadeIDsCSV = shadeIDs.joined(separator: ",")
    }
}

@Model
final class FavoriteLook {
    @Attribute(.unique) var id: UUID
    var lookID: String
    var addedAt: Date
    init(id: UUID = UUID(), lookID: String, addedAt: Date = .now) {
        self.id = id; self.lookID = lookID; self.addedAt = addedAt
    }
}

@Model
final class ProfileRecord {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var avatarSeed: Int
    var parentEmailHash: String?
    var createdAt: Date
    init(id: UUID = UUID(), displayName: String, avatarSeed: Int, parentEmailHash: String? = nil) {
        self.id = id; self.displayName = displayName; self.avatarSeed = avatarSeed
        self.parentEmailHash = parentEmailHash
        self.createdAt = .now
    }
}

CREATE GRWMStudio/Persistence/SchemaMigrations.swift:

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [SavedCapture.self, FavoriteLook.self, ProfileRecord.self] }
}

enum GRWMMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

CREATE GRWMStudio/Persistence/PersistenceContainer.swift:

@MainActor
enum PersistenceContainer {
    static let shared: ModelContainer = {
        do {
            let cfg = ModelConfiguration(schema: Schema(versionedSchema: SchemaV1.self), isStoredInMemoryOnly: false)
            return try ModelContainer(for: Schema(versionedSchema: SchemaV1.self), migrationPlan: GRWMMigrationPlan.self, configurations: cfg)
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }()
}

UPDATE GRWMStudioApp.swift to apply .modelContainer(PersistenceContainer.shared) on the root view.

VERIFY:
1. App launches with empty store, no crash
2. Save a capture → file in Documents/captures, record in store
3. Force-quit and relaunch → captures persist in Locker grid
4. Profile record can be created and retrieved by id
````

---

## GRWM-509 — Looks Library (DHLooks)

**Goal:** The Looks tab — a curated catalog of looks with category sections (Everyday, Party, Holiday, Pro). Reference: `docs/design-source/v3/screens-3.jsx` → DHLooks.

**Prereqs:** GRWM-310 (Looks data), GRWM-08 (DH primitives).

**Files:**
- `GRWMStudio/Library/LooksLibraryView.swift`
- `GRWMStudio/Library/LooksLibraryViewModel.swift`
- `GRWMStudio/Library/LookSection.swift`

**Acceptance criteria:**
- [ ] Layout exactly matches DHLooks: chunky pink top header with sparkle, horizontal sections of look cards.
- [ ] Sections (3 free + 1 Pro): "Everyday" (Sunday Best, School Day), "Party" (Birthday Glam, Sleepover), "Pro Looks" (Pop Star, Disco Princess, Garden Party, Time Warp — all locked behind gold star).
- [ ] Each card 140×180, br=20, white, chunky pink shadow.
- [ ] Tap a card → opens `DHLookDetail` (next ticket).
- [ ] Pro cards show gold star + slight overlay tint.
- [ ] Heart icon top-right of each card to favorite (FavoriteLook record).

**Prompt:**

````
Build LooksLibraryView matching docs/design-source/v3/screens-3.jsx DHLooks.

CREATE GRWMStudio/Library/LooksLibraryViewModel.swift:

@Observable @MainActor
final class LooksLibraryViewModel {
    private(set) var sections: [LookSection] = []
    private(set) var favorites: Set<String> = []
    private let modelContext: ModelContext

    init(_ ctx: ModelContext) {
        self.modelContext = ctx
        buildSections()
        reloadFavorites()
    }

    private func buildSections() {
        sections = [
            LookSection(title: "Everyday ✨", looks: [Looks.byID("look.sunday-best"), Looks.byID("look.school-day")].compactMap { $0 }),
            LookSection(title: "Party 💖",   looks: [Looks.byID("look.birthday-glam"), Looks.byID("look.sleepover")].compactMap { $0 }),
            LookSection(title: "Pro Looks 🌟", looks: [Looks.byID("look.pop-star"), Looks.byID("look.disco-princess"), Looks.byID("look.garden-party"), Looks.byID("look.time-warp")].compactMap { $0 }),
        ]
    }

    func reloadFavorites() {
        let records = (try? modelContext.fetch(FetchDescriptor<FavoriteLook>())) ?? []
        favorites = Set(records.map(\.lookID))
    }

    func toggleFavorite(lookID: String) {
        if favorites.contains(lookID) {
            let records = (try? modelContext.fetch(FetchDescriptor<FavoriteLook>(predicate: #Predicate { $0.lookID == lookID }))) ?? []
            for r in records { modelContext.delete(r) }
        } else {
            modelContext.insert(FavoriteLook(lookID: lookID))
        }
        try? modelContext.save()
        reloadFavorites()
    }
}

CREATE GRWMStudio/Library/LookSection.swift:

struct LookSection: Identifiable, Hashable {
    var id: String { title }
    let title: String
    let looks: [LookPreset]
}

CREATE GRWMStudio/Library/LooksLibraryView.swift with the chunky DHLooks layout — top sparkly header, vertical scroll of sections, each section: title in Fredoka 22, ScrollView(.horizontal) of cards.

Each card:
- 140×180
- white, br=20, chunky pink shadow
- top: 100pt thumbnail
- bottom: name in Fredoka 14 + heart toggle right
- if isPro: gold StickerStar at top-right corner + 10% tint overlay
- tap → coordinator.showLookDetail(look)

VERIFY:
1. Looks tab → 3 sections, scrollable horizontally
2. Tap heart on a card → favorite saved, persists across relaunches
3. Tap Pro card → opens DHLookDetail (placeholder until next ticket)
4. Layout matches DHLooks reference 1:1
````

---

## GRWM-510 — Look detail (DHLookDetail) + tutorial (DHTutorial)

**Goal:** Detail view of a single Look. Hero image, description, "Try it on" CTA, list of shades that compose the look. If the user has never opened a look, show the chunky tutorial overlay (DHTutorial). References: `docs/design-source/v3/screens-5.jsx`.

**Prereqs:** GRWM-509.

**Files:**
- `GRWMStudio/Library/LookDetailView.swift`
- `GRWMStudio/Library/LookTutorialOverlay.swift`

**Acceptance criteria:**
- [ ] DHLookDetail layout 1:1: full-bleed hero (look thumbnail), chunky pink card with name + description + composition list, primary CTA "Try this look ✨".
- [ ] Composition list: chips per category (e.g., "Lips: Petal Pink", "Eyes: Dreamy Pink Shadow").
- [ ] Heart in top-right.
- [ ] Tutorial overlay (DHTutorial) appears once per user — chunky speech-bubble pointing at Try button: "Tap to wear this look!".
- [ ] Tutorial dismiss tracked in UserDefaults `dh_seen_look_tutorial` = true.
- [ ] CTA tap → switch to mirror tab + immediately apply the look via vm.selectLook.

**Prompt:**

````
Build LookDetailView + LookTutorialOverlay matching docs/design-source/v3/screens-5.jsx DHLookDetail and DHTutorial.

CREATE GRWMStudio/Library/LookDetailView.swift:

struct LookDetailView: View {
    let look: LookPreset
    let onTryItOn: () -> Void
    let onDismiss: () -> Void

    @State private var showTutorial: Bool = !UserDefaults.standard.bool(forKey: "dh_seen_look_tutorial")
    @Environment(LooksLibraryViewModel.self) private var libraryVM

    var body: some View {
        ZStack(alignment: .top) {
            DHWallpaperGradient().ignoresSafeArea()

            ScrollView {
                Image(look.thumbnailAsset)
                    .resizable().scaledToFill()
                    .frame(height: 360)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .padding(.horizontal, 12)
                    .padding(.top, 80)

                DHCard(color: .white, deep: DH.pinkDeep) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text(look.name).font(DH.font(.titleL)).foregroundStyle(DH.ink)
                            if look.isPro { StickerStar(size: 26, fill: DH.butter) }
                            Spacer()
                            Button { libraryVM.toggleFavorite(lookID: look.id); DHHaptics.medium() } label: {
                                Image(systemName: libraryVM.favorites.contains(look.id) ? "heart.fill" : "heart")
                                    .font(.system(size: 22, weight: .heavy))
                                    .foregroundStyle(DH.pinkDeep)
                            }
                        }
                        Text(LookCopy.description(for: look.id))
                            .font(DH.font(.body)).foregroundStyle(DH.ink.opacity(0.7))

                        Text("What's in this look")
                            .font(DH.font(.cardTitle)).foregroundStyle(DH.ink)
                            .padding(.top, 8)
                        FlowLayout(spacing: 6) {
                            ForEach(LookCopy.composition(for: look.id), id: \.self) { c in
                                DHChip(label: c)
                            }
                        }
                    }
                    .padding(18)
                }
                .padding(18)
            }

            HStack {
                CircleButton(systemName: "chevron.left", action: onDismiss).accessibilityLabel("Back")
                Spacer()
            }
            .padding(.horizontal, 18).padding(.top, 16)

            VStack { Spacer()
                DHButton(kind: .primary, size: .xl, label: "Try this look ✨", icon: "sparkles", action: onTryItOn)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 18).padding(.bottom, 28)
            }

            if showTutorial { LookTutorialOverlay { showTutorial = false; UserDefaults.standard.set(true, forKey: "dh_seen_look_tutorial") } }
        }
    }
}

ADD LookCopy with description + composition strings per look ID.

CREATE GRWMStudio/Library/LookTutorialOverlay.swift matching docs/design-source/v3/screens-5.jsx DHTutorial:

struct LookTutorialOverlay: View {
    let onDismiss: () -> Void
    var body: some View {
        ZStack { Color.black.opacity(0.5).ignoresSafeArea().onTapGesture(perform: onDismiss)
            VStack { Spacer()
                speechBubble.padding(.bottom, 96)
            }
        }
    }
    private var speechBubble: some View {
        VStack(spacing: 6) {
            DHCard(color: DH.butter, deep: DH.pinkDeep) {
                HStack(spacing: 10) {
                    StickerSparkle(size: 22, fill: DH.pinkDeep)
                    Text("Tap to wear this look!").font(DH.font(.cardTitle)).foregroundStyle(DH.ink)
                }.padding(14)
            }
            Triangle().fill(DH.butter).frame(width: 22, height: 14).overlay(Triangle().stroke(DH.pinkDeep, lineWidth: 0))
        }
    }
}

private struct Triangle: Shape { func path(in rect: CGRect) -> Path { var p = Path(); p.move(to: CGPoint(x: rect.midX, y: rect.maxY)); p.addLine(to: CGPoint(x: rect.minX, y: rect.minY)); p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)); p.closeSubpath(); return p } }

UPDATE coordinator: showLookDetail(look) → presents LookDetailView. Try it on → setTab(.mirror) + vm.selectLook(look) on the mirror VM.

VERIFY:
1. First open of any look detail → tutorial overlay appears, dismiss persisted
2. Subsequent opens → no tutorial
3. Try it on → returns to mirror with the look applied
4. Heart toggles favorite, persists
````

---


---

# Phase 6 — Profile & Feed (Local-Only)

> **CRITICAL COPPA NOTE for this phase:** The JSX mockups for DHProfile and DHFeed in `screens-4.jsx` and `screens-5.jsx` show social features (handles, follower counts, comments, friend stories). These are visual templates only. **GRWM Studio is a Made-for-Kids app with no accounts, no networking, no UGC.** We adapt the JSX visuals but back them with **local-only data** and a **curated bundled feed** (read-only). Do NOT add networking to user data. Do NOT add comments/follows/likes that persist anywhere except locally. Cite this phase note in any ticket where the JSX implies social behavior.

---

## GRWM-600 — Profile tab (DHProfile, local-only)

**Goal:** Build the Profile tab matching the visual layout of `docs/design-source/v3/screens-4.jsx` `DHProfile`, adapted for local-only data: avatar swatches, kid-chosen display name, Glow Level (derived from saved captures count), Recent Looks (latest saved captures from SwiftData). No followers/following counts. No share button. No stories rail.

**Prereqs:** GRWM-300 (Mirror tab shell), GRWM-508 (SwiftData), GRWM-009 (DHCard, DHButton, StickerSparkle)

**Files:**
- `GRWMStudio/Profile/DHProfileView.swift` (new)
- `GRWMStudio/Profile/ProfileViewModel.swift` (new)
- `GRWMStudio/Profile/GlowLevel.swift` (new)
- `GRWMStudio/Coordinator/AppCoordinator.swift` (update — wire Profile tab content)

**Acceptance criteria:**
- [ ] Pink hero gradient (DH.pink → DH.pinkLight) covers top 300pt
- [ ] Scallop divider SVG between hero and cream body
- [ ] Avatar circle 120pt with 5pt white border, 6pt deep-pink shadow drop, 12pt extra blur
- [ ] Avatar shows kid's selected swatch (default: pink) — tap → routes to AvatarEditor (GRWM-601)
- [ ] "EDIT AVATAR" butter pill below avatar, tap → AvatarEditor
- [ ] Display name centered, white text, 26pt heavy, deep-pink drop shadow (3pt y), default: "GRWM Star"
- [ ] Subtitle line: kid's chosen tagline OR default "Bubblegum girlie ✨"
- [ ] **NO follower/following stats** — replaced with three Looks-themed counters: `LOOKS SAVED`, `LOOKS TRIED`, `STREAK 🔥`
- [ ] Glow Level row: dynamic level computed from `GlowLevel.compute(captureCount:)` (1 level per 5 captures, max 99)
- [ ] Glow progress bar 14pt height, white inset shadow, gradient fill, sparkle marker at fill end
- [ ] "Recent looks" horizontal scroller showing last 3 saved captures (or empty-state pill: "No looks yet — go to Mirror!")
- [ ] Tab bar visible, "me" tab active
- [ ] All copy verbatim from design where applicable; replacements documented in code comments

**Prompt:**
````
CONTEXT: Build the Profile tab. The JSX `docs/design-source/v3/screens-4.jsx` `DHProfile` is the visual template. We REMOVE all social affordances (handle, followers, share) because GRWM Studio is Made-for-Kids with no accounts. Replace with local-only metrics.

CREATE GRWMStudio/Profile/GlowLevel.swift:

import Foundation

enum GlowLevel {
    static let capturesPerLevel = 5
    static let maxLevel = 99

    static func compute(captureCount: Int) -> (level: Int, progressInLevel: Int, target: Int) {
        let level = min(maxLevel, max(1, captureCount / capturesPerLevel + 1))
        let progressInLevel = captureCount % capturesPerLevel
        return (level, progressInLevel, capturesPerLevel)
    }

    static func percent(captureCount: Int) -> Double {
        let info = compute(captureCount: captureCount)
        return Double(info.progressInLevel) / Double(info.target)
    }
}

CREATE GRWMStudio/Profile/ProfileViewModel.swift:

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    private(set) var profile: ProfileRecord?
    private(set) var captureCount: Int = 0
    private(set) var looksTried: Int = 0
    private(set) var streak: Int = 0
    private(set) var recent: [SavedCapture] = []

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func reload() {
        // Profile
        let pdesc = FetchDescriptor<ProfileRecord>()
        if let existing = try? context.fetch(pdesc).first {
            self.profile = existing
        } else {
            let p = ProfileRecord.makeDefault()
            context.insert(p)
            try? context.save()
            self.profile = p
        }

        // Captures
        var cdesc = FetchDescriptor<SavedCapture>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        cdesc.fetchLimit = 1000
        let captures = (try? context.fetch(cdesc)) ?? []
        self.captureCount = captures.count
        self.recent = Array(captures.prefix(3))
        self.looksTried = profile?.distinctLooksTried ?? 0
        self.streak = profile?.streakDays ?? 0
    }

    var glowLevel: Int { GlowLevel.compute(captureCount: captureCount).level }
    var glowPercent: Double { GlowLevel.percent(captureCount: captureCount) }
    var glowTarget: Int { (glowLevel) * GlowLevel.capturesPerLevel }
}

CREATE GRWMStudio/Profile/DHProfileView.swift:

import SwiftUI
import SwiftData

struct DHProfileView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm: ProfileViewModel?

    var body: some View {
        Group {
            if let vm {
                content(vm: vm)
            } else {
                Color.clear.onAppear {
                    let v = ProfileViewModel(context: context)
                    v.reload()
                    self.vm = v
                }
            }
        }
        .onAppear { vm?.reload() }
        .background(DH.cream.ignoresSafeArea())
    }

    @ViewBuilder
    private func content(vm: ProfileViewModel) -> some View {
        ScrollView {
            ZStack(alignment: .top) {
                // Pink hero gradient (top 300pt)
                LinearGradient(colors: [DH.pink, DH.pinkLight], startPoint: .top, endPoint: .bottom)
                    .frame(height: 300)
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 0) {
                    // Top icon row (gear + share placeholder, share is non-functional / removed)
                    HStack {
                        Button { coordinator.showSettings() } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.white)
                                .frame(width: 42, height: 42)
                                .background(Color.white.opacity(0.3), in: Circle())
                        }
                        .accessibilityLabel("Settings")
                        Spacer()
                        // Share circle removed for COPPA — no networking
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)

                    // Avatar
                    AvatarBubble(swatch: vm.profile?.avatarSwatch ?? .pink)
                        .padding(.top, 18)
                        .onTapGesture { coordinator.showAvatarEditor() }

                    DHButton(kind: .yellow, size: .sm, label: "EDIT AVATAR", action: { coordinator.showAvatarEditor() })
                        .padding(.top, 8)

                    Text(vm.profile?.displayName ?? "GRWM Star")
                        .font(DH.font(.titleLarge))
                        .foregroundStyle(.white)
                        .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 3)
                        .padding(.top, 10)

                    Text(vm.profile?.tagline ?? "Bubblegum girlie ✨")
                        .font(DH.font(.subhead))
                        .foregroundStyle(.white.opacity(0.85))

                    // Stats row — local metrics only
                    HStack(spacing: 8) {
                        ProfileStatCard(value: "\(vm.captureCount)", label: "LOOKS SAVED")
                        ProfileStatCard(value: "\(vm.looksTried)", label: "LOOKS TRIED")
                        ProfileStatCard(value: "\(vm.streak)🔥", label: "DAY STREAK")
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 24)

                    // Glow level
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            (Text("Glow level ") + Text("\(vm.glowLevel)").foregroundColor(DH.pinkDeep))
                                .font(DH.font(.cardTitle))
                                .foregroundStyle(DH.ink)
                            Spacer()
                            Text("\(vm.captureCount % GlowLevel.capturesPerLevel) / \(GlowLevel.capturesPerLevel) to lvl \(vm.glowLevel + 1)")
                                .font(DH.font(.caption))
                                .foregroundStyle(DH.ink.opacity(0.55))
                        }
                        GlowProgressBar(percent: vm.glowPercent)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)

                    // Recent looks
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Recent looks").font(DH.font(.cardTitle)).foregroundStyle(DH.ink)
                            Spacer()
                            Button { coordinator.setTab(.locker) } label: {
                                Text("See all →").font(DH.font(.caption)).foregroundStyle(DH.pinkDeep)
                            }
                        }
                        if vm.recent.isEmpty {
                            DHCard(color: .white, deep: DH.pinkLight) {
                                Text("No looks yet — go to Mirror!")
                                    .font(DH.font(.body))
                                    .foregroundStyle(DH.ink.opacity(0.7))
                                    .padding(18)
                                    .frame(maxWidth: .infinity)
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(vm.recent) { c in
                                        RecentLookTile(capture: c)
                                            .onTapGesture { coordinator.showLockerDetail(c) }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)

                    Spacer(minLength: 130)
                }
            }
        }
    }
}

private struct AvatarBubble: View {
    let swatch: AvatarSwatch
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle().fill(swatch.color)
                .frame(width: 120, height: 120)
                .overlay(Circle().stroke(.white, lineWidth: 5))
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 6)
                .shadow(color: DH.pinkDeep.opacity(0.4), radius: 24, x: 0, y: 12)
                .overlay {
                    // Stylized face glyph in the swatch tint
                    Image(systemName: "face.smiling.inverse")
                        .resizable().scaledToFit().frame(width: 60, height: 60)
                        .foregroundStyle(swatch.accent)
                }
            Circle().fill(DH.mint)
                .frame(width: 18, height: 18)
                .overlay(Circle().stroke(.white, lineWidth: 3))
                .padding(8)
        }
    }
}

private struct ProfileStatCard: View {
    let value: String
    let label: String
    var body: some View {
        DHCard(color: .white, deep: DH.pinkLight) {
            VStack(spacing: 2) {
                Text(value).font(DH.font(.headline)).foregroundStyle(DH.pinkDeep)
                Text(label).font(DH.font(.tinyCaps)).foregroundStyle(DH.ink.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

private struct GlowProgressBar: View {
    let percent: Double
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 7).fill(.white)
                    .shadow(color: DH.pinkDeep.opacity(0.15), radius: 0, x: 0, y: 2)
                RoundedRectangle(cornerRadius: 7)
                    .fill(LinearGradient(colors: [DH.pinkLight, DH.pink], startPoint: .top, endPoint: .bottom))
                    .frame(width: max(8, g.size.width * percent))
                StickerSparkle(size: 14, fill: .white)
                    .position(x: max(7, g.size.width * percent - 7), y: 7)
            }
        }
        .frame(height: 14)
    }
}

private struct RecentLookTile: View {
    let capture: SavedCapture
    var body: some View {
        DHCard(color: DH.pinkLight, deep: DH.pinkDeep) {
            ZStack {
                if let img = capture.thumbnail() {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Image(systemName: "sparkles").font(.system(size: 32)).foregroundStyle(DH.pinkDeep)
                }
            }
            .frame(width: 104, height: 124)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

UPDATE GRWMStudio/Coordinator/AppCoordinator.swift to add showAvatarEditor() and showSettings() routes (sheet presentations).

UPDATE GRWMStudio/Profile/ProfileRecord.swift (in SwiftData schema): add fields `displayName: String`, `tagline: String`, `avatarSwatchRaw: String`, `distinctLooksTried: Int`, `streakDays: Int`, `lastActiveDay: Date?`. Provide `makeDefault()`. Add `AvatarSwatch` enum with cases pink/lav/butter/mint/peach + computed `color` and `accent`.

UPDATE the streak logic in CapturePersistence: when a capture is saved, call `ProfileRecord.recordActivity(today:)` which updates streakDays based on lastActiveDay (consecutive day +1, gap > 1 day reset to 1).

VERIFY:
1. Open Profile tab → all elements render at correct positions
2. With 0 captures: shows level 1, 0/5 progress, empty recent looks card
3. Save 6 captures → level becomes 2, progress 1/5
4. Save captures across two days → streak shows 2
5. Tap avatar or EDIT AVATAR → coordinator.showAvatarEditor() called
6. Tap gear → coordinator.showSettings() called
7. No follower count, no @handle, no share button visible
8. VoiceOver labels all stat cards and CTA correctly
````

---

## GRWM-601 — Avatar & display-name editor sheet

**Goal:** Sheet presented from Profile letting the kid pick an avatar swatch (5 colors) and edit display name (max 16 chars, alphanumerics + emoji, no profanity filter needed since input is local) and tagline (max 32 chars). Persists to `ProfileRecord` via SwiftData. Keyboard handled with iOS-native `.keyboardType(.default)`.

**Prereqs:** GRWM-600

**Files:**
- `GRWMStudio/Profile/AvatarEditorView.swift` (new)
- `GRWMStudio/Profile/AvatarEditorViewModel.swift` (new)
- `GRWMStudio/Coordinator/AppCoordinator.swift` (update — sheet presentation)

**Acceptance criteria:**
- [ ] Sheet presents medium-then-large detents
- [ ] Top nav: "Cancel" left, "Edit Avatar" centered, "Save" right (DH.pinkDeep, fontWeight 800)
- [ ] Avatar preview at top using current selected swatch
- [ ] 5 swatch chips in a row: pink/lav/butter/mint/peach — tap selects, selected gets 4pt deep-pink ring + spring animation
- [ ] Display name `TextField`, 16-char limit enforced live
- [ ] Tagline `TextField`, 32-char limit
- [ ] Save button validates: name not empty, name not all whitespace; on validation fail, shake the field with haptic
- [ ] On save: persist to SwiftData, dismiss sheet, post `Notification.Name.profileChanged` so DHProfileView reloads
- [ ] On cancel: discard changes
- [ ] Sounds: bubble pop on swatch select; sparkle on save

**Prompt:**
````
CONTEXT: Sheet for editing the local profile (avatar swatch + display name + tagline). All data is local; no network.

CREATE GRWMStudio/Profile/AvatarEditorViewModel.swift:

import Foundation
import SwiftData
import Observation

@Observable @MainActor
final class AvatarEditorViewModel {
    var swatch: AvatarSwatch
    var displayName: String
    var tagline: String
    private(set) var validationShake: Int = 0

    private let context: ModelContext
    private let record: ProfileRecord

    init(context: ModelContext, record: ProfileRecord) {
        self.context = context
        self.record = record
        self.swatch = record.avatarSwatch
        self.displayName = record.displayName
        self.tagline = record.tagline
    }

    func setName(_ s: String) {
        displayName = String(s.prefix(16))
    }
    func setTagline(_ s: String) {
        tagline = String(s.prefix(32))
    }

    func save() -> Bool {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            validationShake &+= 1
            DHHaptics.warning()
            return false
        }
        record.displayName = trimmed
        record.tagline = tagline.trimmingCharacters(in: .whitespacesAndNewlines)
        record.avatarSwatch = swatch
        try? context.save()
        DHHaptics.success()
        DHSounds.play(.sparkle)
        NotificationCenter.default.post(name: .profileChanged, object: nil)
        return true
    }
}

extension Notification.Name {
    static let profileChanged = Notification.Name("dh.profileChanged")
}

CREATE GRWMStudio/Profile/AvatarEditorView.swift:

import SwiftUI
import SwiftData

struct AvatarEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var vm: AvatarEditorViewModel?

    var body: some View {
        Group {
            if let vm { content(vm: vm) }
            else {
                Color.clear.onAppear {
                    let pdesc = FetchDescriptor<ProfileRecord>()
                    if let rec = try? context.fetch(pdesc).first {
                        self.vm = AvatarEditorViewModel(context: context, record: rec)
                    }
                }
            }
        }
        .background(DH.pinkPaper.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func content(vm: AvatarEditorViewModel) -> some View {
        VStack(spacing: 0) {
            // Nav
            HStack {
                Button("Cancel") { dismiss() }
                    .font(DH.font(.body)).foregroundStyle(DH.ink.opacity(0.6))
                Spacer()
                Text("Edit Avatar").font(DH.font(.cardTitle)).foregroundStyle(DH.pinkDeep)
                Spacer()
                Button("Save") {
                    if vm.save() { dismiss() }
                }
                .font(DH.font(.body).bold()).foregroundStyle(DH.pinkDeep)
            }
            .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 12)

            // Preview
            Circle().fill(vm.swatch.color)
                .frame(width: 110, height: 110)
                .overlay(Circle().stroke(.white, lineWidth: 5))
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 5)
                .overlay {
                    Image(systemName: "face.smiling.inverse").resizable().scaledToFit()
                        .frame(width: 56, height: 56).foregroundStyle(vm.swatch.accent)
                }
                .padding(.bottom, 16)

            // Swatches
            HStack(spacing: 12) {
                ForEach(AvatarSwatch.allCases, id: \.self) { s in
                    Button {
                        DHSounds.play(.bubble); DHHaptics.light()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { vm.swatch = s }
                    } label: {
                        Circle().fill(s.color)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().stroke(vm.swatch == s ? DH.pinkDeep : .white, lineWidth: 4))
                            .scaleEffect(vm.swatch == s ? 1.12 : 1.0)
                    }
                    .accessibilityLabel("\(s.rawValue) avatar")
                }
            }
            .padding(.bottom, 18)

            // Form
            VStack(alignment: .leading, spacing: 14) {
                FieldLabel("DISPLAY NAME")
                FormField(text: Binding(get: { vm.displayName }, set: vm.setName), placeholder: "GRWM Star", limit: 16)
                    .modifier(ShakeModifier(animatableData: CGFloat(vm.validationShake)))
                FieldLabel("TAGLINE")
                FormField(text: Binding(get: { vm.tagline }, set: vm.setTagline), placeholder: "Bubblegum girlie ✨", limit: 32)
            }
            .padding(.horizontal, 18)

            Spacer()
        }
    }
}

private struct FieldLabel: View {
    let text: String
    init(_ s: String) { self.text = s }
    var body: some View {
        Text(text).font(DH.font(.tinyCaps)).foregroundStyle(DH.pinkDeep).tracking(1.6)
    }
}

private struct FormField: View {
    @Binding var text: String
    let placeholder: String
    let limit: Int
    var body: some View {
        TextField(placeholder, text: $text)
            .font(DH.font(.body)).foregroundStyle(DH.ink)
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(DH.pink, lineWidth: 2.5))
            .shadow(color: DH.pink, radius: 0, x: 0, y: 3)
    }
}

struct ShakeModifier: AnimatableModifier {
    var animatableData: CGFloat
    func body(content: Content) -> some View {
        content.offset(x: sin(animatableData * .pi * 4) * 6)
    }
}

UPDATE AppCoordinator: add `showAvatarEditor()` that toggles a `@Published var presentingAvatarEditor: Bool`. RootView observes and presents `.sheet(isPresented:)` { AvatarEditorView() }.

UPDATE DHProfileView to listen for `.profileChanged` and call `vm.reload()`.

VERIFY:
1. Tap avatar → sheet rises; medium detent
2. Pick a swatch → spring scale + bubble pop sound; ring moves
3. Type beyond limits → text truncates at limit
4. Empty name → tap save → field shakes, warning haptic, sheet stays open
5. Valid save → success haptic, sparkle sound, sheet dismisses, profile updates
6. Cancel → no changes persisted
````

---

## GRWM-602 — Feed tab shell (DHFeed, curated/local)

**Goal:** Build the Feed tab matching layout of `docs/design-source/v3/screens-5.jsx` `DHFeed` BUT with curated bundled content (read-only inspiration looks) instead of UGC. Replace "Stories" rail with "Featured Looks" curated entries. Replace "your squad" with "Inspiration". Mosaic shows curated cards from a bundled JSON. NO comments/follows/likes-that-persist-publicly. Local "Heart" is repurposed as the same Favorites toggle from GRWM-509 (favoriting Looks library entries).

**Prereqs:** GRWM-300, GRWM-509 (Looks library)

**Files:**
- `GRWMStudio/Feed/DHFeedView.swift` (new)
- `GRWMStudio/Feed/FeedViewModel.swift` (new)
- `GRWMStudio/Feed/FeedItem.swift` (new)
- `GRWMStudio/Resources/feed-curated.json` (new bundled)

**Acceptance criteria:**
- [ ] `feed-curated.json` ships in app bundle with 8 hand-curated entries pointing to Looks library look IDs (the 8 looks defined in GRWM-509)
- [ ] No networking
- [ ] Header: "INSPIRATION" caps subtitle, "The Feed ♡" hero in DH.pinkDeep
- [ ] Notification bell removed (no notifications system)
- [ ] Featured rail shows 5 entries, each a circle (64pt) with conic gradient ring, tappable → opens Look Detail
- [ ] Mosaic: 2-column layout, alternating heights, content is curated `FeedItem` cards
- [ ] Each card: face glyph in tinted background, look name, hashtags, heart button + count (count is static curated value, NOT user-incremented)
- [ ] Tap card → coordinator opens LookDetail for the linked look
- [ ] Heart toggle uses LookLibraryViewModel favorites (already exists)
- [ ] No comment input, no @handle taps, no follow buttons
- [ ] Tab bar visible, "feed" tab active
- [ ] If JSON malformed (defensive), fall back to empty state with cute copy

**Prompt:**
````
CONTEXT: The Feed tab is INSPIRATION ONLY. Bundled JSON, no network, no UGC. The visual scaffolding follows screens-5.jsx DHFeed but every social-implying element is removed or repurposed.

CREATE GRWMStudio/Feed/FeedItem.swift:

import Foundation
import SwiftUI

struct FeedItem: Codable, Identifiable, Hashable {
    let id: String              // matches LookID from looks library
    let lookID: String
    let displayTitle: String    // e.g. "Cherry Crush ♡"
    let tagline: String         // e.g. "cherry crush vibes"
    let cardHeight: CardHeight  // small/medium/large
    let palette: Palette
    let hot: Bool
    let hearts: Int             // static curated number
    let featured: Bool

    enum CardHeight: String, Codable { case s, m, l
        var pt: CGFloat { switch self { case .s: 200; case .m: 220; case .l: 260 } }
    }
    struct Palette: Codable, Hashable {
        let cardHex: String
        let deepHex: String
        var card: Color { Color(hex: cardHex) ?? DH.pinkLight }
        var deep: Color { Color(hex: deepHex) ?? DH.pinkDeep }
    }
}

CREATE GRWMStudio/Resources/feed-curated.json (add to bundle, 8 entries — IDs MUST match LookCatalog):

[
  { "id":"sunday-best",     "lookID":"sunday-best",     "displayTitle":"Sunday Best ☁️", "tagline":"natural day vibes", "cardHeight":"m", "palette":{"cardHex":"#FFE4D8","deepHex":"#C98090"}, "hot":false, "hearts":67,  "featured":true },
  { "id":"school-day",      "lookID":"school-day",      "displayTitle":"School Day 📚", "tagline":"classroom-chic", "cardHeight":"s", "palette":{"cardHex":"#C8EAFF","deepHex":"#3D7FBF"}, "hot":false, "hearts":42,  "featured":true },
  { "id":"birthday-glam",   "lookID":"birthday-glam",   "displayTitle":"Birthday Glam 🎂", "tagline":"cake-day sparkle", "cardHeight":"l", "palette":{"cardHex":"#FFE5F2","deepHex":"#D4127B"}, "hot":true,  "hearts":124, "featured":true },
  { "id":"sleepover",       "lookID":"sleepover",       "displayTitle":"Sleepover 🌙", "tagline":"pjs + popcorn", "cardHeight":"m", "palette":{"cardHex":"#E8C8FF","deepHex":"#5A1099"}, "hot":false, "hearts":88,  "featured":true },
  { "id":"pop-star",        "lookID":"pop-star",        "displayTitle":"Pop Star ⭐", "tagline":"stage lights on", "cardHeight":"l", "palette":{"cardHex":"#FFB46B","deepHex":"#C99B1F"}, "hot":true,  "hearts":312, "featured":true },
  { "id":"disco-princess",  "lookID":"disco-princess",  "displayTitle":"Disco Princess 🪩", "tagline":"glittery overload", "cardHeight":"s", "palette":{"cardHex":"#FFD66B","deepHex":"#9C2BFF"}, "hot":false, "hearts":201, "featured":false },
  { "id":"garden-party",    "lookID":"garden-party",    "displayTitle":"Garden Party 🌸", "tagline":"flowy florals", "cardHeight":"m", "palette":{"cardHex":"#C9E8C9","deepHex":"#5DBD8E"}, "hot":false, "hearts":156, "featured":false },
  { "id":"time-warp",       "lookID":"time-warp",       "displayTitle":"Time Warp ⏳", "tagline":"y2k babe", "cardHeight":"l", "palette":{"cardHex":"#C9A8FF","deepHex":"#5A1099"}, "hot":true,  "hearts":278, "featured":false }
]

CREATE GRWMStudio/Feed/FeedViewModel.swift:

import Foundation
import Observation

@Observable @MainActor
final class FeedViewModel {
    private(set) var items: [FeedItem] = []
    private(set) var featured: [FeedItem] = []

    func load() {
        guard let url = Bundle.main.url(forResource: "feed-curated", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([FeedItem].self, from: data) else {
            self.items = []; self.featured = []
            DHLog.warn("Feed JSON missing or malformed; falling back to empty state")
            return
        }
        self.items = decoded
        self.featured = decoded.filter(\.featured)
    }
}

CREATE GRWMStudio/Feed/DHFeedView.swift:

import SwiftUI

struct DHFeedView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LookLibraryViewModel.self) private var library
    @State private var vm = FeedViewModel()

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                LinearGradient(colors: [DH.pinkPaper, DH.cream], startPoint: .top, endPoint: .bottom)
                    .frame(height: 260).ignoresSafeArea(edges: .top)

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 2) {
                        Text("INSPIRATION").font(DH.font(.tinyCaps)).foregroundStyle(DH.ink.opacity(0.5)).tracking(2.5)
                        Text("The Feed ♡").font(DH.font(.titleLarge)).foregroundStyle(DH.pinkDeep)
                    }
                    .padding(.horizontal, 18).padding(.top, 8)

                    // Featured rail
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(vm.featured) { item in
                                FeaturedRing(item: item)
                                    .onTapGesture { openLook(item) }
                            }
                        }
                        .padding(.horizontal, 18).padding(.top, 14)
                    }

                    // Mosaic
                    if vm.items.isEmpty {
                        EmptyFeedCard()
                            .padding(.horizontal, 18).padding(.top, 24)
                    } else {
                        FeedMosaic(items: vm.items, onTap: openLook, onHeart: toggleFavorite, isFavorited: { id in library.favorites.contains(id) })
                            .padding(.horizontal, 18).padding(.top, 14)
                            .padding(.bottom, 130)
                    }
                }
            }
        }
        .background(DH.cream)
        .onAppear { vm.load() }
    }

    private func openLook(_ item: FeedItem) {
        if let look = library.look(id: item.lookID) {
            coordinator.showLookDetail(look)
        }
    }
    private func toggleFavorite(_ item: FeedItem) {
        library.toggleFavorite(lookID: item.lookID)
        DHHaptics.light()
    }
}

private struct FeaturedRing: View {
    let item: FeedItem
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                AngularGradient(colors: [DH.pink, DH.lav, DH.butter, DH.pink], center: .center)
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                Circle().fill(item.palette.card)
                    .frame(width: 56, height: 56)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .overlay { Image(systemName: "sparkles").foregroundStyle(item.palette.deep) }
            }
            Text(item.displayTitle.components(separatedBy: " ").first ?? "")
                .font(DH.font(.tinyCaps)).foregroundStyle(DH.ink)
        }
        .frame(width: 70)
    }
}

private struct EmptyFeedCard: View {
    var body: some View {
        DHCard(color: .white, deep: DH.pinkLight) {
            VStack(spacing: 8) {
                Text("✨").font(.system(size: 40))
                Text("No inspiration loaded yet").font(DH.font(.cardTitle)).foregroundStyle(DH.pinkDeep)
                Text("Pull down to refresh!").font(DH.font(.caption)).foregroundStyle(DH.ink.opacity(0.6))
            }.padding(20).frame(maxWidth: .infinity)
        }
    }
}

CREATE FeedMosaic in same file: 2-column VStacks, right column padded 24pt top, both columns iterate alternate items by index parity. Each card uses DHCard with item.palette, height = item.cardHeight.pt, overlays heart pill bottom-right with tap action.

VERIFY:
1. Open Feed tab → 8 cards render in 2 columns with masonry offset
2. Featured rail scrolls horizontally with 5 conic-gradient ringed entries
3. Tap card → opens LookDetailView for that look
4. Tap heart → favorite toggles in LookLibraryViewModel; persists across launches
5. No comment/follow UI present
6. Damage feed-curated.json (corrupted JSON in test) → empty state shows; no crash
7. VoiceOver: each card announces "[Look name], [hearts] hearts"
````

---

## GRWM-603 — Feed mosaic component + heart pill

**Goal:** Reusable `FeedMosaic` view + `FeedHeartPill` button. The mosaic enforces the masonry pattern from the JSX (left column starts at top, right column padded 24pt top). The heart pill toggles favorite state, animates with spring, and shows the curated heart count adjusted by +1 if the user has favorited the look (purely visual, count is not persisted publicly).

**Prereqs:** GRWM-602

**Files:**
- `GRWMStudio/Feed/FeedMosaic.swift` (new)
- `GRWMStudio/Feed/FeedHeartPill.swift` (new)
- `GRWMStudio/Feed/FeedCardView.swift` (new)

**Acceptance criteria:**
- [ ] Two columns laid out via `HStack` of two `LazyVStack`s
- [ ] Right column has `.padding(.top, 24)` for masonry effect
- [ ] Each card height matches `FeedItem.cardHeight.pt`
- [ ] Hot badge appears top-left if `item.hot == true`, butter background, "🔥 HOT" 9pt 800-weight letterspaced
- [ ] Bottom gradient overlay from transparent → `palette.deep` 87% opacity
- [ ] Footer text: tagline (12pt 700 white), heart count line (14pt heart icon + count)
- [ ] Heart pill bottom-right area: 28pt round, white background when not favorited, DH.pink when favorited, scale spring on tap
- [ ] Tap heart triggers `onHeart`; tap rest of card triggers `onTap`
- [ ] Card uses DHCard with item.palette colors; rounded 20pt
- [ ] Face glyph at bottom-center using SF Symbol `face.smiling.inverse` scaled 0.7, tinted with palette deep

**Prompt:**
````
CONTEXT: Implement the Feed mosaic + card components.

CREATE GRWMStudio/Feed/FeedMosaic.swift:

import SwiftUI

struct FeedMosaic: View {
    let items: [FeedItem]
    let onTap: (FeedItem) -> Void
    let onHeart: (FeedItem) -> Void
    let isFavorited: (String) -> Bool

    var body: some View {
        let split = items.enumerated().reduce(into: ([FeedItem](), [FeedItem]())) { acc, pair in
            if pair.offset % 2 == 0 { acc.0.append(pair.element) } else { acc.1.append(pair.element) }
        }
        return HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 10) {
                ForEach(split.0) { item in card(item) }
            }
            VStack(spacing: 10) {
                ForEach(split.1) { item in card(item) }
            }
            .padding(.top, 24)
        }
    }

    @ViewBuilder
    private func card(_ item: FeedItem) -> some View {
        FeedCardView(item: item, favorited: isFavorited(item.id), onHeart: { onHeart(item) })
            .onTapGesture { onTap(item) }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(item.displayTitle), \(item.hearts) hearts")
            .accessibilityHint("Double tap to view this look")
    }
}

CREATE GRWMStudio/Feed/FeedCardView.swift:

import SwiftUI

struct FeedCardView: View {
    let item: FeedItem
    let favorited: Bool
    let onHeart: () -> Void

    var body: some View {
        DHCard(color: item.palette.card, deep: item.palette.deep, radius: 20, padding: 0) {
            ZStack(alignment: .bottom) {
                // Face glyph
                Image(systemName: "face.smiling.inverse")
                    .resizable().scaledToFit()
                    .frame(height: item.cardHeight.pt * 0.55)
                    .foregroundStyle(item.palette.deep.opacity(0.85))
                    .offset(y: 18)

                // Bottom gradient
                LinearGradient(
                    colors: [.clear, item.palette.deep.opacity(0.87)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: item.cardHeight.pt * 0.45)

                // Footer overlay
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.displayTitle)
                        .font(DH.font(.cardTitle))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(item.tagline)
                        .font(DH.font(.caption).bold())
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Image(systemName: favorited ? "heart.fill" : "heart")
                            .font(.system(size: 12, weight: .heavy))
                        Text("\(item.hearts + (favorited ? 1 : 0))")
                            .font(DH.font(.caption).bold())
                    }
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 10).padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Heart pill (top right? bottom right? per JSX, bottom right within footer).
                FeedHeartPill(favorited: favorited, action: onHeart)
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

                // Hot badge top-left
                if item.hot {
                    Text("🔥 HOT")
                        .font(.system(size: 9, weight: .heavy)).tracking(1.0)
                        .foregroundStyle(DH.ink)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(DH.butter, in: Capsule())
                        .shadow(color: DH.butterDeep, radius: 0, x: 0, y: 2)
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .frame(height: item.cardHeight.pt)
            .clipped()
        }
    }
}

CREATE GRWMStudio/Feed/FeedHeartPill.swift:

import SwiftUI

struct FeedHeartPill: View {
    let favorited: Bool
    let action: () -> Void
    @State private var bouncing = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { bouncing = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { bouncing = false }
            action()
        } label: {
            Image(systemName: favorited ? "heart.fill" : "heart")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(favorited ? .white : DH.pinkDeep)
                .frame(width: 28, height: 28)
                .background(favorited ? DH.pink : .white, in: Circle())
                .shadow(color: DH.pinkDeep.opacity(0.3), radius: 0, x: 0, y: 2)
                .scaleEffect(bouncing ? 1.25 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(favorited ? "Unfavorite" : "Favorite")
    }
}

VERIFY:
1. Cards alternate left/right with 24pt right-column offset
2. Hot badge appears only on `hot:true` items (3 of 8)
3. Tap heart bubble → spring scale animation
4. Heart count visually shows +1 when favorited; reverts when unfavorited
5. Tap card body (not heart) → triggers onTap, opens look detail
6. Layout adapts cleanly across iPhone SE → 16 Pro Max widths
````

---

## GRWM-604 — Feed → Look Detail navigation hookup

**Goal:** Wire feed taps to the existing `LookDetailView` (GRWM-510). Ensure the "Try this look" CTA returns to Mirror tab and applies the look. Add a back-navigation breadcrumb so dismissing returns to the Feed (not Mirror, not Looks).

**Prereqs:** GRWM-510, GRWM-602

**Files:**
- `GRWMStudio/Coordinator/AppCoordinator.swift` (update — context-aware return path)
- `GRWMStudio/Library/LookDetailView.swift` (update — accept origin)

**Acceptance criteria:**
- [ ] `AppCoordinator.showLookDetail(_:from:)` records the origin tab (`.feed`, `.locker`, `.looks`)
- [ ] Dismiss returns to the same tab
- [ ] "Try this look" → switches to Mirror tab, applies look, dismisses sheet
- [ ] Back button on LookDetail dismisses sheet (no tab switch)

**Prompt:**
````
CONTEXT: Make Feed → LookDetail navigation explicit so dismiss returns to the originating tab.

UPDATE GRWMStudio/Coordinator/AppCoordinator.swift:

@Observable @MainActor
final class AppCoordinator {
    var presentedLook: Look? = nil
    var presentedLookOrigin: AppTab? = nil
    // ... existing fields

    func showLookDetail(_ look: Look, from origin: AppTab) {
        self.presentedLookOrigin = origin
        self.presentedLook = look
    }

    func dismissLookDetail() {
        self.presentedLook = nil
        self.presentedLookOrigin = nil
    }

    func tryLookOnMirror(_ look: Look) {
        setTab(.mirror)
        // The mirror VM observes this signal:
        NotificationCenter.default.post(name: .applyLookFromDetail, object: look)
        dismissLookDetail()
    }
}
extension Notification.Name { static let applyLookFromDetail = Notification.Name("dh.applyLookFromDetail") }

UPDATE callsites:
- DHFeedView: `coordinator.showLookDetail(look, from: .feed)`
- DHLooksView (GRWM-509): `coordinator.showLookDetail(look, from: .looks)`
- LockerDetailView (GRWM-507) — if it cross-navigates to a Look — `from: .locker`

UPDATE MirrorViewModel: subscribe to `.applyLookFromDetail`:

init() {
    // ...
    NotificationCenter.default.addObserver(forName: .applyLookFromDetail, object: nil, queue: .main) { [weak self] note in
        guard let look = note.object as? Look else { return }
        Task { @MainActor in self?.selectLook(look) }
    }
}

VERIFY:
1. From Feed → tap card → LookDetail sheet opens
2. Press back → returns to Feed tab (not Mirror)
3. Press "Try this look" → tab switches to Mirror, look applied, sheet dismissed
4. From Looks → tap card → LookDetail; press back → returns to Looks tab
5. From Locker (if applicable) → same behavior with `.locker` origin
````

---

## GRWM-605 — Profile settings entry hookup

**Goal:** Hook the gear icon in DHProfileView to open the Settings screen (built in Phase 8). For now, route to a placeholder `DHSettingsView` which we'll fill in GRWM-750. Ensure the route exists end-to-end.

**Prereqs:** GRWM-600

**Files:**
- `GRWMStudio/Settings/DHSettingsView.swift` (new — placeholder body)
- `GRWMStudio/Coordinator/AppCoordinator.swift` (update — settings route)

**Acceptance criteria:**
- [ ] `AppCoordinator.showSettings()` toggles `presentingSettings: Bool`
- [ ] RootView observes and presents fullScreenCover with `DHSettingsView()`
- [ ] Placeholder shows nav header "Settings", a back chevron that dismisses, and a "Coming soon" body card
- [ ] Tapping gear from Profile opens it

**Prompt:**
````
CONTEXT: Stub the Settings route now so Profile compiles and routes work. Real content lands in GRWM-750.

CREATE GRWMStudio/Settings/DHSettingsView.swift:

import SwiftUI

struct DHSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [DH.pinkPaper, DH.cream], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    CircleButton(systemName: "chevron.left", action: { dismiss() })
                    Spacer()
                    Text("Settings").font(DH.font(.titleSmall)).foregroundStyle(DH.pinkDeep)
                    Spacer()
                    Color.clear.frame(width: 42, height: 42)
                }
                .padding(.horizontal, 18).padding(.top, 12)

                DHCard(color: .white, deep: DH.pinkLight) {
                    VStack(spacing: 10) {
                        Text("✨").font(.system(size: 40))
                        Text("Coming soon").font(DH.font(.cardTitle)).foregroundStyle(DH.pinkDeep)
                    }.padding(20).frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 18).padding(.top, 18)

                Spacer()
            }
        }
    }
}

UPDATE AppCoordinator with `var presentingSettings: Bool = false` and `func showSettings() { presentingSettings = true }`.

UPDATE RootView to attach `.fullScreenCover(isPresented: $coordinator.presentingSettings) { DHSettingsView() }`.

VERIFY:
1. Tap gear on Profile → Settings cover slides up
2. Chevron-back dismisses
3. No regressions in tab switching
````


---

# Phase 7 — Commerce (Parent Gate + Paywall + StoreKit 2)

> **Critical pricing decision:** The DHPaywall design explicitly states "One payment. Forever access. No subscriptions, no ads, no surprises." We are shipping GRWM Studio Pro as a **non-consumable in-app purchase**, NOT a subscription. The product ID is `app.grwmstudio.ios.pro.lifetime`. Launch price: $14.99 USD. There is **no auto-renewal**, no trial, no grace period. Restore purchases is supported.

> **Parent gate strategy:** Apple's App Store Review Guideline 1.3 (Kids Category) requires that all in-app purchases are gated behind a parental gate that "is not easily passed by children." We provide TWO gate variants and randomly select one per session:
> 1. **Math gate** (`DHParentMathIdle` + `DHParentMathWrong`): "9 + 6 = ?" with numpad. 3 attempts.
> 2. **Hold gate** (`DHParentHold`): Press-and-hold heart for 3 seconds with two-finger touch (multi-touch requirement also satisfies Apple's "not easily passed" bar).
>
> Both gates time out after 30s of inactivity and reset.

---

## GRWM-700 — Parent gate coordinator + intent routing

**Goal:** Build a `ParentGate` coordinator that owns gate-flow state, randomly picks gate variant on entry, handles success/fail/cancel, and routes to the original intent (paywall, settings reveal, etc.). The gate is presented as a full-screen cover and is the ONLY way to reach the paywall or "manage subscription" links.

**Prereqs:** GRWM-008 (AppCoordinator scaffolding), GRWM-009 (DH primitives)

**Files:**
- `GRWMStudio/ParentGate/ParentGateCoordinator.swift` (new)
- `GRWMStudio/ParentGate/ParentGateIntent.swift` (new)
- `GRWMStudio/ParentGate/ParentGateRootView.swift` (new)
- `GRWMStudio/Coordinator/AppCoordinator.swift` (update)

**Acceptance criteria:**
- [ ] `ParentGateIntent` enum: `.paywall`, `.manageSubscription`, `.privacyDeepLink(URL)`, `.deleteAllData`
- [ ] On entry, `ParentGateCoordinator` randomly picks `.math` or `.hold` variant (50/50, seed `SystemRandomNumberGenerator`)
- [ ] Gate state machine: `.choosing` → `.math(challenge)` or `.hold` → `.passed` → execute intent OR `.failed(reason)` → reset
- [ ] Math: regenerates challenge on each retry. Up to 3 wrong answers before locking for 30 seconds with copy "Take a break, friend! Try again in 30s 💕"
- [ ] Hold: must hold for 3.0 seconds continuously WITH two-finger touch (multi-touch). If finger lifts before 3s OR fewer than 2 fingers, progress resets.
- [ ] Cancel via X button → routes back without executing intent
- [ ] Successful completion → executes intent and dismisses
- [ ] No state persisted across cold launches (parental presence is verified per session per intent)

**Prompt:**
````
CONTEXT: Coordinator + state machine for the parent gate flow. Owns RNG, attempts counter, lockout timer.

CREATE GRWMStudio/ParentGate/ParentGateIntent.swift:

import Foundation

enum ParentGateIntent: Equatable {
    case paywall
    case manageSubscription
    case privacyDeepLink(URL)
    case deleteAllData
}

CREATE GRWMStudio/ParentGate/ParentGateCoordinator.swift:

import Foundation
import Observation

enum ParentGateVariant { case math, hold }
enum ParentGatePhase: Equatable {
    case math(challenge: MathChallenge, attempts: Int, lockedUntil: Date?)
    case hold(progress: Double)
    case passed
    case failedLocked(remaining: TimeInterval)
}

struct MathChallenge: Equatable {
    let lhs: Int
    let rhs: Int
    let answer: Int
    static func random() -> MathChallenge {
        let l = Int.random(in: 5...12)
        let r = Int.random(in: 4...9)
        return MathChallenge(lhs: l, rhs: r, answer: l + r)
    }
}

@Observable @MainActor
final class ParentGateCoordinator {
    let intent: ParentGateIntent
    let variant: ParentGateVariant
    var phase: ParentGatePhase
    var idleTimerExpired: Bool = false

    private(set) var entry: String = ""
    private var idleTimer: Task<Void, Never>?
    private var lockoutTimer: Task<Void, Never>?
    private(set) var attempts: Int = 0

    private let onPass: (ParentGateIntent) -> Void
    private let onCancel: () -> Void

    init(intent: ParentGateIntent, onPass: @escaping (ParentGateIntent) -> Void, onCancel: @escaping () -> Void) {
        self.intent = intent
        self.onPass = onPass
        self.onCancel = onCancel
        let variant: ParentGateVariant = Bool.random() ? .math : .hold
        self.variant = variant
        switch variant {
        case .math: self.phase = .math(challenge: .random(), attempts: 0, lockedUntil: nil)
        case .hold: self.phase = .hold(progress: 0)
        }
        startIdleWatch()
    }

    deinit { idleTimer?.cancel(); lockoutTimer?.cancel() }

    func cancel() { idleTimer?.cancel(); onCancel() }

    func touchActivity() { resetIdleWatch() }

    // MARK: - Math gate
    func appendDigit(_ d: Int) {
        guard case .math(let c, let a, _) = phase else { return }
        if entry.count < 3 { entry.append("\(d)") }
        touchActivity()
        _ = (c, a)
    }
    func backspace() { if !entry.isEmpty { entry.removeLast() }; touchActivity() }
    func submitMath() {
        guard case .math(let challenge, var a, _) = phase else { return }
        guard let val = Int(entry) else { return }
        if val == challenge.answer {
            phase = .passed
            onPass(intent)
        } else {
            a += 1
            entry = ""
            DHHaptics.warning()
            if a >= 3 {
                let until = Date().addingTimeInterval(30)
                phase = .math(challenge: .random(), attempts: 0, lockedUntil: until)
                startLockoutCountdown(until: until)
            } else {
                phase = .math(challenge: .random(), attempts: a, lockedUntil: nil)
            }
        }
    }

    // MARK: - Hold gate
    func updateHold(progress: Double, twoFingers: Bool) {
        guard case .hold = phase else { return }
        if !twoFingers {
            phase = .hold(progress: 0)
            return
        }
        let clamped = min(1.0, max(0, progress))
        phase = .hold(progress: clamped)
        if clamped >= 1.0 {
            phase = .passed
            DHHaptics.success()
            onPass(intent)
        } else {
            touchActivity()
        }
    }
    func resetHold() { phase = .hold(progress: 0) }

    // MARK: - Idle watch (30s)
    private func startIdleWatch() {
        idleTimer?.cancel()
        idleTimer = Task { [weak self] in
            try? await Task.sleep(for: .seconds(30))
            guard let self else { return }
            self.idleTimerExpired = true
            self.cancel()
        }
    }
    private func resetIdleWatch() { startIdleWatch() }

    private func startLockoutCountdown(until: Date) {
        lockoutTimer?.cancel()
        lockoutTimer = Task { [weak self] in
            while let self, Date() < until {
                let remaining = until.timeIntervalSinceNow
                if case .math(let c, _, _) = self.phase {
                    self.phase = .math(challenge: c, attempts: 0, lockedUntil: until)
                }
                try? await Task.sleep(for: .seconds(1))
            }
            guard let self else { return }
            self.phase = .math(challenge: .random(), attempts: 0, lockedUntil: nil)
        }
    }
}

CREATE GRWMStudio/ParentGate/ParentGateRootView.swift:

import SwiftUI

struct ParentGateRootView: View {
    @State var coordinator: ParentGateCoordinator
    var body: some View {
        Group {
            switch coordinator.variant {
            case .math: DHParentMathView(coordinator: coordinator)
            case .hold: DHParentHoldView(coordinator: coordinator)
            }
        }
        .onAppear { DHSounds.play(.lockTap) }
    }
}

UPDATE AppCoordinator: 
- `var presentedParentGate: ParentGateIntent? = nil`
- `func presentParentGate(_ intent: ParentGateIntent) { presentedParentGate = intent }`
- `func parentGatePassed(intent: ParentGateIntent) { presentedParentGate = nil; executeIntent(intent) }`
- `private func executeIntent(_ intent: ParentGateIntent) { switch intent { case .paywall: presentingPaywall = true; case .manageSubscription: openManageSubscriptionsURL(); case .privacyDeepLink(let url): UIApplication.shared.open(url); case .deleteAllData: deleteAllUserData() } }`

UPDATE RootView: `.fullScreenCover(item: $coordinator.presentedParentGate) { intent in ParentGateRootView(coordinator: ParentGateCoordinator(intent: intent, onPass: { coordinator.parentGatePassed(intent: $0) }, onCancel: { coordinator.presentedParentGate = nil })) }`

VERIFY:
1. Trigger gate from any source → 50/50 math vs hold
2. 3 wrong math answers → 30s lockout, copy shown, numpad disabled
3. Idle 30s without input → gate dismisses (cancel path)
4. Hold passes only with two fingers; lift one finger → progress resets
5. Cold relaunch → gate re-required for next intent
````

---

## GRWM-701 — DHParentMathView (math gate UI)

**Goal:** Build the math-gate screen matching `docs/design-source/v3/screens-7.jsx` `DHParentMathIdle` + `DHParentMathWrong`. Numpad, math chips, animated wrong-state, lockout overlay.

**Prereqs:** GRWM-700

**Files:**
- `GRWMStudio/ParentGate/DHParentMathView.swift` (new)
- `GRWMStudio/ParentGate/MathChip.swift` (new)

**Acceptance criteria:**
- [ ] Background: linear gradient pinkLight → pinkPaper, decorative heart sprites at fixed positions with rotation/opacity from JSX
- [ ] Top bar: X button left, "GROWN-UP CHECK" caps centered, 42pt spacer right
- [ ] Card: "👋 For grown-ups only", subtitle "To make a purchase, please solve this:"
- [ ] Math chips show challenge.lhs, +, challenge.rhs, =, ?-chip (hollow with dashed border)
- [ ] Input field: 18pt rounded, pinkPaper bg, 3pt border (pinkLight or red on wrong), 4pt drop shadow
- [ ] On wrong: red border, red shadow, monkey-cover-mouth chip with copy "Hmm, not quite. Try again!"
- [ ] Numpad: 3 cols × 4 rows, [1..9, ⌫, 0, OK]; OK button DH.pink with white text; rest white with pinkDeep text
- [ ] Tap digit → appends to entry (max 3 chars); ⌫ deletes last; OK submits
- [ ] On lockout: numpad disabled (50% opacity, no taps); centered card "Take a break, friend! Try again in <N>s 💕"
- [ ] Bubble pop sound on each digit; warning haptic on wrong; success haptic on correct

**Prompt:**
````
CONTEXT: Visual + interaction layer for the math gate. Pure SwiftUI driven by ParentGateCoordinator state.

CREATE GRWMStudio/ParentGate/MathChip.swift:

import SwiftUI

struct MathChip: View {
    let value: String
    let hollow: Bool
    var body: some View {
        Text(value)
            .font(DH.font(.headlineLarge))
            .foregroundStyle(DH.pinkDeep)
            .frame(width: 60, height: 60)
            .background(hollow ? Color.clear : DH.pinkLight, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(DH.pinkDeep, style: StrokeStyle(lineWidth: 3, dash: hollow ? [6,5] : []))
                    .opacity(hollow ? 1 : 0)
            }
            .overlay {
                if !hollow {
                    RoundedRectangle(cornerRadius: 18).stroke(.white, lineWidth: 3)
                }
            }
            .shadow(color: hollow ? .clear : DH.pink, radius: 0, x: 0, y: 4)
    }
}

CREATE GRWMStudio/ParentGate/DHParentMathView.swift:

import SwiftUI

struct DHParentMathView: View {
    let coordinator: ParentGateCoordinator
    var body: some View {
        ZStack {
            backgroundLayer
            VStack(spacing: 0) {
                topBar
                mathCard
                    .padding(.horizontal, 18).padding(.top, 40)
                numpad
                    .padding(.horizontal, 18).padding(.top, 18)
                Spacer(minLength: 0)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(colors: [DH.pinkLight, DH.pinkPaper], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            Image(systemName: "heart.fill").font(.system(size: 120))
                .foregroundStyle(DH.pink.opacity(0.5)).rotationEffect(.degrees(-18))
                .position(x: 60, y: 200)
            Image(systemName: "heart.fill").font(.system(size: 140))
                .foregroundStyle(DH.pinkDeep.opacity(0.5)).rotationEffect(.degrees(15))
                .position(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 220)
        }
    }

    private var topBar: some View {
        HStack {
            Button { DHHaptics.light(); coordinator.cancel() } label: {
                Image(systemName: "xmark").font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(DH.pinkDeep).frame(width: 42, height: 42)
                    .background(.white, in: Circle())
                    .shadow(color: DH.pink, radius: 0, x: 0, y: 3)
            }
            .accessibilityLabel("Close grown-up check")
            Spacer()
            Text("GROWN-UP CHECK").font(DH.font(.tinyCaps)).tracking(2.5).foregroundStyle(DH.pinkDeep)
            Spacer()
            Color.clear.frame(width: 42)
        }
        .padding(.horizontal, 18).padding(.top, 8)
    }

    @ViewBuilder
    private var mathCard: some View {
        DHCard(color: .white, deep: DH.pinkDeep, radius: 28) {
            VStack(spacing: 0) {
                Text("👋").font(.system(size: 46))
                Text("For grown-ups only").font(DH.font(.titleMedium)).foregroundStyle(DH.pinkDeep)
                Text("To make a purchase, please solve this:")
                    .font(DH.font(.body)).foregroundStyle(DH.ink.opacity(0.7))
                    .padding(.top, 6)

                if case .math(let challenge, let attempts, let lockedUntil) = coordinator.phase {
                    HStack(spacing: 10) {
                        MathChip(value: "\(challenge.lhs)", hollow: false)
                        Text("+").font(DH.font(.headline)).foregroundStyle(DH.pinkDeep)
                        MathChip(value: "\(challenge.rhs)", hollow: false)
                        Text("=").font(DH.font(.headline)).foregroundStyle(DH.pinkDeep)
                        MathChip(value: "?", hollow: true)
                    }
                    .padding(.top, 20)

                    let isWrong = attempts > 0 && coordinator.entry.isEmpty
                    EntryField(text: coordinator.entry.isEmpty ? "___" : coordinator.entry,
                               wrong: isWrong)
                        .padding(.top, 20)

                    if isWrong {
                        HStack(spacing: 8) {
                            Text("🙊")
                            Text("Hmm, not quite. Try again!")
                                .font(DH.font(.caption).bold()).foregroundStyle(Color(red: 0.71, green: 0.08, blue: 0.25))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color(red: 1.0, green: 0.89, blue: 0.92), in: RoundedRectangle(cornerRadius: 12))
                        .padding(.top, 10)
                    }

                    if let until = lockedUntil, Date() < until {
                        let remaining = max(1, Int(ceil(until.timeIntervalSinceNow)))
                        Text("Take a break, friend! Try again in \(remaining)s 💕")
                            .font(DH.font(.caption).bold()).foregroundStyle(DH.pinkDeep)
                            .padding(.top, 10)
                    }
                }
            }
            .padding(24)
        }
    }

    private var numpad: some View {
        let keys: [NumpadKey] = [.d(1),.d(2),.d(3),.d(4),.d(5),.d(6),.d(7),.d(8),.d(9),.backspace,.d(0),.ok]
        let locked: Bool = {
            if case .math(_, _, let until) = coordinator.phase { return (until ?? .distantPast) > Date() }
            return false
        }()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(keys, id: \.id) { key in
                Button {
                    DHSounds.play(.bubble); DHHaptics.light()
                    switch key {
                    case .d(let n): coordinator.appendDigit(n)
                    case .backspace: coordinator.backspace()
                    case .ok: coordinator.submitMath()
                    }
                } label: {
                    Text(key.label)
                        .font(DH.font(key == .ok ? .caption : .headline).bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(key == .ok ? DH.pink : .white,
                                    in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(key == .ok ? .white : DH.pinkDeep)
                        .shadow(color: key == .ok ? DH.pinkDeep : DH.pinkLight, radius: 0, x: 0, y: key == .ok ? 4 : 3)
                }
                .disabled(locked)
                .opacity(locked ? 0.5 : 1)
            }
        }
    }
}

private enum NumpadKey: Equatable, Hashable {
    case d(Int), backspace, ok
    var id: String { switch self { case .d(let n): "\(n)"; case .backspace: "bs"; case .ok: "ok" } }
    var label: String { switch self { case .d(let n): "\(n)"; case .backspace: "⌫"; case .ok: "OK" } }
}

private struct EntryField: View {
    let text: String
    let wrong: Bool
    var body: some View {
        HStack {
            Text(text).font(DH.font(.headlineLarge)).foregroundStyle(wrong ? Color(red: 1, green: 0.18, blue: 0.35) : DH.pinkDeep)
            Spacer()
            Text("YOUR ANSWER").font(DH.font(.tinyCaps)).tracking(1.5).foregroundStyle(DH.ink.opacity(0.5))
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
        .background(DH.pinkPaper, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(wrong ? Color(red: 1, green: 0.18, blue: 0.35) : DH.pinkLight, lineWidth: 3))
        .shadow(color: wrong ? Color(red: 0.71, green: 0.08, blue: 0.25) : DH.pinkLight, radius: 0, x: 0, y: 4)
    }
}

VERIFY:
1. Random challenge appears (lhs 5..12, rhs 4..9)
2. Tap digits → fill entry up to 3 chars
3. ⌫ removes last
4. Wrong answer → red border, monkey error chip, new challenge generated
5. After 3 wrong → numpad goes 50% opacity & disabled, lockout copy with countdown
6. Correct answer → coordinator.onPass fires
7. VoiceOver: numpad labels, "X to close", "Your answer field"
````

---

## GRWM-702 — DHParentHoldView (hold gate UI)

**Goal:** Build the hold-gate screen matching `docs/design-source/v3/screens-7.jsx` `DHParentHold`. Big heart with progress ring, requires two-finger continuous hold for 3.0s. Counter shows live elapsed time.

**Prereqs:** GRWM-700

**Files:**
- `GRWMStudio/ParentGate/DHParentHoldView.swift` (new)
- `GRWMStudio/ParentGate/TwoFingerHoldGesture.swift` (new — UIViewRepresentable wrapper)

**Acceptance criteria:**
- [ ] Background gradient pinkLight → pinkPaper, decorative hearts at corners
- [ ] Top bar: X button left, "GROWN-UP CHECK" caps centered
- [ ] Title block: "👆" emoji, "Press & hold the heart" headline, subtitle "Hold the heart for 3 whole seconds with two fingers to confirm a grown-up is here."
- [ ] 240pt progress ring (white track, pink-deep stroke, 14pt width, animated rotating from 12 o'clock)
- [ ] Inside ring: 200pt heart bubble with radial pink gradient, white border, deep-pink shadow
- [ ] Heart accepts custom multi-touch gesture: when ≥2 fingers active, progress accumulates (3.0s = 100%); fingers lift or only 1 finger active → progress resets to 0
- [ ] Live counter "1.8s" shows elapsed time, 42pt heavy
- [ ] On 3.0s reach: success haptic, fanfare sound, ring fills, heart pulses, coordinator.onPass fires
- [ ] Cancel via X dismisses

**Prompt:**
````
CONTEXT: Press-and-hold gate. Uses UIKit gesture recognizer (UILongPressGestureRecognizer.minimumNumberOfTouches=2 isn't quite enough—we need progress tracking. Use a custom MultiTouchProgressGesture).

CREATE GRWMStudio/ParentGate/TwoFingerHoldGesture.swift:

import SwiftUI
import UIKit

struct TwoFingerHoldGesture: UIViewRepresentable {
    let onProgress: (Double, Bool) -> Void  // progress 0..1, twoFingersActive
    let onReset: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onProgress: onProgress, onReset: onReset) }
    func makeUIView(context: Context) -> TouchTrackingView {
        let v = TouchTrackingView(); v.delegate = context.coordinator; v.isMultipleTouchEnabled = true; return v
    }
    func updateUIView(_ uiView: TouchTrackingView, context: Context) {}

    final class Coordinator: TouchTrackingViewDelegate {
        let onProgress: (Double, Bool) -> Void
        let onReset: () -> Void
        var startedAt: Date?
        var displayLink: CADisplayLink?
        init(onProgress: @escaping (Double, Bool) -> Void, onReset: @escaping () -> Void) {
            self.onProgress = onProgress; self.onReset = onReset
        }
        func touchCountChanged(_ count: Int) {
            if count >= 2, startedAt == nil {
                startedAt = Date()
                let dl = CADisplayLink(target: self, selector: #selector(tick))
                dl.add(to: .main, forMode: .common)
                displayLink = dl
            } else if count < 2 {
                startedAt = nil
                displayLink?.invalidate(); displayLink = nil
                onReset()
            }
        }
        @objc func tick() {
            guard let start = startedAt else { return }
            let elapsed = Date().timeIntervalSince(start)
            let progress = min(1.0, elapsed / 3.0)
            onProgress(progress, true)
            if progress >= 1.0 {
                displayLink?.invalidate(); displayLink = nil
                startedAt = nil
            }
        }
    }
}

protocol TouchTrackingViewDelegate: AnyObject {
    func touchCountChanged(_ count: Int)
}

final class TouchTrackingView: UIView {
    weak var delegate: TouchTrackingViewDelegate?
    private var active = Set<UITouch>()
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { active.formUnion(touches); delegate?.touchCountChanged(active.count) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { active.subtract(touches); delegate?.touchCountChanged(active.count) }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { active.subtract(touches); delegate?.touchCountChanged(active.count) }
}

CREATE GRWMStudio/ParentGate/DHParentHoldView.swift:

import SwiftUI

struct DHParentHoldView: View {
    let coordinator: ParentGateCoordinator
    @State private var progressDisplay: Double = 0

    var body: some View {
        ZStack {
            backgroundLayer
            VStack(spacing: 0) {
                topBar
                title
                heartArea
                counter
                Spacer(minLength: 0)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(colors: [DH.pinkLight, DH.pinkPaper], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            Image(systemName: "heart.fill").font(.system(size: 120)).foregroundStyle(DH.pink.opacity(0.4)).rotationEffect(.degrees(-18)).position(x: 70, y: 220)
            Image(systemName: "heart.fill").font(.system(size: 140)).foregroundStyle(DH.pinkDeep.opacity(0.4)).rotationEffect(.degrees(20)).position(x: UIScreen.main.bounds.width - 70, y: UIScreen.main.bounds.height - 240)
        }
    }

    private var topBar: some View {
        HStack {
            Button { DHHaptics.light(); coordinator.cancel() } label: {
                Image(systemName: "xmark").font(.system(size: 18, weight: .heavy)).foregroundStyle(DH.pinkDeep)
                    .frame(width: 42, height: 42).background(.white, in: Circle())
                    .shadow(color: DH.pink, radius: 0, x: 0, y: 3)
            }.accessibilityLabel("Close grown-up check")
            Spacer()
            Text("GROWN-UP CHECK").font(DH.font(.tinyCaps)).tracking(2.5).foregroundStyle(DH.pinkDeep)
            Spacer()
            Color.clear.frame(width: 42)
        }
        .padding(.horizontal, 18).padding(.top, 8)
    }

    private var title: some View {
        VStack(spacing: 8) {
            Text("👆").font(.system(size: 46))
            Text("Press & hold the heart")
                .font(DH.font(.titleMedium)).foregroundStyle(DH.pinkDeep)
                .multilineTextAlignment(.center)
            Text("Hold the heart for **3 whole seconds** with two fingers to confirm a grown-up is here.")
                .font(DH.font(.body)).foregroundStyle(DH.ink.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .padding(.top, 40)
    }

    private var heartArea: some View {
        ZStack {
            Circle().stroke(.white, lineWidth: 14)
                .frame(width: 240, height: 240)
            Circle().trim(from: 0, to: progressDisplay)
                .stroke(DH.pinkDeep, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: progressDisplay)

            Circle().fill(RadialGradient(colors: [DH.pinkLight, DH.pink], center: .topLeading, startRadius: 4, endRadius: 200))
                .frame(width: 200, height: 200)
                .overlay(Circle().stroke(.white, lineWidth: 5))
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 8)
                .shadow(color: DH.pinkDeep.opacity(0.4), radius: 24, x: 0, y: 14)
                .overlay {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80, weight: .heavy))
                        .foregroundStyle(.white)
                }

            // Multi-touch capture overlay (transparent, sits on top of the heart only)
            TwoFingerHoldGesture(onProgress: { p, two in
                progressDisplay = p
                coordinator.updateHold(progress: p, twoFingers: two)
            }, onReset: {
                progressDisplay = 0
                coordinator.resetHold()
            })
            .frame(width: 240, height: 240)
            .clipShape(Circle())
        }
        .padding(.top, 48)
    }

    private var counter: some View {
        VStack(spacing: 0) {
            Text("HOLDING").font(DH.font(.tinyCaps)).tracking(2.5).foregroundStyle(DH.pinkDeep.opacity(0.6))
            Text(String(format: "%.1fs", progressDisplay * 3.0))
                .font(DH.font(.headlineLarge)).foregroundStyle(DH.pinkDeep)
        }
        .padding(.top, 24)
    }
}

VERIFY:
1. Open hold gate → 0.0s shown, ring empty
2. Tap with one finger → no progress
3. Place two fingers → counter ticks up; ring fills proportionally
4. Lift one finger before 3s → progress instantly resets to 0
5. Hold 3.0s → success haptic, fanfare, coordinator.onPass fires
6. Tap X → cancels, no intent fires
7. VoiceOver labels heart "Press and hold with two fingers"
````

---

## GRWM-703 — DHParentInfo onboarding form

**Goal:** Build the parent-info onboarding screen (`docs/design-source/v3/screens-6.jsx` `DHParentInfo`). This is collected ONCE during onboarding (Step 1 of 3) before camera permissions. Captures: parent email (validated), kid age range (chip select), weekly recap toggle. Stored locally in SwiftData; never sent off-device.

**Prereqs:** GRWM-200 (onboarding scaffold)

**Files:**
- `GRWMStudio/Onboarding/DHParentInfoView.swift` (new)
- `GRWMStudio/Onboarding/ParentInfoViewModel.swift` (new)
- `GRWMStudio/Profile/ProfileRecord.swift` (update — add parentEmail, kidAgeRange, weeklyRecap)

**Acceptance criteria:**
- [ ] Striped diagonal background `repeating-linear-gradient(45deg, pinkPaper, cream)` at 0.7 opacity
- [ ] Top bar: chevron-back, "STEP 1 OF 3", spacer
- [ ] Hero card: 👋 emoji, "HI, GROWN-UP" caps subtitle, "A quick check-in" headline, copy: "We need a parent or guardian's email to keep things safe. Nothing posts publicly. Photos stay on this device."
- [ ] Form card with cream bg:
  - Email input (envelope icon, pink border, pink shadow): validates RFC-light email regex on continue
  - Age chips: 6–7, 8–9, 10–11, 12+ (single select; default 8–9)
  - Weekly recap toggle row
- [ ] Disclaimer footer: "By continuing, you agree GRWM may store your email locally to send recaps and recovery links. Privacy · Parent terms" with deep-pink underlined links
- [ ] Continue button at bottom (xl primary): validates email, persists to ProfileRecord, advances coordinator to permissions step
- [ ] If email invalid: shake field, warning haptic, inline copy "Enter a valid email"
- [ ] **Important:** Despite the design implying email "weekly recap" sends, the MVP will NOT send any email — the toggle and email field are stored locally only. Document this in code comments. Future server-side recap is a v2 feature.

**Prompt:**
````
CONTEXT: First onboarding step. We collect parent email + kid age + recap preference, all stored LOCALLY in SwiftData. No network calls. Future versions may add a server, but MVP is local-only and the disclaimer wording reflects that.

UPDATE ProfileRecord.swift schema (add fields, migrate v1 → v2 if needed):

@Model
final class ProfileRecord {
    var displayName: String
    var tagline: String
    var avatarSwatchRaw: String
    var distinctLooksTried: Int
    var streakDays: Int
    var lastActiveDay: Date?
    // NEW
    var parentEmail: String
    var kidAgeRangeRaw: String   // "6-7" / "8-9" / "10-11" / "12+"
    var weeklyRecapEnabled: Bool
    var onboardingCompleted: Bool
    init(displayName: String = "GRWM Star", ...) { ... }
}

enum KidAgeRange: String, CaseIterable {
    case six = "6-7"; case eight = "8-9"; case ten = "10-11"; case twelvePlus = "12+"
    var display: String { switch self { case .six: "6–7"; case .eight: "8–9"; case .ten: "10–11"; case .twelvePlus: "12+" } }
}

CREATE GRWMStudio/Onboarding/ParentInfoViewModel.swift:

import Foundation
import SwiftData
import Observation

@Observable @MainActor
final class ParentInfoViewModel {
    var email: String = ""
    var ageRange: KidAgeRange = .eight
    var weeklyRecap: Bool = true
    private(set) var shakeCount: Int = 0
    private(set) var inlineError: String? = nil

    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func validateAndSave() -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidEmail(trimmed) else {
            inlineError = "Enter a valid email"
            shakeCount &+= 1
            DHHaptics.warning()
            return false
        }
        let pdesc = FetchDescriptor<ProfileRecord>()
        let record = (try? context.fetch(pdesc).first) ?? ProfileRecord.makeDefault()
        record.parentEmail = trimmed
        record.kidAgeRangeRaw = ageRange.rawValue
        record.weeklyRecapEnabled = weeklyRecap
        if (try? context.fetch(pdesc).first) == nil { context.insert(record) }
        try? context.save()
        return true
    }

    private func isValidEmail(_ s: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }
}

CREATE GRWMStudio/Onboarding/DHParentInfoView.swift:

import SwiftUI
import SwiftData

struct DHParentInfoView: View {
    @Environment(\.modelContext) private var context
    @Environment(OnboardingCoordinator.self) private var onboarding
    @State private var vm: ParentInfoViewModel?

    var body: some View {
        if vm == nil {
            Color.clear.onAppear { self.vm = ParentInfoViewModel(context: context) }
        } else { content }
    }

    private var content: some View {
        ZStack(alignment: .top) {
            stripedBackground
            VStack(spacing: 0) {
                topBar
                heroCard.padding(.horizontal, 18).padding(.top, 14)
                formCard.padding(.horizontal, 18).padding(.top, 14)
                disclaimer.padding(.horizontal, 24).padding(.top, 14)
                Spacer(minLength: 80)
                continueButton.padding(.horizontal, 18).padding(.bottom, 46)
            }
        }
    }

    private var stripedBackground: some View {
        ZStack {
            Color(DH.pinkPaper).ignoresSafeArea()
            // Approximate diagonal stripes via Canvas
            Canvas { ctx, size in
                let stripeW: CGFloat = 32; let pinkW: CGFloat = 30
                let count = Int((size.width + size.height) / stripeW) + 4
                for i in -count...count {
                    let x = CGFloat(i) * stripeW
                    let path = Path { p in
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x + size.height, y: size.height))
                        p.addLine(to: CGPoint(x: x + size.height + pinkW, y: size.height))
                        p.addLine(to: CGPoint(x: x + pinkW, y: 0))
                        p.closeSubpath()
                    }
                    ctx.fill(path, with: .color(DH.cream.opacity(0.7)))
                }
            }
        }
    }

    // ... (build heroCard, formCard with email field bound to vm.email, age chip selector, recap toggle, disclaimer, continueButton hitting vm.validateAndSave() then onboarding.advance())

    private var continueButton: some View {
        DHButton(kind: .primary, size: .xl, label: "Continue", icon: "arrow.right") {
            guard let vm else { return }
            if vm.validateAndSave() { onboarding.advance() }
        }
    }
}

UPDATE OnboardingCoordinator: register .parentInfo as step 1 of 3 (before .permissions, .welcomeFinal). Step copy: "STEP 1 OF 3" / "STEP 2 OF 3" / "STEP 3 OF 3".

VERIFY:
1. Email invalid (e.g. "abc") → continue → field shakes, inline error
2. Email valid → continue → SwiftData saved, onboarding advances
3. Age chip selection → only one selected at a time, spring scale
4. Recap toggle → flips; saved to record
5. App relaunch with onboarding incomplete → returns to ParentInfo step
6. App relaunch with onboarding complete → goes to main app
````

---

## GRWM-704 — DHPaywall view

**Goal:** Build the paywall screen matching `docs/design-source/v3/screens-7.jsx` `DHPaywall`. Hero gradient (pinkDeep → purple), sparkle confetti, GRWM logo, feature list, butter CTA "Unlock for $14.99 ✨", restore link top right. Wired to StoreKit 2 (next ticket).

**Prereqs:** GRWM-700, GRWM-009

**Files:**
- `GRWMStudio/Commerce/DHPaywallView.swift` (new)
- `GRWMStudio/Commerce/PaywallViewModel.swift` (new — stub now, wired in GRWM-705)

**Acceptance criteria:**
- [ ] Background: linear gradient pinkDeep → #9C2BFF → #5A1099, 160deg
- [ ] 7 sparkles at fixed positions per JSX: (t:120,l:30,s:18), (t:170,l:340,s:14), (t:240,l:60,s:22), (t:320,l:330,s:16), (t:480,l:40,s:14), (t:560,l:340,s:20), (t:640,l:80,s:16); rotated by index*23°, opacity 0.55
- [ ] Top: X close button (white-bg-30%-opacity circle, blurred), "RESTORE" caps text right
- [ ] Hero: "Unlock all of" 48pt 700 white, GRWM logo stacked (pink "GRWM" / "STUDIO" deep), tagline "One payment. Forever access. No subscriptions, no ads, no surprises."
- [ ] Feature list card: 5 rows with emoji circles + headline + sub
- [ ] Price banner: butter pill "🎁 LAUNCH PRICE — SAVE $5"
- [ ] Bottom CTA: butter gradient button "Unlock for $14.99 ✨" (price comes from product when loaded; falls back to "$14.99" placeholder)
- [ ] Footer: "Grown-up check first · One-time payment · No subscription"
- [ ] X dismisses paywall
- [ ] RESTORE → triggers vm.restore() (implementation in GRWM-707)
- [ ] CTA → triggers vm.purchase() (implementation in GRWM-706)
- [ ] During load: CTA disabled, shimmer
- [ ] On purchase success: confetti animation overlay, "You unlocked Studio Pro!" splash for 2s, then dismiss
- [ ] On purchase failure (non-cancel): inline error toast "Something went wrong. Try again."
- [ ] On user cancel: no error shown, return to paywall

**Prompt:**
````
CONTEXT: The paywall UI. Wires to ViewModel functions that may be no-ops until GRWM-705 implements StoreKit. Build full visual fidelity now.

CREATE GRWMStudio/Commerce/PaywallViewModel.swift (stub):

import Foundation
import Observation
import StoreKit

@Observable @MainActor
final class PaywallViewModel {
    enum Phase: Equatable { case loading, ready, purchasing, success, restoring, error(String) }
    private(set) var phase: Phase = .loading
    private(set) var displayPrice: String = "$14.99"
    private(set) var product: Product? = nil

    func loadProducts() async { /* GRWM-705 */ }
    func purchase() async { /* GRWM-706 */ }
    func restore() async { /* GRWM-707 */ }
}

CREATE GRWMStudio/Commerce/DHPaywallView.swift:

import SwiftUI

struct DHPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm = PaywallViewModel()
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            backgroundLayer
            sparkleLayer
            VStack(spacing: 0) {
                topBar
                heroBlock.padding(.horizontal, 24).padding(.top, 24)
                featureList.padding(.horizontal, 18).padding(.top, 20)
                priceBanner.padding(.horizontal, 18).padding(.top, 14)
                Spacer()
                ctaBlock.padding(.horizontal, 18).padding(.bottom, 46)
            }
            if showConfetti { ConfettiOverlay() }
            if vm.phase == .success {
                SuccessSplash().transition(.opacity)
            }
        }
        .task { await vm.loadProducts() }
        .onChange(of: vm.phase) { _, new in
            if case .success = new {
                showConfetti = true
                DHSounds.play(.fanfare); DHHaptics.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { dismiss() }
            }
        }
    }

    private var backgroundLayer: some View {
        LinearGradient(
            stops: [
                .init(color: DH.pinkDeep, location: 0),
                .init(color: Color(red: 0.611, green: 0.169, blue: 1.0), location: 0.6),
                .init(color: Color(red: 0.353, green: 0.063, blue: 0.6), location: 1.0)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var sparkleLayer: some View {
        let positions: [(t: CGFloat, l: CGFloat, s: CGFloat)] = [
            (120,30,18),(170,340,14),(240,60,22),(320,330,16),(480,40,14),(560,340,20),(640,80,16)
        ]
        return ZStack {
            ForEach(Array(positions.enumerated()), id: \.offset) { idx, pos in
                StickerSparkle(size: pos.s, fill: .white)
                    .opacity(0.55)
                    .rotationEffect(.degrees(Double(idx) * 23))
                    .position(x: pos.l, y: pos.t)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var topBar: some View {
        HStack {
            Button { DHHaptics.light(); dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 18, weight: .heavy)).foregroundStyle(.white)
                    .frame(width: 42, height: 42).background(.white.opacity(0.2), in: Circle())
            }.accessibilityLabel("Close paywall")
            Spacer()
            Button {
                DHHaptics.light()
                Task { await vm.restore() }
            } label: {
                Text("RESTORE").font(DH.font(.tinyCaps)).tracking(1.4).foregroundStyle(.white.opacity(0.7))
            }.accessibilityLabel("Restore previous purchases")
        }
        .padding(.horizontal, 18).padding(.top, 8)
    }

    private var heroBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Unlock all of").font(.system(size: 48, weight: .heavy)).foregroundStyle(.white)
                .tracking(-1).shadow(color: .black.opacity(0.2), radius: 0, x: 0, y: 4)
            GRWMLogo(size: 0.62, layout: .stack, pink: .white, deep: Color(red: 0.353, green: 0.063, blue: 0.6))
            Text("One payment. Forever access. No subscriptions, no ads, no surprises.")
                .font(DH.font(.body)).foregroundStyle(.white.opacity(0.85))
                .frame(maxWidth: 300, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var featureList: some View {
        DHCard(color: .white.opacity(0.15), deep: .black.opacity(0.3), radius: 22) {
            VStack(spacing: 10) {
                ForEach(features, id: \.title) { f in
                    HStack(spacing: 10) {
                        Text(f.emoji).font(.system(size: 20))
                            .frame(width: 38, height: 38)
                            .background(.white.opacity(0.95), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(f.title).font(DH.font(.cardTitle)).foregroundStyle(.white)
                            Text(f.sub).font(DH.font(.caption)).foregroundStyle(.white.opacity(0.75))
                        }
                        Spacer()
                    }
                }
            }
            .padding(16)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.3), lineWidth: 2))
    }

    private var features: [(emoji: String, title: String, sub: String)] {
        [
            ("💄", "62 pro shades", "Holographic, chrome, glittery, all unlocked"),
            ("✨", "All effects", "Disco, Mermaid, Galaxy, Doll, Chrome"),
            ("💼", "Unlimited locker", "Save as many looks as you dream up"),
            ("🎬", "1-min recording", "Up from 30 seconds. Make a real GRWM."),
            ("🚫", "Zero ads", "Forever. Promise."),
        ]
    }

    private var priceBanner: some View {
        HStack {
            Spacer()
            Text("🎁 LAUNCH PRICE — SAVE $5")
                .font(DH.font(.caption).bold()).tracking(1.2).foregroundStyle(DH.ink)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(DH.butter, in: RoundedRectangle(cornerRadius: 14))
                .shadow(color: DH.butterDeep, radius: 0, x: 0, y: 3)
            Spacer()
        }
    }

    private var ctaBlock: some View {
        VStack(spacing: 8) {
            Button {
                DHHaptics.medium(); DHSounds.play(.bubble)
                Task { await vm.purchase() }
            } label: {
                HStack {
                    if case .purchasing = vm.phase {
                        ProgressView().tint(DH.ink)
                    } else {
                        Text("Unlock for \(vm.displayPrice) ✨")
                            .font(DH.font(.button))
                    }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(LinearGradient(colors: [DH.butter, DH.butterDeep], startPoint: .top, endPoint: .bottom),
                            in: RoundedRectangle(cornerRadius: 22))
                .shadow(color: Color(red: 0.788, green: 0.608, blue: 0.122), radius: 0, x: 0, y: 5)
                .foregroundStyle(DH.ink)
            }
            .disabled(!isCTAEnabled)
            .opacity(isCTAEnabled ? 1 : 0.5)

            Text("Grown-up check first · One-time payment · No subscription")
                .font(DH.font(.caption).bold()).foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var isCTAEnabled: Bool {
        switch vm.phase {
        case .ready, .error: return true
        default: return false
        }
    }
}

private struct ConfettiOverlay: View { /* simple emoji rain animation */ var body: some View { Color.clear } }
private struct SuccessSplash: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("✨🎉✨").font(.system(size: 60))
            Text("You unlocked Studio Pro!").font(DH.font(.titleMedium)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.5))
    }
}

VERIFY:
1. Open paywall → gradient + sparkles render
2. Hero, features, price banner, CTA all match JSX layout
3. Tap RESTORE → calls vm.restore() (no-op until GRWM-707)
4. Tap CTA → calls vm.purchase() (no-op until GRWM-706)
5. CTA disabled while loading/purchasing
6. Tap X → dismisses
````

---

## GRWM-705 — StoreKit 2 product loading

**Goal:** Configure App Store Connect non-consumable IAP and load it via StoreKit 2 `Product.products(for:)`. Display formatted price on the paywall CTA. Provide a `.storekit` config file for local testing.

**Prereqs:** GRWM-704

**Files:**
- `GRWMStudio/Commerce/PaywallViewModel.swift` (update)
- `GRWMStudio/Commerce/ProEntitlements.swift` (new)
- `GRWMStudioTests/Configuration.storekit` (new — testing)
- `GRWMStudio/Commerce/StoreIDs.swift` (new — central product ID constant)

**Acceptance criteria:**
- [ ] Single product ID: `app.grwmstudio.ios.pro.lifetime`
- [ ] `PaywallViewModel.loadProducts()` calls `Product.products(for: [StoreIDs.proLifetime])`
- [ ] On success: `displayPrice = product.displayPrice`; phase → .ready
- [ ] On failure: phase → .error("Couldn't reach the App Store. Check your connection.")
- [ ] StoreKit config file with the product mocked at $14.99 USD for local testing
- [ ] Scheme set to use config in DEBUG (commands.md updates)

**Prompt:**
````
CONTEXT: Wire StoreKit 2 product loading. The product is non-consumable lifetime unlock.

CREATE GRWMStudio/Commerce/StoreIDs.swift:

enum StoreIDs {
    static let proLifetime = "app.grwmstudio.ios.pro.lifetime"
}

CREATE GRWMStudio/Commerce/ProEntitlements.swift:

import Foundation
import StoreKit
import Observation

@Observable @MainActor
final class ProEntitlements {
    private(set) var isPro: Bool = false
    private var transactionListener: Task<Void, Never>?

    init() {
        startListening()
        Task { await refresh() }
    }
    deinit { transactionListener?.cancel() }

    func refresh() async {
        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result, tx.productID == StoreIDs.proLifetime, tx.revocationDate == nil {
                found = true
            }
        }
        self.isPro = found
        UserDefaults.standard.set(found, forKey: "dh.isPro.cached")
    }

    private func startListening() {
        transactionListener = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let tx) = result {
                    if tx.productID == StoreIDs.proLifetime, tx.revocationDate == nil {
                        await MainActor.run { self?.isPro = true }
                    }
                    await tx.finish()
                }
            }
        }
    }
}

UPDATE PaywallViewModel:

func loadProducts() async {
    phase = .loading
    do {
        let products = try await Product.products(for: [StoreIDs.proLifetime])
        guard let p = products.first else {
            phase = .error("Couldn't reach the App Store. Check your connection.")
            return
        }
        self.product = p
        self.displayPrice = p.displayPrice
        phase = .ready
    } catch {
        DHLog.error("Product load failed: \(error)")
        phase = .error("Couldn't reach the App Store. Check your connection.")
    }
}

CREATE Tests/Configuration.storekit:
{
  "identifier" : "app.grwmstudio.iap",
  "nonRenewingSubscriptions" : [],
  "products" : [
    {
      "displayPrice" : "14.99",
      "familyShareable" : false,
      "internalID" : "PRO_LIFETIME",
      "localizations" : [
        { "description" : "Unlock GRWM Studio Pro forever — all shades, all effects, unlimited locker.", "displayName" : "Studio Pro Lifetime", "locale" : "en_US" }
      ],
      "productID" : "app.grwmstudio.ios.pro.lifetime",
      "referenceName" : "Studio Pro Lifetime",
      "type" : "NonConsumable"
    }
  ],
  "settings" : { "_storeKitErrors" : [] },
  "subscriptionGroups" : [],
  "version" : { "major" : 3, "minor" : 0 }
}

UPDATE Xcode scheme: Run → Options → StoreKit Configuration: Tests/Configuration.storekit (DEBUG only).

UPDATE 03-COMMANDS.md commerce section to include:
xcrun simctl privacy booted grant photos app.grwmstudio.ios   # for testing
# StoreKit Configuration File path: Tests/Configuration.storekit
# Set in scheme: Edit Scheme → Run → Options → StoreKit Configuration

VERIFY:
1. With StoreKit config attached: open paywall → CTA shows "$14.99" within ~1s
2. With airplane mode + no config: phase → .error, CTA shows error toast
3. ProEntitlements.refresh() called at app launch; isPro reflects cached state
4. Restart app after a successful sandbox purchase → isPro = true persists via Transaction.currentEntitlements
````

---

## GRWM-706 — Purchase flow

**Goal:** Implement `PaywallViewModel.purchase()` using StoreKit 2 `Product.purchase()`. Handles success, user-cancel, pending (Ask to Buy), and verification failures. Updates `ProEntitlements.isPro` on success.

**Prereqs:** GRWM-705

**Files:**
- `GRWMStudio/Commerce/PaywallViewModel.swift` (update)

**Acceptance criteria:**
- [ ] `purchase()` checks `product` is loaded; if not, calls loadProducts first
- [ ] Phase becomes .purchasing during call
- [ ] On `.success(.verified(tx))`: finish transaction, set isPro on entitlements, phase → .success
- [ ] On `.success(.unverified)`: phase → .error("Verification failed. Please try again.")
- [ ] On `.userCancelled`: phase → .ready (silent)
- [ ] On `.pending`: phase → .error("Waiting on grown-up approval. We'll unlock when approved.") + don't dismiss
- [ ] On exception: phase → .error("Couldn't complete the purchase. Try again.")
- [ ] All error copy is kid-friendly

**Prompt:**
````
CONTEXT: Implement the actual purchase action.

UPDATE PaywallViewModel.swift:

import StoreKit

func purchase() async {
    if product == nil { await loadProducts() }
    guard let product else { return }
    phase = .purchasing
    do {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let tx):
                await tx.finish()
                await ProEntitlementsHolder.shared.entitlements.refresh()
                phase = .success
            case .unverified:
                phase = .error("Verification failed. Please try again.")
            }
        case .userCancelled:
            phase = .ready
        case .pending:
            phase = .error("Waiting on grown-up approval. We'll unlock when approved.")
        @unknown default:
            phase = .error("Couldn't complete the purchase. Try again.")
        }
    } catch {
        DHLog.error("Purchase error: \(error)")
        phase = .error("Couldn't complete the purchase. Try again.")
    }
}

CREATE GRWMStudio/Commerce/ProEntitlementsHolder.swift (singleton wrapper for cross-VM access):

@MainActor
final class ProEntitlementsHolder {
    static let shared = ProEntitlementsHolder()
    let entitlements = ProEntitlements()
    private init() {}
}

UPDATE app entry to instantiate `ProEntitlementsHolder.shared` early so transaction listener starts.

VERIFY (with StoreKit config attached, simulator):
1. Tap Unlock → "Confirm Subscription"-style alert (sandbox) → Subscribe → success splash → confetti → dismiss
2. Tap Unlock → Cancel sheet → no error, returns to paywall
3. Force Ask-to-Buy in StoreKit config → tap Unlock → pending error copy shown
4. Disable network mid-purchase → error copy shown
5. After successful purchase → restart app → ProEntitlements.isPro == true (no re-purchase)
````

---

## GRWM-707 — Restore purchases flow

**Goal:** Implement `PaywallViewModel.restore()` using `AppStore.sync()`. Handles success (entitlement restored or already absent), errors. Provides clear feedback in either case.

**Prereqs:** GRWM-706

**Files:**
- `GRWMStudio/Commerce/PaywallViewModel.swift` (update)

**Acceptance criteria:**
- [ ] `restore()` sets phase → .restoring
- [ ] Calls `try await AppStore.sync()` then refreshes ProEntitlements
- [ ] If isPro becomes true: phase → .success (same path as purchase, dismiss + confetti)
- [ ] If isPro stays false: phase → .error("No previous purchase found.")
- [ ] If sync throws: phase → .error("Couldn't reach the App Store.")

**Prompt:**
````
CONTEXT: Restore purchases path.

UPDATE PaywallViewModel.swift:

func restore() async {
    phase = .restoring
    do {
        try await AppStore.sync()
        await ProEntitlementsHolder.shared.entitlements.refresh()
        if ProEntitlementsHolder.shared.entitlements.isPro {
            phase = .success
        } else {
            phase = .error("No previous purchase found.")
        }
    } catch {
        DHLog.error("Restore error: \(error)")
        phase = .error("Couldn't reach the App Store.")
    }
}

VERIFY:
1. With prior sandbox purchase → tap RESTORE → success splash → dismiss
2. Without any prior purchase → tap RESTORE → "No previous purchase found." error toast
3. Network off → tap RESTORE → "Couldn't reach the App Store." error toast
4. Multiple rapid taps → second tap ignored while phase == .restoring
````

---

## GRWM-708 — Pro entitlement persistence + cold-start cache

**Goal:** Cache the Pro entitlement state in `UserDefaults` (`dh.isPro.cached`) so the app can render Pro UI immediately at cold start before StoreKit has finished syncing. Always reconcile with `Transaction.currentEntitlements` once loaded; if reconciliation contradicts cache, prefer authoritative value and log telemetry.

**Prereqs:** GRWM-705

**Files:**
- `GRWMStudio/Commerce/ProEntitlements.swift` (update)

**Acceptance criteria:**
- [ ] On `init`, read cached `isPro` from UserDefaults; set as initial value
- [ ] `refresh()` updates UserDefaults after authoritative check
- [ ] If cached=true but authoritative=false (refund/revocation): set isPro=false, log warning
- [ ] If cached=false but authoritative=true (restored): set isPro=true
- [ ] Cache key namespaced `dh.isPro.cached`

**Prompt:**
````
CONTEXT: We want Pro UI to render instantly at cold start without waiting for the App Store. Cache + reconcile pattern.

UPDATE GRWMStudio/Commerce/ProEntitlements.swift:

@Observable @MainActor
final class ProEntitlements {
    private static let cacheKey = "dh.isPro.cached"
    private(set) var isPro: Bool = UserDefaults.standard.bool(forKey: cacheKey)
    private var transactionListener: Task<Void, Never>?

    init() {
        startListening()
        Task { await refresh() }
    }

    func refresh() async {
        var authoritative = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result, tx.productID == StoreIDs.proLifetime, tx.revocationDate == nil {
                authoritative = true
            }
        }
        if authoritative != self.isPro {
            DHLog.info("Pro entitlement reconciled: cache=\(self.isPro) authoritative=\(authoritative)")
        }
        self.isPro = authoritative
        UserDefaults.standard.set(authoritative, forKey: Self.cacheKey)
    }
}

VERIFY:
1. Cold launch with cache=true, network off → Pro UI shows; refresh later corrects if revoked
2. Cold launch with cache=false, network on, prior purchase → UI initially non-Pro then flips to Pro within 2s
3. Sandbox refund → next launch: cache reconciles to false; warning logged
````

---

## GRWM-709 — Pro entitlement gating across the app

**Goal:** Audit every "Pro" gate in the app and ensure they read from `ProEntitlementsHolder.shared.entitlements.isPro`. Confirm gates: Pro shades in Lips/Eyes filter trays (locked overlay + tap → parent gate → paywall); Pro Looks (4 of 8); Recording cap 8s vs 15s; "Studio Pro" indicator in Settings; Mirror Pro Gate banner during gated effect attempt.

**Prereqs:** GRWM-708, GRWM-300+

**Files:**
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — uses entitlement)
- `GRWMStudio/Mirror/Filter Trays/EyesTray.swift` (update — pro lock)
- `GRWMStudio/Mirror/Filter Trays/LipsTray.swift` (update)
- `GRWMStudio/Mirror/Filter Trays/LooksTray.swift` (update)
- `GRWMStudio/Capture/RecordingService.swift` (update — caps)
- `GRWMStudio/Settings/DHSettingsView.swift` (update — show Pro state)

**Acceptance criteria:**
- [ ] All filter "isPro" items render lock badge when `!isPro`
- [ ] Tap locked filter → opens parent gate with .paywall intent
- [ ] After successful purchase: entitlement flips → all locks disappear immediately (UI re-renders via @Observable)
- [ ] Recording cap evaluated each time recording starts: `isPro ? 15.0 : 8.0` seconds
- [ ] Mirror Pro Gate (DHMirrorProGate) opens for any Pro filter tap path
- [ ] Settings shows "Studio Pro · Unlocked · forever 👑" if isPro, else "Studio Pro · Locked" with tap → parent gate

**Prompt:**
````
CONTEXT: Single source of truth for Pro state. Audit pass.

UPDATE all view models that previously had local isPro flags to read from `ProEntitlementsHolder.shared.entitlements.isPro` (via `@Environment` if injected, or via `@MainActor` property access).

EXAMPLE — LipsTray.swift filter cell:

struct LipsCell: View {
    let item: LipsItem
    @Environment(ProEntitlements.self) private var entitlements
    let onTap: (LipsItem) -> Void
    var body: some View {
        Button {
            if item.isPro && !entitlements.isPro {
                AppCoordinator.shared.presentParentGate(.paywall)
                return
            }
            onTap(item)
        } label: { ... ProLockBadge(visible: item.isPro && !entitlements.isPro) ... }
    }
}

EXAMPLE — RecordingService:

func cap() -> TimeInterval {
    return ProEntitlementsHolder.shared.entitlements.isPro ? 15.0 : 8.0
}

EXAMPLE — DHSettingsView (placeholder for now, full content in GRWM-750):

let pro = entitlements.isPro
SettingsRow(label: "Studio Pro", sub: pro ? "Unlocked · forever" : "Locked — tap to unlock", trailing: pro ? Text("👑") : Image(systemName: "chevron.right"), onTap: { if !pro { coordinator.presentParentGate(.paywall) } })

VERIFY:
1. Fresh install (non-Pro) → all Pro shades show 🔒, all Pro looks show 🔒, recording cap = 8s
2. Tap any Pro shade → parent gate → paywall flow
3. Complete purchase → all 🔒 disappear within 0.5s of dismissing paywall
4. Recording cap becomes 15s
5. Settings reflects "Unlocked · forever 👑"
6. Force-quit and relaunch → Pro state persists via cache then reconciles via StoreKit
````

---

## GRWM-710 — Manage subscription & refund routing

**Goal:** Although we sell a non-consumable (no subscription), Apple requires a "Manage Subscription" or refund-request affordance for IAPs. We provide a "Manage Purchases" deep link to the App Store account page. Also provide "Request a refund" link to Apple's refund page. Both gated behind parent gate.

**Prereqs:** GRWM-700, GRWM-708

**Files:**
- `GRWMStudio/Settings/PurchasesSection.swift` (new — to be embedded in DHSettings GRWM-750)
- `GRWMStudio/Commerce/PurchaseLinks.swift` (new)

**Acceptance criteria:**
- [ ] `PurchaseLinks.openManagePurchases()` opens `https://apps.apple.com/account` via UIApplication
- [ ] `PurchaseLinks.openRequestRefund()` opens `https://reportaproblem.apple.com/`
- [ ] Both wrapped in parent gate (`.manageSubscription` intent that opens manage; `.privacyDeepLink(refundURL)` for refund)
- [ ] Settings rows: "Manage Purchases" + "Request Refund" (only visible if isPro)

**Prompt:**
````
CONTEXT: Apple requires IAP apps to expose "manage" + "refund" affordances. We route via parent gate so kids can't tap through.

CREATE GRWMStudio/Commerce/PurchaseLinks.swift:

import UIKit

enum PurchaseLinks {
    static let managePurchases = URL(string: "https://apps.apple.com/account")!
    static let requestRefund = URL(string: "https://reportaproblem.apple.com/")!

    @MainActor
    static func openManagePurchases() {
        UIApplication.shared.open(managePurchases)
    }
    @MainActor
    static func openRequestRefund() {
        UIApplication.shared.open(requestRefund)
    }
}

CREATE GRWMStudio/Settings/PurchasesSection.swift (used in GRWM-750):

import SwiftUI

struct PurchasesSection: View {
    @Environment(ProEntitlements.self) private var entitlements
    @Environment(AppCoordinator.self) private var coordinator
    var body: some View {
        SettingsGroup(title: "PURCHASES") {
            if entitlements.isPro {
                SettingsRow(icon: "cart.fill", iconBg: DH.lav, label: "Studio Pro", sub: "Unlocked · forever 👑", trailing: Image(systemName: "chevron.right")) {
                    // No-op or info modal
                }
                SettingsRow(icon: "creditcard.fill", iconBg: DH.mint, label: "Manage Purchases", trailing: Image(systemName: "chevron.right")) {
                    coordinator.presentParentGate(.manageSubscription)
                }
                SettingsRow(icon: "questionmark.circle.fill", iconBg: DH.butter, label: "Request Refund", trailing: Image(systemName: "chevron.right")) {
                    coordinator.presentParentGate(.privacyDeepLink(PurchaseLinks.requestRefund))
                }
            } else {
                SettingsRow(icon: "lock.fill", iconBg: DH.pink, label: "Studio Pro", sub: "Locked — tap to unlock", trailing: Image(systemName: "chevron.right")) {
                    coordinator.presentParentGate(.paywall)
                }
            }
        }
    }
}

UPDATE AppCoordinator.executeIntent for .manageSubscription and .privacyDeepLink (already covered by GRWM-700).

VERIFY:
1. Settings (Pro user): rows for "Studio Pro · Unlocked", "Manage Purchases", "Request Refund"
2. Tap Manage → parent gate → on pass → opens https://apps.apple.com/account in Safari
3. Tap Refund → parent gate → on pass → opens reportaproblem.apple.com
4. Settings (non-Pro): only one row "Studio Pro · Locked → tap to unlock"
````


---

# Phase 8 — Settings (full content)

> Two tickets. The settings shell was stubbed in GRWM-605; now we replace the placeholder with the full settings UI. The settings screen uses the SettingsGroup/SettingsRow primitives matching `docs/design-source/v3/screens-7.jsx` `DHSettings`. Items that change permissions/data are gated behind the parent gate.

---

## GRWM-750 — DHSettings full implementation

**Goal:** Replace the GRWM-605 stub with the full settings screen matching `docs/design-source/v3/screens-7.jsx` `DHSettings`. Sections: ACCOUNT, PRIVACY & SAFETY, LOOK & FEEL, PURCHASES (from GRWM-710), ABOUT. Most actions either reflect state read-only or open a parent gate before changing anything sensitive.

**Prereqs:** GRWM-605, GRWM-708, GRWM-710, GRWM-700

**Files:**
- `GRWMStudio/Settings/DHSettingsView.swift` (replace stub)
- `GRWMStudio/Settings/SettingsGroup.swift` (new)
- `GRWMStudio/Settings/SettingsRow.swift` (new)
- `GRWMStudio/Settings/Toggle/DHToggle.swift` (new)
- `GRWMStudio/Settings/SettingsViewModel.swift` (new)

**Acceptance criteria:**
- [ ] Background: linear gradient pinkPaper → cream
- [ ] Top bar: chevron-back, "Settings" title centered (DH.pinkDeep, 18pt 800)
- [ ] ACCOUNT section: rows for kid display name (with chevron → routes to AvatarEditor), parent email (read-only display), Studio Pro state
- [ ] PRIVACY & SAFETY section:
  - Camera toggle (read-only, links to iOS Settings if user wants to change — tap → `UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)`)
  - Microphone toggle (same as above)
  - Save to Photos toggle (controls behavior of GRWM-506 share — defaults OFF; persisted in UserDefaults)
  - Block share extensions toggle (controls whether the iOS share sheet is shown or only the in-app save flow — default ON for Made-for-Kids; persisted)
- [ ] LOOK & FEEL section:
  - Theme row read-only "Bubblegum Plastic" (no theme switching in MVP, design only V01)
  - Sounds & haptics toggle (master enable; persisted in UserDefaults; affects DHSounds and DHHaptics)
- [ ] PURCHASES section: embed `PurchasesSection` from GRWM-710
- [ ] ABOUT section:
  - Help Center → opens https://grwmstudio.app/help (parent-gated)
  - Privacy Policy → opens https://grwmstudio.app/privacy (parent-gated)
  - Terms → https://grwmstudio.app/terms (parent-gated)
  - Version row read-only: "X.Y.Z · Build N" pulled from Bundle
- [ ] DANGER ZONE section (gated):
  - "Delete all my looks" → parent gate → confirmation alert → wipes SwiftData captures + files
- [ ] Sign-out row replaced with "Reset onboarding" (debug-only, only in DEBUG builds)

**Prompt:**
````
CONTEXT: Full settings implementation. Replace the GRWM-605 stub.

CREATE GRWMStudio/Settings/SettingsGroup.swift:

import SwiftUI

struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(DH.font(.tinyCaps)).tracking(2.5)
                .foregroundStyle(DH.pinkDeep.opacity(0.6))
                .padding(.horizontal, 6).padding(.bottom, 6)
            DHCard(color: .white, deep: DH.pinkLight, radius: 20, padding: 0) {
                VStack(spacing: 0) { content() }
            }
        }
    }
}

CREATE GRWMStudio/Settings/SettingsRow.swift:

import SwiftUI

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconBg: Color
    let label: String
    let sub: String?
    let trailing: Trailing
    let onTap: (() -> Void)?
    init(icon: String, iconBg: Color, label: String, sub: String? = nil, @ViewBuilder trailing: () -> Trailing = { EmptyView() }, onTap: (() -> Void)? = nil) {
        self.icon = icon; self.iconBg = iconBg; self.label = label; self.sub = sub
        self.trailing = trailing(); self.onTap = onTap
    }
    var body: some View {
        Button { DHHaptics.light(); onTap?() } label: {
            HStack(spacing: 10) {
                ZStack { iconBg; Text(icon).font(.system(size: 18)) }
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 11))
                    .shadow(color: .black.opacity(0.08), radius: 0, x: 0, y: 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(DH.font(.body).bold()).foregroundStyle(DH.ink)
                    if let sub { Text(sub).font(DH.font(.caption)).foregroundStyle(DH.ink.opacity(0.55)) }
                }
                Spacer()
                trailing
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }
}

CREATE GRWMStudio/Settings/Toggle/DHToggle.swift:

import SwiftUI

struct DHToggle: View {
    @Binding var on: Bool
    var body: some View {
        ZStack(alignment: on ? .trailing : .leading) {
            Capsule().fill(on ? DH.pink : DH.ink.opacity(0.15))
                .shadow(color: on ? DH.pinkDeep : .clear, radius: 0, x: 0, y: 2)
            Circle().fill(.white)
                .frame(width: 20, height: 20)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                .padding(2)
        }
        .frame(width: 40, height: 24)
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { on.toggle() }
            DHHaptics.light()
        }
        .accessibilityElement()
        .accessibilityLabel(on ? "On" : "Off")
        .accessibilityAddTraits(.isButton)
    }
}

CREATE GRWMStudio/Settings/SettingsViewModel.swift:

import Foundation
import SwiftData
import Observation
import AVFoundation
import Photos

@Observable @MainActor
final class SettingsViewModel {
    private let context: ModelContext
    var saveToPhotos: Bool { didSet { UserDefaults.standard.set(saveToPhotos, forKey: "dh.saveToPhotos") } }
    var blockShareExtensions: Bool { didSet { UserDefaults.standard.set(blockShareExtensions, forKey: "dh.blockShareExtensions") } }
    var soundsAndHaptics: Bool { didSet { UserDefaults.standard.set(soundsAndHaptics, forKey: "dh.soundsHaptics"); DHSounds.shared.enabled = soundsAndHaptics; DHHaptics.shared.enabled = soundsAndHaptics } }

    private(set) var profile: ProfileRecord?
    var cameraGranted: Bool { AVCaptureDevice.authorizationStatus(for: .video) == .authorized }
    var micGranted: Bool { AVCaptureDevice.authorizationStatus(for: .audio) == .authorized }
    var photoLibAuth: PHAuthorizationStatus { PHPhotoLibrary.authorizationStatus(for: .addOnly) }

    var versionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(v) · Build \(b)"
    }

    init(context: ModelContext) {
        self.context = context
        self.saveToPhotos = UserDefaults.standard.object(forKey: "dh.saveToPhotos") as? Bool ?? false
        self.blockShareExtensions = UserDefaults.standard.object(forKey: "dh.blockShareExtensions") as? Bool ?? true
        self.soundsAndHaptics = UserDefaults.standard.object(forKey: "dh.soundsHaptics") as? Bool ?? true
        let pdesc = FetchDescriptor<ProfileRecord>()
        self.profile = try? context.fetch(pdesc).first
    }

    func deleteAllLooks() async {
        // Delete files
        let fm = FileManager.default
        if let docs = try? fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let captures = docs.appendingPathComponent("captures", isDirectory: true)
            try? fm.removeItem(at: captures)
            try? fm.createDirectory(at: captures, withIntermediateDirectories: true)
        }
        // Delete records
        let desc = FetchDescriptor<SavedCapture>()
        if let all = try? context.fetch(desc) {
            for c in all { context.delete(c) }
            try? context.save()
        }
    }
}

REPLACE GRWMStudio/Settings/DHSettingsView.swift with:

import SwiftUI
import SwiftData

struct DHSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(ProEntitlements.self) private var entitlements
    @State private var vm: SettingsViewModel?
    @State private var deleteConfirm: Bool = false

    var body: some View {
        Group {
            if let vm { content(vm: vm) }
            else { Color.clear.onAppear { self.vm = SettingsViewModel(context: context) } }
        }
        .background(LinearGradient(colors: [DH.pinkPaper, DH.cream], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }

    @ViewBuilder
    private func content(vm: SettingsViewModel) -> some View {
        VStack(spacing: 0) {
            HStack {
                CircleButton(systemName: "chevron.left") { dismiss() }
                Spacer()
                Text("Settings").font(DH.font(.titleSmall)).foregroundStyle(DH.pinkDeep)
                Spacer()
                Color.clear.frame(width: 42)
            }
            .padding(.horizontal, 18).padding(.top, 12)

            ScrollView {
                VStack(spacing: 14) {
                    accountSection(vm: vm)
                    privacySection(vm: vm)
                    lookFeelSection(vm: vm)
                    PurchasesSection()
                    aboutSection(vm: vm)
                    dangerSection(vm: vm)
                    #if DEBUG
                    debugSection(vm: vm)
                    #endif
                }
                .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 130)
            }
        }
        .alert("Delete all my looks?", isPresented: $deleteConfirm) {
            Button("Delete", role: .destructive) { Task { await vm.deleteAllLooks() } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This removes every saved look from this iPhone. It can't be undone.") }
    }

    private func accountSection(vm: SettingsViewModel) -> some View {
        SettingsGroup(title: "ACCOUNT") {
            SettingsRow(icon: "👧", iconBg: DH.pink, label: vm.profile?.displayName ?? "GRWM Star", sub: nil, trailing: { Image(systemName: "chevron.right").foregroundStyle(DH.pinkDeep) }, onTap: { coordinator.showAvatarEditor() })
            Divider().background(DH.pinkPaper)
            SettingsRow(icon: "👋", iconBg: DH.lav, label: "Grown-up email", sub: vm.profile?.parentEmail.isEmpty == false ? vm.profile!.parentEmail : "Not set")
        }
    }

    private func privacySection(vm: SettingsViewModel) -> some View {
        SettingsGroup(title: "PRIVACY & SAFETY") {
            permissionRow(icon: "📷", iconBg: Color(hex: "#FF8AB8")!, label: "Camera", granted: vm.cameraGranted)
            Divider().background(DH.pinkPaper)
            permissionRow(icon: "🎙️", iconBg: Color(hex: "#FFB46B")!, label: "Microphone", granted: vm.micGranted)
            Divider().background(DH.pinkPaper)
            SettingsRow(icon: "📂", iconBg: DH.mint, label: "Save to Photos", sub: vm.saveToPhotos ? "On" : "Off", trailing: { DHToggle(on: Binding(get: { vm.saveToPhotos }, set: { vm.saveToPhotos = $0 })) }, onTap: nil)
            Divider().background(DH.pinkPaper)
            SettingsRow(icon: "🚫", iconBg: Color(hex: "#C8C8FF")!, label: "Block share extensions", sub: vm.blockShareExtensions ? "Stays inside GRWM" : "iOS share sheet enabled", trailing: { DHToggle(on: Binding(get: { vm.blockShareExtensions }, set: { vm.blockShareExtensions = $0 })) }, onTap: nil)
        }
    }

    private func permissionRow(icon: String, iconBg: Color, label: String, granted: Bool) -> some View {
        SettingsRow(icon: icon, iconBg: iconBg, label: label, sub: granted ? "On" : "Off — tap to open Settings", trailing: { Image(systemName: "chevron.right").foregroundStyle(DH.pinkDeep) }, onTap: { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) })
    }

    private func lookFeelSection(vm: SettingsViewModel) -> some View {
        SettingsGroup(title: "LOOK & FEEL") {
            SettingsRow(icon: "🎀", iconBg: DH.pinkLight, label: "Theme", sub: "Bubblegum Plastic")
            Divider().background(DH.pinkPaper)
            SettingsRow(icon: "🔊", iconBg: Color(hex: "#7AE8E0")!, label: "Sounds & haptics", sub: vm.soundsAndHaptics ? "Sparkly" : "Off", trailing: { DHToggle(on: Binding(get: { vm.soundsAndHaptics }, set: { vm.soundsAndHaptics = $0 })) })
        }
    }

    private func aboutSection(vm: SettingsViewModel) -> some View {
        SettingsGroup(title: "ABOUT") {
            SettingsRow(icon: "❓", iconBg: DH.mint, label: "Help center", trailing: { Image(systemName: "chevron.right").foregroundStyle(DH.pinkDeep) }, onTap: { coordinator.presentParentGate(.privacyDeepLink(URL(string: "https://grwmstudio.app/help")!)) })
            Divider().background(DH.pinkPaper)
            SettingsRow(icon: "📜", iconBg: DH.butter, label: "Privacy policy", trailing: { Image(systemName: "chevron.right").foregroundStyle(DH.pinkDeep) }, onTap: { coordinator.presentParentGate(.privacyDeepLink(URL(string: "https://grwmstudio.app/privacy")!)) })
            Divider().background(DH.pinkPaper)
            SettingsRow(icon: "📄", iconBg: Color(hex: "#C8C8FF")!, label: "Terms", trailing: { Image(systemName: "chevron.right").foregroundStyle(DH.pinkDeep) }, onTap: { coordinator.presentParentGate(.privacyDeepLink(URL(string: "https://grwmstudio.app/terms")!)) })
            Divider().background(DH.pinkPaper)
            SettingsRow(icon: "ℹ️", iconBg: Color(hex: "#C8C8FF")!, label: "Version", sub: vm.versionString)
        }
    }

    private func dangerSection(vm: SettingsViewModel) -> some View {
        SettingsGroup(title: "DANGER ZONE") {
            SettingsRow(icon: "🗑️", iconBg: Color(hex: "#FFB4B4")!, label: "Delete all my looks", sub: "Removes every saved look", trailing: { Image(systemName: "chevron.right").foregroundStyle(DH.pinkDeep) }, onTap: {
                coordinator.presentParentGate(.deleteAllData)
            })
        }
    }

    #if DEBUG
    private func debugSection(vm: SettingsViewModel) -> some View {
        SettingsGroup(title: "DEBUG") {
            SettingsRow(icon: "🛠️", iconBg: .gray.opacity(0.2), label: "Reset onboarding", trailing: { Image(systemName: "chevron.right").foregroundStyle(DH.pinkDeep) }, onTap: {
                if let p = vm.profile { p.onboardingCompleted = false; try? context.save() }
                exit(0) // forces a clean cold start
            })
        }
    }
    #endif
}

UPDATE AppCoordinator.executeIntent for `.deleteAllData` → call settingsVM.deleteAllLooks() (route via Notification or shared singleton).

VERIFY:
1. All 5 sections render with correct rows
2. Camera/mic rows reflect current iOS authorization state; tap → opens app's iOS Settings
3. Save-to-Photos toggle → persists across launches
4. Block-share-extensions toggle → persists; controls share sheet visibility
5. Sounds toggle → persists; mutes sounds + haptics globally when off
6. Privacy/Help/Terms taps → parent gate → on pass → external Safari opens
7. Delete all → parent gate → on pass → confirm alert → all captures wiped
8. Version row shows correct CFBundleShortVersionString and CFBundleVersion
9. DEBUG builds only show "Reset onboarding"
````

---

## GRWM-751 — Manage subscription deep link wiring

**Goal:** Although already implemented in GRWM-710, this ticket is the explicit settings-side wire-up: the PurchasesSection rows must launch the parent gate then route to either (a) `https://apps.apple.com/account` for managing the lifetime purchase, or (b) the refund URL. Verify these intents pass cleanly through the gate coordinator and that the URL opens in Safari (NOT in-app SafariViewController, since this is an account action).

**Prereqs:** GRWM-710, GRWM-750

**Files:**
- `GRWMStudio/Coordinator/AppCoordinator.swift` (audit)
- `GRWMStudio/Settings/PurchasesSection.swift` (verified embedded)

**Acceptance criteria:**
- [ ] `executeIntent(.manageSubscription)` calls `PurchaseLinks.openManagePurchases()` which uses `UIApplication.shared.open(_:options:completionHandler:)`
- [ ] `executeIntent(.privacyDeepLink(URL))` opens via `UIApplication.shared.open` (Safari, not in-app)
- [ ] On URL open failure (e.g., simulator with no App Store): show an inline toast "Couldn't open the App Store. Try later."
- [ ] Buttons are debounced — second tap within 1s ignored

**Prompt:**
````
CONTEXT: Confirm the parent-gated routing actually opens the right URLs.

UPDATE AppCoordinator:

private var lastDeepLinkAt: Date = .distantPast

func executeIntent(_ intent: ParentGateIntent) {
    let now = Date()
    if now.timeIntervalSince(lastDeepLinkAt) < 1.0 { return }
    lastDeepLinkAt = now
    switch intent {
    case .paywall: presentingPaywall = true
    case .manageSubscription:
        UIApplication.shared.open(PurchaseLinks.managePurchases) { ok in
            if !ok { Toast.shared.show("Couldn't open the App Store. Try later.") }
        }
    case .privacyDeepLink(let url):
        UIApplication.shared.open(url) { ok in
            if !ok { Toast.shared.show("Couldn't open that link.") }
        }
    case .deleteAllData:
        NotificationCenter.default.post(name: .deleteAllRequested, object: nil)
    }
}
extension Notification.Name { static let deleteAllRequested = Notification.Name("dh.deleteAll") }

CREATE/UPDATE GRWMStudio/Components/Toast.swift if not yet created — small kid-friendly toast with butter card + ink text, auto-dismisses after 2.4s.

VERIFY:
1. From Settings → Manage Purchases → parent gate → on pass → Safari opens to apps.apple.com/account
2. From Settings → Request Refund → parent gate → on pass → Safari opens to reportaproblem.apple.com
3. From Settings → Privacy / Help / Terms → parent gate → on pass → Safari opens to expected URLs
4. Rapid double-tap → only one open call fires
5. Simulator without App Store → inline toast appears
````


---

# Phase 9 — Error states (9 variants, one ticket each)

> **Source of truth:** `docs/design-source/v3/screens-8.jsx` `DHError` component. There are 9 variants. Each must be ONE PER TICKET — no shortcuts, no abbreviation. Copy is verbatim from JSX, including em-dashes and punctuation.
>
> All errors use the same shell (radial-gradient hero with emoji, title, body, primary CTA, ghost alt CTA, X-close, ERROR · VARIANT chip top-left). The shell is built in GRWM-800 alongside the first variant (cam-denied). Each subsequent ticket adds one new variant trigger and routing.


---

## GRWM-800 — Error shell + Cam-Denied variant

**Goal:** Build the shared `DHErrorView` component matching `docs/design-source/v3/screens-8.jsx` `DHError`, including the `ErrorTone` palette (pink/lav/butter/mint), the radial-gradient hero, sticker overlay, ERROR chip, primary CTA, ghost alt CTA. Wire up the `cam-denied` variant: triggered when camera authorization is `.denied` or `.restricted` at any point during the app lifetime. CTA opens iOS Settings; ALT dismisses the error and routes back to the previous screen.

**Prereqs:** GRWM-009 (DH primitives), GRWM-200 (onboarding/permissions baseline)

**Files:**
- `GRWMStudio/Errors/DHErrorView.swift` (new)
- `GRWMStudio/Errors/ErrorVariant.swift` (new)
- `GRWMStudio/Errors/ErrorTone.swift` (new)
- `GRWMStudio/Errors/ErrorRouter.swift` (new)
- `GRWMStudio/Errors/Stickers.swift` (update — ensure StickerHeart/Sparkle/Star exist)
- `GRWMStudio/Coordinator/AppCoordinator.swift` (update — error route)

**Acceptance criteria:**
- [ ] `ErrorVariant` enum with 9 cases: `.camDenied .micDenied .photoDenied .license .effectFail .recFail .saveFail .noFace .lowStorage`
- [ ] Each variant exposes: emoji, sticker view, title, sub, ctaLabel, altLabel, tone
- [ ] `ErrorTone.pink/lav/butter/mint` with hero/deep/bg/card colors per JSX hex codes:
  - pink: hero=#FF3DA5, deep=#D4127B, bg=#FFE5F2
  - lav: hero=#C9A8FF, deep=#5A1099, bg=#F1E8FF
  - butter: hero=#FFD66B, deep=#C99B1F, bg=#FFF6E0
  - mint: hero=DH.mint, deep=#5DBD8E, bg=#E5FFF4
- [ ] Background: linear gradient tone.bg → DH.cream at 50%
- [ ] Top close (X) button: 42pt circle, white bg, tone.hero shadow
- [ ] Hero: 160pt circle, radial gradient `circle at 30% 30%, #fff, tone.hero`, 6pt white border, tone.deep shadow drop 7pt + 14pt blur
- [ ] Emoji 80pt centered in hero
- [ ] Sticker overlay: 26pt at top-right of hero, rotated 15°
- [ ] Title: 24pt 700 INK, letterSpacing -0.01, lineHeight 1.1
- [ ] Sub: 14pt 500, INK opacity 0.7, lineHeight 1.5
- [ ] ERROR chip top-left at y=130: "ERROR · {VARIANT}", 9.5pt 700, letterSpacing 0.12, INK opacity 0.55, INK 8% bg
- [ ] Primary CTA xl: bg = tone.hero, shadow = tone.deep 5pt; ALT ghost md
- [ ] **For cam-denied:** Title "The mirror can't see you 💕"; Sub "Camera access was turned off. Tap below to switch it back on in Settings."; CTA "Open Settings"; ALT "I'll do it later"
- [ ] CTA action: `UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)`
- [ ] ALT action: dismiss error
- [ ] Trigger source: `MirrorViewModel` observes `AVCaptureDevice.authorizationStatus(for: .video)`; if `.denied`/`.restricted` while Mirror tab active, presents this error
- [ ] Also presented from onboarding permissions step if the user denied camera
- [ ] Error is presented as fullScreenCover via `coordinator.presentedError = .camDenied`

**Prompt:**
````
CONTEXT: Build the shared error component shell + first variant. 9 variants total — keep the shell extensible (data-driven via ErrorVariant).

CREATE GRWMStudio/Errors/ErrorTone.swift:

import SwiftUI

enum ErrorTone {
    case pink, lav, butter, mint
    var hero: Color { switch self { case .pink: DH.pink; case .lav: DH.lav; case .butter: DH.butter; case .mint: DH.mint } }
    var deep: Color { switch self { case .pink: DH.pinkDeep; case .lav: Color(hex: "#5A1099")!; case .butter: Color(hex: "#C99B1F")!; case .mint: Color(hex: "#5DBD8E")! } }
    var bg: Color { switch self { case .pink: DH.pinkPaper; case .lav: Color(hex: "#F1E8FF")!; case .butter: Color(hex: "#FFF6E0")!; case .mint: Color(hex: "#E5FFF4")! } }
}

CREATE GRWMStudio/Errors/ErrorVariant.swift:

import SwiftUI

enum ErrorVariant: String, Identifiable, CaseIterable {
    case camDenied = "cam-denied"
    case micDenied = "mic-denied"
    case photoDenied = "photo-denied"
    case license
    case effectFail = "effect-fail"
    case recFail = "rec-fail"
    case saveFail = "save-fail"
    case noFace = "no-face"
    case lowStorage = "low-storage"

    var id: String { rawValue }
    var tone: ErrorTone { switch self {
        case .camDenied, .license, .recFail, .lowStorage: .pink
        case .micDenied, .noFace: .lav
        case .photoDenied, .saveFail: .butter
        case .effectFail: .mint
    }}
    var emoji: String { switch self {
        case .camDenied: "📷"; case .micDenied: "🎙️"; case .photoDenied: "🖼️"
        case .license: "🔒"; case .effectFail: "✨"; case .recFail: "🎬"
        case .saveFail: "💼"; case .noFace: "👀"; case .lowStorage: "📦"
    }}
    var title: String { switch self {
        case .camDenied: "The mirror can't see you 💕"
        case .micDenied: "No microphone, no voiceover"
        case .photoDenied: "Can't reach Photos"
        case .license: "This shade is Pro"
        case .effectFail: "That sparkle didn't load"
        case .recFail: "Recording didn't save"
        case .saveFail: "Couldn't add to Locker"
        case .noFace: "I can't see your face!"
        case .lowStorage: "Almost out of space"
    }}
    var sub: String { switch self {
        case .camDenied: "Camera access was turned off. Tap below to switch it back on in Settings."
        case .micDenied: "Recording works without sound, but giggles are nicer with audio."
        case .photoDenied: "Photos access is off, so we can't save your video to the camera roll. Looks still save inside GRWM."
        case .license: "Disco Brat is part of Studio Pro. Want a peek at everything?"
        case .effectFail: "The effect couldn't download. Check your wifi and try again — it'll only take a sec."
        case .recFail: "Something hiccuped while saving. Don't worry — you can record it again right now."
        case .saveFail: "There was a problem saving this look. Your last 3 looks are still safe inside the app."
        case .noFace: "Move into the light, or come a little closer to the camera so the makeup can land."
        case .lowStorage: "Your phone is nearly full. Free up some room or your next save might not stick."
    }}
    var ctaLabel: String { switch self {
        case .camDenied: "Open Settings"; case .micDenied: "Turn on Microphone"
        case .photoDenied: "Allow Photos"; case .license: "See Pro stuff"
        case .effectFail: "Try again"; case .recFail: "Record again"
        case .saveFail: "Try saving again"; case .noFace: "Got it, try again"
        case .lowStorage: "Show me how"
    }}
    var altLabel: String { switch self {
        case .camDenied: "I'll do it later"; case .micDenied: "Record without sound"
        case .photoDenied: "Keep inside GRWM"; case .license: "Maybe later"
        case .effectFail: "Pick a different look"; case .recFail: "Discard"
        case .saveFail: "Throw away"; case .noFace: "Use a sample face"
        case .lowStorage: "Save anyway"
    }}
}

CREATE GRWMStudio/Errors/DHErrorView.swift:

import SwiftUI

struct DHErrorView: View {
    let variant: ErrorVariant
    let onCTA: () -> Void
    let onAlt: () -> Void
    let onClose: () -> Void

    private var tone: ErrorTone { variant.tone }

    var body: some View {
        ZStack(alignment: .top) {
            background
            VStack(spacing: 0) {
                topClose
                ZStack(alignment: .topLeading) {
                    errorChip
                    VStack(spacing: 0) {
                        hero.padding(.top, 24)
                        copyBlock.padding(.top, 24).padding(.horizontal, 28)
                    }
                    .frame(maxWidth: .infinity)
                }
                Spacer()
                ctaBlock.padding(.horizontal, 18).padding(.bottom, 46)
            }
        }
    }

    private var background: some View {
        LinearGradient(stops: [.init(color: tone.bg, location: 0), .init(color: DH.cream, location: 0.5)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }

    private var topClose: some View {
        HStack { Spacer()
            Button { DHHaptics.light(); onClose() } label: {
                Image(systemName: "xmark").font(.system(size: 18, weight: .heavy)).foregroundStyle(tone.deep)
                    .frame(width: 42, height: 42).background(.white, in: Circle())
                    .shadow(color: tone.hero, radius: 0, x: 0, y: 3)
            }.accessibilityLabel("Close")
        }
        .padding(.horizontal, 18).padding(.top, 8)
    }

    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Circle().fill(RadialGradient(colors: [.white, tone.hero], center: UnitPoint(x: 0.3, y: 0.3), startRadius: 4, endRadius: 110))
                    .frame(width: 160, height: 160)
                    .overlay(Circle().stroke(.white, lineWidth: 6))
                    .shadow(color: tone.deep, radius: 0, x: 0, y: 7)
                    .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 14)
                Text(variant.emoji).font(.system(size: 80))
            }
            // Sticker
            Group {
                switch variant.tone {
                case .pink: StickerHeart(size: 26, fill: DH.pinkDeep, stroke: .white, sw: 2.5)
                case .lav: StickerSparkle(size: 24, fill: DH.lav)
                case .butter: StickerSparkle(size: 24, fill: DH.butter)
                case .mint: StickerSparkle(size: 24, fill: DH.mint)
                }
            }
            .rotationEffect(.degrees(15))
            .offset(x: 4, y: -4)
        }
    }

    private var errorChip: some View {
        Text("ERROR · \(variant.rawValue.uppercased())")
            .font(.system(size: 9.5, weight: .heavy)).tracking(1.4)
            .foregroundStyle(DH.ink.opacity(0.55))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(DH.ink.opacity(0.08), in: Capsule())
            .padding(.leading, 18).padding(.top, 130 - 60)
    }

    private var copyBlock: some View {
        VStack(spacing: 12) {
            Text(variant.title)
                .font(DH.font(.titleSmall)).foregroundStyle(DH.ink)
                .multilineTextAlignment(.center).lineLimit(2).fixedSize(horizontal: false, vertical: true)
            Text(variant.sub)
                .font(DH.font(.body)).foregroundStyle(DH.ink.opacity(0.7))
                .multilineTextAlignment(.center).lineSpacing(2)
        }
    }

    private var ctaBlock: some View {
        VStack(spacing: 8) {
            DHButton(kind: .primary, size: .xl, label: variant.ctaLabel) {
                DHHaptics.medium(); onCTA()
            }
            .background(tone.hero)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: tone.deep, radius: 0, x: 0, y: 5)

            DHButton(kind: .ghost, size: .md, label: variant.altLabel) {
                DHHaptics.light(); onAlt()
            }
        }
    }
}

CREATE GRWMStudio/Errors/ErrorRouter.swift:

import Foundation
import UIKit

@MainActor
enum ErrorRouter {
    static func handleCTA(_ variant: ErrorVariant, coordinator: AppCoordinator) {
        switch variant {
        case .camDenied, .micDenied, .photoDenied:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        case .license:
            coordinator.presentedError = nil
            coordinator.presentParentGate(.paywall)
        case .effectFail:
            NotificationCenter.default.post(name: .retryEffectLoad, object: nil)
        case .recFail:
            NotificationCenter.default.post(name: .retryRecording, object: nil)
        case .saveFail:
            NotificationCenter.default.post(name: .retrySave, object: nil)
        case .noFace:
            coordinator.presentedError = nil
        case .lowStorage:
            UIApplication.shared.open(URL(string: "App-Prefs:General&path=STORAGE_MGMT")!)
        }
    }

    static func handleAlt(_ variant: ErrorVariant, coordinator: AppCoordinator) {
        coordinator.presentedError = nil
        switch variant {
        case .micDenied:
            // Continue without audio
            NotificationCenter.default.post(name: .recordWithoutAudio, object: nil)
        case .photoDenied:
            NotificationCenter.default.post(name: .keepInsideGRWM, object: nil)
        case .effectFail:
            NotificationCenter.default.post(name: .pickDifferentLook, object: nil)
        case .recFail:
            NotificationCenter.default.post(name: .discardRecording, object: nil)
        case .saveFail:
            NotificationCenter.default.post(name: .discardCapture, object: nil)
        case .noFace:
            NotificationCenter.default.post(name: .useSampleFace, object: nil)
        default:
            break
        }
    }
}

extension Notification.Name {
    static let retryEffectLoad = Notification.Name("dh.retryEffectLoad")
    static let retryRecording = Notification.Name("dh.retryRecording")
    static let retrySave = Notification.Name("dh.retrySave")
    static let recordWithoutAudio = Notification.Name("dh.recordWithoutAudio")
    static let keepInsideGRWM = Notification.Name("dh.keepInsideGRWM")
    static let pickDifferentLook = Notification.Name("dh.pickDifferentLook")
    static let discardRecording = Notification.Name("dh.discardRecording")
    static let discardCapture = Notification.Name("dh.discardCapture")
    static let useSampleFace = Notification.Name("dh.useSampleFace")
}

UPDATE AppCoordinator: `var presentedError: ErrorVariant? = nil`. Add `func presentError(_ v: ErrorVariant) { presentedError = v }`.

UPDATE RootView: `.fullScreenCover(item: $coordinator.presentedError) { variant in DHErrorView(variant: variant, onCTA: { ErrorRouter.handleCTA(variant, coordinator: coordinator) }, onAlt: { ErrorRouter.handleAlt(variant, coordinator: coordinator) }, onClose: { coordinator.presentedError = nil }) }`

UPDATE MirrorViewModel — observe AVAuthorizationStatus on appear; if .denied/.restricted → coordinator.presentError(.camDenied).

VERIFY:
1. Cold launch with camera denied (manually toggled in Settings) → on entering Mirror, .camDenied error appears
2. Tap "Open Settings" → app's iOS Settings page opens
3. Tap "I'll do it later" → error dismisses; mirror stays in disabled state (cannot record)
4. ERROR · CAM-DENIED chip visible top-left
5. All visual elements (radial hero, sticker, copy, ghost CTA) match JSX
````


---

## GRWM-801 — Error variant: Mic-Denied

**Goal:** Wire the `.micDenied` variant. Triggered when user attempts video recording but microphone authorization is `.denied` or `.restricted`.

**Prereqs:** GRWM-800, GRWM-403 (video recording flow).

**Files:**
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — pre-flight mic check)
- `GRWMStudio/Errors/ErrorRouter.swift` (update)

**Acceptance criteria:**
- [ ] Title/sub/CTAs already declared in ErrorVariant enum from GRWM-800 — verify on screen
- [ ] CTA "Open Settings" → opens iOS Settings app
- [ ] ALT "Record without audio" → dismisses error AND posts `.recordWithoutAudio` notification → MirrorViewModel begins recording with `withAudio: false`
- [ ] Trigger: in `MirrorViewModel.startVideoRecording()` — before calling RecordingService, check `AVCaptureDevice.authorizationStatus(for: .audio)`; if denied, fire `coordinator.presentError(.micDenied)` and return
- [ ] ERROR · MIC-DENIED chip visible
- [ ] Tone: lav (lavender) — verify gradient + sticker color match JSX

**Prompt:**
````
CONTEXT: Wire the second error variant — mic-denied. Shell from GRWM-800 already has all the copy/visual logic; we just hook up trigger + alt CTA action.

UPDATE GRWMStudio/Mirror/MirrorViewModel.swift — extend startVideoRecording():

func startVideoRecording(forceNoAudio: Bool = false) async {
    let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    if !forceNoAudio && (micStatus == .denied || micStatus == .restricted) {
        coordinator.presentError(.micDenied)
        return
    }
    // ... existing recording logic, pass forceNoAudio into RecordingService
}

UPDATE GRWMStudio/Errors/ErrorRouter.swift — handleAlt for .micDenied:

case .micDenied:
    NotificationCenter.default.post(name: .recordWithoutAudio, object: nil)
    coordinator.presentedError = nil

UPDATE MirrorViewModel — observe .recordWithoutAudio:
NotificationCenter.default.addObserver(forName: .recordWithoutAudio, object: nil, queue: .main) { [weak self] _ in
    Task { await self?.startVideoRecording(forceNoAudio: true) }
}

UPDATE RecordingService.startRecording — accept withAudio Bool, pass through to DeepAR.

VERIFY:
1. Toggle mic permission OFF in Settings, return to app, attempt video record → .micDenied appears
2. Tap "Record without audio" → error dismisses, recording begins with audio track muted
3. Tap "Open Settings" → iOS Settings opens
4. Recorded video plays back with no audio in preview
````

---

## GRWM-802 — Error variant: Photo-Denied

**Goal:** Wire the `.photoDenied` variant. Triggered when user taps "Save to Camera Roll" but Photos write permission is denied.

**Prereqs:** GRWM-800, GRWM-505 (Save/Share screen), GRWM-506 (Share sheet integration).

**Files:**
- `GRWMStudio/Capture/SaveShareViewModel.swift` (update)
- `GRWMStudio/Errors/ErrorRouter.swift` (update)

**Acceptance criteria:**
- [ ] Trigger: tap "Save to Photos" on DHSaveShare → check `PHPhotoLibrary.authorizationStatus(for: .addOnly)`; if denied/restricted, fire `.photoDenied`
- [ ] CTA "Open Settings" → iOS Settings
- [ ] ALT "Keep inside GRWM" → dismisses error, returns to Save/Share screen with confirmation toast: "Saved to your Locker only"
- [ ] Tone: butter; ERROR · PHOTO-DENIED chip
- [ ] Locker save still succeeds (those are separate paths)

**Prompt:**
````
UPDATE GRWMStudio/Capture/SaveShareViewModel.swift:

func saveToPhotos() async {
    let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    switch status {
    case .denied, .restricted:
        coordinator.presentError(.photoDenied); return
    case .notDetermined:
        let new = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard new == .authorized || new == .limited else {
            coordinator.presentError(.photoDenied); return
        }
        fallthrough
    case .authorized, .limited:
        await performPhotosWrite()
    @unknown default:
        coordinator.presentError(.photoDenied)
    }
}

UPDATE ErrorRouter.handleAlt for .photoDenied → post .keepInsideGRWM, dismiss. SaveShareViewModel listens, shows toast "Saved to your Locker only" via in-screen banner.

VERIFY:
1. With Photos denied: tap Save to Photos → .photoDenied fires
2. ALT "Keep inside GRWM" → toast appears; check Locker → look saved
3. Toggle Photos to Allow → retry → image arrives in iOS Photos
4. Toast color: butter bg, INK text; auto-dismisses 2.4s
````

---

## GRWM-803 — Error variant: License + Effect-Fail

**Goal:** Wire `.license` (Pro shade tapped without entitlement) and `.effectFail` (DeepAR effect download/load failure).

**Prereqs:** GRWM-800, GRWM-301 (MirrorViewModel selectShade), GRWM-704 (Paywall).

**Files:**
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update)
- `GRWMStudio/DeepAR/EffectCatalog.swift` (update — surface load errors)
- `GRWMStudio/Errors/ErrorRouter.swift` (update)

**Acceptance criteria:**
- [ ] `.license` triggered in `selectShade(_:)` when `shade.isPro && !env.entitlements.isPro`
- [ ] CTA "See Pro Looks" → dismiss error, route to paywall (`coordinator.presentPaywall(intent: .shade(shadeId:lookId:))`)
- [ ] ALT "Pick a different shade" → dismiss only
- [ ] `.effectFail` triggered when EffectCatalog.load throws (network/asset miss). Use `coordinator.presentError(.effectFail)`
- [ ] CTA "Try again" → retries last load via `MirrorViewModel.retryLastEffect()`
- [ ] ALT "Pick another look" → dismiss + route to Looks Library
- [ ] Both variants use mint tone for effectFail, pink for license

**Prompt:**
````
UPDATE MirrorViewModel.selectShade(_:):

func selectShade(_ shade: Shade) {
    if shade.isPro && !env.entitlements.isPro {
        env.coordinator.presentError(.license)
        env.analytics.log(.shadeBlockedPro(shadeId: shade.id))
        return
    }
    Task {
        do {
            try await applyShade(shade)
            lastSuccessfulShade = shade
        } catch {
            env.coordinator.presentError(.effectFail)
            os_log(.error, log: .mirror, "applyShade failed: %{public}@", String(describing: error))
        }
    }
}

func retryLastEffect() async {
    guard let shade = lastSuccessfulShade ?? pendingShade else { return }
    await applyShade(shade)
}

UPDATE ErrorRouter.handleCTA:
case .license:
    coordinator.presentedError = nil
    coordinator.presentPaywall(intent: .shade(coordinator.lastBlockedShadeId))
case .effectFail:
    NotificationCenter.default.post(name: .retryEffectLoad, object: nil)
    coordinator.presentedError = nil

handleAlt:
case .license:
    coordinator.presentedError = nil  // user just declines
case .effectFail:
    coordinator.presentedError = nil
    coordinator.selectTab(.looks)

VERIFY:
1. Free user taps Pro shade → .license appears with correct copy + chip
2. CTA → paywall opens with `.shade` intent (verify in paywall context)
3. Force EffectCatalog to throw (rename a .deepar file) → .effectFail appears
4. CTA "Try again" → re-loads; if rename reverted, succeeds; if still missing, error reappears
5. ALT "Pick another look" → routes to Looks Library tab
````

---

## GRWM-804 — Error variant: Rec-Fail

**Goal:** Wire `.recFail` — DeepAR video recording failed mid-record or finalization failed.

**Prereqs:** GRWM-800, GRWM-110 (RecordingService), GRWM-403 (video recording flow).

**Files:**
- `GRWMStudio/DeepAR/RecordingService.swift` (update — error surface)
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update)
- `GRWMStudio/Errors/ErrorRouter.swift` (update)

**Acceptance criteria:**
- [ ] RecordingService publishes `recordingResult: Result<URL, RecordingError>` via continuation; finalize step propagates DeepAR delegate failure
- [ ] On failure, MirrorViewModel sets state = `.idle`, deletes any partial file in Documents/captures/_tmp/, fires `.recFail`
- [ ] CTA "Record again" → dismiss + reset countdown UI
- [ ] ALT "Discard" → dismiss only
- [ ] Tone: pink; chip: ERROR · REC-FAIL
- [ ] Failure also reported via OSLog .error level for debugging

**Prompt:**
````
UPDATE GRWMStudio/DeepAR/RecordingService.swift:

enum RecordingError: Error { case startFailed, finalizeFailed, diskWriteFailed }

func deepAR(_ deepAR: DeepAR!, didFinishVideoRecording videoFilePath: String!) {
    // existing success path
}

func deepAR(_ deepAR: DeepAR!, recordingFailedWithError error: Error!) {
    cleanupTmp()
    activeContinuation?.resume(throwing: RecordingError.finalizeFailed)
    activeContinuation = nil
    os_log(.error, log: .recording, "deepAR recordingFailed: %{public}@", error.localizedDescription)
}

UPDATE MirrorViewModel.startVideoRecording — wrap in try/catch:
do {
    let url = try await env.recording.record(duration: 15, withAudio: micOK)
    state = .preview(.video(url: url))
} catch {
    cleanupPartialFiles()
    state = .idle
    env.coordinator.presentError(.recFail)
}

UPDATE ErrorRouter.handleCTA for .recFail → post .retryRecording; MirrorViewModel observes and re-enters countdown.

VERIFY:
1. Force a failure (e.g., kill camera mid-record by simulating background) → .recFail appears
2. Tmp files cleaned (no orphaned _tmp_*.mp4 after error)
3. CTA "Record again" → countdown restarts at 3-2-1-RECORD
4. ALT "Discard" → returns to mirror idle
5. OSLog shows error breadcrumb at .error level
````

---

## GRWM-805 — Error variant: Save-Fail

**Goal:** Wire `.saveFail` — SwiftData write failure when saving to Locker.

**Prereqs:** GRWM-800, GRWM-501 (Save to Locker), GRWM-508 (SwiftData persistence).

**Files:**
- `GRWMStudio/Library/CaptureRepository.swift` (update — error surface)
- `GRWMStudio/Capture/PreviewViewModel.swift` (update)

**Acceptance criteria:**
- [ ] `CaptureRepository.save(_:)` throws on SwiftData failures or file copy failure
- [ ] `PreviewViewModel.saveToLocker()` catches → fires `.saveFail`
- [ ] CTA "Try again" → retry save with same model context
- [ ] ALT "Discard" → dismiss + return to mirror, tmp file deleted
- [ ] Tone: butter; chip: ERROR · SAVE-FAIL
- [ ] Sub mentions "Your last 3 looks are still safe inside the app" — reference SwiftData fallback

**Prompt:**
````
UPDATE GRWMStudio/Library/CaptureRepository.swift:

enum SaveError: Error { case copyFailed, contextFailed, capacityExceeded }

func save(_ capture: PendingCapture) async throws -> SavedCapture {
    do {
        let dest = try copyToCapturesDirectory(capture.tmpURL)
        let model = SavedCapture(id: UUID(), kind: capture.kind, fileURL: dest, createdAt: .now, lookId: capture.lookId)
        modelContext.insert(model)
        try modelContext.save()
        return model
    } catch let e as CocoaError where e.code == .fileWriteOutOfSpace {
        throw SaveError.capacityExceeded  // routes to .lowStorage in 808
    } catch {
        throw SaveError.contextFailed
    }
}

UPDATE GRWMStudio/Capture/PreviewViewModel.swift:

func saveToLocker() async {
    do {
        let saved = try await env.captures.save(pendingCapture)
        state = .saved(saved)
    } catch SaveError.capacityExceeded {
        env.coordinator.presentError(.lowStorage)
    } catch {
        env.coordinator.presentError(.saveFail)
    }
}

UPDATE ErrorRouter.handleCTA for .saveFail → post .retrySave; PreviewViewModel observes and re-runs saveToLocker().
handleAlt for .saveFail → post .discardCapture; PreviewViewModel deletes tmp + routes coordinator back to mirror.

VERIFY:
1. Mock CaptureRepository.save to throw .contextFailed → .saveFail appears
2. CTA "Try again" → re-runs save (succeeds if mock removed)
3. ALT "Discard" → tmp file deleted from Documents/captures/_tmp/, returns to mirror idle
4. ERROR · SAVE-FAIL chip visible
````

---

## GRWM-806 — Error variant: No-Face

**Goal:** Wire `.noFace` — DeepAR reports no face detected for >6 seconds during active mirror session. Note: this is the FULL-SCREEN error variant (different from the in-screen overlay from GRWM-313 which appears immediately). This shows after sustained no-face state to nudge the user.

**Prereqs:** GRWM-800, GRWM-313 (No-face overlay).

**Files:**
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — sustained timer)
- `GRWMStudio/Errors/ErrorRouter.swift` (update)

**Acceptance criteria:**
- [ ] When `isFaceDetected == false` for 6 continuous seconds, fire `.noFace`
- [ ] Timer resets on any face-detected event
- [ ] Suppress while error already presented or while in countdown/recording
- [ ] CTA "Got it" → dismiss
- [ ] ALT "Use a sample face" → dismiss + load `samples/face_a.png` into DeepAR via `loadImage(forFaceTrack:)` (DEBUG-only path; in Release, this ALT button is hidden)
- [ ] Tone: lav; chip: ERROR · NO-FACE
- [ ] Reduce Motion: skip the gentle bounce on hero

**Prompt:**
````
UPDATE MirrorViewModel:

private var noFaceTimer: Task<Void, Never>?

func onFaceDetected(_ detected: Bool) {
    isFaceDetected = detected
    if detected {
        noFaceTimer?.cancel(); noFaceTimer = nil
    } else if noFaceTimer == nil && state.allowsNoFaceNudge {
        noFaceTimer = Task { [weak self] in
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled, let self, !self.isFaceDetected else { return }
            await MainActor.run {
                if self.env.coordinator.presentedError == nil {
                    self.env.coordinator.presentError(.noFace)
                }
            }
        }
    }
}

extension MirrorState {
    var allowsNoFaceNudge: Bool {
        switch self { case .live: true; default: false }
    }
}

UPDATE ErrorVariant — add hidesAltCTAInRelease for .noFace.
UPDATE DHErrorView — when variant.hidesAltCTAInRelease && !isDebug, render only the primary CTA centered.

VERIFY:
1. Cover camera with hand → no-face overlay (313) appears immediately
2. After 6 continuous seconds → full .noFace error appears
3. Move face into frame → if error not yet shown, timer cancels
4. CTA "Got it" → dismiss; mirror returns to live; if face still absent, timer restarts
5. DEBUG build: ALT "Use a sample face" → loads bundled face_a.png; Release: ALT hidden
````

---

## GRWM-807 — Error variant: Low-Storage

**Goal:** Wire `.lowStorage` — device free space below threshold OR SwiftData reports `fileWriteOutOfSpace`.

**Prereqs:** GRWM-800, GRWM-805 (save fail surface).

**Files:**
- `GRWMStudio/Utilities/StorageMonitor.swift` (new)
- `GRWMStudio/Mirror/MirrorViewModel.swift` (update — pre-record check)
- `GRWMStudio/Capture/PreviewViewModel.swift` (already routes lowStorage from 805)
- `GRWMStudio/Errors/ErrorRouter.swift` (update)

**Acceptance criteria:**
- [ ] `StorageMonitor.availableBytes` reads `URL.fileURLWithPath(NSHomeDirectory())` resourceValues `.volumeAvailableCapacityForImportantUsageKey`
- [ ] Threshold: if available < 250 MB before record OR < 100 MB before save → fire `.lowStorage`
- [ ] CTA "Open Settings" → opens iOS Settings → General → iPhone Storage (deep link `App-Prefs:STORAGE_ICLOUD_USAGE/DEVICE_STORAGE` not allowed publicly; fall back to `UIApplication.openSettingsURLString` and copy reads "Open Settings")
- [ ] ALT "Manage Locker" → dismiss + route to Locker tab in delete mode
- [ ] Tone: pink; chip: ERROR · LOW-STORAGE
- [ ] Pre-record check runs in `MirrorViewModel.startCountdown()` before video FAB

**Prompt:**
````
CREATE GRWMStudio/Utilities/StorageMonitor.swift:

import Foundation

enum StorageMonitor {
    static var availableBytes: Int64 {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        let v = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        return v?.volumeAvailableCapacityForImportantUsage ?? 0
    }
    static let recordThreshold: Int64 = 250 * 1_000_000
    static let saveThreshold: Int64 = 100 * 1_000_000
    static var canRecord: Bool { availableBytes > recordThreshold }
    static var canSave: Bool { availableBytes > saveThreshold }
}

UPDATE MirrorViewModel.startCountdown():
guard StorageMonitor.canRecord else {
    env.coordinator.presentError(.lowStorage); return
}

UPDATE PreviewViewModel.saveToLocker — pre-check StorageMonitor.canSave; if false, present .lowStorage.

UPDATE ErrorRouter:
case .lowStorage CTA → UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!); coordinator.presentedError = nil
case .lowStorage ALT → coordinator.presentedError = nil; coordinator.selectTab(.locker); NotificationCenter.default.post(name: .lockerEnterDeleteMode, object: nil)

VERIFY:
1. Fill simulator disk to <250MB free (see Scripts/ simulate-low-disk.sh) → tap record FAB → .lowStorage appears
2. CTA → iOS Settings opens
3. ALT "Manage Locker" → Locker tab opens; delete-mode toggle is on; selecting items shows trash CTA
4. Free up space → record proceeds normally
````

---

## GRWM-808 — Error variant matrix QA + screenshots for App Store

**Goal:** Force-trigger every error variant for visual QA + capture screenshots for the App Store privacy review packet (kids category requires we document our error states).

**Prereqs:** GRWM-800 through GRWM-807.

**Files:**
- `GRWMStudio/Debug/ErrorTriggerView.swift` (new — DEBUG only)
- `GRWMStudio/Settings/DHSettings.swift` (update — DEBUG menu)
- `docs/qa/error-screenshots/` (new — output folder, gitignored)
- `Scripts/capture-error-screenshots.sh` (new)

**Acceptance criteria:**
- [ ] DEBUG-only ErrorTriggerView lists all 9 variants with "Trigger" buttons
- [ ] Compiled out in Release via `#if DEBUG`
- [ ] Settings → "Developer" section appears only in DEBUG and routes to ErrorTriggerView
- [ ] `Scripts/capture-error-screenshots.sh` boots simulator, taps each trigger, snapshots, exits
- [ ] Output: `docs/qa/error-screenshots/{variant}.png` × 9
- [ ] All 9 chips show correct text (CAM-DENIED / MIC-DENIED / PHOTO-DENIED / LICENSE / EFFECT-FAIL / REC-FAIL / SAVE-FAIL / NO-FACE / LOW-STORAGE)
- [ ] All 9 screens compared visually against `docs/design-source/v3/screens-8.jsx` DHError variants
- [ ] Snapshot tests added in GRWMStudioTests/ErrorSnapshotTests.swift to lock visuals

**Prompt:**
````
CREATE GRWMStudio/Debug/ErrorTriggerView.swift (#if DEBUG wrapped):

import SwiftUI

#if DEBUG
struct ErrorTriggerView: View {
    @Environment(AppCoordinator.self) var coordinator
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(ErrorVariant.allCases, id: \.self) { v in
                    DHButton(label: "Trigger \(v.rawValue)", kind: .ghost, size: .md) {
                        coordinator.presentError(v)
                    }
                }
            }.padding()
        }
        .background(DH.cream)
        .navigationTitle("Error trigger")
    }
}
#endif

UPDATE DHSettings — at bottom, after "About":
#if DEBUG
DHSection(title: "Developer") {
    DHRow(label: "Error trigger", icon: "🐞") { coordinator.routeTo(.errorTrigger) }
}
#endif

CREATE Scripts/capture-error-screenshots.sh:
#!/bin/bash
set -e
SCHEME="GRWMStudio"
DEVICE="iPhone 16"
OUT="docs/qa/error-screenshots"
mkdir -p "$OUT"
xcrun simctl boot "$DEVICE" || true
xcodebuild -scheme "$SCHEME" -destination "platform=iOS Simulator,name=$DEVICE" -derivedDataPath build/ -configuration Debug build install
xcrun simctl launch booted app.grwmstudio.ios
# UI test pass below taps triggers and screenshots — see GRWMStudioUITests/ErrorScreenshotsUITests.swift
xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=$DEVICE" -only-testing:GRWMStudioUITests/ErrorScreenshotsUITests
# tests use XCUIScreenshot save; we move them out:
find ~/Library/Developer/Xcode/DerivedData -name "*-Attachment.png" -newer /tmp/.last-run -exec cp {} "$OUT" \;

CREATE GRWMStudioUITests/ErrorScreenshotsUITests.swift — taps Settings → Developer → each trigger, attaches screenshot named with variant slug.

CREATE GRWMStudioTests/ErrorSnapshotTests.swift using SnapshotTesting library — 9 tests, one per variant, comparing rendered DHErrorView at iPhone 16 size.

VERIFY:
1. Build DEBUG → Settings → Developer → Error trigger menu appears with 9 buttons
2. Tap each → corresponding error renders correctly
3. Build Release → Developer section absent
4. Run capture script → 9 PNGs in docs/qa/error-screenshots/
5. Snapshot tests pass; failure on intentional change diffs visually
````

---

# Phase 10 — Polish (GRWM-850 – GRWM-857)

These tickets are global passes after all features are wired. Each touches multiple files but produces a measurable end-state.

---

## GRWM-850 — Sound effects pack + DHAudio service

**Goal:** Bundle the 20 sound effect MP3s referenced in 06-DESIGN-SYSTEM.md and implement `DHAudio` service. Hook into all interactions.

**Prereqs:** GRWM-009 (env), all interaction tickets in place.

**Files:**
- `GRWMStudio/Resources/Audio/*.mp3` (20 files — see asset list in 06)
- `GRWMStudio/UX/DHAudio.swift` (new)
- All callsites that should fire SFX: DHButton tap, DHChip tap, capture click, save success, error appear, locker swipe, etc.

**Acceptance criteria:**
- [ ] All 20 SFX bundled at <80 KB each (use `afconvert -f m4af -d aac -b 96000` if needed)
- [ ] `DHAudio.shared.play(.tapSoft / .tapHard / .shutter / .saved / .errorSoft / .lockerSwipe / ...)` API
- [ ] Uses `AVAudioPlayer` pool of 4 to avoid interrupting overlapping plays
- [ ] Respects `Settings.soundEnabled` toggle (default: true)
- [ ] Mixes with other audio (`.ambient` category, `.mixWithOthers`)
- [ ] Volume capped at 0.6 to avoid jarring playback in classrooms
- [ ] DHButton plays `.tapSoft`; DHChip plays `.tapHard`; capture FAB plays `.shutter`; save success plays `.saved`; error appearance plays `.errorSoft` (gentle, not harsh)
- [ ] Reduce Motion does NOT silence sounds (separate axis); only `Settings.soundEnabled` does

**Prompt:**
````
CREATE GRWMStudio/UX/DHAudio.swift:

import AVFoundation

enum DHSound: String, CaseIterable {
    case tapSoft, tapHard, shutter, countdownTick, countdownFinal,
         saved, recordStart, recordStop, errorSoft, lockerSwipe,
         lockerDelete, paywallReveal, sparkle1, sparkle2, sparkle3,
         confettiPop, swooshIn, swooshOut, heart, magic
    var url: URL? { Bundle.main.url(forResource: rawValue, withExtension: "mp3", subdirectory: "Audio") }
}

@MainActor
final class DHAudio {
    static let shared = DHAudio()
    private var pool: [AVAudioPlayer] = []
    private let poolSize = 4
    private var isEnabled: Bool { UserDefaults.standard.bool(forKey: "dh.sound.enabled", default: true) }

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(_ sound: DHSound) {
        guard isEnabled, let url = sound.url else { return }
        let player = pool.first(where: { !$0.isPlaying }) ?? createPlayer(for: url)
        player.url == url ? () : (player.url = url)  // pseudo; AVAudioPlayer is fixed-URL — see actual impl
        // Real impl: keep one AVAudioPlayer per sound, prepared on first hit:
        // [implementation: cache [DHSound: AVAudioPlayer] of size 20, prepareToPlay on init lazy]
        ...
    }
}

[Codex: implement the real cached-per-sound version; the pool note above is illustrative — final design is one AVAudioPlayer per DHSound, lazy-loaded, kept in a [DHSound: AVAudioPlayer] dictionary, with prepareToPlay() called once.]

UPDATE DHButton/DHChip — call DHAudio.shared.play(.tapSoft / .tapHard) on tap action.
UPDATE CaptureFAB — .shutter.
UPDATE PreviewViewModel save success — .saved.
UPDATE DHErrorView appear (.onAppear) — .errorSoft.
UPDATE Locker swipe row — .lockerSwipe / .lockerDelete.
UPDATE Paywall .onAppear — .paywallReveal.
UPDATE DHCountdown — .countdownTick on each tick, .countdownFinal at "RECORD".

VERIFY:
1. All 20 mp3 files present in Resources/Audio/, build phase copies them
2. Each interaction fires the documented sound
3. Toggle Settings → Sound off → app is silent
4. Background music in iOS continues playing while app is open (mixWithOthers)
5. Sound files <80KB each (du -sh Resources/Audio/*.mp3)
````

---

## GRWM-851 — Haptics pass (DHHaptics)

**Goal:** Replace the stub from GRWM-007 with full haptics service. Hook into all interactions.

**Prereqs:** GRWM-007.

**Files:**
- `GRWMStudio/UX/DHHaptics.swift` (replace stub)
- All interaction callsites (parallel to audio)

**Acceptance criteria:**
- [ ] API: `DHHaptics.shared.fire(.tap / .pop / .shutter / .saved / .errorSoft / .heavy)`
- [ ] Backed by `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`
- [ ] Generators prepared lazily on first use, retained for re-use
- [ ] Respects Reduce Motion (`UIAccessibility.isReduceMotionEnabled`) AND a user toggle (`Settings.hapticsEnabled` default: true)
- [ ] Same callsites as DHAudio: button=.tap, chip=.pop, capture=.shutter, save=.saved, error appear=.errorSoft, paywall purchase success=.heavy
- [ ] On non-haptic devices (iPad/iPod sim), API silently no-ops

**Prompt:**
````
REPLACE GRWMStudio/UX/DHHaptics.swift:

import UIKit

enum DHHapticKind { case tap, pop, shutter, saved, errorSoft, heavy }

@MainActor
final class DHHaptics {
    static let shared = DHHaptics()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let notification = UINotificationFeedbackGenerator()

    private var enabled: Bool {
        !UIAccessibility.isReduceMotionEnabled
        && UserDefaults.standard.bool(forKey: "dh.haptics.enabled", default: true)
    }

    init() {
        // prepare on first interaction is fine; iOS warms within ~150ms
    }

    func fire(_ kind: DHHapticKind) {
        guard enabled else { return }
        switch kind {
        case .tap: lightImpact.prepare(); lightImpact.impactOccurred()
        case .pop: mediumImpact.prepare(); mediumImpact.impactOccurred(intensity: 0.7)
        case .shutter: rigidImpact.prepare(); rigidImpact.impactOccurred()
        case .saved: notification.prepare(); notification.notificationOccurred(.success)
        case .errorSoft: notification.prepare(); notification.notificationOccurred(.warning)
        case .heavy: heavyImpact.prepare(); heavyImpact.impactOccurred()
        }
    }
}

UPDATE all callsites listed in GRWM-850 to ALSO fire DHHaptics.shared.fire(...) at the same moment.

VERIFY:
1. Each interaction fires correct haptic on physical device (iPhone 12+)
2. Toggle Settings → Haptics off → app is silent (haptically)
3. Toggle iOS Settings → Accessibility → Reduce Motion ON → app is silent
4. iPad / non-haptic device → no crash, no haptic
````

---

## GRWM-852 — Animations pass (DHAnim curves + canned transitions)

**Goal:** Codify the animation curves from 06-DESIGN-SYSTEM.md and apply consistently. Replace ad-hoc `.animation()` calls.

**Prereqs:** all UI tickets.

**Files:**
- `GRWMStudio/DesignSystem/DHAnim.swift` (new)
- All view files that animate state changes

**Acceptance criteria:**
- [ ] `DHAnim` enum with named cases: `.bouncy / .softSpring / .quickPop / .slowFade / .stickerWobble / .heroEmerge`
- [ ] Each maps to a specific `Animation` instance
- [ ] All state changes route through `withAnimation(DHAnim.bouncy.animation) { ... }`
- [ ] Reduce Motion awareness: `DHAnim.respecting(...)` returns `.linear(duration: 0.01)` when Reduce Motion is on
- [ ] Sticker wobble: `Animation.easeInOut(duration: 1.6).repeatForever(autoreverses: true)` — disabled under Reduce Motion
- [ ] Hero emerge (paywall, error): `interpolatingSpring(stiffness: 180, damping: 15)`
- [ ] Audit pass: `grep -rn "withAnimation(.spring" GRWMStudio/` returns zero hits — all replaced

**Prompt:**
````
CREATE GRWMStudio/DesignSystem/DHAnim.swift:

import SwiftUI

enum DHAnim {
    case bouncy, softSpring, quickPop, slowFade, stickerWobble, heroEmerge

    var animation: Animation {
        switch self {
        case .bouncy: .spring(response: 0.4, dampingFraction: 0.65)
        case .softSpring: .spring(response: 0.55, dampingFraction: 0.85)
        case .quickPop: .spring(response: 0.25, dampingFraction: 0.55)
        case .slowFade: .easeInOut(duration: 0.45)
        case .stickerWobble: .easeInOut(duration: 1.6).repeatForever(autoreverses: true)
        case .heroEmerge: .interpolatingSpring(stiffness: 180, damping: 15)
        }
    }

    static func respecting(_ kind: DHAnim, reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.01) : kind.animation
    }
}

extension View {
    func dhAnimation(_ kind: DHAnim, value: some Equatable) -> some View {
        // Read reduce-motion at use site
        modifier(DHAnimationModifier(kind: kind, value: value))
    }
}

struct DHAnimationModifier<V: Equatable>: ViewModifier {
    let kind: DHAnim
    let value: V
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    func body(content: Content) -> some View {
        content.animation(DHAnim.respecting(kind, reduceMotion: reduceMotion), value: value)
    }
}

REFACTOR all state-change animations:
- Old: .animation(.spring(...), value: x)
- New: .dhAnimation(.bouncy, value: x)

REFACTOR all sticker wobble:
- Old: ad-hoc rotationEffect with TimelineView
- New: .rotationEffect(...).dhAnimation(.stickerWobble, value: ...)

VERIFY:
1. Open every screen, observe consistent feel
2. Toggle Reduce Motion → all animations become near-instant; UI still updates
3. grep -rn "withAnimation(.spring" GRWMStudio → 0 hits
4. grep -rn ".animation(.spring" GRWMStudio → 0 hits
5. grep -rn ".animation(.easeInOut" GRWMStudio → 0 hits (all funneled through DHAnim)
````

---

## GRWM-853 — Accessibility pass

**Goal:** VoiceOver labels, Dynamic Type clamping, color contrast verification, hit-target audit.

**Prereqs:** all UI tickets.

**Files:**
- All view files (selective edits)
- `GRWMStudio/DesignSystem/DHFont.swift` (Dynamic Type clamp)
- `GRWMStudioTests/AccessibilitySnapshotTests.swift` (new)

**Acceptance criteria:**
- [ ] Every interactive element has `.accessibilityLabel(...)` and `.accessibilityHint(...)` where the visible label is an emoji or sticker
- [ ] DHButton — accessibilityLabel pulls from `label`, hint describes action
- [ ] DHChip — accessibilityLabel includes category + selected state
- [ ] FaceTrackingDots — `.accessibilityHidden(true)` (decorative only)
- [ ] Dynamic Type: scaled with `@ScaledMetric` up to AX2; cap chip widths via `lineLimit(2)` and `minimumScaleFactor(0.85)`
- [ ] Mirror screen: VoiceOver announces "{shade name}, {category} shade, {N} of {M}, double-tap to apply"
- [ ] All DH color combinations verified for WCAG AA contrast (using local script `Scripts/audit-contrast.swift`)
- [ ] Hit-target audit: every tappable element ≥44×44pt (snapshot test fails otherwise)
- [ ] Capture FAB labeled "Capture button. Double-tap to take photo. Triple-tap and hold to record video"
- [ ] Tab bar: each tab announces its name + selected state

**Prompt:**
````
[scope is broad — Codex performs the audit in passes]

PASS 1: Add accessibilityLabel/Hint to every interactive view.

DHButton:
.accessibilityLabel(Text(label))
.accessibilityHint(hint ?? "")
.accessibilityAddTraits(.isButton)

DHChip:
.accessibilityLabel(Text("\(label)\(isSelected ? \", selected\" : \"\")"))
.accessibilityHint(Text(hint ?? "Double-tap to choose this shade"))

FaceTrackingDots, DHWallpaper background patterns, sticker primitives:
.accessibilityHidden(true)

PASS 2: Dynamic Type clamping in DHFont:
extension DH {
    static func font(_ style: DHTextStyle) -> Font {
        // existing — but add .scaledFont(category cap to AX2):
        .custom(style.face, size: style.size, relativeTo: style.textStyle)
        // Wrap call sites with .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}

In DHRoot (or root container):
.dynamicTypeSize(...DynamicTypeSize.accessibility2)

PASS 3: Hit-target audit.
CREATE GRWMStudioTests/HitTargetTests.swift — uses SwiftUI introspect or snapshot to verify every Button/Tap area has min 44pt frame.

PASS 4: Contrast audit.
CREATE Scripts/audit-contrast.swift — Swift script iterating all DH color pairs documented in 06-DESIGN-SYSTEM.md, computes WCAG ratio, reports any <4.5:1 for body text or <3:1 for large text.

PASS 5: Mirror VoiceOver script.
In MirrorView shade tray:
.accessibilityElement(children: .combine)
.accessibilityLabel(Text("\(shade.name), \(category.rawValue) shade, \(index + 1) of \(shades.count)"))
.accessibilityHint(Text("Double-tap to apply"))

PASS 6: Tab bar.
Each tab button:
.accessibilityLabel(Text(tab.rawValue.capitalized))
.accessibilityValue(Text(currentTab == tab ? "Selected" : ""))
.accessibilityAddTraits(.isTabBar) on container

VERIFY:
1. Run app with VoiceOver on; navigate every screen; every interactive element announces sensibly
2. Set Dynamic Type to AX2 in Accessibility Inspector → no clipping or truncation visible
3. Run audit-contrast.swift → 0 failures
4. Run HitTargetTests → all pass
5. Capture FAB triple-tap-hold opens video record (separate from accessibility, but verify the audio cue is announced)
````

---

## GRWM-854 — Performance pass: 60fps mirror, memory budget, cold-start

**Goal:** Lock 60fps in mirror, ≤180MB sustained, cold-start ≤1.8s on iPhone 12 mini (lowest target).

**Prereqs:** all features.

**Files:**
- `GRWMStudio/DeepAR/DeepARController.swift` (preview resolution audit)
- `GRWMStudio/Mirror/MirrorViewModel.swift` (texture cache audit)
- `Scripts/profile-mirror.sh` (Instruments invoke)
- `GRWMStudio/App/GRWMStudioApp.swift` (cold-start audit)

**Acceptance criteria:**
- [ ] DeepAR preview at 1280×720 (NOT 1920×1080 default) — verify via DeepAR config
- [ ] Effect texture cache (UIImage) limited to 12 textures; LRU eviction
- [ ] Cold-start trace: from `application(_:didFinishLaunching)` to `MirrorView` first frame ≤1.8s on iPhone 12 mini (DEBUG); ≤1.2s Release
- [ ] Mirror sustained frame rate ≥58fps with skin+lips+eyes effects loaded; verified via `os_signpost` markers + Instruments
- [ ] Memory peak ≤220MB during recording; sustained ≤180MB idle mirror
- [ ] Splash → first frame: no main-thread sync I/O (verified by Instruments)
- [ ] All Image(uiImage:) loads on background queue with `.task` modifier
- [ ] Effect cache survives backgrounding for 60s (don't reload on quick re-foreground)

**Prompt:**
````
AUDIT GRWMStudio/DeepAR/DeepARController.swift:
- Verify CameraController.videoOrientation = .portrait
- Verify CameraController.preset = .hd1280x720 (NOT .hd1920x1080)
- If higher resolution is set, lower to 720p

CREATE GRWMStudio/DeepAR/EffectTextureCache.swift:
@MainActor final class EffectTextureCache {
    private var cache: [String: UIImage] = [:]
    private var lru: [String] = []
    private let limit = 12
    func image(for key: String, loader: @escaping () async -> UIImage?) async -> UIImage? {
        if let hit = cache[key] {
            lru.removeAll { $0 == key }; lru.append(key)
            return hit
        }
        guard let img = await loader() else { return nil }
        cache[key] = img
        lru.append(key)
        if lru.count > limit, let oldest = lru.first {
            cache.removeValue(forKey: oldest); lru.removeFirst()
        }
        return img
    }
}

REPLACE all UIImage(named:) calls for effect textures with EffectTextureCache.shared.image(for:loader:).

ADD os_signpost markers in DeepARController for: bootstrap, startCamera, loadEffect, didInitialize. Also in MirrorViewModel.applyShade.

CREATE Scripts/profile-mirror.sh:
#!/bin/bash
xcrun instruments -t "Time Profiler" -D /tmp/mirror.trace -l 30000 -p $(xcrun simctl get_app_container booted app.grwmstudio.ios) ...
[Codex: write a working invocation; alternative is to require the engineer to run Instruments manually with template guidance]

ADD scenePhase observer in GRWMStudioApp.swift:
- on .background: keep DeepAR controller alive for 60s (don't release effect cache)
- on .background after 60s (timer): release texture cache, deinit DeepARController
- on .active within 60s: warm path resumes immediately

MEASURE cold-start:
Add os_signpost intervals in App.swift `init` and MirrorView `.onAppear`. Run on iPhone 12 mini Release build, log delta. Target ≤1.2s. If exceeded, identify hottest call via Time Profiler and optimize (likely candidates: font registration, SwiftData migration, splash asset load).

VERIFY:
1. Instruments Time Profiler: cold-start ≤1.2s Release (≤1.8s Debug) on iPhone 12 mini
2. Instruments Allocations: peak ≤220MB during 15s record; idle ≤180MB
3. Instruments Core Animation FPS: 58–60fps in mirror with effects loaded
4. Backgrounding for 30s and returning: mirror resumes instantly (no DeepAR re-bootstrap)
5. Backgrounding for 90s: scene returns; DeepAR re-bootstraps cleanly
````

---

## GRWM-855 — Empty states, skeleton loaders, edge-case copy

**Goal:** Ensure every loading/empty/error state is visually polished — no spinners, no system fonts, all on-brand.

**Prereqs:** all UI tickets.

**Files:**
- All View files with potential async data
- `GRWMStudio/DesignSystem/DHSkeleton.swift` (new)

**Acceptance criteria:**
- [ ] No `ProgressView()` system spinners anywhere (use DHSkeleton or animated sticker)
- [ ] Loading mirror: shows `DHSpinner` (animated chunky pink ring with sparkle) — defined in DesignSystem
- [ ] Locker loading: shows 6 placeholder DHCard skeletons with shimmer
- [ ] Feed loading: shows 4 placeholder mosaic items with shimmer
- [ ] Looks Library loading: shows 6 placeholder look cards
- [ ] Empty Locker → DHSavedEmpty (already exists)
- [ ] Empty Looks Library → "No looks yet" copy with sticker hero
- [ ] Empty Feed (network fail + no cache) → friendly copy + "Try again" CTA
- [ ] Skeleton shimmer: linear gradient pinkPaper→cream→pinkPaper, 1.4s loop
- [ ] All copy reviewed for kid-friendly tone (no "Failed", "Error", "Crash" — use "hiccup", "didn't load", "try again 💕")

**Prompt:**
````
CREATE GRWMStudio/DesignSystem/DHSkeleton.swift:

import SwiftUI

struct DHSkeleton: View {
    let shape: AnyShape
    @State private var phase: CGFloat = -1
    var body: some View {
        shape
            .fill(LinearGradient(
                colors: [DH.pinkPaper, DH.cream, DH.pinkPaper],
                startPoint: UnitPoint(x: phase, y: 0.5),
                endPoint: UnitPoint(x: phase + 0.6, y: 0.5)
            ))
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
            .accessibilityHidden(true)
    }
}

struct DHSpinner: View {
    @State private var rotation: Double = 0
    var body: some View {
        ZStack {
            Circle().stroke(DH.pinkPaper, lineWidth: 6).frame(width: 48, height: 48)
            Circle().trim(from: 0.1, to: 0.7).stroke(DH.pink, style: StrokeStyle(lineWidth: 6, lineCap: .round)).frame(width: 48, height: 48)
                .rotationEffect(.degrees(rotation))
            Text("✨").font(.system(size: 18))
        }
        .onAppear { withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) { rotation = 360 } }
        .accessibilityLabel(Text("Loading"))
    }
}

REPLACE all ProgressView() in app:
- MirrorView loading state → DHSpinner
- Locker loading → ForEach(0..<6) { DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 24))) }
- Feed loading → mosaic skeletons
- Looks Library loading → look card skeletons

EMPTY STATE COPY AUDIT (run grep + manual review):
- "Failed" → "had a hiccup"
- "Error" → "something hiccuped"
- "Crash" → never used
- "Network unavailable" → "Couldn't reach the internet"
- All caps: only ERROR chip in DHErrorView; nowhere else

VERIFY:
1. Disable network → Feed shows skeleton then friendly empty state with "Try again" — no system spinner
2. Tap into Locker on first launch → 6 skeleton cards then DHSavedEmpty
3. Tap Mirror cold → DHSpinner shows for ≤1.5s during DeepAR bootstrap
4. grep -rn "ProgressView" GRWMStudio → 0 hits in production code (test fixtures okay)
5. All loading transitions feel intentional and on-brand
````

---

## GRWM-856 — Localization scaffolding (English-only ship, Spanish-ready strings)

**Goal:** Externalize all user-facing strings into Localizable.strings (en) for v1; structure for adding `es` in v1.1 without code changes.

**Prereqs:** all UI tickets.

**Files:**
- `GRWMStudio/Resources/en.lproj/Localizable.strings` (new)
- All view files (replace hardcoded strings with `String(localized:)`)
- `Scripts/check-localization.sh` (new)

**Acceptance criteria:**
- [ ] Every user-visible string moved to Localizable.strings (en)
- [ ] Use String Catalog (`.xcstrings`) format — Xcode 15+ native
- [ ] Keys grouped by feature: `mirror.shade.label`, `errors.cam_denied.title`, `paywall.cta.subscribe`, etc.
- [ ] All `Text("literal")` replaced with `Text("key")` resolving via String Catalog
- [ ] Pluralization rules in catalog (e.g., locker count: "1 look" / "%lld looks")
- [ ] DEBUG: `Scripts/check-localization.sh` greps for `Text("[A-Z][^"]*"` outside `# preview` macros — should return 0 hits
- [ ] Localizable.xcstrings has empty `es` translations placeholder (will be filled in v1.1)
- [ ] No string concatenation: use `String(format:)` or interpolation with localized format strings only

**Prompt:**
````
CREATE GRWMStudio/Resources/Localizable.xcstrings (Xcode String Catalog).

[Codex: enumerate all user-facing strings across the codebase. Group by feature folder. Format: "feature.subfeature.purpose" key.]

EXAMPLES:
- onboarding.welcome.title = "Welcome to GRWM Studio 💕"
- onboarding.welcome.cta = "Get Started"
- mirror.fab.capture_label = "Capture"
- mirror.shade.label = "%@" (parameterized — shade name)
- errors.cam_denied.title = "The mirror can't see you 💕"
- errors.cam_denied.sub = "Camera access was turned off..."
- errors.cam_denied.cta = "Open Settings"
- errors.cam_denied.alt = "I'll do it later"
- paywall.feature.unlimited_recording = "Unlimited recording"
- locker.empty.title = "Your Locker is empty"
- locker.count = "%lld looks" (with one="1 look")

REFACTOR every Text("literal") and Button label to use String(localized: "key").
For SwiftUI: Text("key") resolves automatically against String Catalog.

CREATE Scripts/check-localization.sh:
#!/bin/bash
HITS=$(grep -rn 'Text("[A-Z][^"]*"' GRWMStudio --include="*.swift" | grep -v "// preview" | grep -v "_PreviewProvider" | wc -l)
if [ "$HITS" -gt 0 ]; then
  echo "❌ Found $HITS hardcoded user-facing strings:"
  grep -rn 'Text("[A-Z][^"]*"' GRWMStudio --include="*.swift" | grep -v "// preview" | grep -v "_PreviewProvider"
  exit 1
fi
echo "✅ No hardcoded strings"

ADD this script to .githooks/pre-commit and CI.

VERIFY:
1. Build with -e xcstrings → no missing-key warnings
2. Switch device language to Spanish (es) → app stays English (es entries empty) — no crashes
3. Scripts/check-localization.sh → 0 hits
4. Strings catalog covers all user-facing copy from JSX mockups
5. Plural counts work: change Locker count from 0 → 1 → 5; copy reads "0 looks" → "1 look" → "5 looks"
````

---

## GRWM-857 — Final visual QA against design pack

**Goal:** Pixel-level review of every screen against `docs/design-source/v3/*.jsx`. Capture before/after screenshots; lock with snapshot tests.

**Prereqs:** all phases.

**Files:**
- `docs/qa/screen-comparisons/` (new — output)
- `Scripts/screenshot-all-screens.sh` (new — uses XCUITest)
- `GRWMStudioTests/ScreenSnapshotTests.swift` (new — 33 tests)

**Acceptance criteria:**
- [ ] Snapshot tests for all 33 screens at iPhone 16 size, light mode, AX0 type
- [ ] Each test compares against committed reference PNG in `GRWMStudioTests/__Snapshots__/`
- [ ] Visual diff tool report (using SnapshotTesting) included in PR template
- [ ] Manual side-by-side review docs/qa/screen-comparisons/{screen}.png (left: JSX render; right: app render)
- [ ] Comments on any pixel deltas >2pt — must either justify or fix
- [ ] All 33 screens reviewed and signed off (checkbox in PR)
- [ ] Color values verified hex-perfect (no "close enough")
- [ ] Font sizes verified (Fredoka 24/32/48 only; Quicksand 12/14/16/18 only)
- [ ] Sticker placements verified ±2pt
- [ ] Shadow offsets verified (chunkyShadow 7-9pt offset, 0pt blur for solid layer)

**Prompt:**
````
CREATE GRWMStudioTests/ScreenSnapshotTests.swift (using SnapshotTesting library):

import XCTest
import SnapshotTesting
@testable import GRWMStudio

final class ScreenSnapshotTests: XCTestCase {
    override class func setUp() {
        // isRecording = true to capture references; flip to false to verify
    }

    func test_DHSplash() {
        let view = DHSplash()
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
    }

    func test_DHWelcome() { ... }
    func test_DHParentInfo() { ... }
    func test_DHPermissions() { ... }
    func test_DHPermissionsDenied() { ... }
    func test_DHMirror_Skin() { ... }
    func test_DHMirror_Base() { ... }
    func test_DHMirror_Eyes() { ... }
    func test_DHMirror_Brows() { ... }
    func test_DHMirror_Cheeks() { ... }
    func test_DHMirror_Lips() { ... }
    func test_DHMirror_Looks() { ... }
    func test_DHMirrorCountdown() { ... }
    func test_DHMirrorRecording() { ... }
    func test_DHMirrorProGate() { ... }
    func test_DHPreviewIdle_Photo() { ... }
    func test_DHPreviewIdle_Video() { ... }
    func test_DHPreviewSaved() { ... }
    func test_DHSaveShare() { ... }
    func test_DHLooks_Library() { ... }
    func test_DHLookDetail() { ... }
    func test_DHTutorial() { ... }
    func test_DHSavedEmpty() { ... }
    func test_DHSavedAtLimit() { ... }
    func test_DHLockerGrid() { ... }
    func test_DHLockerDetail() { ... }
    func test_DHProfile() { ... }
    func test_DHFeed() { ... }
    func test_DHParentMath() { ... }
    func test_DHParentHold() { ... }
    func test_DHPaywall() { ... }
    func test_DHSettings() { ... }
    func test_DHError_All9() { ... }  // includes all 9 variants

    // ~33 total tests
}

CREATE Scripts/screenshot-all-screens.sh:
#!/bin/bash
xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:GRWMStudioTests/ScreenSnapshotTests
# After first pass with isRecording=true, snapshots commit to __Snapshots__/
# All future runs verify against committed PNGs.

CREATE docs/qa/screen-comparisons/README.md — documents the visual review process; engineer captures both JSX render (via headless React render) and app screenshot, places side-by-side, marks any >2pt deltas.

VERIFY:
1. Run snapshot tests: all 33 pass on first commit
2. Make an intentional 1pt color change → test fails with diff
3. Revert change → test passes
4. Side-by-side comparisons in docs/qa/screen-comparisons/ for all 33 screens, each annotated with engineer initials and date
5. PR template links to comparison folder; reviewer checks each screen
````

---

# Phase 11 — Testing (GRWM-900 – GRWM-906)

These tickets stitch together the test surfaces that grew alongside features.

---

## GRWM-900 — Unit test pass: ViewModels + services

**Goal:** ≥80% line coverage on all ViewModels and services. Each VM's state machine has explicit test cases for every transition.

**Prereqs:** all features.

**Files:**
- `GRWMStudioTests/MirrorViewModelTests.swift`
- `GRWMStudioTests/PreviewViewModelTests.swift`
- `GRWMStudioTests/CaptureRepositoryTests.swift`
- `GRWMStudioTests/EffectCatalogTests.swift`
- `GRWMStudioTests/StoreServiceTests.swift`
- `GRWMStudioTests/PermissionsServiceTests.swift`
- `GRWMStudioTests/SettingsServiceTests.swift`

**Acceptance criteria:**
- [ ] Each ViewModel test file: ≥1 test per state transition (idle → loading → live → preview → saved, error paths included)
- [ ] DeepARController is mocked via protocol injection — actual SDK never invoked in tests
- [ ] Permissions service mocked — tests cover all 4 statuses (notDetermined / authorized / denied / restricted)
- [ ] StoreKit 2 tests use `StoreKit Testing` framework with `Configuration.storekit` file
- [ ] EffectCatalog tests parse the actual production manifest.json
- [ ] CaptureRepository tests use `ModelContainer(for: ..., configurations: .init(isStoredInMemoryOnly: true))`
- [ ] Coverage gate: scheme runs `xcodebuild test -enableCodeCoverage YES`; CI fails if line coverage <80% on `GRWMStudio/Mirror/`, `GRWMStudio/Capture/`, `GRWMStudio/Library/`, `GRWMStudio/Commerce/`
- [ ] No flaky tests: 50 consecutive runs in CI must be 100% green

**Prompt:**
````
CREATE GRWMStudioTests/MirrorViewModelTests.swift:

import XCTest
@testable import GRWMStudio

@MainActor
final class MirrorViewModelTests: XCTestCase {
    var sut: MirrorViewModel!
    var mockCoordinator: MockAppCoordinator!
    var mockEffectCatalog: MockEffectCatalog!
    var mockEntitlements: MockEntitlements!

    override func setUp() async throws {
        mockCoordinator = MockAppCoordinator()
        mockEffectCatalog = MockEffectCatalog()
        mockEntitlements = MockEntitlements()
        sut = MirrorViewModel(env: AppEnv.mock(coordinator: mockCoordinator, effectCatalog: mockEffectCatalog, entitlements: mockEntitlements))
    }

    func test_initial_state_is_idle() { XCTAssertEqual(sut.state, .idle) }

    func test_start_transitions_to_loading_then_live() async {
        await sut.start()
        XCTAssertEqual(sut.state, .live)
    }

    func test_selectShade_proShadeWithoutEntitlement_presentsLicenseError() {
        let proShade = Shade.fixture(isPro: true)
        sut.selectShade(proShade)
        XCTAssertEqual(mockCoordinator.lastError, .license)
    }

    func test_selectShade_proShadeWithEntitlement_appliesShade() async {
        mockEntitlements.isPro = true
        let proShade = Shade.fixture(isPro: true)
        sut.selectShade(proShade)
        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertEqual(mockEffectCatalog.lastApplied, proShade.id)
    }

    func test_selectShade_effectCatalogThrows_presentsEffectFailError() async {
        mockEffectCatalog.shouldThrow = true
        sut.selectShade(.fixture())
        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertEqual(mockCoordinator.lastError, .effectFail)
    }

    func test_noFace_for6seconds_presentsNoFaceError() async {
        await sut.start()
        sut.onFaceDetected(false)
        try? await Task.sleep(for: .seconds(7))
        XCTAssertEqual(mockCoordinator.lastError, .noFace)
    }

    func test_noFace_lessThan6seconds_doesNotPresentError() async {
        await sut.start()
        sut.onFaceDetected(false)
        try? await Task.sleep(for: .seconds(3))
        XCTAssertNil(mockCoordinator.lastError)
    }

    // ... at least 12 more transitions covered

    func test_pauseOnBackground_stopsCamera_cachesEffect() async { ... }
    func test_resumeOnForeground_within60s_doesNotReBootstrap() async { ... }
    func test_resumeOnForeground_after60s_reBootstraps() async { ... }
    func test_camDenied_atRuntime_presentsCamDeniedError() async { ... }
    // etc.
}

[Codex: write equivalent test files for PreviewViewModelTests, CaptureRepositoryTests, EffectCatalogTests, StoreServiceTests, PermissionsServiceTests, SettingsServiceTests. Each ≥10 tests. Use protocol mocks defined in GRWMStudioTests/Mocks/.]

CREATE GRWMStudioTests/Mocks/ folder with:
- MockAppCoordinator.swift
- MockEffectCatalog.swift
- MockEntitlements.swift
- MockDeepARController.swift  (conforms to DeepARControlling protocol — must define this protocol in source)
- MockPermissionsService.swift
- MockStoreService.swift
- MockCaptureRepository.swift

UPDATE source: every service consumed by VMs must be a protocol so it can be mocked.

UPDATE .github/workflows/ci.yml:
- Run xcodebuild test with -enableCodeCoverage YES
- Use xcresulttool to extract coverage; fail job if <80% on critical folders
- Run test scheme 5 times in matrix to catch flakiness

VERIFY:
1. xcodebuild test → all tests pass
2. Coverage report shows ≥80% on Mirror/, Capture/, Library/, Commerce/
3. Run tests 50 times via Scripts/test-flake.sh → 0 failures
4. CI matrix runs tests on iPhone 16, 16 Pro Max, 12 mini → all green
````

---

## GRWM-901 — UI test pass: critical user journeys

**Goal:** XCUITest coverage of the 8 critical journeys end-to-end.

**Prereqs:** GRWM-900.

**Files:**
- `GRWMStudioUITests/CriticalJourneysUITests.swift`
- `GRWMStudioUITests/Helpers/UITestHarness.swift`
- `Scripts/run-uitests.sh`

**Acceptance criteria:**
- [ ] Eight journey tests:
  1. Cold launch → onboarding (5 steps) → mirror → take photo → save to locker → verify in locker
  2. Cold launch (returning user) → mirror directly → swap shades across all 7 categories → no errors
  3. Mirror → tap Pro shade → license error → CTA "See Pro Looks" → paywall → close
  4. Mirror → record 15s video (mock — use 3s in tests via `UITEST_OVERRIDE_RECORD_DURATION=3`) → preview plays → save → locker
  5. Mirror → permissions denied → cam-denied error → "I'll do it later" → mirror disabled state visible
  6. Looks Library → tap a Pro look → look detail → "Get Pro" → paywall
  7. Locker → swipe to delete → confirm → entry removed; pull-to-refresh shows correct count
  8. Settings → toggle sound off → return to mirror → tap shade → no audio plays
- [ ] Each test uses Page-Object pattern via `MirrorPage`, `OnboardingPage`, etc.
- [ ] Tests run on iPhone 16 simulator; CI matrix adds 12 mini and 16 Pro Max
- [ ] Mock DeepAR via launch arg `UITEST_MOCK_DEEPAR=1` — prevents real camera/license calls
- [ ] Total UI test runtime ≤6 minutes on M2 Mac

**Prompt:**
````
CREATE GRWMStudioUITests/Helpers/UITestHarness.swift:
- Sets up XCUIApplication with launchArguments: ["UITEST_MOCK_DEEPAR", "UITEST_OVERRIDE_RECORD_DURATION=3", "UITEST_RESET_ONBOARDING"]
- App reads these in AppEnv.bootstrap and substitutes mocks accordingly

CREATE GRWMStudioUITests/Pages/ (page objects):
- OnboardingPage: tapWelcomeContinue(), enterParentEmail(_:), tapAllowCamera(), etc.
- MirrorPage: selectCategory(_:), selectShade(named:), tapCaptureFAB(), holdCaptureFAB(seconds:), expectShadeApplied(named:)
- PreviewPage: tapSaveToLocker(), tapShare(), expectSavedConfirmation()
- LockerPage: expectCount(_:), swipeDelete(at:), confirmDelete()
- PaywallPage: tapSubscribeMonthly(), tapClose(), tapRestore()
- SettingsPage: toggleSound(), toggleHaptics(), tapManageSubscription()

CREATE GRWMStudioUITests/CriticalJourneysUITests.swift:

import XCTest

final class CriticalJourneysUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = UITestHarness.boot(resetState: true)
    }

    func test_journey1_onboarding_to_first_save() throws {
        OnboardingPage(app: app).tapWelcomeContinue().enterParentEmail("p@example.com").tapContinue().tapAllowCamera().tapAllowMic().tapAllowPhotos()
        let mirror = MirrorPage(app: app)
        mirror.expectIdleVisible()
        mirror.selectCategory(.skin).selectShade(named: "Honey").expectShadeApplied(named: "Honey")
        mirror.tapCaptureFAB()
        let preview = PreviewPage(app: app)
        preview.expectVisible().tapSaveToLocker().expectSavedConfirmation()
        TabBarPage(app: app).tapLocker()
        LockerPage(app: app).expectCount(1)
    }

    // 7 more journeys...
}

CREATE Scripts/run-uitests.sh:
#!/bin/bash
set -e
SIMS=("iPhone 16" "iPhone 12 mini" "iPhone 16 Pro Max")
for sim in "${SIMS[@]}"; do
    echo "▶ Running UI tests on $sim"
    xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=$sim" -only-testing:GRWMStudioUITests | xcbeautify
done

VERIFY:
1. All 8 journeys pass on iPhone 16
2. Matrix passes on 12 mini + 16 Pro Max
3. Total runtime ≤6 minutes
4. No flakiness over 20 consecutive runs
5. Failure on intentional regression (e.g., break locker count) produces clear error
````

---

## GRWM-902 — Snapshot test infrastructure (lock to design)

**Goal:** SnapshotTesting library wired; CI fails on visual regressions.

**Prereqs:** GRWM-857 (Final visual QA).

**Files:**
- `Package.swift` (add SnapshotTesting dependency via SwiftPM if using Tuist; otherwise Xcode project SPM)
- `GRWMStudioTests/SnapshotTestCase.swift`
- `GRWMStudioTests/__Snapshots__/` (committed PNGs)
- `.github/workflows/ci.yml`

**Acceptance criteria:**
- [ ] SnapshotTesting v1.17+ added via SwiftPM
- [ ] Base class `SnapshotTestCase` with default config (light mode, AX0, iPhone 16)
- [ ] All 33 screens have snapshot tests (from GRWM-857)
- [ ] All 9 error variants have snapshot tests (from GRWM-808)
- [ ] All 12 DH primitive states have snapshot tests (DHButton 4 sizes × 5 kinds, etc.)
- [ ] CI runs snapshot tests; failure produces diff PNG attached to job artifacts
- [ ] LFS pointer files in __Snapshots__/ for binary PNGs (lfs already configured for .png in GRWM-007/repo bootstrap)
- [ ] PR template includes "Snapshot diffs reviewed" checkbox

**Prompt:**
````
ADD to Package.swift dependencies (if SPM-managed) or via Xcode → File → Add Packages:
.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0")

CREATE GRWMStudioTests/SnapshotTestCase.swift:

import XCTest
import SnapshotTesting

class SnapshotTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        // diffTool = "ksdiff"  // optional: enable Kaleidoscope diff
        // isRecording = true   // set to true once to record references
    }

    func assertScreen<V: View>(_ view: V, named: String? = nil, file: StaticString = #filePath, function: String = #function, line: UInt = #line) {
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone16), traits: .init(userInterfaceStyle: .light)), named: named, file: file, function: function, line: line)
    }
}

[Codex: ensure all GRWM-857 screen snapshots, GRWM-808 error snapshots, and DH primitive snapshots inherit from SnapshotTestCase.]

ADD .github/workflows/ci.yml step:
- name: Run snapshot tests
  run: |
    set -e
    xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:GRWMStudioTests/ScreenSnapshotTests -only-testing:GRWMStudioTests/ErrorSnapshotTests -only-testing:GRWMStudioTests/PrimitiveSnapshotTests | xcbeautify
- name: Upload snapshot diffs on failure
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: snapshot-diffs
    path: '**/FailureDiff*.png'

UPDATE .gitattributes:
GRWMStudioTests/__Snapshots__/*.png filter=lfs diff=lfs merge=lfs -text

VERIFY:
1. First commit with isRecording=true → all snapshots saved as PNG references
2. Second run with isRecording=false → all pass
3. Intentional break (change pink hex) → fails with FailureDiff PNG showing red overlay
4. Revert → passes
5. CI artifacts contain diff PNGs on failure
````

---

## GRWM-903 — Performance regression tests

**Goal:** Lock cold-start, mirror FPS, memory peak via measure() blocks. CI fails on regression.

**Prereqs:** GRWM-854.

**Files:**
- `GRWMStudioTests/PerformanceTests.swift`
- `Scripts/run-perftests.sh`

**Acceptance criteria:**
- [ ] `XCTOSSignpostMetric` for cold-start (App init → MirrorView .onAppear)
- [ ] `XCTApplicationLaunchMetric` baseline on iPhone 16 simulator
- [ ] `XCTMemoryMetric` for mirror with 3 effects loaded
- [ ] `XCTClockMetric` for shade tap → visual change (target ≤80ms p50, ≤120ms p99)
- [ ] Baselines committed; deviation >10% fails CI
- [ ] Tests run in matrix on iPhone 12 mini (lowest target) and iPhone 16 (typical)
- [ ] Recording perf test: `measure { startVideoRecord(3s); stop }` — must complete <3.5s

**Prompt:**
````
CREATE GRWMStudioTests/PerformanceTests.swift:

import XCTest

final class PerformanceTests: XCTestCase {
    func test_appLaunch_performance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func test_mirrorBootstrap_signpost() throws {
        let metric = XCTOSSignpostMetric(subsystem: "app.grwmstudio.ios.mirror", category: "lifecycle", name: "bootstrap")
        measure(metrics: [metric]) {
            // Programmatically construct MirrorViewModel and call start()
            // Use protocol mocks to keep test self-contained
        }
    }

    func test_shadeApply_clockMetric() {
        let vm = MirrorViewModel(env: .mock())
        measure(metrics: [XCTClockMetric()]) {
            let exp = expectation(description: "shadeApplied")
            vm.selectShade(.fixture(named: "Honey"))
            // wait for vm.appliedShadeId update
            vm.$appliedShadeId.sink { id in if id == "honey" { exp.fulfill() } }
            wait(for: [exp], timeout: 1)
        }
    }

    func test_recording_clockMetric() {
        // measure 3s recording end-to-end, with mocked DeepAR
    }

    func test_mirrorMemory_metric() {
        measure(metrics: [XCTMemoryMetric()]) {
            // Bootstrap mirror, apply 3 effects, hold 5 seconds
        }
    }
}

COMMIT baseline measurements (Xcode auto-creates xcbaselines/ folder). Set deviation threshold to 10%.

UPDATE .github/workflows/ci.yml:
- name: Performance regression
  run: |
    xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=iPhone 12 mini" -only-testing:GRWMStudioTests/PerformanceTests | xcbeautify

VERIFY:
1. Baselines exist in xcbaselines/
2. CI runs perf tests on each PR
3. Intentional regression (insert sleep(0.5) in MirrorViewModel.start) → CI fails with metric breakdown
4. Revert → passes
````

---

## GRWM-904 — Accessibility regression tests

**Goal:** Lock VoiceOver labels, hit-target sizes, contrast ratios via automated tests.

**Prereqs:** GRWM-853.

**Files:**
- `GRWMStudioTests/AccessibilityTests.swift`
- `Scripts/audit-contrast.swift` (already exists from 853)

**Acceptance criteria:**
- [ ] `XCUIElement.isHittable` checked for every interactive element across all screens
- [ ] All `accessibilityLabel`s asserted non-empty for buttons/chips
- [ ] All decorative elements asserted `accessibilityHidden == true`
- [ ] Hit-target test: every button frame ≥44×44pt verified via XCUITest `.frame.size`
- [ ] Contrast script run as part of test suite; failure on any pair <4.5:1 (body) or <3:1 (large)
- [ ] Dynamic Type test: launches app at AX2, asserts no clipping (using snapshot diff against AX2 baselines)
- [ ] VoiceOver navigation test: simulates swipe-right traversal of mirror screen, asserts announce order matches expected

**Prompt:**
````
CREATE GRWMStudioTests/AccessibilityTests.swift:

import XCTest

final class AccessibilityTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        app = UITestHarness.boot()
    }

    func test_allButtons_haveNonEmptyAccessibilityLabel() {
        // navigate each screen, query buttons, assert label.isEmpty == false
    }

    func test_allTabBarButtons_meetMinHitTarget() {
        let tabs = app.buttons.matching(identifier: "tabbar.").allElementsBoundByIndex
        for tab in tabs {
            XCTAssertGreaterThanOrEqual(tab.frame.width, 44)
            XCTAssertGreaterThanOrEqual(tab.frame.height, 44)
        }
    }

    func test_decorativeStickers_areAccessibilityHidden() {
        let stickers = app.images.matching(identifier: "sticker.").allElementsBoundByIndex
        for s in stickers {
            XCTAssertFalse(s.isHittable)  // decorative
        }
    }

    func test_dynamicType_AX2_noClipping() {
        // boot with launchArg UITEST_DYNAMIC_TYPE=AX2
        // navigate each screen, screenshot, compare against AX2 baseline
    }

    func test_voiceOverOrder_mirrorScreen() {
        // Use accessibility activation point traversal
    }
}

ADD CI step:
- name: Contrast audit
  run: swift Scripts/audit-contrast.swift
- name: Accessibility tests
  run: xcodebuild test -only-testing:GRWMStudioTests/AccessibilityTests

VERIFY:
1. All a11y tests pass on iPhone 16
2. Removing accessibilityLabel from any button → test fails
3. Reducing hit target below 44pt → test fails
4. Contrast audit catches any new color pair below threshold
5. AX2 dynamic type → no truncation visible
````

---

## GRWM-905 — Localization parity tests (English-only ship)

**Goal:** Verify all user-facing strings come from String Catalog; no hardcoded text leaks.

**Prereqs:** GRWM-856.

**Files:**
- `GRWMStudioTests/LocalizationTests.swift`
- `Scripts/check-localization.sh` (already exists from 856)

**Acceptance criteria:**
- [ ] Test asserts every screen's visible text resolves through the String Catalog
- [ ] Build phase script runs `check-localization.sh` and fails build on hardcoded strings
- [ ] Pseudo-locale test: launches app with `-AppleLanguages "(zz_Pseudo)"`, captures snapshots, verifies strings expand without breaking layout
- [ ] Empty `es` translations don't crash app on language switch

**Prompt:**
````
CREATE GRWMStudioTests/LocalizationTests.swift:

import XCTest

final class LocalizationTests: XCTestCase {
    func test_allUserFacingStrings_inCatalog() throws {
        let catalogURL = Bundle(for: type(of: self)).url(forResource: "Localizable", withExtension: "xcstrings")!
        let data = try Data(contentsOf: catalogURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let strings = (json["strings"] as! [String: Any]).keys
        // Snapshot a known set of expected keys (from a frozen list updated per release)
        let required: Set<String> = ["onboarding.welcome.title", "errors.cam_denied.cta", "paywall.cta.subscribe", /* ...full list... */]
        for k in required { XCTAssertTrue(strings.contains(k), "Missing key: \(k)") }
    }

    func test_pseudoLocale_layoutDoesNotBreak() {
        // launchArg: -AppleLanguages "(zz_Pseudo)"
        // Apple's pseudo-locale doubles string length; assert no clipping via snapshot diff
    }
}

ADD as Xcode Run Script Build Phase (in main target):
"$SRCROOT/Scripts/check-localization.sh" || exit 1

VERIFY:
1. Insert a hardcoded Text("Click me") somewhere → build fails with check-localization script
2. Remove → build succeeds
3. Pseudo-locale snapshot test passes (no layout breaks)
4. Switching device to Spanish → app shows English fallback (no missing-key crashes)
````

---

## GRWM-906 — Manual QA matrix (test plan deliverable)

**Goal:** Documented manual QA pass before each TestFlight build. Owner: lead engineer (you).

**Prereqs:** all phases.

**Files:**
- `docs/qa/MANUAL-QA-MATRIX.md` (new)
- `docs/qa/CHECKLISTS/` (per-build checklists)

**Acceptance criteria:**
- [ ] Documented matrix: device × scenario × pass/fail
- [ ] Devices: iPhone 12 mini (lowest), iPhone 14, iPhone 16, iPhone 16 Pro Max
- [ ] Scenarios: cold start, all 5 onboarding paths, all 7 categories, all 33 screens, all 9 errors, all 4 perms states, Pro purchase, Pro restore, Pro cancellation
- [ ] Network conditions: offline, 3G (Network Link Conditioner), wifi
- [ ] Battery: low-power mode test, background app refresh test
- [ ] Time/locale: device set to French, Japanese, Hindi (English fallback expected)
- [ ] Output: filled checklist signed by tester before TestFlight ship

**Prompt:**
````
CREATE docs/qa/MANUAL-QA-MATRIX.md (full matrix in markdown table):

[See file 08-TESTING-PLAN.md for the canonical text — this ticket links there.]

CREATE docs/qa/CHECKLISTS/TEMPLATE.md (copy-paste-fill template for each build):

# Manual QA Build {VERSION} ({DATE}) — {TESTER}

## Devices tested
- [ ] iPhone 12 mini (iOS 17.x)
- [ ] iPhone 14 (iOS 18.x)
- [ ] iPhone 16 (iOS 18.x)

## Critical paths
- [ ] Cold start ≤2s
- [ ] Onboarding 5 screens (no skip)
- [ ] Mirror — 7 categories, 3 shades each
- [ ] Capture photo → save → locker
- [ ] Capture video 15s → preview → save → share to Photos
- [ ] All 9 errors triggered via Settings → Developer
- [ ] Pro purchase (StoreKit sandbox)
- [ ] Pro restore on second device

[full template — see 08-TESTING-PLAN.md]

VERIFY:
1. Filled checklist exists for each TestFlight build in docs/qa/CHECKLISTS/v{N}.md
2. Matrix covers all dimensions before submission
3. Sign-off field visible at bottom
````

---

# Phase 12 — Launch (GRWM-950 – GRWM-957)

App Store readiness — kids category review prep, privacy manifest, marketing assets, submission process.

---

## GRWM-950 — Privacy manifest (PrivacyInfo.xcprivacy)

**Goal:** Complete required PrivacyInfo.xcprivacy reflecting all SDKs and APIs used. Required for App Store submission.

**Prereqs:** all SDK integrations final.

**Files:**
- `GRWMStudio/Resources/PrivacyInfo.xcprivacy`
- `docs/privacy/PRIVACY-MANIFEST.md` (rationale doc)

**Acceptance criteria:**
- [ ] Manifest declares NSPrivacyTracking = false
- [ ] NSPrivacyCollectedDataTypes = empty array (we collect nothing)
- [ ] NSPrivacyAccessedAPITypes covers: UserDefaults (CA92.1), FileTimestamp (C617.1), DiskSpace (E174.1)
- [ ] DeepAR SDK's PrivacyInfo verified compatible (third-party SDK manifests bundled with their package)
- [ ] No tracking domains in NSPrivacyTrackingDomains (empty array)
- [ ] Validates with `xcrun --sdk iphoneos privacy-validation` (Xcode 15.4+)
- [ ] App Store Connect privacy questionnaire matches manifest exactly
- [ ] Document in PRIVACY-MANIFEST.md why we declare each API category

**Prompt:**
````
CREATE GRWMStudio/Resources/PrivacyInfo.xcprivacy (plist format):

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array><string>CA92.1</string></array>
        </dict>
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
    </array>
</dict>
</plist>

ADD to Xcode target → Build Phases → Copy Bundle Resources.

CREATE docs/privacy/PRIVACY-MANIFEST.md:

# Privacy manifest rationale

## NSPrivacyTracking: false
We do not engage in tracking as defined by Apple. No third-party tracking SDKs.

## NSPrivacyCollectedDataTypes: empty
We collect zero personally identifiable data. Parent emails (entered during onboarding) are SHA-256 hashed locally and stored only in iOS Keychain. They never leave the device in v1.

## NSPrivacyAccessedAPITypes
- UserDefaults (CA92.1 — "App functionality"): for storing in-app preferences (sound on/off, haptics on/off, last-seen onboarding step). Not used for tracking.
- FileTimestamp (C617.1 — "App functionality"): captures stored in Documents/captures/ track createdAt for sorting in Locker.
- DiskSpace (E174.1 — "App functionality"): pre-flight check before recording/saving to surface .lowStorage error.

## DeepAR SDK
DeepAR ships with its own PrivacyInfo.xcprivacy bundled in the framework. Verified contents: declares Camera and Microphone usage; no tracking; no data collection beyond on-device face landmarks.

VERIFY:
1. Build → no privacy validation errors
2. Archive → Validate → no privacy warnings
3. xcrun --sdk iphoneos privacy-validation /path/to/build → "Privacy manifest valid"
4. App Store Connect submission privacy questionnaire matches manifest 100%
````

---

## GRWM-951 — Made for Kids App Store category prep

**Goal:** Configure the app for the Kids category (ages 6–8 OR 9–11; we choose 6–8 for tightest review). Strict requirements: no third-party advertising, no third-party analytics, no UGC sharing, parental gate for purchases, links must lead only to App Store/parent info.

**Prereqs:** All commerce + parent gate tickets.

**Files:**
- App Store Connect (browser configuration — see 03-COMMANDS.md §3)
- `docs/launch/KIDS-CATEGORY-COMPLIANCE.md` (new)

**Acceptance criteria:**
- [ ] App Store Connect → Kids Age Band: 6–8 selected
- [ ] No third-party SDKs except DeepAR (which is on-device CV — no network calls except license validation)
- [ ] Parent gate (math + hold) is enforced for: paywall, settings → manage subscription, share-to-Photos, external links
- [ ] No social features in v1 (Feed is curated, read-only)
- [ ] No "rate this app" prompt
- [ ] No web links in app → exception: parent-info screen has "Apple's Family Sharing" link, gated behind parent gate
- [ ] Privacy nutrition label = "Data Not Collected" (matches PrivacyInfo)
- [ ] Compliance doc in docs/launch/KIDS-CATEGORY-COMPLIANCE.md tracking each requirement vs evidence

**Prompt:**
````
This ticket is mostly process + manual configuration. Codex implements the in-app pieces; engineer handles ASC.

CONFIRM in code:
- All third-party imports: ONLY DeepAR. Run `grep -rn "import " GRWMStudio --include="*.swift" | grep -v "import Foundation\|import SwiftUI\|import UIKit\|import AVFoundation\|import StoreKit\|import SwiftData\|import Photos\|import CoreImage\|import OSLog\|import DeepAR" | sort -u`. Result must be empty.

CONFIRM parent gate enforcement:
- coordinator.presentPaywall — check coordinator.parentGateRequired = true
- DHSettings → Manage Subscription — wraps in parentGate
- DHSaveShare → Save to Photos — wraps in parentGate (per Kids category rules, sharing to other apps requires gate)
- Any tappable link to web — wraps in parentGate

REMOVE if present:
- Any "rate this app" prompts (StoreKit SKStoreReviewController)
- Any "share to social" features beyond explicit Save to Photos

CREATE docs/launch/KIDS-CATEGORY-COMPLIANCE.md:

# Kids Category Compliance (Apple)

| Requirement | Status | Evidence |
|-------------|--------|----------|
| No third-party advertising | ✅ | Zero ad SDKs (verified by import audit script) |
| No third-party analytics | ✅ | Zero analytics SDKs (only OSLog, on-device) |
| No behavioral tracking | ✅ | PrivacyInfo NSPrivacyTracking=false |
| Parental gate for purchases | ✅ | Math + hold gate (GRWM-700/701/702) before paywall |
| Parental gate for external links | ✅ | parentGate wraps all UIApplication.open calls |
| No UGC sharing | ✅ | Feed is curated/read-only; no upload feature |
| Age band declared | ✅ | 6–8 in App Store Connect |
| Privacy nutrition label | ✅ | "Data Not Collected" |
| COPPA compliance | ✅ | No PII transmission; parent email SHA-256 hashed locally |
| Family Sharing support | ✅ | StoreKit 2 default behavior |

VERIFY:
1. Import audit → only DeepAR + system frameworks
2. All gated paths verified manually
3. App Store Connect age band set to 6–8
4. Privacy nutrition label submitted
5. Compliance doc complete and signed
````

---

## GRWM-952 — App Store metadata + screenshots

**Goal:** All App Store Connect text fields filled, screenshots captured, app icon delivered.

**Prereqs:** GRWM-951.

**Files:**
- `docs/launch/APP-STORE-METADATA.md` (master copy)
- `docs/launch/screenshots/` (output)
- `Scripts/generate-store-screenshots.sh` (new)

**Acceptance criteria:**
- [ ] App name: "GRWM Studio"
- [ ] Subtitle: "Sparkly mirror for kids" (≤30 chars)
- [ ] Description (≤4000 chars) drafted in metadata doc
- [ ] Keywords (≤100 chars): "kids,makeup,mirror,filters,beauty,glam,studio,fashion,dress up,girls"
- [ ] Promotional text (≤170 chars)
- [ ] App icon 1024×1024 (PNG, no alpha) — based on GRWMLogo from design pack
- [ ] iPhone screenshots: 6.7" (iPhone 16 Pro Max) and 6.5" (iPhone 14 Plus) — 4 each minimum, 10 max
- [ ] Screenshots captured via XCUITest screenshot script
- [ ] Each screenshot annotated with branded chunky-pink frame + caption (e.g., "Try every shade ✨")
- [ ] All copy reviewed for COPPA compliance (no language implying social/competitive features)
- [ ] No mention of "tracking", "ads", "social", "share with friends" in any copy
- [ ] Support URL: built-in (about:blank-quality acceptable for v1; or single static page on grwmstudio.app)

**Prompt:**
````
CREATE docs/launch/APP-STORE-METADATA.md:

# App Store metadata — GRWM Studio v1.0

## App name
GRWM Studio

## Subtitle (30 char max)
Sparkly mirror for kids

## Promotional text (170 char max)
Get ready with sparkly makeup magic! Tap, swipe, and pose with shades that move with your face. Save your fave looks to your private Locker. ✨

## Description (4000 char max)
[draft 4 paragraphs covering: what it does, how it works, what's free vs Pro, parental controls, privacy stance]

## Keywords (100 char max, no spaces between commas)
kids,makeup,mirror,filters,beauty,glam,studio,fashion,dressup,girls

## Categories
Primary: Entertainment
Secondary: Lifestyle
Age band: 6–8

## App Privacy
Data Not Collected (verified against PrivacyInfo.xcprivacy)

## Support URL
https://grwmstudio.app/support  [single static page; engineer to set up]

## Marketing URL
https://grwmstudio.app

CREATE Scripts/generate-store-screenshots.sh:
#!/bin/bash
# Boots simulator, runs screenshot UI test, post-processes with branded frame
xcodebuild test -scheme GRWMStudio -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" -only-testing:GRWMStudioUITests/StoreScreenshotsUITests
# Move screenshots, apply chunky-pink frame via Sips/ImageMagick

CREATE GRWMStudioUITests/StoreScreenshotsUITests.swift:
- 6 hero screens to capture: Mirror w/ shade, Mirror w/ Pro look, Locker grid, Save/Share, Looks Library, Paywall
- Each takes XCUIScreen.main.screenshot() → attaches with name "store_{slug}.png"

DELIVER app icon 1024×1024 — engineer designs based on GRWMLogo from design pack (centered logo on radial pink-to-cream gradient, with chunky shadow). PNG, no alpha channel (Apple rejects with alpha).

VERIFY:
1. All ASC fields fillable from APP-STORE-METADATA.md
2. Screenshots in docs/launch/screenshots/ folder, all 6 captured at 6.7"
3. App icon valid (no alpha) — verify with `sips -g hasAlpha icon-1024.png`
4. Description scanned for forbidden phrases (no "social", "share with friends", "track", "ads")
````

---

## GRWM-953 — Crash & metric collection (on-device only)

**Goal:** Local crash logs viewable for testers via Settings → Developer (DEBUG) and via TestFlight integration. NO third-party crash SDK (Sentry/Crashlytics) — kids category.

**Prereqs:** GRWM-953 standalone (final touches before launch).

**Files:**
- `GRWMStudio/Diagnostics/CrashRingBuffer.swift` (new — symbolicated last-run crash log)
- `GRWMStudio/Settings/DHSettings.swift` (update — DEBUG-only crash log viewer)

**Acceptance criteria:**
- [ ] No third-party crash SDK
- [ ] iOS native MetricKit MXMetricManager subscriber writes recent metrics to ~/Library/Diagnostics/grwm-metrics.json
- [ ] DEBUG: Settings → Developer → "View last metrics" shows JSON
- [ ] Production: TestFlight + App Store Connect crash logs are the only telemetry sink
- [ ] No PII in any logged crash payload (verified via grep audit)

**Prompt:**
````
CREATE GRWMStudio/Diagnostics/MetricSubscriber.swift:

import Foundation
import MetricKit

@MainActor final class MetricSubscriber: NSObject, MXMetricManagerSubscriber {
    static let shared = MetricSubscriber()
    private let queue = DispatchQueue(label: "metrics", qos: .utility)
    private var fileURL: URL { URL.documentsDirectory.appending(path: "metrics.json") }

    func start() {
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        queue.async { [weak self] in
            guard let self else { return }
            do {
                var existing: [Data] = (try? Data(contentsOf: self.fileURL).chunked()) ?? []
                for payload in payloads {
                    existing.append(payload.jsonRepresentation())
                }
                let combined = try JSONSerialization.data(withJSONObject: existing.compactMap { try? JSONSerialization.jsonObject(with: $0) })
                try combined.write(to: self.fileURL, options: .atomic)
            } catch {
                os_log(.error, "metrics write failed: %@", error.localizedDescription)
            }
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        // Same: append diagnostic payloads to local file. NO network transmission.
    }
}

CALL MetricSubscriber.shared.start() in GRWMStudioApp.init.

UPDATE DHSettings — DEBUG-only:
#if DEBUG
DHRow(label: "View metrics", icon: "📊") { showMetricsViewer = true }
#endif

CREATE MetricsViewerView (DEBUG only) — pretty-prints metrics.json contents.

VERIFY:
1. App runs for 24h on TestFlight device → metrics.json populated
2. Settings → Developer → View metrics → readable JSON
3. Force a crash (DEBUG button: fatalError) → next launch, MetricKit payload contains crash details
4. grep -rn "Sentry\|Crashlytics\|Bugsnag\|Firebase" GRWMStudio → 0 hits
5. App Store Connect crash logs populate after TestFlight builds with crashes
````

---

## GRWM-954 — TestFlight rollout plan

**Goal:** Document staged rollout: internal (5 testers) → beta (50 parents) → public ship.

**Prereqs:** All testing tickets green.

**Files:**
- `docs/launch/TESTFLIGHT-PLAN.md` (new)
- `Fastfile` (lane updates — uses fastlane pilot)

**Acceptance criteria:**
- [ ] Internal group: 5 hand-picked engineers + designers — daily builds for 1 week
- [ ] External group "Parents Beta": 50 invited parents (kids ages 6–12) — 2-week beta
- [ ] Beta survey form linked in app: Settings → "Send feedback" (DEBUG path; in beta builds only via #if BETA)
- [ ] Crash-free rate threshold: ≥99.5% over beta period before submission
- [ ] At least one full-week beta on iOS 17 (lowest target)
- [ ] Beta build expiration auto-set to 90 days
- [ ] Build metadata: `What to test` field describes new features per build

**Prompt:**
````
CREATE docs/launch/TESTFLIGHT-PLAN.md (process doc — see 09-LAUNCH-CHECKLIST.md for canonical)

UPDATE fastlane/Fastfile:

lane :beta do
  increment_build_number(xcodeproj: "GRWMStudio.xcodeproj")
  build_app(scheme: "GRWMStudio", configuration: "Release", export_method: "app-store")
  upload_to_testflight(
    skip_waiting_for_build_processing: false,
    distribute_external: true,
    groups: ["Parents Beta"],
    notify_external_testers: true,
    changelog: ENV["BETA_CHANGELOG"] || "Bug fixes and improvements"
  )
end

lane :release do
  ensure_git_status_clean
  ensure_git_branch(branch: "main")
  build_app(scheme: "GRWMStudio", configuration: "Release", export_method: "app-store")
  upload_to_app_store(
    submit_for_review: true,
    automatic_release: false,
    force: true,
    skip_screenshots: true,  # use docs/launch/screenshots/ via separate deliver lane
    submission_information: { add_id_info_uses_idfa: false, content_rights_contains_third_party_content: false }
  )
end

VERIFY:
1. fastlane beta uploads to TestFlight → build appears in App Store Connect
2. Parents Beta group receives invite emails
3. Crash-free rate visible in App Store Connect Analytics
4. fastlane release submits → ASC shows "Waiting for Review" status
````

---

## GRWM-955 — App Review pre-submission checklist

**Goal:** Self-audit against Apple's review guidelines for Kids category. Catch issues before submission.

**Prereqs:** GRWM-954.

**Files:**
- `docs/launch/APP-REVIEW-CHECKLIST.md` (canonical in 09-LAUNCH-CHECKLIST.md)

**Acceptance criteria:**
- [ ] Manually walk every guideline relevant to Kids category (Apple guidelines 1.3, 5.1.4, 5.2)
- [ ] Verify no in-app browser opens to non-Apple sites
- [ ] Verify no Sign In With Apple redirects (we have no accounts)
- [ ] Verify all auto-renewable subscriptions show: title, price, duration, what's included, terms link, privacy link, EULA link
- [ ] Verify EULA link in paywall (or use Apple's standard EULA)
- [ ] Verify "Restore Purchases" visible in paywall AND settings
- [ ] No mentions of "Apple", "iPhone", "iOS" in app copy (per guideline 2.3)
- [ ] First-launch parental info screen documented
- [ ] Demo account NOT required (no login system)
- [ ] Reviewer notes drafted: "App is for kids ages 6–12. Parental gate (math + hold) gates all purchases and external actions. No data leaves the device. To test Pro: tap any sparkle on Mirror, complete parent gate (any single-digit math answer), select monthly subscription. Use sandbox tester per ASC settings."

**Prompt:**
````
CREATE docs/launch/APP-REVIEW-CHECKLIST.md (see 09-LAUNCH-CHECKLIST.md for full body — the checklist is the deliverable)

UPDATE GRWMStudio/Commerce/DHPaywall.swift — verify all required disclosures visible:
- "Auto-renews monthly. Cancel anytime in Settings."
- "Privacy Policy" link → opens parent gate → opens Safari to grwmstudio.app/privacy
- "Terms" link → opens parent gate → opens Safari to grwmstudio.app/terms (or Apple's standard EULA)
- "Restore Purchases" button visible

UPDATE DHSettings — add "Restore Purchases" row in Subscription section.

DRAFT App Review notes (in ASC submission form):
"GRWM Studio is a kids' AR makeup app. Sandbox test: tap Mirror → tap any sparkle ⭐ on a shade → complete parent gate (math: any answer) → select Monthly. Subscription is Apple-managed. Restore: Settings → Restore Purchases. No accounts; no PII collected; all data stays on device."

VERIFY:
1. Walk through paywall as fresh user — all required text visible
2. Restore Purchases works in both paywall and settings
3. No 'Apple', 'iPhone', 'iOS' phrasing in user-facing copy (grep audit)
4. Reviewer notes saved in ASC submission draft
````

---

## GRWM-956 — Final regression + smoke test before submission

**Goal:** One final 4-hour pass on production build (Release config, real device, real DeepAR license, real StoreKit sandbox).

**Prereqs:** GRWM-955.

**Files:**
- `docs/launch/FINAL-SMOKE-{DATE}.md` (filled checklist)

**Acceptance criteria:**
- [ ] Production Release build installed on iPhone 12 mini AND iPhone 16
- [ ] All 8 critical journeys (from GRWM-901) executed manually
- [ ] All 9 errors triggered manually
- [ ] Sandbox subscription purchased + restored on second device
- [ ] App goes through 24-hour idle on device — no crashes, no excessive memory
- [ ] Final battery drain check: 30 minutes active use ≤8% battery
- [ ] Final cold-start verification: ≤1.5s on iPhone 12 mini
- [ ] Filled checklist signed off

**Prompt:**
````
This is a manual ticket. No code changes unless smoke test surfaces a regression.

EXECUTE the full GRWM-906 manual QA matrix on production builds.

EXECUTE these stress tests:
- Background/foreground 50 times in mirror — no leak
- Take 100 photos consecutively — no leak; locker shows last 50 (clamped)
- Record 20 videos consecutively — disk usage stable; old tmp files cleaned
- Apply all 50+ shades in 5-min session — no FPS drop
- Toggle between mirror and locker 30 times — clean transitions

FILL docs/launch/FINAL-SMOKE-{DATE}.md (template in 09-LAUNCH-CHECKLIST.md).

If any P0 or P1 bug found, FIX before submission. Re-run final smoke after fix.

VERIFY:
1. Filled checklist with engineer sign-off and timestamp
2. Zero P0 or P1 bugs open
3. Production build cold-start ≤1.5s on iPhone 12 mini (verified once more)
4. Memory peak ≤220MB during full session (verified via Instruments)
````

---

## GRWM-957 — Submit to App Review

**Goal:** Submit production build to App Review.

**Prereqs:** GRWM-956 signed off.

**Files:**
- ASC submission form (browser)
- Internal release-notes draft

**Acceptance criteria:**
- [ ] Build uploaded via `fastlane release` (or manual archive + upload)
- [ ] All ASC fields complete: metadata, screenshots, app icon, age rating, privacy nutrition, kids category, content rights, EULA, support URL
- [ ] Reviewer demo notes attached
- [ ] Submission status: "Waiting for Review"
- [ ] Internal Slack/email notification with submission link
- [ ] Watch for review feedback within 48 hours
- [ ] Have plan for likely rejection reasons (kids category strictness): doc with response templates in `docs/launch/REJECTION-PLAYBOOK.md`

**Prompt:**
````
EXECUTE submission:

1. Run `fastlane release` from main branch with clean working tree
2. ASC → My Apps → GRWM Studio → 1.0 → Submit for Review
3. Confirm answers:
   - Export Compliance: Uses standard encryption only (HTTPS) → Yes
   - Content Rights: Does NOT contain, show, or access third-party content → Yes (DeepAR is on-device CV; no third-party content delivered)
   - Advertising Identifier: Does NOT use IDFA → Yes
4. Hit Submit

CREATE docs/launch/REJECTION-PLAYBOOK.md:

# Likely rejection reasons (Kids category) + responses

## "Kids category apps must have parental gate before purchases"
We do — math + hold gate (GRWM-700/701/702). Provide screen recording showing flow. Reviewer notes already include this.

## "Subscription disclosures incomplete"
Fix in next build: ensure title/price/duration/what's-included/terms/privacy/EULA all visible above subscribe CTA.

## "App tracks user behavior"
We do not. PrivacyInfo NSPrivacyTracking=false. Demonstrate that no network calls happen during normal use (provide Wireshark capture).

## "Demo content insufficient"
Provide additional clarifying notes; offer to set up a screen-share demo with reviewer (rare but possible).

[5 more anticipated objections with responses]

VERIFY:
1. ASC shows "Waiting for Review" → "In Review" → "Pending Developer Release" or "Approved" or "Rejected"
2. If rejected, identify category, look up playbook entry, respond within 24h
3. If approved, manually release (we set automatic_release: false in fastlane to control timing)
4. Post-release: monitor App Store reviews + crash dashboard daily for first 2 weeks
````

---

# End of ticket pack

Total: **111 tickets** across **13 phases**, written for direct ingestion by Codex.

Each ticket includes: goal, prereqs, files touched, acceptance checklist, copy-pasteable prompt body. Order is dependency-correct — work top-to-bottom.

Phase summary:
- Phase 0 Bootstrap (10): empty Xcode project to splash
- Phase 1 DeepAR foundation (11): SDK install through recording service
- Phase 2 Onboarding (6): all 5 screens + router + tab shell
- Phase 3 Mirror (16): hero mirror flow + 4 mirror screens + capture services
- Phase 4 Capture/Preview (6): preview, save, share
- Phase 5 Library/Locker (11): grid, detail, library, look detail, persistence
- Phase 6 Profile/Feed (6): 3 screens + Feed networking + tutorial
- Phase 7 Commerce (11): parent gate + paywall + StoreKit + entitlement
- Phase 8 Settings (2): full settings + manage subscription
- Phase 9 Errors (9): all 9 error variants individually
- Phase 10 Polish (8): a11y, haptics, sounds, animation, perf, empty states, l10n, visual QA
- Phase 11 Testing (7): unit, UI, snapshot, perf, a11y, l10n, manual matrix
- Phase 12 Launch (8): privacy manifest, kids compliance, ASC metadata, telemetry, TestFlight, review prep, smoke, submit
