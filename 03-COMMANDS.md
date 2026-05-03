# 03 — Commands

Every shell command, in the order you'll run it, from "empty Mac" to "App Store submission." Run sections top-to-bottom. Each section has a one-line goal so you can skim before running.

---

## §1 — Local environment setup (one-time, ~30 minutes)

> Goal: get a Mac ready to build iOS apps with Codex/Cursor + Xcode.

### 1.1 Install Xcode 16

```bash
# Open Mac App Store and install Xcode 16 (or download from developer.apple.com)
# After install:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -version          # verify: should show "Xcode 16.x"
swift --version              # verify: should show Swift 5.10+ (or 6.x)
```

### 1.2 Install Homebrew + CLI tools

```bash
# Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Tools
brew install swiftlint                # Swift linter
brew install xcbeautify              # cleaner xcodebuild output
brew install jq                       # JSON tooling for the manifest
brew install git-lfs                  # for the .deepar binary effect files
git lfs install --system              # one-time
brew install --cask fork              # GUI git client (optional but recommended for binary diffs)
```

### 1.3 Install Ruby + fastlane (for release automation)

```bash
brew install rbenv ruby-build
rbenv install 3.3.5
rbenv global 3.3.5
echo 'eval "$(rbenv init -)"' >> ~/.zshrc && source ~/.zshrc

gem install bundler
gem install fastlane -NV
fastlane --version            # verify
```

### 1.4 Apple Developer Program

You need this before §3. **$99/year, must enroll as an individual or organization.**

```bash
# This step is browser-only, no commands.
# Go to https://developer.apple.com/programs/enroll/ and complete enrollment.
# After enrollment finishes (can take 24–48h), you'll have:
#   • A Team ID (10-character hex like "ABCDE12345")
#   • Access to App Store Connect at https://appstoreconnect.apple.com
```

### 1.5 Sign in to Xcode

```bash
# Open Xcode > Settings > Accounts > "+" > Apple ID > sign in with the Apple ID
# tied to your Apple Developer Program membership.
# This pulls down your signing certificates.
```

---

## §2 — DeepAR developer portal setup

> Goal: get a license key bound to bundle ID `app.grwmstudio.ios`.

### 2.1 Create developer account

Browser-only:

1. Go to `https://developer.deepar.ai/`
2. Sign up (or sign in)
3. Verify your email

### 2.2 Create the project & app

Browser-only:

1. Navigate to `https://developer.deepar.ai/projects`
2. Click **+ New Project**
3. Name: **GRWM Studio**
4. Plan: **FREE** (sufficient for MVP)
5. Under the new project, click **+ Add App** > **iOS App**
6. Bundle ID: `app.grwmstudio.ios` *(must match exactly — change here means changing in 1000 places later)*
7. Save. The portal will display your **license key** — a long string.

### 2.3 Store the license key locally (do NOT commit)

```bash
# After the repo is bootstrapped in §4:
cd grwm-studio-ios
cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
# Open Config/Secrets.xcconfig in your editor, set:
#   DEEPAR_LICENSE_KEY = your_real_key_here
# Verify .gitignore excludes it:
grep "Secrets.xcconfig" .gitignore
# If missing, add it:
echo "Config/Secrets.xcconfig" >> .gitignore
```

### 2.4 Download the free filter pack

You already have `Free.v1.3` from this conversation — that's the free pack. The larger pack you mentioned will arrive separately. When it does, drop the additional `.deepar` files into `GRWMStudio/Resources/Effects/` and add manifest entries (see DEEPAR-INTEGRATION.md §4).

---

## §3 — Apple Developer + App Store Connect setup

> Goal: get the app registered on Apple's side so you can sign builds and submit.

### 3.1 Register the App ID

Browser-only:

1. Go to `https://developer.apple.com/account/resources/identifiers/list`
2. Click **+** > **App IDs** > **App** > Continue
3. Description: **GRWM Studio**
4. Bundle ID: **Explicit** > `app.grwmstudio.ios`
5. Capabilities — enable now (you can change later):
   - **In-App Purchase** (required for paywall)
   - **Push Notifications** (only if you ever want them; safe to leave on)
6. Save.

### 3.2 Create the App Store Connect record

Browser-only:

