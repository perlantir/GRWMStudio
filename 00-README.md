# GRWM Studio — iOS Build Package

**Product:** Get Ready With Me Studio — a kids' AR makeup mirror for iPhone
**Built on:** DeepAR iOS SDK
**Visual direction:** V01 Dreamhouse Plastic (chunky bubblegum, plastic-toy)
**Target:** iOS 17+, iPhone-first
**Builder:** Codex
**Quality bar:** Enterprise-grade. No shortcuts. Pixel-exact to the v3 design pack.

---

## What's in this package

This is the complete build package for GRWM Studio. Every artifact you need to drive Codex from empty repo to App Store submission lives here. Read in order.

| # | File | When to read it |
|---|------|-----------------|
| 00 | **README.md** (this file) | First. Orientation. |
| 01 | **PROJECT-SCOPE.md** | Before any building. Vision, decisions, in/out scope. |
| 02 | **FILE-STRUCTURE.md** | Reference. The complete Xcode project layout. |
| 03 | **COMMANDS.md** | Run these in order. Setup, builds, signing, releases. |
| 04 | **ARCHITECTURE.md** | Reference. Patterns, concurrency, persistence, COPPA. |
| 05 | **DEEPAR-INTEGRATION.md** | Reference. SDK wrapper, effect catalog, parameter map. |
| 06 | **DESIGN-SYSTEM.md** | Reference. Tokens, primitives, fonts, sounds, haptics. |
| 07 | **CODEX-PROMPTS.md** | The build itself. 70+ tickets, run top-to-bottom. |
| 08 | **TESTING-PLAN.md** | Reference. What to test, how, when. |
| 09 | **LAUNCH-CHECKLIST.md** | Final 2 weeks before submission. |
| 10 | **APPENDICES.md** | Design tokens, error copy, Codex fix-up template. |

---

## How to use this package

### Day 0 — Read

1. Read **01-PROJECT-SCOPE.md** end to end. There are 12 locked decisions; if any are wrong for your business, stop and re-scope before writing code.
2. Skim **02** through **06**. You don't need to memorize them — you'll come back to specifics.
3. Keep **07-CODEX-PROMPTS.md** open in a tab. It's your daily driver.

### Day 1 — Setup

1. Open **03-COMMANDS.md**.
2. Run section 1 (environment setup) — Xcode 16, Homebrew, Ruby for fastlane, etc.
3. Run section 2 (DeepAR developer portal) — register the project, get the license key.
4. Run section 3 (Apple Developer setup) — App ID, App Store Connect record.
5. Run section 4 (repo bootstrap) — git init, push to your remote.

### Day 2+ — Build

Open **07-CODEX-PROMPTS.md**. Each ticket has:

- A unique ID (e.g., `GRWM-101`)
- A goal (one sentence)
- Prerequisites (which tickets must land first)
- Files (what gets created/edited)
- Acceptance criteria (testable)
- The prompt itself (a code block, copy-paste into Codex)

Drive Codex top-to-bottom by ticket ID. Don't skip ahead — later tickets assume earlier ones landed.

### After each ticket

1. Verify the acceptance criteria yourself. Don't trust Codex.
2. Run the build. Run the tests.
3. Commit with the ticket ID in the message: `[GRWM-101] DeepAR controller bootstrap`.
4. Move to the next ticket.

### When something breaks

1. Look at **10-APPENDICES.md** §C — the Codex fix-up template. Copy-paste it with the error and Codex will repair its work.
2. If a prompt produced something fundamentally wrong, file an issue against the prompt itself — the project plan is a living document and these tickets get refined.

---

## Critical scope decisions (locked — see 01-PROJECT-SCOPE.md for the full list)

These have already been made. Don't re-litigate during the build; raise objections before starting.

1. **7 filter categories:** Skin, Base, Eyes, Brows, Cheeks, Lips, **Looks**. The 7th category — Looks — is full-face presets that override the per-category layers.
2. **The Looks Locker is a separate tab** for the user's saved photo/video captures. It is NOT the same as the Looks filter category.
3. **Effect catalog is data-driven**, fed by a manifest plus the contents of `Resources/Effects/`. The free pack ships now; the larger pack you mentioned drops in by adding files + manifest entries — no code changes.
4. **iOS 17+** minimum. iPhone-only. Portrait-only. Light mode only. English-only at launch.
5. **No accounts. No UGC. No third-party analytics.** Made-for-Kids App Store category.
6. **One file in the app imports DeepAR.** Everywhere else uses the Swift-native wrapper.

---

## Quality bar — what "enterprise-grade" means here

- Every screen has its own SwiftUI Preview that renders pixel-close to the source JSX.
- Every screen has VoiceOver labels and Dynamic Type support up to AX2.
- Every async operation has a timeout, a failure path, and a user-facing error variant from the design.
- Every persistence write has a corresponding read test.
- Every public API on a service has a unit test (mock + real-impl smoke test).
- The DeepAR wrapper is the only file in the app that imports DeepAR — verified by a build-phase script that greps for `import DeepAR` and fails if it appears elsewhere.
- Privacy manifest declared, App Store privacy questionnaire pre-filled.
- COPPA: no PII collected without verifiable parental consent. Camera frames never leave the device.
- The app builds clean with `-warnings-as-errors` after Phase 8 polish.
- Every release is tagged in git, signed, archived, and uploaded via Xcode Cloud (or fastlane fallback documented in COMMANDS.md).

---

## Estimated timeline (one engineer driving Codex full-time)

| Phase | Tickets | Working days |
|-------|---------|-------------|
| 0. Bootstrap | GRWM-001 to GRWM-099 | 3 |
| 1. DeepAR foundation | GRWM-100 to GRWM-199 | 4 |
| 2. Onboarding (5 screens) | GRWM-200 to GRWM-299 | 3 |
| 3. Mirror & capture (7 screens) | GRWM-300 to GRWM-399 | 8 |
| 4. Library & locker (5 screens) | GRWM-400 to GRWM-499 | 4 |
| 5. Profile, Feed, Tutorial (3 screens) | GRWM-500 to GRWM-599 | 3 |
| 6. Commerce — gate + paywall (5 screens) | GRWM-600 to GRWM-699 | 4 |
| 7. Settings + 9 error variants | GRWM-700 to GRWM-799 | 3 |
| 8. Polish (a11y, haptics, sound, anim) | GRWM-800 to GRWM-899 | 4 |
| 9. Testing pass | GRWM-900 to GRWM-949 | 3 |
| 10. Launch readiness | GRWM-950 to GRWM-999 | 3 |
| **Total** | **~75 tickets** | **~42 working days** (~8.5 weeks) |

Add 2–4 weeks of beta testing in TestFlight before submitting to App Review. Plan for a 2-week App Review window for first kids-category submission (it's stricter and slower).

---

## What's NOT in this package

- **The DeepAR license key** — get from `https://developer.deepar.ai/projects` after registering your app.
- **Studio asset work** — the artist's `.deepar` files for the larger filter pack you mentioned. The package architecture accepts these as drop-ins.
- **Fonts** — Fredoka and Quicksand TTF files. Both are free under the Open Font License; download from Google Fonts.
- **Avatar assets, sound effects** — list of what's needed in `06-DESIGN-SYSTEM.md`.
- **Privacy Policy and Terms of Use copy** — required URLs for App Store submission. A skeleton is in `09-LAUNCH-CHECKLIST.md` but the legal review is on you.

---

If anything in this package is unclear, the Codex fix-up template in **10-APPENDICES.md §C** can repair the prompt itself. The plan is meant to be edited as you learn — keep it under version control alongside the code.
