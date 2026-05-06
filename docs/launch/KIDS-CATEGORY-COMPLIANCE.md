# Kids Category Compliance

Status: In progress, code path aligned for launch hardening

| Requirement | Status | Evidence |
|-------------|--------|----------|
| No third-party advertising | ✅ | `Scripts/audit-third-party-sdks.sh`; app includes DeepAR only |
| No third-party analytics | ✅ | No Firebase / Sentry / Crashlytics / Bugsnag imports; OSLog only |
| No behavioral tracking | ✅ | `GRWMStudio/Resources/PrivacyInfo.xcprivacy` sets `NSPrivacyTracking = false` |
| Data not collected | ✅ | Privacy manifest collected-data array is empty; on-device only persistence |
| Parent gate for purchases | ✅ | Parent gate wraps paywall presentation and purchase-entry points |
| Parent gate for external links | ✅ | Settings and paywall links route through `ParentGateIntent.privacyDeepLink` |
| Parent gate for Save to Photos | ✅ | Preview + Locker/Feed export routes use `ParentGateIntent.saveToPhotos` before Photos writes |
| No social / UGC sharing | ✅ | Generic share-sheet routes removed from preview and Save/Share flow; Feed is local-only |
| No "rate this app" prompt | ✅ | No `SKStoreReviewController` usage in app source |
| Age band for ASC | ⏳ Manual | Set to `6–8` in App Store Connect during submission prep |
| Privacy nutrition label | ⏳ Manual | Must be entered as `Data Not Collected` to match manifest |

## Notes

- Feed is a private on-device memory surface, not a public or networked social feed.
- The app does not upload photos, videos, or face landmarks.
- Export is limited to parent-gated Save to Photos.
- Remaining manual launch work lives in App Store Connect, not in app code.
