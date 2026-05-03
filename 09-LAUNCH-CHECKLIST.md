# 09 — LAUNCH CHECKLIST

> Companion to 07-CODEX-PROMPTS.md tickets GRWM-950 through GRWM-957.

This is the final checklist between "code complete" and "shipped." Walk it top-to-bottom. Don't skip.

---

## A. Pre-flight (T-14 days)

### A1. Code freeze
- [ ] All Phase 0–11 tickets closed
- [ ] All P0 + P1 bugs from final smoke (GRWM-956) fixed
- [ ] Main branch protected: requires CI green + 1 review
- [ ] `git tag v1.0.0-rc1` cut on a clean main

### A2. Asset finalization
- [ ] App icon 1024×1024 PNG (no alpha) → `docs/launch/assets/icon-1024.png`
- [ ] Verify with `sips -g hasAlpha icon-1024.png` → returns "no"
- [ ] Verify with `sips -g pixelWidth icon-1024.png` → 1024
- [ ] App icon variants for all sizes generated via `Scripts/generate-icon-set.sh`
- [ ] Launch screen identical to splash (DHSplash) in `Assets.xcassets/LaunchImage`
- [ ] All 20 SFX mp3 files <80KB each
- [ ] All `.deepar` effect files in `Resources/Effects/` properly LFS-tracked
- [ ] All Free Beauty Pack textures bundled and verified renderable
- [ ] PrivacyInfo.xcprivacy in target's Copy Bundle Resources phase

