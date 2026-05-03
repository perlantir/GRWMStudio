# 10 — APPENDICES

Reference materials cited throughout the build package.

---

## A. Design tokens reference (V01 Dreamhouse Plastic)

### A1. Colors

| Token | Hex | Usage |
|---|---|---|
| `DH.pink` | `#FF3DA5` | Primary action, hero, chips |
| `DH.pinkDeep` | `#D4127B` | Shadows, deep accents |
| `DH.pinkLight` | `#FF8FCF` | Hovers, soft highlights |
| `DH.pinkPaper` | `#FFE5F2` | Card bg, error backgrounds (pink tone) |
| `DH.cream` | `#FFF8EC` | Page bg, neutral |
| `DH.butter` | `#FFD66B` | Butter accent, yellow tone |
| `DH.lav` | `#C9A8FF` | Lavender accent |
| `DH.mint` | `#A8F0D1` | Mint accent |
| `DH.ink` | `#1B0E1F` | Body text, dark elements |
| `DH.recRed` | `#FF3D5A` | Recording dot, urgent |
| `DH.proGold` | `#E5A623` | Pro lock icon, sparkle |

Derived (per ErrorTone in 07 GRWM-800):
| Tone | hero | deep | bg |
|---|---|---|---|
| pink | `#FF3DA5` | `#D4127B` | `#FFE5F2` |
| lav | `#C9A8FF` | `#5A1099` | `#F1E8FF` |
| butter | `#FFD66B` | `#C99B1F` | `#FFF6E0` |
| mint | `#A8F0D1` | `#5DBD8E` | `#E5FFF4` |

### A2. Typography

| Style | Face | Size | Weight | Use |
|---|---|---|---|---|
| Display | Fredoka | 48pt | 700 | DHSplash, hero numbers |
| Title | Fredoka | 32pt | 700 | Screen titles |
| Headline | Fredoka | 24pt | 700 | Section headers, error titles |
| Body large | Quicksand | 18pt | 600 | CTA labels, prominent body |
| Body | Quicksand | 16pt | 500 | Default body text |
| Body small | Quicksand | 14pt | 500 | Sub-copy, hints |
| Caption | Quicksand | 12pt | 600 | Metadata, timestamps |
| Chip | Quicksand | 9.5pt | 700 | ERROR · variant chip |

Letter spacing: chips +0.12, headlines -0.01, body 0. Line height: titles 1.1, body 1.5.

### A3. Radii

| Token | Value | Use |
|---|---|---|
| `DH.radius.sm` | 12 | Chips |
| `DH.radius.md` | 18 | Cards, secondary buttons |
| `DH.radius.lg` | 24 | Primary cards, FAB outer |
| `DH.radius.xl` | 32 | Sheet corners, hero containers |
| `DH.radius.pill` | 9999 | Pill buttons |

### A4. Chunky shadow

```swift
extension View {
    func chunkyShadow(color: Color, offset: CGFloat = 7, blur: CGFloat = 0) -> some View {
        self
            .background(color.offset(y: offset).blur(radius: blur)) // solid layer
            .shadow(color: color.opacity(0.4), radius: 14, y: offset + 7) // soft layer
    }
}
```

Standard offsets: 7pt (md buttons), 9pt (lg buttons), 5pt (chips), 14pt blur on second layer.

### A5. Wallpapers

Three procedurally-generated repeating SVG patterns (defined in `DHWallpaper.swift`):
- `dotsCream` — cream background, pink dots ø8pt at 32pt grid
- `heartsButter` — butter background, pink hearts at 48pt offset grid
- `sparklesLavender` — lavender background, white sparkle stars at 56pt grid

### A6. Sticker primitives

Five SVG paths exposed as SwiftUI Views in `Stickers.swift`:
- `StickerHeart` — chunky heart, default fill DH.pink
- `StickerSparkle` — 4-point sparkle, default fill white with DH.pink stroke
- `StickerStar` — 5-point star, default fill DH.butter
- `StickerFlower` — 5-petal flower, default fill DH.pinkLight
- `StickerCrown` — 3-point crown, default fill DH.proGold

All accept `size:` (default 24pt), `fill:`, `rotation:`. Wobble animation = `DHAnim.stickerWobble`.

Plus `GRWMLogo` — wordmark "GRWM" in chunky Fredoka 700 with sparkle on the W.

---

## B. Error variants — copy strings table

(Authoritative source — referenced from GRWM-800 through GRWM-808.)

