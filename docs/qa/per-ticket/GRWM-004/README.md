# GRWM-004 QA Evidence

## Scope

- Added `DH.ChunkyShadow` with `solidColor`, `solidOffset`, `blurColor`, `blurRadius`, and `blurY`.
- Added `.sm`, `.md`, and `.lg` presets matching the V01 shadow table.
- Added `View.chunkyShadow(_:)` and `View.chunkyShadow(_:shape:)`.
- Added `DH.chunkyShadowedRect(cornerRadius:size:fillColor:shadowColor:)`.
- Added previews for three shadow sizes and the generic image modifier case.

## Verification

- `xcodebuild-build.txt`: app build passes and compiles `DH+ChunkyShadow.swift`.
- `swiftlint.txt`: pass, 0 violations across 8 Swift files.
- `deepar-isolation.txt`: pass.
