# GRWM-001 QA Evidence

## Automated Build

Command:

```sh
xcodebuild build -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' | xcbeautify
```

Result: `Build Succeeded` with no warnings or errors. Full output is saved in `xcodebuild-build.txt`.

## Visual Smoke

- Simulator: iPhone 16, iOS 26.4 latest runtime.
- App bundle: `app.grwmstudio.ios`.
- Observed screen: solid placeholder pink, no default `Hello, world!` label.
- Screenshot: `placeholder-pink.png`.

## Static Checks

- `Scripts/verify-deepar-isolation.sh`: pass.
- `Scripts/lint.sh`: pass, 0 violations across 4 Swift files.
- Extra sanity: `xcodebuild test -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' | xcbeautify`: pass, 2 tests, 0 failures. Full output is saved in `xcodebuild-test.txt`.