### A3. Configuration
- [ ] Bundle ID = `app.grwmstudio.ios`
- [ ] Display name = "GRWM Studio"
- [ ] Marketing version = `1.0.0`
- [ ] Build number = monotonic (use fastlane's `increment_build_number`)
- [ ] Info.plist NSCameraUsageDescription: "GRWM Studio uses your camera to apply sparkly makeup looks to your face in real time. Nothing is sent anywhere — it all stays on your device. 💕"
- [ ] Info.plist NSMicrophoneUsageDescription: "GRWM Studio uses your microphone so your video saves come with sound. We never record without you tapping the record button."
- [ ] Info.plist NSPhotoLibraryAddUsageDescription: "GRWM Studio saves your photos and videos to Photos when you tap Save. We don't browse your library."
- [ ] Minimum deployment target: iOS 17.0
- [ ] Supported devices: iPhone only (no iPad)
- [ ] Supported orientations: Portrait only
- [ ] Supported interface styles: Light only (`UIUserInterfaceStyle = Light`)
- [ ] App Transport Security: default (no exceptions)
- [ ] LSApplicationCategoryType = `public.app-category.entertainment`

### A4. Static audits — final
- [ ] `Scripts/verify-deepar-isolation.sh` → ✅
- [ ] `Scripts/check-localization.sh` → ✅
- [ ] `Scripts/audit-third-party-sdks.sh` → ✅ (only DeepAR + system frameworks)
- [ ] `Scripts/audit-tracking-strings.sh` → ✅ (no Sentry/Crashlytics/Bugsnag/Firebase)
- [ ] `Scripts/audit-hardcoded-colors.sh` → ✅
- [ ] `Scripts/audit-hardcoded-fonts.sh` → ✅
- [ ] `swift Scripts/audit-contrast.swift` → ✅
- [ ] `swiftlint --strict` → ✅
- [ ] No DEBUG-only code reachable in Release (grep `#if DEBUG` blocks; verify via Release build inspection)

### A5. Privacy manifest validation
- [ ] PrivacyInfo.xcprivacy is in target's Copy Bundle Resources
- [ ] `xcrun --sdk iphoneos privacy-validation $BUILT_PRODUCTS_DIR/GRWMStudio.app` → no errors
- [ ] DeepAR's bundled PrivacyInfo verified (open the .framework, inspect)
- [ ] No undeclared API access categories (Apple emails warnings on submission if mismatched)

---

## B. App Store Connect setup (T-10 days)

### B1. App record
- [ ] Create app in ASC if not done
- [ ] Bundle ID matches `app.grwmstudio.ios`
- [ ] Default language: English (U.S.)
- [ ] Primary category: Entertainment
- [ ] Secondary category: Lifestyle (or none)
- [ ] **Made for Kids: ENABLED**
- [ ] **Age band: 6–8** (tightest review for highest trust)
- [ ] Pricing: Free with In-App Purchases

### B2. App information
- [ ] Subtitle (≤30): "Sparkly mirror for kids"
- [ ] Privacy Policy URL: `https://grwmstudio.app/privacy` (must be live before submission)
- [ ] Support URL: `https://grwmstudio.app/support` (must be live)
- [ ] Marketing URL: `https://grwmstudio.app` (optional, recommended)

### B3. Pricing & availability
- [ ] Price: Free
- [ ] Available in all territories (or selected list — note kids-app local laws)
- [ ] In-App Purchases registered:
  - Product ID: `studio.pro.monthly` — Auto-renewable subscription, $4.99/month, in subscription group "Studio Pro"
  - Product ID: `studio.pro.yearly` — Auto-renewable subscription, $39.99/year, in same group
- [ ] Subscription duration set correctly (1 month / 1 year)
- [ ] Subscription localizations: English title, description, promotional image (1024×1024 PNG)
- [ ] App Store promotion image: 1024×1024 (optional)
- [ ] Subscription review screenshot (one per product): demonstrates the entitlement gating in-app

### B4. App Privacy
- [ ] Click "Get Started" on App Privacy
- [ ] Answer "Data Not Collected" → Yes
- [ ] If asked about specific categories, all answer "No"
- [ ] Privacy nutrition label preview matches PrivacyInfo.xcprivacy

### B5. Age rating
- [ ] Cartoon or Fantasy Violence: None
- [ ] Realistic Violence: None
- [ ] Sexual Content or Nudity: None
- [ ] Profanity or Crude Humor: None
- [ ] Alcohol, Tobacco, or Drug Use: None
- [ ] Mature/Suggestive Themes: None
- [ ] Simulated Gambling: None
- [ ] Horror/Fear Themes: None
- [ ] Medical/Treatment Information: None
- [ ] Contests: None
- [ ] Unrestricted Web Access: No
- [ ] Gambling and Contests: No
- [ ] Result: 4+

### B6. Content rights
- [ ] Does this app contain, show, or access third-party content? **No**
  - DeepAR is on-device computer vision; no third-party content delivered through the app.

### B7. Advertising identifier
- [ ] Does this app use the IDFA? **No**

---

## C. Metadata (T-7 days)

All copy reviewed for kids-category compliance: no "social", no "share with friends", no "track", no "compete", no "Apple"/"iPhone"/"iOS" mentions.

### C1. Description (≤4000 chars)

```
GRWM Studio is the sparkliest mirror in the playroom. Tap any shade — gloss, glow, glitter — and watch it land on your face right away. No waiting. No filters that look like everybody else's. Just colors that move with you.

🌸 Seven kinds of magic
Skin, base, eyes, brows, cheeks, lips, and full looks. Stack them, swap them, restart whenever. Your reflection, your rules.

📸 Capture & keep
Snap a photo. Record a 15-second video. Everything saves to your private Locker — your own little vault inside the app. No accounts. No uploads. Nothing leaves your device.

✨ Studio Pro (optional)
Unlock all the limited-edition Looks, longer videos, and the Looks Library catalogue. A grown-up enters a quick math gate before any purchase, and you can manage everything in iPhone Settings anytime.

🛡️ Made for kids — built for parents
We don't track, profile, or share. No ads. No analytics. No social features. Your child's data stays on the device, full stop. Designed for ages 6+, COPPA-compliant by default.

A few things to know:
• Camera access required for the mirror
• Microphone (optional) for video sound
• Photos access (optional) to save videos to Camera Roll
• All purchases gated behind a parent screen
• Subscriptions auto-renew until cancelled in Settings
```

### C2. Promotional text (≤170 chars, can be edited post-release)

```
Get ready with sparkly makeup magic! Tap, swipe, and pose with shades that move with your face. Save your fave looks to your private Locker. ✨
```

### C3. Keywords (≤100 chars, no spaces between commas)

```
kids,makeup,mirror,filter,beauty,glam,studio,fashion,dressup,girls
```

### C4. What's New in This Version (first release)

```
Welcome to GRWM Studio v1.0! 💕 Tap a shade and start sparkling.
```

### C5. App Review information

- Sign-in required: **No**
- Demo account: not applicable
- Notes for App Reviewer:

```
GRWM Studio is a kids' AR makeup mirror app for iPhone (ages 6–8 band). All face tracking happens on-device via DeepAR's CV SDK; no facial data ever leaves the phone.

Test the Pro flow:
1. Tap "Mirror" tab.
2. Tap any shade with a sparkle ⭐ icon (these are Pro-only).
3. License error appears → tap "See Pro Looks".
4. Parent gate (math problem) appears → answer correctly (any single-digit math).
5. Paywall appears → choose "Monthly $4.99".
6. Use sandbox tester credentials from ASC to complete purchase.
7. Return to mirror; sparkly shades now apply.

Restore: Settings tab → Subscription → Restore Purchases.

Privacy: PrivacyInfo.xcprivacy declares NSPrivacyTracking=false and NSPrivacyCollectedDataTypes=empty. No third-party SDKs except DeepAR.

Parental gate: Math + hold gate (Apple guideline 1.3) wraps every purchase, every external link, and every Save-to-Photos action.

If you have any questions, please reach us at app-review@grwmstudio.app — we'll respond within 4 hours.
```

- Contact name: [Engineer's name]
- Contact phone: [Engineer's phone]
- Contact email: app-review@grwmstudio.app

### C6. Version release options
- [ ] Manually release this version (NOT automatic)
- [ ] Reason: control launch timing; allow a 24h soak before push

### C7. Screenshots (per device size)

#### 6.7" (iPhone 16 Pro Max) — required, 4–10 screenshots
1. Hero: Mirror with shade applied, caption "Sparkle on your face ✨"
2. Looks Library: caption "Pick a look 💕"
3. Capture: caption "Snap, record, save 📸"
4. Locker: caption "Your private Locker 🔒"
5. Pro: caption "Unlock all the magic 🌟"
6. Parent gate: caption "Grown-ups in charge of money 🛡️"

#### 6.5" (iPhone 14 Plus / 11 Pro Max) — required for older devices, 4–10 screenshots
- Same six, captured at 6.5" simulator dimensions

Generated via `Scripts/generate-store-screenshots.sh` running `GRWMStudioUITests/StoreScreenshotsUITests.swift`.

Each screenshot is 1290×2796 (6.7") or 1242×2688 (6.5"), with chunky-pink frame and caption applied via post-processing (Sips or ImageMagick).

#### App Preview (video, optional)
- 15–30s video showing key flow (mirror tap → shade → capture → save)
- 6.7" portrait, .mov/.mp4, ≤500MB
- Optional but recommended for kids category — shows reviewers the experience

---

## D. Kids category compliance audit (T-5 days)

Run through every Apple guideline that applies to the Kids category. Cross-reference `docs/launch/KIDS-CATEGORY-COMPLIANCE.md`.

### D1. Apple App Review Guideline 1.3 — Kids category
- [ ] All purchases gated behind parental gate
- [ ] No links to web outside Apple's apps (no Safari except via parent gate)
- [ ] No third-party advertising
- [ ] No third-party analytics
- [ ] No behavioral tracking
- [ ] Privacy policy is age-appropriate and prominent
- [ ] Personally identifiable info NOT collected from children

### D2. Apple App Review Guideline 5.1.4 — Kids
- [ ] Comply with applicable children's privacy statutes (COPPA/GDPR-K)
- [ ] No data sent to third parties
- [ ] All data on-device

### D3. Apple App Review Guideline 5.2 — Intellectual property
- [ ] No copyrighted/trademarked content (no Disney/Mattel/etc references)
- [ ] App name "GRWM Studio" cleared (no trademark conflicts — engineer to verify)
- [ ] All visual assets either created in-house or properly licensed (DeepAR effect templates licensed under DeepAR EULA, free tier)

### D4. Subscription disclosure (Apple guideline 3.1.2)

Verify on paywall, in this order, all visible without scrolling on iPhone 12 mini:
- [ ] Title: "Studio Pro"
- [ ] Length of subscription: "Monthly" or "Yearly"
- [ ] Price per period: "$4.99/month" or "$39.99/year"
- [ ] What's included: bullet list of features
- [ ] "Subscriptions auto-renew unless turned off 24 hours before the period ends"
- [ ] "Cancel anytime in iPhone Settings → Apple ID → Subscriptions"
- [ ] Terms of Service link → Apple's standard EULA OR our custom EULA
- [ ] Privacy Policy link → grwmstudio.app/privacy
- [ ] Restore Purchases button visible

### D5. Parental gate verification
Test these flows manually:
- [ ] Paywall: requires math gate
- [ ] Save to Photos: requires hold gate (per kids guideline — sharing to other apps)
- [ ] External link (Privacy Policy from paywall): requires hold gate
- [ ] Settings → Manage Subscription: requires math gate (deep-links to iOS Settings)
- [ ] Wrong answer 3 times → 60s cooldown
- [ ] Hold gate: early release → fail; full hold → success

### D6. No collected data audit
- [ ] No HTTP/HTTPS network calls except: DeepAR license validation (handled by SDK at first launch only) and StoreKit (Apple-managed)
- [ ] Verify by running app with Wireshark/Proxyman → 0 unexpected hosts
- [ ] No Firebase/Sentry/Crashlytics SDKs imported
- [ ] No analytics events sent anywhere (only OSLog → device console)

---

## E. TestFlight rollout (T-7 to T-1 days)

### E1. Internal testing (T-14 to T-10)
- [ ] `fastlane beta` uploads build to TestFlight
- [ ] Internal group: 5 engineers + designers
- [ ] Daily build cadence
- [ ] Each tester runs full `docs/qa/CHECKLISTS/TEMPLATE.md`
- [ ] Bugs filed in `docs/qa/BUGS-{BUILD}.md`

### E2. External beta (T-10 to T-3)
- [ ] Submit beta build for Beta App Review (usually approved <24h)
- [ ] Group: "Parents Beta" — 50 invited parents (kids ages 6–12)
- [ ] Public beta link distributed via private channel (no public broadcasting)
- [ ] Build duration: 7+ days minimum
- [ ] Beta survey link in app: Settings → "Send feedback" (#if BETA only)
- [ ] Beta build expiration: 90 days
- [ ] What to test: per-build summary in upload metadata

### E3. Beta exit criteria
- [ ] Crash-free rate ≥99.5% across all builds (ASC analytics)
- [ ] No P0 bugs open
- [ ] No P1 bugs open
- [ ] At least 30 of 50 testers completed full flow
- [ ] At least 10 video captures and saves observed across testers
- [ ] At least 5 sandbox subscription purchases observed

### E4. Final smoke (GRWM-956)
- [ ] Run full GRWM-906 manual matrix on production Release build, real device, real DeepAR license
- [ ] All 8 critical journeys executed
- [ ] All 9 errors triggered
- [ ] Sandbox purchase + restore on second device
- [ ] 24-hour idle test → no crash
- [ ] 30-min active session → ≤8% battery drain on iPhone 14
- [ ] Cold-start ≤1.5s on iPhone 12 mini
- [ ] Filled checklist saved as `docs/launch/FINAL-SMOKE-{DATE}.md`, signed

---

## F. Submission day (T-0)

### F1. Pre-submit checklist
- [ ] Working tree clean: `git status` returns nothing
- [ ] On main branch
- [ ] Final regression smoke green
- [ ] All ASC fields filled (run through B and C above one more time)
- [ ] Demo notes saved
- [ ] Version "1.0.0", build number monotonic and unique

### F2. Submit
```bash
cd ios
fastlane release
```

This:
1. Verifies clean tree
2. Builds Release archive
3. Uploads to App Store Connect
4. Submits for review
5. Sets `automatic_release: false` so we control timing

### F3. Confirmation
- [ ] ASC shows "Waiting for Review"
- [ ] Email confirmation received
- [ ] Slack/team channel posted: "1.0.0 submitted, ETA 24–72h"
- [ ] Engineer monitors email for review feedback

### F4. Watch window (next 72h)
- [ ] Check ASC every 6 hours
- [ ] Be reachable for reviewer questions (phone + email)
- [ ] Have `docs/launch/REJECTION-PLAYBOOK.md` open and ready

---

## G. Rejection playbook

If rejected, identify category. Common kids-category rejections:

### G1. "Parental gate insufficient"
- Verify gate triggers on every gated path
- Provide screen recording of all gated flows
- Confirm math/hold gate is age-appropriate (single-digit math, 3s+ hold)
- Re-submit with note clarifying

### G2. "Subscription disclosures incomplete"
- Re-audit paywall against §D4 above
- Most common miss: ToS/Privacy/EULA links not visible above subscribe CTA
- Fix and re-submit

### G3. "App tracks user behavior"
- Re-confirm PrivacyInfo NSPrivacyTracking=false
- Provide Wireshark capture showing 0 unexpected network calls
- Confirm no third-party SDKs
- Re-submit with manifest evidence

### G4. "Demo content insufficient"
- Add explicit step-by-step instructions in reviewer notes
- Offer screen-share with reviewer
- Provide test account/sandbox credentials again

### G5. "Privacy policy missing or insufficient for kids"
- Verify Privacy Policy URL is live
- Verify policy explicitly addresses kids: data we don't collect, third parties (none), parental rights
- Engineer to draft v2 of policy if needed; re-submit

### G6. "Age rating mismatch"
- Verify all answers in §B5 are accurate
- Common miss: app icon contains imagery that triggers a higher rating
- Fix imagery if needed

### G7. "Bundle ID mismatch"
- Should not happen if §A3 followed
- Re-archive with correct bundle ID

### G8. "Missing privacy manifest"
- Verify PrivacyInfo.xcprivacy in Copy Bundle Resources
- Re-archive

Each rejection: respond within 24h with specific fix + new build.

---

## H. Approval & release

### H1. Approved
- [ ] Email received: "Your app is approved"
- [ ] ASC status: "Pending Developer Release"
- [ ] Decide release time (typically Tuesday morning Pacific for max visibility)
- [ ] Release in ASC: click "Release this Version"
- [ ] Status changes to "Processing for App Store" (~1h)
- [ ] Status changes to "Ready for Sale"
- [ ] App is live worldwide

### H2. Post-release monitoring (first 48h)
- [ ] Check ASC analytics every 4 hours
- [ ] Crash-free rate must stay ≥99% (action threshold ≥99.5% sustained)
- [ ] Reviews: respond to all 1-star and 2-star reviews within 4h
- [ ] Reviews: respond to all 3+ star reviews within 24h
- [ ] Refund rate: monitor; <2% acceptable
- [ ] Subscription conversion: track first 30-day cohort
- [ ] If crash spike >1%: hotfix build queued

### H3. Post-release (week 1)
- [ ] Daily monitoring of ASC analytics, reviews, crash logs
- [ ] Respond to all reviews
- [ ] File P0/P1 bugs found via crash logs immediately
- [ ] Identify telemetry gaps and queue v1.1 telemetry tickets

### H4. v1.0.1 hotfix (if needed)
If crash rate >1% sustained over 24h, OR critical bug surfaces:
- Cut hotfix branch from v1.0.0 tag
- Apply minimal fix
- Run static + unit + smoke
- `fastlane release` with `expedited_review: true` (for true emergencies only)

---

## I. Post-launch dashboard

After release, maintain `docs/launch/POST-LAUNCH-DASHBOARD.md` with weekly snapshots:

```
Week of: 2025-XX-XX
Downloads: ___
DAU: ___
Crash-free rate: ___%
Avg rating: ___ (from ___ reviews)
Subscription conversions: ___
Refund rate: ___
Top crash signature: ___
Top user complaint: ___
Notes: ___
```

This is for product, not for the app — never sent anywhere, just an internal log to inform v1.1 priorities.

---

## J. v1.1 backlog seed

Things noted during v1.0 build that we explicitly deferred:
- Spanish localization (es) — strings catalog already structured (GRWM-856)
- iPad support
- Larger filter pack (incoming from user) — manifest-driven, drop-in
- Cheeks (blush) and Brows filters — once added in larger pack
- Family Sharing improvements
- Photo-only sharing flow improvements
- More tutorial videos in Looks Library
- Optional CloudKit sync for Locker (privacy-preserving — would require parent consent flow)

These are NOT for v1. Do not let scope-creep delay submission.

---

End 09-LAUNCH-CHECKLIST.md
