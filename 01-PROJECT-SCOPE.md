# 01 — Project Scope

## 1. Product vision

**GRWM Studio** is an iPhone AR makeup mirror for kids ages 6–12. The front camera shows the child's face. They tap chunky plastic-toy buttons to apply real makeup filters — lipstick, blush, eyeshadow, eyeliner, lashes, foundation, brow shapes — that track their face in real time. They take photos and short videos of their looks, save favorites to a personal "Locker," and browse a curated daily Feed of trending looks.

The product is built on the **DeepAR iOS SDK**, which provides face tracking, real-time effect rendering, runtime parameter manipulation (color/texture/blendshape changes), screenshots, and video recording — all out of the box.

Visual direction is **V01 Dreamhouse Plastic** from the v3 design pack: glossy bubblegum pink, chunky offset shadows, plastic-toy aesthetic. Every UI element looks moulded out of pink plastic with a wet shine.

## 2. Target user & context

- **Primary:** Kids ages 6–12. They open the app, see themselves, play.
- **Secondary:** A parent who downloads the app, manages permissions, gates purchases.
- **Use context:** A bedroom, a car ride, a sleepover. Often shared with friends. Often photographed.
- **Mood:** Joyful, low-stakes, playful. Never anxiety-inducing, never time-pressured.

## 3. Locked decisions

These are not up for re-litigation during the build. If any are wrong, fix them now before writing code.

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **7 filter categories.** Skin, Base, Eyes, Brows, Cheeks, Lips, Looks. Looks is the 7th — full-face presets that override per-category layers. | Matches user requirement. The Looks category is conceptually different from the per-component categories but lives in the same chip bar for consistency. |
| 2 | **Looks Locker is a separate tab** for the user's saved captures (photos/videos), not the same as the Looks filter category. | Clear mental model: one tab for "my saves," one chip in the mirror for "preset full-face looks I can apply." |
| 3 | **Effect catalog is data-driven.** Manifest in `Resources/Effects/manifest.json` + files in `Resources/Effects/`. Larger filter pack (incoming) drops in via files + manifest — no code changes. | User has a larger pack coming. Architecture must accept any number of effects without code edits. |
| 4 | **V01 Dreamhouse Plastic only.** The 9 other directions in the design zip are dropped. | User confirmed. App Flow file uses V01 throughout. |
| 5 | **iOS 17+** minimum. iPhone-only. Portrait-only. Light mode only. English-only. | Lets us use Observation framework, SwiftData, modern SwiftUI. Cuts platform tax. |
| 6 | **Bundle ID:** `app.grwmstudio.ios` (placeholder — set before requesting DeepAR license). | Locked before any external setup. |
| 7 | **Architecture:** SwiftUI-first; UIKit `UIViewRepresentable` only for the DeepAR `ARView`. MVVM via `@Observable` view models. Coordinator for top-level routing. SwiftData for local persistence. | Idiomatic iOS 17. Minimal third-party deps. |
| 8 | **No accounts. No user-generated content.** Profile is local-only. Feed is read-only, fed by a curated remote JSON. | Made-for-Kids App Store category requires this for a clean review. |
| 9 | **One file imports DeepAR.** Everything else uses the Swift-native wrapper in `DeepAR/DeepARController.swift`. Enforced by a build-phase grep. | If we ever swap SDKs, blast radius is one file. Also forces clean abstraction. |
| 10 | **StoreKit 2** for the paywall. Two products: `studio.pro.monthly`, `studio.pro.yearly`. One tier ("Studio Pro"). | Modern API, server-less validation viable for MVP. |
| 11 | **Parental gate** is a math problem (primary) with press-and-hold fallback. Both gate the paywall, external links, and "delete my data" action. | Apple's recommended pattern for kids apps. |
| 12 | **No third-party analytics, no crash reporters, no ad SDKs in v1.** `AnalyticsService` is a no-op protocol; replace later with vendor of choice if needed. | Made-for-Kids constraints. Keeps v1 review clean. |

## 4. The 33 screens

Every screen in `v3/GRWM Studio App Flow.html`. Each gets its own ticket in 07-CODEX-PROMPTS.md.