1. Go to `https://appstoreconnect.apple.com/apps`
2. Click **+** > **New App**
3. Platforms: **iOS**
4. Name: **GRWM Studio**
5. Primary language: **English (U.S.)**
6. Bundle ID: select `app.grwmstudio.ios`
7. SKU: `grwm-studio-ios-001` (anything unique to you)
8. User Access: **Full Access**
9. Click **Create**.

### 3.3 Mark as Made for Kids

Critical for COPPA compliance and review. Browser-only:

1. In the new App Store Connect record, navigate to **App Information**
2. Under **Age Rating** > **Edit**, complete the questionnaire honestly. Set **Made for Kids** = Yes.
3. Set primary age band = **6–8** (or **9–11** depending on your target).

### 3.4 Configure StoreKit subscription products

Browser-only, but you'll mirror these in a local StoreKit configuration file (§4.6).

1. In App Store Connect, **Subscriptions** > **+** > Create a subscription group: **Studio Pro**
2. Add subscription **Studio Pro Monthly**:
   - Product ID: `studio.pro.monthly`
   - Reference Name: `Studio Pro Monthly`
   - Price: $4.99/mo (set in your tier)
   - Localization: EN — Display Name: "Studio Pro", Description: "Unlock all looks, longer recordings, unlimited locker."
3. Add subscription **Studio Pro Yearly**:
   - Product ID: `studio.pro.yearly`
   - Reference Name: `Studio Pro Yearly`
   - Price: $39.99/yr (~33% savings vs monthly)
   - Same localization.

### 3.5 Set up Sandbox tester

For testing paywall flows without real charges. Browser-only:

1. App Store Connect > **Users and Access** > **Sandbox Testers** > **+**
2. Create a tester with a fake email like `grwm-tester-01@yourdomain.com`. Note the password.
3. On your physical test device: Settings > Developer > Sandbox Apple ID > sign in with this tester.

---

## §4 — Repo bootstrap

> Goal: empty repo on disk → first successful `xcodebuild` against an empty SwiftUI app.

### 4.1 Create the repo

```bash
mkdir grwm-studio-ios && cd grwm-studio-ios
git init
git lfs install
git lfs track "*.deepar" "*.ttf" "*.otf" "*.mp3" "*.mov" "*.mp4"
git add .gitattributes
git commit -m "Initialize repo with LFS tracking"

# Create remote (GitHub example):
gh repo create grwm-studio-ios --private --source=. --remote=origin
git push -u origin main
```

### 4.2 Project skeleton (NOT the Xcode project itself yet — that's GRWM-001)

```bash
# This builds the directory layout. The actual Xcode project file is created
# by Codex in ticket GRWM-001 — DO NOT manually create the .xcodeproj.

mkdir -p Config GRWMStudio/{App,DesignSystem/{PhoneShell,Stickers},DeepAR}
mkdir -p GRWMStudio/{Onboarding,Mirror,Capture,Library,Locker,Profile,Feed}
mkdir -p GRWMStudio/{Commerce,Settings,Errors,Persistence,Permissions,Analytics,Utilities}
mkdir -p GRWMStudio/Resources/{Effects/thumbnails,Fonts,Sounds,Avatars}
mkdir -p GRWMStudio/Resources/Assets.xcassets
mkdir -p GRWMStudioTests/{DesignSystem,DeepAR,Permissions,Persistence,Capture,Commerce,Feed,Onboarding,Mirror}
mkdir -p GRWMStudioUITests/Helpers
mkdir -p Scripts fastlane docs .github/workflows

# Placeholder files so git tracks empty dirs:
find GRWMStudio GRWMStudioTests GRWMStudioUITests Config Scripts -type d -exec touch {}/.gitkeep \;
```

### 4.3 Drop the foundational config files

