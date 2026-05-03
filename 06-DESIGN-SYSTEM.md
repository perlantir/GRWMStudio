# 06 — Design System

The V01 Dreamhouse Plastic visual language, codified for SwiftUI. Reference document — Codex prompts cite specific subsections.

---

## 1. Philosophy

Everything looks **moulded out of pink plastic with a wet shine.** Buttons have chunky offset shadows that mimic a stamped toy. Text has thick white strokes with deep-pink drop shadows like sticker labels. Backgrounds use repeating diagonal stripes or soft pink gradients. Stickers (hearts, sparkles, bows) decorate negative space.

Three core moves applied to every interactive element:

1. **Two-layer shadow** — a solid offset color block (the "stamp") + a soft blur underneath
2. **Translate up 1–2pt when selected** — gives a satisfying tactile-press inverse
3. **Heavy white inner highlights / outer strokes** — the wet plastic gloss

Reference for every token: `docs/design-source/v3/dh-screens-1.jsx` (the `DH` JS object) and `docs/design-source/v3/v01-mirror.jsx`.

---

## 2. Color tokens

Mirror exactly to `DesignSystem/DH+Tokens.swift` enum `DH`:

| Token | Hex | Use |
|-------|-----|-----|
| `pink` | `#FF3DA5` | primary brand pink |
| `pinkDeep` | `#D4127B` | shadow color, primary text on light, deep accents |
| `pinkLight` | `#FFB8DC` | light pink for soft fills, gradients |
| `pinkPaper` | `#FFE5F2` | the "wallpaper" pink — most screen backgrounds |
| `cream` | `#FFF6FA` | secondary off-white for stripes, cards |
| `butter` | `#FFD66B` | yellow accent (hot badges, sparkle highlights) |
| `butterDeep` | `#C99B1F` | butter shadow color |
| `lavender` | `#C9A8FF` | secondary purple (eyeshadow swatches, alt accents) |
| `lavenderDeep` | `#7A53C9` | lavender shadow |
| `mint` | `#A8E8C8` | tertiary mint (used sparingly) |
| `ink` | `#3A0E25` | the deepest text color (titles on butter/mint) |
| `recRed` | `#FF2D5A` | recording state red |
| `recRedDeep` | `#B41540` | recording state red shadow |

All colors defined as static `Color` constants. Mirror set in `Assets.xcassets` for any system-tint use cases.

**Don't add new colors without explicit scope expansion.** The palette is closed.

---

## 3. Typography

Two families:

- **Fredoka** — display, brand, big titles, button labels (weights: Regular 400, Medium 500, SemiBold 600, Bold 700)
- **Quicksand** — supporting body and labels (weights: Medium 500, SemiBold 600, Bold 700)

Fonts ship as TTF files in `Resources/Fonts/`. Registered in Info.plist `UIAppFonts` array AND defensively at runtime via `CTFontManagerRegisterGraphicsFont`.

### 3.1 Type scale

| Style | Font | Size | Tracking | Use |
|-------|------|------|----------|-----|
| `display1` | Fredoka-Bold | 96pt | -0.02em | Splash logo |
| `display2` | Fredoka-Bold | 48pt | -0.02em | Hero headlines on onboarding |
| `display3` | Fredoka-Bold | 32pt | -0.02em | Screen headlines (Looks Locker, etc.) |
| `headline` | Fredoka-Bold | 22pt | -0.01em | Card titles, shade name (e.g., "Showtime") |
| `body` | Quicksand-Medium | 14pt | 0 | Default body copy |
| `bodyEmphasis` | Quicksand-Bold | 14pt | 0.02em | Emphasized body |
| `caption` | Fredoka-SemiBold | 11pt | 0.16em | Labels (e.g., "SHADE №007") |
| `microLabel` | Fredoka-SemiBold | 9pt | 0.32em | Tiny tracked labels (e.g., "SAVED") |
| `buttonSmall` | Fredoka-Bold | 12pt | 0.02em | sm/md button labels |
| `buttonLarge` | Fredoka-Bold | 18pt | 0.02em | lg/xl button labels |

