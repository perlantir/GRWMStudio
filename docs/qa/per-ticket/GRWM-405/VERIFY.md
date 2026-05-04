# GRWM-405 Pro Recording Gate Verification

Date: 2026-05-03

## Decision

GRWM-405 is intentionally superseded.

## Reason

The original ticket specified an 8s non-Pro recording cap and a Pro upsell gate for longer videos. During real-device testing, the product direction changed to camera-style recording: users choose Photo or Video, tap Record to start, tap again to stop, and recording should not have an arbitrary GRWM-imposed time limit.

## Outcome

- No Pro recording cap was added.
- No "Want longer videos?" upsell sheet was added.
- GRWM-404 records the visible elapsed time without a cap.
- Future storage or platform limits should surface as capture/save error variants, not as a Pro feature gate.

## Evidence

- See GRWM-403 follow-up evidence for unlimited recording behavior.
- See GRWM-404 evidence for the uncapped recording overlay.