```bash
# .gitignore
cat > .gitignore <<'EOF'
# Xcode
build/
DerivedData/
*.xcuserstate
*.xcscheme
xcuserdata/
*.swp
.DS_Store

# CocoaPods (we don't use them but just in case)
Pods/

# Swift Package Manager
.build/
Package.resolved

# Secrets
Config/Secrets.xcconfig

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/
fastlane/test_output/

# IDE
.vscode/
.idea/

# misc
.env
*.log
EOF

# Secrets template
cat > Config/Secrets.example.xcconfig <<'EOF'
// Copy to Secrets.xcconfig and fill in real values. NEVER commit Secrets.xcconfig.
DEEPAR_LICENSE_KEY = your_deepar_license_key_here
EOF

# Initial empty Secrets.xcconfig (user fills in real key in §2.3)
cat > Config/Secrets.xcconfig <<'EOF'
DEEPAR_LICENSE_KEY = 
EOF

# Debug + Release xcconfig
cat > Config/Debug.xcconfig <<'EOF'
#include "Secrets.xcconfig"
SWIFT_ACTIVE_COMPILATION_CONDITIONS = $(inherited) DEBUG
GCC_PREPROCESSOR_DEFINITIONS = $(inherited) DEBUG=1
EOF

cat > Config/Release.xcconfig <<'EOF'
#include "Secrets.xcconfig"
SWIFT_OPTIMIZATION_LEVEL = -O
EOF

# SwiftLint config
cat > .swiftlint.yml <<'EOF'
disabled_rules:
  - trailing_whitespace
  - todo

opt_in_rules:
  - empty_count
  - explicit_init
  - first_where
  - force_unwrapping
  - implicitly_unwrapped_optional
  - missing_docs
  - prefer_self_type_over_type_of_self
  - redundant_nil_coalescing
  - sorted_imports
  - unused_import

line_length:
  warning: 140
  error: 200
  ignores_urls: true
  ignores_comments: true

force_unwrapping:
  severity: warning

implicitly_unwrapped_optional:
  severity: warning

missing_docs:
  severity: warning
  excludes_inherited_types: true

excluded:
  - Pods
  - .build
  - DerivedData
  - GRWMStudio/Resources
EOF

# Lint runner script
cat > Scripts/lint.sh <<'EOF'
#!/bin/sh
if which swiftlint > /dev/null; then
  swiftlint --strict
else
  echo "warning: SwiftLint not installed. brew install swiftlint"
  exit 0
fi
EOF
chmod +x Scripts/lint.sh

# DeepAR isolation enforcement script
cat > Scripts/verify-deepar-isolation.sh <<'EOF'
#!/bin/sh
# Fails the build if `import DeepAR` appears outside the DeepAR/ folder.
set -eu
OFFENDERS=$(grep -lr --include="*.swift" "^import DeepAR" GRWMStudio/ \
  | grep -v "^GRWMStudio/DeepAR/" || true)
if [ -n "$OFFENDERS" ]; then
  echo "error: DeepAR is imported outside GRWMStudio/DeepAR/:"
  echo "$OFFENDERS"
  exit 1
fi
EOF
chmod +x Scripts/verify-deepar-isolation.sh

# README seed
cat > README.md <<'EOF'
# GRWM Studio (iOS)

A kids' AR makeup mirror for iPhone, built on the DeepAR iOS SDK.

## Getting started

1. Clone with LFS: `git clone … && git lfs pull`
2. `cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig`
3. Fill in `DEEPAR_LICENSE_KEY` in `Config/Secrets.xcconfig`.
4. Open `GRWMStudio.xcodeproj` in Xcode 16+.
5. Run on iPhone simulator or device.

## License

Proprietary. © 2026 GRWM Studio.
EOF

# Commit the skeleton
git add -A
git commit -m "Bootstrap repo skeleton (configs, scripts, gitignore)"
git push
```

### 4.4 Drop the design pack into the repo (for reference)

```bash
mkdir -p docs/design-source/v3
# Copy the unzipped contents of get_ready_with_me-2.zip into docs/design-source/v3/
# Codex prompts reference these JSX files by relative path:
#   docs/design-source/v3/v01-mirror.jsx
#   docs/design-source/v3/dh-screens-1.jsx
#   ...etc

git add docs/design-source/
git commit -m "Add v3 design source for reference"
git push
```

### 4.5 Drop the DeepAR free pack into the repo