### Onboarding (5)
1. Splash — `DHSplash` in `dh-screens-1.jsx`
2. Welcome — `DHWelcome` in `dh-screens-1.jsx`
3. Parent info — `DHParentInfo` in `dh-screens-6.jsx`
4. Permissions ask — `DHPermissions` in `dh-screens-2.jsx`
5. Permissions denied — `DHPermissionsDenied` in `dh-screens-6.jsx`

### Mirror & Capture (7)
6. Mirror — live — `V01Dreamhouse` in `v01-mirror.jsx`
7. Mirror — countdown — `DHMirrorCountdown` in `dh-screens-6.jsx`
8. Mirror — recording — `DHMirrorRecording` in `dh-screens-6.jsx`
9. Mirror — Pro gate — `DHMirrorProGate` in `dh-screens-6.jsx`
10. Preview — idle — `DHPreviewIdle` in `dh-screens-7.jsx`
11. Preview — saved — `DHPreviewSaved` in `dh-screens-7.jsx`
12. Save & Share — `DHSaveShare` in `dh-screens-4.jsx`

### Library & You (5)
13. Looks library — `DHLooks` in `dh-screens-3.jsx`
14. Saved — empty — `DHSavedEmpty` in `dh-screens-7.jsx`
15. Saved — at limit — `DHSavedAtLimit` in `dh-screens-7.jsx`
16. Look detail — `DHLookDetail` in `dh-screens-5.jsx`
17. Profile — `DHProfile` in `dh-screens-4.jsx`

### Social & Learn (2)
18. Feed — `DHFeed` in `dh-screens-5.jsx`
19. Tutorial — `DHTutorial` in `dh-screens-5.jsx`

### Parental Gate & Paywall (5)
20. Parental gate — math — `DHParentMathIdle` in `dh-screens-7.jsx`
21. Parental gate — math wrong — `DHParentMathWrong` in `dh-screens-7.jsx`
22. Parental gate — press & hold — `DHParentHold` in `dh-screens-7.jsx`
23. Paywall — `DHPaywall` in `dh-screens-7.jsx`
24. Settings — `DHSettings` in `dh-screens-7.jsx`

### Errors (9)
25. Camera denied — `DHError` variant `cam-denied` in `dh-screens-8.jsx`
26. Mic denied — `DHError` variant `mic-denied`
27. Photos denied — `DHError` variant `photo-denied`
28. Pro shade locked — `DHError` variant `license`
29. Effect failed — `DHError` variant `effect-fail`
30. Recording failed — `DHError` variant `rec-fail`
31. Save failed — `DHError` variant `save-fail`
32. No face — `DHError` variant `no-face`
33. Low storage — `DHError` variant `low-storage`

## 5. In scope (must ship in v1)

**Capture**
- Live front-camera AR mirror with face tracking
- 7 filter categories (Skin, Base, Eyes, Brows, Cheeks, Lips, Looks) on a horizontally scrolling chip bar exactly as designed
- Per-category shade row (gumball candies in V01 design)
- Photo capture
- Video capture (free: 30s, Pro: 5min)
- 3-2-1 countdown before video starts
- Recording UI with audio level meter and time-remaining pill
- Pro gate overlay when free user touches a Pro-locked shade
- Before/after slider on the mirror viewport
- Camera flip (front/back; back camera disables face tracking gracefully)

**Library**
- Looks Library tab with grid, filter chips, hot/hearted badges, all 8+ presets bundled
- Looks Locker tab for saved captures (free: 12-cap, Pro: unlimited) with empty + limit states
- Look Detail view: full-screen, re-apply, share, delete

**Commerce**
- Parental gate (math primary, hold fallback)
- StoreKit 2 paywall (monthly + yearly + restore)
- Pro entitlement enforcement: premium shades, longer recordings, unlimited locker

**Lifecycle**
- All 5 onboarding screens with delayed-permission ask pattern
- Profile (local-only): display name, avatar from built-in set, badges, stats
- Settings: notifications toggle, sound toggle, parental controls section, restore purchases, privacy info, "delete my data"
- Curated Feed (read-only, remote JSON with bundled fallback)
- Single tutorial video player

**Engineering**
- All 9 error states fully implemented and reachable from the appropriate failure paths
- Full VoiceOver coverage
- Dynamic Type up to AX2 (with chunky-chip exception)
- Reduce Motion respected
- Privacy manifest declared
- App Store metadata, screenshots, App Privacy questionnaire prepped

