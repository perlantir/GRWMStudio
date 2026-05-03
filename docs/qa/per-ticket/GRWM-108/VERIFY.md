# GRWM-108 Verification

## Scope

Added the production `EffectCatalog` actor, the starter `Resources/Effects/manifest.json`, placeholder thumbnails, launch-time catalog loading, and focused catalog tests.

## Screenshots

| State | Screenshot |
| --- | --- |
| App launch after catalog load | `docs/qa/per-ticket/GRWM-108/catalog-launch-welcome.png` |

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| `jq . GRWMStudio/Resources/Effects/manifest.json` | PASS | Manifest parses as valid JSON. |
| Manifest contents | PASS | Includes `baseBeauty` with 5 skin shades, `noFilter` with `bright` base shade, starter `shadow`, starter `eyeliner`, `lipstick` with 5 shades, and `look_legacy01`/`look_legacy02`. |
| Pro shade coverage | PASS | Skin, base, eyeshadow, eyeliner, and lips rows each include at least one `isPro: true` shade. |
| `./Scripts/lint.sh` | PASS | 0 violations. |
| `./Scripts/verify-deepar-isolation.sh` | PASS | DeepAR imports remain confined to `GRWMStudio/DeepAR/`. |
| `xcodebuild -quiet build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` | PASS | Generic iOS compile/link verification without signing. |
| `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/EffectCatalogTests` | PASS | Verifies manifest load, category coverage, starter shape, parameter ref resolution, effect files, thumbnails, and Pro flags. |
| XcodeBuildMCP simulator run | PASS | Built, installed, and launched on iPhone 16 Pro simulator `BFD7E422-B789-4380-9588-B952559B6A92`, iOS 18.3.1. |
| Computer Use visual smoke | PASS | App advanced from splash to the existing Welcome placeholder instead of routing to `.effectFail`, which confirms launch-time catalog load did not fail. |

## Notes

- Placeholder thumbnails are 720 x 720 PNG files and stage through Git LFS via the repo's `*.png` attribute.
- Brows and cheeks remain placeholder manifest entries because the current free pack lacks those runtime nodes; GRWM-105/106 already document that the larger pack must verify those refs on device.