```bash
mkdir -p GRWMStudio/Resources/Effects/_source
# Copy contents of Free.v1.3/ into GRWMStudio/Resources/Effects/_source/Free.v1.3/
# (the _source directory holds the original artist files; the .deepar files
#  used at runtime live one level up at GRWMStudio/Resources/Effects/)

# For now, copy the runtime files into place:
cp GRWMStudio/Resources/Effects/_source/Free.v1.3/baseBeauty.deepar \
   GRWMStudio/Resources/Effects/baseBeauty.deepar
cp GRWMStudio/Resources/Effects/_source/Free.v1.3/Looks/look1.deepar \
   GRWMStudio/Resources/Effects/look_legacy01.deepar
cp GRWMStudio/Resources/Effects/_source/Free.v1.3/Looks/look2.deepar \
   GRWMStudio/Resources/Effects/look_legacy02.deepar

# Verify LFS tracked them:
git status        # the .deepar files should show as LFS-tracked
git add GRWMStudio/Resources/Effects/
git commit -m "Add DeepAR free pack effects"
git push
```

### 4.6 StoreKit configuration file (for offline paywall testing)

```bash
# Codex creates the StoreKit configuration file in ticket GRWM-601.
# After that ticket lands, you can run:
xcrun simctl --set testing storekit list-products  # verify products are registered
```

### 4.7 GitHub Actions CI workflow

```bash
cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.app
      - name: Install SwiftLint
        run: brew install swiftlint
      - name: Lint
        run: ./Scripts/lint.sh
      - name: Verify DeepAR isolation
        run: ./Scripts/verify-deepar-isolation.sh
      - name: Build & Test
        run: |
          set -o pipefail
          xcodebuild test \
            -scheme GRWMStudio \
            -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
            -resultBundlePath TestResults.xcresult \
            | xcbeautify
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: TestResults.xcresult
EOF

git add .github/workflows/ci.yml
git commit -m "Add CI workflow"
git push
```

---

## §5 — Daily build commands (run constantly)

> Goal: things you'll type 100 times a day.

### 5.1 Build

```bash
xcodebuild build \
  -scheme GRWMStudio \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  | xcbeautify
```

### 5.2 Run unit tests

```bash
xcodebuild test \
  -scheme GRWMStudio \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:GRWMStudioTests \
  | xcbeautify
```

### 5.3 Run UI tests

```bash
xcodebuild test \
  -scheme GRWMStudio \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:GRWMStudioUITests \
  | xcbeautify
```

### 5.4 Lint

```bash
./Scripts/lint.sh
```

### 5.5 Verify DeepAR isolation

```bash
./Scripts/verify-deepar-isolation.sh
```

### 5.6 Run on a physical device

```bash
# List connected devices:
xcrun devicectl list devices

# Run (use device ID from above):
xcodebuild build \
  -scheme GRWMStudio \
  -destination 'platform=iOS,id=<DEVICE_ID>' \
  | xcbeautify

# Then in Xcode, hit ⌘R with the device selected. CLI install is fiddly with signing.
```

### 5.7 Reset simulator state

```bash
xcrun simctl shutdown all
xcrun simctl erase all
```

---

## §6 — Effect manifest workflow (when new .deepar files arrive)

> Goal: drop new effects into the repo without code changes.

### 6.1 Add a new .deepar file

```bash
# Copy the new file into the runtime effects folder:
cp /path/to/new_effect.deepar GRWMStudio/Resources/Effects/look_newEffect.deepar

# Add a 720×720 thumbnail PNG:
cp /path/to/thumbnail.png GRWMStudio/Resources/Effects/thumbnails/newEffect.png

# Verify LFS picked it up:
git status   # should show as LFS-tracked

# Edit GRWMStudio/Resources/Effects/manifest.json — append a new entry under "looks":
# {
#   "id": "newEffect",
#   "displayName": "New Effect",
#   "category": "looks",
#   "file": "look_newEffect.deepar",
#   "thumbnail": "thumbnails/newEffect.png",
#   "tag": "BOLD",
#   "isPro": false
# }

# Validate the JSON:
jq . GRWMStudio/Resources/Effects/manifest.json > /dev/null
echo "manifest valid"

# Commit:
git add GRWMStudio/Resources/Effects/
git commit -m "Add 'New Effect' to looks library"
git push
```

### 6.2 Add a new per-category effect (e.g., a new Cheeks blush style)

Same as 6.1 but `"category": "cheeks"` and the manifest entry must reference the parameter map node names. See DEEPAR-INTEGRATION.md §5 for the schema.

### 6.3 Validate the parameter map covers all effects

```bash
# After adding a new effect, run the integration test:
xcodebuild test \
  -scheme GRWMStudio \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:GRWMStudioTests/EffectCatalogTests \
  | xcbeautify
# Tests will fail if any manifest entry references a parameter map node that doesn't exist,
# or if a shipped .deepar file isn't referenced in the manifest.
```