| Variant | Tone | Emoji | Sticker | Title | Sub | CTA | ALT |
|---|---|---|---|---|---|---|---|
| `cam-denied` | pink | 📷 | Heart | The mirror can't see you 💕 | Camera access was turned off. Tap below to switch it back on in Settings. | Open Settings | I'll do it later |
| `mic-denied` | lav | 🎙️ | Sparkle | No microphone, no voiceover | Recording works without sound, but giggles are nicer with audio. | Open Settings | Record without audio |
| `photo-denied` | butter | 🖼️ | Star | Can't reach Photos | Photos access is off, so we can't save your video to the camera roll. Looks still save inside GRWM. | Open Settings | Keep inside GRWM |
| `license` | pink | 🔒 | Crown | This shade is Pro | Disco Brat is part of Studio Pro. Want a peek at everything? | See Pro Looks | Pick a different shade |
| `effect-fail` | mint | ✨ | Sparkle | That sparkle didn't load | The effect couldn't download. Check your wifi and try again — it'll only take a sec. | Try again | Pick another look |
| `rec-fail` | pink | 🎬 | Heart | Recording didn't save | Something hiccuped while saving. Don't worry — you can record it again right now. | Record again | Discard |
| `save-fail` | butter | 💼 | Star | Couldn't add to Locker | There was a problem saving this look. Your last 3 looks are still safe inside the app. | Try again | Discard |
| `no-face` | lav | 👀 | Flower | I can't see your face! | Move into the light, or come a little closer to the camera so the makeup can land. | Got it | Use a sample face *(DEBUG only)* |
| `low-storage` | pink | 📦 | Heart | Almost out of space | Your phone is nearly full, so we can't save this right now. Free up some space and try again. | Open Settings | Manage Locker |

Chip text (top-left, 9.5pt 700, INK 55%): `ERROR · {VARIANT}` where VARIANT is uppercased rawValue (e.g., `ERROR · CAM-DENIED`).

---

## C. JSX → screen mapping

For each screen in the app, the source design file in `docs/design-source/v3/`:

| App screen | JSX source file | JSX component name |
|---|---|---|
| Splash | `screens-1.jsx` | `DHSplash` |
| Welcome | `screens-1.jsx` | `DHWelcome` |
| Parent Info | `screens-1.jsx` | `DHParentInfo` |
| Permissions ask | `screens-1.jsx` | `DHPermissions` |
| Permissions denied | `screens-2.jsx` | `DHPermissionsDenied` |
| Mirror — Skin | `screens-2.jsx` | `DHMirror_Skin` |
| Mirror — Base | `screens-3.jsx` | `DHMirror_Base` |
| Mirror — Eyes | `screens-3.jsx` | `DHMirror_Eyes` |
| Mirror — Brows | `screens-3.jsx` | `DHMirror_Brows` |
| Mirror — Cheeks | `screens-4.jsx` | `DHMirror_Cheeks` |
| Mirror — Lips | `screens-4.jsx` | `DHMirror_Lips` |
| Mirror — Looks | `screens-4.jsx` | `DHMirror_Looks` |
| Mirror — Countdown | `screens-5.jsx` | `DHMirrorCountdown` |
| Mirror — Recording | `screens-5.jsx` | `DHMirrorRecording` |
| Mirror — Pro gate | `screens-5.jsx` | `DHMirrorProGate` |
| Preview — idle | `screens-5.jsx` | `DHPreviewIdle` |
| Preview — saved | `screens-6.jsx` | `DHPreviewSaved` |
| Save / Share | `screens-6.jsx` | `DHSaveShare` |
| Looks Library | `screens-6.jsx` | `DHLooks` |
| Look Detail | `screens-6.jsx` | `DHLookDetail` |
| Tutorial | `screens-6.jsx` | `DHTutorial` |
| Saved — empty | `screens-7.jsx` | `DHSavedEmpty` |
| Saved — at limit | `screens-7.jsx` | `DHSavedAtLimit` |
| Locker grid | `screens-7.jsx` | `DHLockerGrid` |
| Locker detail | `screens-7.jsx` | `DHLockerDetail` |
| Profile | `screens-7.jsx` | `DHProfile` |
| Feed | `screens-7.jsx` | `DHFeed` |
| Parent gate — math | `screens-8.jsx` | `DHParentMath` |
| Parent gate — hold | `screens-8.jsx` | `DHParentHold` |
| Paywall | `screens-8.jsx` | `DHPaywall` |
| Settings | `screens-8.jsx` | `DHSettings` |
| Error (all 9 variants) | `screens-8.jsx` | `DHError` (variant prop) |

Pixel-exact verification: every screen ticket in 07 cites its JSX file. GRWM-857 locks visuals via snapshot tests.

---

## D. Sound effects manifest

20 mp3 files in `GRWMStudio/Resources/Audio/`. Each ≤80KB, 96kbps AAC.

