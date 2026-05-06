# Privacy Manifest Rationale

## NSPrivacyTracking: false

GRWM Studio does not track users across apps or websites. There are no advertising SDKs, analytics SDKs, fingerprinting systems, or tracking domains in the app.

## NSPrivacyCollectedDataTypes: empty

GRWM Studio does not collect or transmit personal data in v1. Captures, preferences, and saved looks stay on-device. Parent email, when entered, is stored locally only for the on-device experience.

## NSPrivacyAccessedAPITypes

- `NSPrivacyAccessedAPICategoryUserDefaults` / `CA92.1`
  - Used for app functionality such as onboarding progress, sound and haptics toggles, selected tab restoration, and save-to-Photos preference.
- `NSPrivacyAccessedAPICategoryFileTimestamp` / `C617.1`
  - Used for app functionality when sorting saved captures in Locker and Feed by creation time.
- `NSPrivacyAccessedAPICategoryDiskSpace` / `E174.1`
  - Used for app functionality before photo/video save operations so the app can surface the low-storage error state instead of failing silently.

## DeepAR SDK

DeepAR remains the only third-party SDK in the app. Its use is limited to on-device AR face tracking and rendering. The app-side manifest declares no tracking and no collected data. DeepAR framework privacy contents should still be verified at archive time as part of final submission prep.

## Validation Notes

- `PrivacyInfo.xcprivacy` lives in `GRWMStudio/Resources/` and must be present in the target resources.
- App Store Connect's privacy questionnaire should remain aligned with this file: `Data Not Collected`, no tracking, no tracking domains.