---

## §7 — Beta release (TestFlight)

> Goal: ship a build to internal testers.

### 7.1 Bump version

```bash
./Scripts/bump-version.sh patch    # 1.0.0 -> 1.0.1
# or `minor` or `major`
```

### 7.2 Archive

```bash
xcodebuild archive \
  -scheme GRWMStudio \
  -destination 'generic/platform=iOS' \
  -archivePath build/GRWMStudio.xcarchive \
  | xcbeautify
```

### 7.3 Export IPA

```bash
xcodebuild -exportArchive \
  -archivePath build/GRWMStudio.xcarchive \
  -exportPath build/ \
  -exportOptionsPlist fastlane/ExportOptions.plist \
  | xcbeautify
```

### 7.4 Upload to App Store Connect

```bash
# Easiest: use Xcode's Organizer (Window > Organizer > select archive > Distribute App)

# CLI alternative (requires App Store Connect API key — set up via fastlane match or
# manually via App Store Connect > Users and Access > Keys):
xcrun altool --upload-app \
  --type ios \
  --file build/GRWMStudio.ipa \
  --apiKey YOUR_KEY_ID \
  --apiIssuer YOUR_ISSUER_ID
```

### 7.5 fastlane shortcut (after Phase 9 ticket sets it up)

```bash
fastlane beta
# Bumps build number, archives, exports, uploads, posts to internal TestFlight.
```

---

## §8 — Production release

> Goal: submit to App Review.

### 8.1 Pre-submission checklist (browser-only)

Open `09-LAUNCH-CHECKLIST.md` and run through every item before submitting.

### 8.2 Submit

```bash
# After uploading the build via §7:
# 1. Go to https://appstoreconnect.apple.com/apps
# 2. Select GRWM Studio
# 3. Under "App Store" > prepare a new version with:
#    • Build (the one you just uploaded)
#    • Screenshots (6.7" iPhone is mandatory; iPad optional since iPhone-only)
#    • App description, keywords, support URL, marketing URL
#    • App Privacy questionnaire (see LAUNCH-CHECKLIST.md §3)
#    • Age Rating questionnaire (Made for Kids = Yes; see §3.3 above)
#    • Pricing & Availability
# 4. Submit for Review.
```

### 8.3 Monitor review

```bash
# Daily: refresh https://appstoreconnect.apple.com/apps and check status.
# First-time kids-category review takes 1–2 weeks. Subsequent reviews ~1–3 days.
# If rejected, response is via Resolution Center on the same page.
```

---

## §9 — Troubleshooting

### "DeepAR.framework not found"

```bash
# SwiftPM cache cleanup:
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .build
# Re-resolve in Xcode: File > Packages > Reset Package Caches
```

### "Invalid bundle ID for DeepAR license"

The license key in `Secrets.xcconfig` must match the bundle ID in the developer portal exactly. Both must be `app.grwmstudio.ios`.

### "git lfs files not found after clone"

```bash
git lfs install
git lfs pull
```

### "Provisioning profile doesn't include the bundle ID"

```bash
# In Xcode: Project > Signing & Capabilities > "Automatically manage signing" should be ON
# during development. Switch to manual + match for CI/release.
```

### Simulator face-tracking quality is bad

That's expected. The simulator can't run face tracking — DeepAR uses the front camera. Test face tracking on a physical device.

---

## §10 — Useful one-liners

```bash
# Count Swift source files
find GRWMStudio -name "*.swift" -not -path "*/Resources/*" | wc -l

# Find TODOs
grep -rn "TODO\|FIXME" GRWMStudio --include="*.swift"

# Find force unwraps (should be near zero in production code)
grep -rn '\!' GRWMStudio --include="*.swift" | grep -v '!='

# List all .deepar effect files in bundle
ls -la GRWMStudio/Resources/Effects/*.deepar

# Validate manifest.json
jq . GRWMStudio/Resources/Effects/manifest.json

# Show project file count by directory
find GRWMStudio -name "*.swift" -not -path "*/Resources/*" \
  | awk -F/ '{print $2}' | sort | uniq -c | sort -rn

# Open the Xcode project from terminal
open GRWMStudio.xcodeproj
```
