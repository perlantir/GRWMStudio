# Manual QA Matrix

Phase 11 requires a real-device manual pass before each TestFlight build. This matrix is intentionally broader than the simulator and Maestro smoke suites because DeepAR face tracking, recording, Photos save, StoreKit sandbox, and permission recovery need human/device verification.

| Area | iPhone 12 mini | iPhone 14 | iPhone 16 | iPhone 16 Pro Max | Evidence |
|---|---|---|---|---|---|
| Cold start to mirror <= 2s | Pending | Pending | Pending | Pending | Screenshot/video |
| Onboarding all paths | Pending | Pending | Pending | Pending | Checklist |
| Mirror all 7 categories | Pending | Pending | Pending | Pending | Screen recording |
| Eye shadow/liner/lashes no bridge artifact | Pending | Pending | Pending | Pending | Face close/mid/far screenshots |
| Photo capture -> preview -> save -> Locker | Pending | Pending | Pending | Pending | Photo + locker screenshot |
| Video capture -> preview playback -> save -> Photos | Pending | Pending | Pending | Pending | Saved video |
| All 9 error variants | Pending | Pending | Pending | Pending | Error screenshots |
| Camera/mic/photos denied recovery | Pending | Pending | Pending | Pending | Settings toggles |
| Feed read-only curated content | Pending | Pending | Pending | Pending | Feed screenshot |
| Looks Pro gate and close path | Pending | Pending | Pending | Pending | StoreKit screenshot |
| Locker delete and detail share | Pending | Pending | Pending | Pending | Before/after screenshots |
| Settings sound/haptics/save/share toggles | Pending | Pending | Pending | Pending | Settings screenshots |
| Offline, 3G, wifi | Pending | Pending | Pending | Pending | Network condition notes |
| Low Power Mode/background/resume | Pending | Pending | Pending | Pending | Screen recording |
| French/Japanese/Hindi device locale fallback | Pending | Pending | Pending | Pending | English fallback screenshots |

## Sign-Off

Tester:

Build:

Date:

Known issues:
