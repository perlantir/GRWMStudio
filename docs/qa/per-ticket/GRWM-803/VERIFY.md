# GRWM-803 VERIFY

Ticket: `GRWM-803 - Error variant: License + Effect-Fail`

## Evidence

- `ErrorVariant.license`, `ErrorVariant.licenseInvalid`, and `ErrorVariant.effectFail` expose localized title, body, CTA, alternate CTA, tone, emoji, and sticker data.
- Mirror effect-loading and entitlement failures route to the corresponding error variants.
- Error screenshot automation includes the public license and effect-fail variants.

## Artifacts

- `docs/qa/error-screenshots/license.png`
- `docs/qa/error-screenshots/effect-fail.png`
- `docs/qa/phase-8-10-ui.log`