## 6. Out of scope (NOT in v1)

- User accounts, sign-in, social graph
- User-generated content, posting, comments, likes from real users
- Custom shade picker / color mixing
- Multi-face simultaneous tracking
- Family Sharing for Pro
- Apple Watch companion
- Dark mode
- Localization (English only)
- iPad-specific layout (works as stretched iPhone)
- AR makeup tutorials with step-by-step coaching (only the single tutorial video is in scope)
- Background-replacement features (DeepAR supports it; we don't ship it)
- Offline preset look downloading (all presets ship in-bundle)

## 7. Success criteria

The v1 ships when **all** of these are true:

1. All 33 screens render pixel-close to the source JSX in SwiftUI Previews.
2. The full mirror loop works on physical hardware: open app → grant permissions → see face → apply Skin + Eyes + Lips → record 30s video → preview → save to Locker → reopen Locker → see saved item.
3. The 8+ preset Looks all apply correctly via DeepAR `switchEffect` and visually match their thumbnails.
4. Each of the 7 categories' shade row drives DeepAR `changeParameter` and the visual change is visible within one frame.
5. StoreKit 2 sandbox: full purchase flow, restore, and entitlement gating work end-to-end.
6. All 9 error states are reachable through their real failure paths (not just dev tooling), and each presents the designed `DHError` variant.
7. SwiftLint clean. `xcodebuild test` exits 0.
8. App Store privacy manifest, kids-category questionnaire, and screenshots ready.
9. Internal beta passes: 5 kids 6–12 each complete the core loop without help in <60 seconds.

## 8. Dependencies & risks

### Hard dependencies (block ship)

- **DeepAR iOS SDK license** — bundle-ID-bound. Free tier covers MVP. Set up in COMMANDS §2.
- **Apple Developer Program membership** — $99/year. Set up in COMMANDS §3.
- **DeepAR effect files** — the free pack ships now; the larger pack you mentioned slots in via the manifest.
- **Fonts** — Fredoka & Quicksand from Google Fonts (Open Font License — free).
- **Privacy Policy & Terms of Use URLs** — required for App Store submission. Outside engineering scope.

### Soft dependencies (manageable risks)

- **DeepAR SDK API stability across versions** — we pin to a specific tag in SwiftPM. The runtime parameter API has been stable since v2.2.1. Changelog at `https://docs.deepar.ai/deepar-sdk/platforms/ios/changelog` — review before any version bump.
- **Studio project node names matching code** — the parameter map in `EffectParameterMap.swift` references node names from the `.deeparproj` files. The artist must publish a Parameter Map Sheet listing every node + material + shader uniform name. Mismatch = effects don't change. Mitigation: integration tests that load every shipped effect and assert every named node exists.
- **App Store kids-category review** — first submissions take 2 weeks vs. the usual 1–3 days. Submit at least 4 weeks before any launch deadline.
- **COPPA + GDPR-K** — requirements differ by region. We collect no PII without verifiable parental consent (which we don't request — so we collect no PII). The "parent email" collected at onboarding (designed but optional) is hashed before storage; if it's ever transmitted, full COPPA verifiable-consent flow is required, which we don't do in v1. Decision: parent email is collected as plaintext locally for the device's own use (e.g., to hash later) but NEVER transmitted off-device in v1. See ARCHITECTURE.md §6 for COPPA details.

### Things to monitor in beta

- Frame rate on iPhone 12 mini (lowest supported device) with all 6 effect slots loaded simultaneously. DeepAR specs target 60fps on mid-range devices but stacking 6 effects is unusual; profile in Phase 8.
- Memory pressure when switching looks rapidly — the SDK should release prior effects, but verify with Instruments.
- Low-light face tracking quality. The kids' use context is often a dim bedroom. We may need to bump exposure/expose a "Brighten" toggle in Settings.

## 9. Non-goals for engineering communication

- **Don't** spend prompts re-explaining V01 design choices. They're locked.
- **Don't** ask Codex to invent UX. Every screen has a JSX file. Mirror it.
- **Don't** add features outside this scope without explicit re-scoping. Scope creep is the #1 risk in a kids' app first launch.
- **Don't** invent new design tokens. The DH namespace is closed.
- **Don't** integrate any third-party SDK except DeepAR and SwiftLint without explicit approval.
