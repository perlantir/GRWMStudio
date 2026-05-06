# GRWM-751 VERIFY

Ticket: `GRWM-751 - Manage subscription deep link wiring`

## Evidence

- `RootCoordinator.executeParentGateIntent(_:)` debounces URL-opening intents for one second.
- Manage purchases routes to `PurchaseLinks.managePurchases`.
- Refund and privacy/help/terms links route through the parent gate and open with `UIApplication.shared.open`.
- URL-open failure surfaces a kid-friendly toast through `RootCoordinator.showToast`.
- Delete-all routes through `.deleteAllRequested` notification for the settings screen.

## Artifacts

- `docs/qa/phase-8-10-unit.log`
- `docs/qa/phase-8-10-ui.log`