| File | Use |
|---|---|
| tapSoft.mp3 | DHButton tap (default) |
| tapHard.mp3 | DHChip tap |
| shutter.mp3 | Capture FAB photo |
| countdownTick.mp3 | 3, 2, 1 tick |
| countdownFinal.mp3 | "RECORD" final tick |
| saved.mp3 | Save success toast |
| recordStart.mp3 | Recording begins |
| recordStop.mp3 | Recording ends |
| errorSoft.mp3 | DHErrorView appear |
| lockerSwipe.mp3 | Swipe row in locker |
| lockerDelete.mp3 | Delete confirmation |
| paywallReveal.mp3 | Paywall sheet appear |
| sparkle1.mp3 | Random sparkle (idle ambient) |
| sparkle2.mp3 | Random sparkle (variant) |
| sparkle3.mp3 | Random sparkle (variant) |
| confettiPop.mp3 | Subscribe success |
| swooshIn.mp3 | Sheet present |
| swooshOut.mp3 | Sheet dismiss |
| heart.mp3 | Heart pill on Feed |
| magic.mp3 | Pro shade unlock animation |

---

## E. Codex fix-up template

When Codex completes a ticket, the engineer reviews. If revisions needed, use this template:

```markdown
# Fix-up for {TICKET-ID}

## What's wrong
- [specific behavior]
- [specific code smell]

## What I expected
- [reference to acceptance criteria #N]

## How to fix
- [specific edit, file:line]
- [or: re-do this section, here's why]

## Verify
- [reproduction steps]
- [expected result]
```

Paste into Codex with the original ticket prompt re-attached for context.

---

## F. Glossary

- **AppEnv** — top-level dependency container struct passed to ViewModels. Holds protocol-backed services.
- **Capture** — a saved photo or video; `SavedCapture` SwiftData model.
- **DH** — DreamHouse design system namespace.
- **DeepAR** — third-party AR/CV SDK; the only third-party library in the app. Used for face tracking + makeup effect rendering.
- **Effect** — a `.deepar` file describing an AR effect. Loaded into a slot on the DeepAR ARView.
- **Effect catalog** — the runtime registry of effects, sourced from `manifest.json`. Decoupled from code so new effects drop in without recompile.
- **EffectParameterMap** — bridges user-facing shade choices (e.g., "Honey") to DeepAR runtime params (e.g., `setVector4("foundationColor", r,g,b,a)`).
- **Effect slot** — a named channel inside DeepAR. We use 7: skin, base, eyes, brows, cheeks, lips, looks. The looks slot overrides the per-category slots.
- **GRWM** — "Get Ready With Me." App brand.
- **Locker** — local-only saved captures. Cap 50.
- **Looks** — full-face presets that override per-category effects. The 7th category in the filter rail.
- **Manifest** — `manifest.json` describing all available effects, shades, and their parameter mappings.
- **Mirror** — the live AR camera view. The hero feature.
- **Parent gate** — math-then-hold gate before any purchase or external action. Apple kids-category requirement.
- **Pro** — premium tier unlocked via auto-renewable subscription. $4.99/mo or $39.99/yr.
- **Shade** — a single user-selectable variant within a category (e.g., "Honey" in Skin).
- **Slot** — see Effect slot.
- **TestFlight** — Apple's beta distribution platform.

---

## G. References

- DeepAR iOS SDK docs: https://docs.deepar.ai/category/ios
- Apple Kids category guidelines: https://developer.apple.com/app-store/review/guidelines/#kids-category
- Apple subscription disclosure: https://developer.apple.com/app-store/review/guidelines/#3.1.2
- COPPA compliance: https://www.ftc.gov/business-guidance/privacy-security/childrens-privacy
- StoreKit 2 docs: https://developer.apple.com/documentation/storekit
- SwiftData docs: https://developer.apple.com/documentation/swiftdata
- SnapshotTesting library: https://github.com/pointfreeco/swift-snapshot-testing
- MetricKit: https://developer.apple.com/documentation/metrickit

---

End 10-APPENDICES.md — and end of the build package.

Read order, once more, for clarity:
1. **00-README** — orientation
2. **01-PROJECT-SCOPE** — what we're building, what we're not
3. **02-FILE-STRUCTURE** — Xcode layout
4. **03-COMMANDS** — every shell command in order
5. **04-ARCHITECTURE** — patterns, services, data flow
6. **05-DEEPAR-INTEGRATION** — the SDK boundary
7. **06-DESIGN-SYSTEM** — visual primitives (this doc references it)
8. **07-CODEX-PROMPTS** — 111 tickets, work top-to-bottom
9. **08-TESTING-PLAN** — what to test and how
10. **09-LAUNCH-CHECKLIST** — App Store path
11. **10-APPENDICES** — this doc

Ship it. ✨