Implement as `DH.Font.style(_:)` returning `Font`:

```swift
extension DH {
    enum TypeStyle {
        case display1, display2, display3, headline,
             body, bodyEmphasis, caption, microLabel,
             buttonSmall, buttonLarge
    }
    static func font(_ style: TypeStyle) -> Font { /* ... */ }
}
```

### 3.2 Dynamic Type

- All `body` and below scale up to AX2.
- `display1`/`display2`/`display3`/`headline` cap at `xLarge` (they're already big; AX scaling breaks layouts).
- `caption` and `microLabel` don't scale — their tracked-out look depends on fixed size.
- Override per-text via `.dynamicTypeSize(...DynamicTypeSize.xLarge)` modifiers in views.

---

## 4. Shadow language

The signature "plastic stamp" effect. **Two layers:**

1. **Solid offset block** — same width as the element, offset down by 4–6pt, in the `deep` color
2. **Soft blur** — wider drop shadow with 25–40% alpha of `deep`

Sizes:

| Size | Solid offset | Blur radius | Blur Y |
|------|-------------|-------------|--------|
| `sm` | 3pt | 10pt | 5pt |
| `md` | 4pt | 14pt | 7pt |
| `lg` | 6pt | 26pt | 12pt |

Implementation in `DH+ChunkyShadow.swift`:

```swift
extension View {
    func chunkyShadow(_ shadow: DH.ChunkyShadow) -> some View {
        modifier(ChunkyShadowModifier(shadow: shadow))
    }
}

struct ChunkyShadowModifier: ViewModifier {
    let shadow: DH.ChunkyShadow

    func body(content: Content) -> some View {
        content
            .background(
                content
                    .foregroundStyle(shadow.solidColor)
                    .offset(y: shadow.solidOffset)
                    .blur(radius: 0)
            )
            .shadow(color: shadow.blurColor,
                    radius: shadow.blurRadius,
                    x: 0, y: shadow.blurY)
    }
}
```

**Note:** the "background of self offset down" trick only works if the content has a defined shape. For arbitrary content, fall back to drawing a `RoundedRectangle` of matching corner radius below.

For SwiftUI Shape-based components (DHButton, DHCard, DHChip), the implementation uses a `ZStack` with two shapes:

```swift
ZStack {
    // Solid offset stamp behind
    RoundedRectangle(cornerRadius: cornerRadius)
        .fill(shadow.solidColor)
        .offset(y: shadow.solidOffset)
    // Foreground (the actual element)
    foreground
}
.shadow(color: shadow.blurColor, radius: shadow.blurRadius, x: 0, y: shadow.blurY)
```

---

## 5. Radii

| Token | Value | Use |
|-------|------|-----|
| `chip` | 17 | DHChip pill |
| `card` | 24 | DHCard default |
| `bigCard` | 32 | Hero cards (permissions hero) |
| `button` | half-of-height | DHButton (height 36/46/56/64 → radius 18/23/28/32) |
| `viewport` | 36 | Mirror outer frame |
| `viewportInner` | 28 | Mirror inner clip |
| `swatch` | 24 | Shade gumball circles |
| `tile` | 22 | LookTile in library grid |

---

## 6. Wallpaper backgrounds

Two recurring patterns:

### 6.1 Diagonal stripes

```swift
struct DHWallpaperStripes: View {
    var primary: Color = DH.pinkPaper
    var secondary: Color = DH.cream
    var stripeWidth: CGFloat = 24
    var opacity: Double = 0.7

    var body: some View {
        Canvas { ctx, size in
            // Draw 45° stripes manually via Canvas (more performant than overlapping shapes)
        }
        .opacity(opacity)
    }
}
```

CSS reference from `v01-mirror.jsx`:
```
background: repeating-linear-gradient(45deg, #FFE5F2 0 24px, #FFF6FA 24px 48px)
opacity: 0.7
```

### 6.2 Soft gradient

```swift
LinearGradient(
    gradient: Gradient(stops: [
        .init(color: DH.pinkPaper, location: 0),
        .init(color: DH.cream, location: 0.6),
    ]),
    startPoint: .top, endPoint: .bottom
)
```

Used on most non-Mirror screens.

### 6.3 Radial highlight (mirror viewport)

```swift
RadialGradient(
    gradient: Gradient(colors: [Color(hex: 0xFFE0EE), Color(hex: 0xFFB3D9)]),
    center: .center, startRadius: 0, endRadius: 240
)
```

---

## 7. Stickers

Five sticker primitives, each implemented as a SwiftUI `Shape` (not a raster). Source paths in `docs/design-source/v3/grwm-shared.jsx`.

| Sticker | SVG path or composition | Default fill | Default stroke |
|---------|------------------------|--------------|----------------|
| `StickerHeart` | `M16 28S2 19 2 11a6 6 0 0111-3 6 6 0 0111 3c0 8-14 17-14 17z` | `pink` | `white`, 2.5 |
| `StickerStar` | `M16 2l4 9 10 1-7 7 2 10-9-5-9 5 2-10-7-7 10-1z` | `butter` | `white`, 2.5 |
| `StickerSparkle` | `M12 2l2 7 7 2-7 2-2 7-2-7-7-2 7-2z` | `white` | none |
| `StickerFlower` | 8 outer petals + center | `pink` (petals), `butter` (center) | `white`, 2 |
| `StickerBow` | 2 triangles + center ellipse | `pinkLight` | `white`, 2 |

All take `size: CGFloat`, `fill: Color`, `stroke: Color`, `strokeWidth: CGFloat`. Animate via `.stickerBob()` modifier (6pt vertical translation, 2s easeInOut yoyo) — respects Reduce Motion.

### 7.1 GRWMLogo

A composed view (text + heart + STUDIO subtitle), not a Shape. Two layouts:

- `.stack` — big, hero use (Splash, Welcome). "GRWM" on top, heart in upper-right corner of GRWM, "STUDIO" tracked below.
- `.row` — single line for top bars. "GRWM" + heart + "STUDIO" inline.

Per `grwm-shared.jsx`:
- "GRWM" in Fredoka-Bold, color `pink`, with `WebkitTextStroke 4px white` (translate to `.foregroundStyle(.white).background(text in pink, offset down for shadow)` — see DHButton ticket for the shadow trick on text)
- Drop shadow: `0 7px 0 pinkDeep, 0 12px 22px rgba(197,24,122,0.4)`
- "STUDIO" in Fredoka-Bold, color `pinkDeep`, letter-spacing `0.32em`

---

## 8. Components

Codified in `DesignSystem/`. Each has a SwiftUI `#Preview` that renders all variants.

### 8.1 `DHButton`

```swift
struct DHButton: View {
    let title: String
    var kind: Kind = .primary
    var size: Size = .md
    var leadingIcon: AnyView? = nil
    var trailingIcon: AnyView? = nil
    var isFullWidth: Bool = false
    let action: () -> Void

    enum Size { case sm, md, lg, xl }
    enum Kind { case primary, white, butter, lavender, ghost }
}
```

| Size | Height | H-pad | Font size | Radius |
|------|--------|-------|-----------|--------|
| sm | 36 | 14 | 12 | 18 |
| md | 46 | 18 | 14 | 23 |
| lg | 56 | 22 | 16 | 28 |
| xl | 64 | 28 | 18 | 32 |

| Kind | bg | text | shadow color |
|------|-----|------|-------------|
| primary | `pink` | white | `pinkDeep` |
| white | white | `pinkDeep` | `pink` |
| butter | `butter` | `ink` | `butterDeep` |
| lavender | `lavender` | white | `lavenderDeep` |
| ghost | `white.opacity(0.55)` | `pinkDeep` | `pinkDeep.opacity(0.25)` |

Tap behavior: `DHHaptics.tapMedium()` on press, scale to 0.97 then back.

### 8.2 `DHCard`

```swift
struct DHCard<Content: View>: View {
    var bg: Color = .white
    var deep: Color = DH.pink
    var cornerRadius: CGFloat = DH.Radius.card
    var padding: CGFloat = 16
    @ViewBuilder var content: () -> Content
}
```

Shadow size: `.md`. Pass any `bg` / `deep` from the palette.

### 8.3 `DHChip`

```swift
struct DHChip: View {
    let title: String
    var selected: Bool = false
    var leadingIcon: AnyView? = nil
    let action: () -> Void
}
```

Height 34, radius 17. Selected: white bg with `pink` shadow; unselected: white at 50% with no shadow. Selected translates up 1pt. Tap: `DHHaptics.tap()`.

### 8.4 `DHTabBar`

```swift
struct DHTabBar: View {
    @Binding var selected: DHTab
    let onFABTap: () -> Void
}
enum DHTab: String, CaseIterable, Hashable {
    case mirror, looks, fab, feed, locker
}
```

Floats 18pt off bottom, 14pt left/right inset. Height 74. Radius 37. Five tabs; FAB is the visual center. The FAB is a 70pt circle with white border, pink fill, "+" SF Symbol, sized larger so it pops above the bar visually. Tab content is icon-on-top, label-below; selected = `pinkDeep` color, unselected = `pinkDeep.opacity(0.55)`.

### 8.5 Tracking dots (`FaceTrackingDots`)

Animated overlay on the mirror viewport showing 17 face landmark dots that pulse. Per `grwm-shared.jsx`. Respects Reduce Motion.

```swift
struct FaceTrackingDots: View {
    var color: Color = .white.opacity(0.55)
    private let points: [CGPoint] = [/* 17 normalized 0–1 coordinates from the JSX */]
}
```

This is a **decorative** overlay — DeepAR's actual face tracking happens internally. We never expose real landmark coordinates. The dots are aesthetic.

---

## 9. Iconography

Default: SF Symbols where they match the design.

Custom Swift Path icons (drawn inline) for the 5 cases SF Symbols can't match:

- The signal-bars status bar icon
- The chunky tab bar icons (heart-with-flower, mirror-with-line, etc.) — the design has bespoke shapes that don't quite match SF Symbols
- The plastic camera illustration (Permissions hero)
- The face tracking dots ring
- The custom record button square inner icon

For all five, paths come from the source JSX. Codex prompts include the exact SVG paths to translate.

For everything else (back arrow, share, search, gear, etc.), use SF Symbols with weight `.semibold` and `pinkDeep` tint. Match icon size to the JSX (typically 18pt or 22pt).

---

## 10. Sounds

Bundled MP3s in `Resources/Sounds/`. ~20 total, each <30KB, 44.1kHz mono.

| Sound | Trigger | File |
|-------|---------|------|
| `tap` | Any chip/swatch tap | `tap.mp3` |
| `tap_button` | DHButton tap | `tap_button.mp3` |
| `shutter` | Photo capture | `shutter.mp3` |
| `rec_start` | Video record start | `rec_start.mp3` |
| `rec_stop` | Video record end | `rec_stop.mp3` |
| `save_success` | Saving capture succeeds | `save_success.mp3` |
| `error` | Any error variant appears | `error.mp3` |
| `sparkle` | Splash, paywall purchase success | `sparkle.mp3` |
| `swipe` | Tab change, before/after slider | `swipe.mp3` |
| `hello` | First app open, after onboarding | `hello.mp3` |
| `pop` | Sticker animation, FAB tap | `pop.mp3` |
| `gate_correct` | Parental gate correct answer | `gate_correct.mp3` |
| `gate_wrong` | Parental gate wrong answer | `gate_wrong.mp3` |
| `unlock` | Pro purchase complete | `unlock.mp3` |
| `heart_bump` | Heart counter increments | `heart_bump.mp3` |
| `slide_in` | Sheet presentation | `slide_in.mp3` |
| `whoosh` | Look application | `whoosh.mp3` |
| `chime` | Look limit reached | `chime.mp3` |
| `magic_appear` | Look applied | `magic_appear.mp3` |
| `boop` | Generic small confirmation | `boop.mp3` |

Implementation: `DHSounds.play(_:)` in `DesignSystem/DHSounds.swift`. Uses `AVAudioPlayer` with a small pool to support overlapping playback. Respects:

- The system mute switch (uses `AVAudioSession.sharedInstance().setCategory(.ambient)` so mute silences playback)
- An in-app **Sound** toggle in Settings (default ON)
- The Settings toggle persists in `UserDefaults` under key `dh_sound_enabled`

Pre-load the 5 most-used sounds at app launch for zero-latency playback (`tap`, `tap_button`, `shutter`, `swipe`, `pop`).

---

## 11. Haptics

`DesignSystem/DHHaptics.swift`:

```swift
enum DHHaptics {
    static func tap()           // .light impact — chip taps, swatch taps
    static func tapMedium()     // .medium impact — DHButton taps
    static func tapHeavy()      // .heavy impact — record button, paywall purchase
    static func success()       // .success notification — save, purchase complete
    static func warning()       // .warning notification — parental gate wrong, pro gate
    static func error()         // .error notification — error variant appearance
    static func selection()     // selection feedback — picking a category, swiping a tab
}
```

Each method:
1. Checks `UIAccessibility.isReduceMotionEnabled` — if true, no-op
2. Uses the appropriate UIKit haptic generator
3. Generators are pre-prepared (cached as singletons) for low latency

---

## 12. Animation library

| Animation | Curve | Duration | Use |
|-----------|-------|---------|-----|
| `bob` | easeInOut, repeating | 2.0s | Sticker hover (subtle) |
| `pop` | spring(response: 0.3, damping: 0.6) | ~0.5s | Selection state, button press release |
| `slideUp` | spring(response: 0.5, damping: 0.85) | ~0.6s | Sheet presentation, paywall |
| `fade` | easeOut | 0.25s | Error overlay appearance, toast |
| `shimmer` | linear, repeating | 2.0s | Holographic text on Y2K-adjacent moments (paywall headline) |
| `progress` | linear | 1.5s | Splash progress bar |
| `countdown` | spring(response: 0.4, damping: 0.7) | per-tick | Mirror countdown 3-2-1 |
| `shake` | sine, 4 cycles | 0.4s | Parental gate wrong answer |

All animations check `UIAccessibility.isReduceMotionEnabled` and either skip (decorative) or shorten to 0 duration (functional).

---

## 13. Spacing & layout

Per the JSX, content typically lives within a `padding-horizontal: 18px` system. Vertical spacing is loose — 14–22pt between sections, larger for hero spacing.

Common layout tokens:

```swift
extension DH {
    enum Spacing {
        static let hPad: CGFloat = 18         // horizontal screen edge
        static let sectionGap: CGFloat = 18   // between major sections
        static let itemGap: CGFloat = 12      // between items in a section
        static let tightGap: CGFloat = 8      // tight grouping
    }
}
```

Tab bar reserves bottom 96pt of screen real estate (74 height + 22 bottom inset).

Mirror viewport is 380pt tall in the V01 design at iPhone 14 Pro size (852pt screen). On smaller devices, the viewport scales down proportionally; on larger devices, it grows up to 460pt.

---

## 14. Asset catalog

`Resources/Assets.xcassets/` ships with:

- `AppIcon` — full set, all sizes, no transparency
- `LaunchImage` — for the LaunchScreen.storyboard
- Color set mirrors of every DH token (so `Color("DH/pink")` works identically to `DH.pink`)
- Per-look thumbnails (one ImageSet per shipped look, 720×720 PNG @1x — let Xcode generate @2x/@3x)
- Avatar set images (12+ avatars at 256×256)
- Texture assets used as `s_texColor` parameter values for runtime swaps (foundation masks, eyeliner shapes, brow shapes — each as PNG @2x with a white-on-transparent design)

When a manifest's `parameters[].asset` references an asset name (e.g., `"brightLUT"`), the catalog must contain `brightLUT.imageset` with the corresponding image. Validated by `EffectCatalogTests` at build time.

---

## 15. Light mode only

The product is **light mode only.** Set `.preferredColorScheme(.light)` on the root scene. Don't use system semantic colors (`Color.primary`, `Color.background`) — they invert in dark mode. Use the explicit `DH` palette everywhere.

If a user has dark mode enabled system-wide, our app still appears light. This is intentional — the design language doesn't have a dark variant.
