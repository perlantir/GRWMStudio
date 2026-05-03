# GRWM-105 Verification

## Scope

Implemented `EffectParameterMap` with every documented ref from `05-DEEPAR-INTEGRATION.md` section 4, added parameter-map tests, and created `docs/PARAMETER-MAP-SHEET.md` for the DeepAR artist contract.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| Source node inspection | PASS | `effect.json` is an object/tree, so the ticket's array-oriented jq command fails. Recursive name inspection found `face_makeup`, `PostprocessLUT`, `eyeshadow`, `eyeliner`, `eyelashes`, and `lips`. |
| Placeholder review | PASS | `browMesh` and `blushMesh` are not present in the free pack and remain marked with `VERIFY` comments for the larger pack. |
| `./Scripts/lint.sh` | PASS | 0 violations. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | DeepAR imports remain confined to `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` | PASS | Device compile/link verification without signing. |
| Effect bundle layout check | PASS | Runtime `.deepar` files are copied to `GRWMStudio.app/Effects/` and `_source` is not bundled. |
| `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/EffectParameterMapTests -only-testing:GRWMStudioTests/DeepARControllerEffectTests` | PASS | iPhone 16 Pro simulator, iOS 18.3.1, x86_64. Result bundle reports 5 passed, 0 failed, 0 skipped. |

## Notes

- Node placeholders were updated to the actual free-pack node names where present: `face_makeup`, `PostprocessLUT`, `eyeshadow`, `eyeliner`, `eyelashes`, and `lips`.
- Material inspection found that some free-pack uniforms differ from the app contract, especially foundation (`softColor`, `softtex`, `masktex`) and lips (`s_texColor` only). `docs/PARAMETER-MAP-SHEET.md` flags these for GRWM-106 device/runtime verification.
- No screenshot was captured for GRWM-105 because this ticket has no visible UI.
