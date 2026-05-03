# DeepAR Parameter Map Sheet

This table is the contract between the iOS app and the DeepAR Studio project files. The app uses these exact node names and shader uniform names to apply runtime parameter changes for color, texture, and enable or disable state. When a node or uniform is renamed or removed, runtime makeup controls can break.

## Skin (foundation)

| Ref | Node name | Component | Parameter (uniform) | Type | What it does |
| --- | --- | --- | --- | --- | --- |
| `foundationColor` | `face_makeup` | `MeshRenderer` | `u_color` | Vector4 | Foundation tint RGBA |
| `foundationMask` | `face_makeup` | `MeshRenderer` | `s_texMask` | Texture | Foundation alpha mask |

Free pack note: `face_makeup` exists in `baseBeauty.deeparproj`. The free pack material currently exposes `softColor`, `softtex`, and `masktex`; GRWM-106 must verify whether the larger pack preserves the app contract uniforms above or needs a parameter-name update.

## Base (LUT)

| Ref | Node name | Component | Parameter | Type | What it does |
| --- | --- | --- | --- | --- | --- |
| `lutEnabled` | `PostprocessLUT` | `(none)` | `enabled` | Bool | LUT toggle |
| `lutTexture` | `PostprocessLUT` | `MeshRenderer` | `s_texLut` | Texture | LUT texture |

## Eyes

| Ref | Node name | Component | Parameter | Type | What it does |
| --- | --- | --- | --- | --- | --- |
| `eyeshadowColor` | `eyeshadow` | `MeshRenderer` | `u_color` | Vector4 | Eyeshadow tint RGBA |
| `eyeshadowMask` | `eyeshadow` | `MeshRenderer` | `s_texMask` | Texture | Eyeshadow alpha mask |
| `eyelinerTexture` | `eyeliner` | `MeshRenderer` | `s_texColor` | Texture | Eyeliner texture |
| `eyelinerEnabled` | `eyeliner` | `(none)` | `enabled` | Bool | Eyeliner toggle |
| `eyelashesTexture` | `eyelashes` | `MeshRenderer` | `s_texColor` | Texture | Eyelashes texture |
| `eyelashesEnabled` | `eyelashes` | `(none)` | `enabled` | Bool | Eyelashes toggle |

Free pack note: `eyeshadow`, `eyeliner`, and `eyelashes` exist in `baseBeauty.deeparproj`.

## Brows

| Ref | Node name | Component | Parameter | Type | What it does |
| --- | --- | --- | --- | --- | --- |
| `browColor` | `browMesh` | `MeshRenderer` | `u_color` | Vector4 | Brow tint RGBA |
| `browTexture` | `browMesh` | `MeshRenderer` | `s_texColor` | Texture | Brow texture |
| `browEnabled` | `browMesh` | `(none)` | `enabled` | Bool | Brow toggle |

Free pack note: brow nodes are not present in the free pack. These placeholders are reserved for the larger filter pack.

## Cheeks

| Ref | Node name | Component | Parameter | Type | What it does |
| --- | --- | --- | --- | --- | --- |
| `blushColor` | `blushMesh` | `MeshRenderer` | `u_color` | Vector4 | Blush tint RGBA |
| `blushMask` | `blushMesh` | `MeshRenderer` | `s_texMask` | Texture | Blush alpha mask |
| `blushEnabled` | `blushMesh` | `(none)` | `enabled` | Bool | Blush toggle |

Free pack note: blush nodes are not present in the free pack. These placeholders are reserved for the larger filter pack.

## Lips

| Ref | Node name | Component | Parameter | Type | What it does |
| --- | --- | --- | --- | --- | --- |
| `lipsColor` | `lips` | `MeshRenderer` | `u_color` | Vector4 | Lip tint RGBA |
| `lipsTexture` | `lips` | `MeshRenderer` | `s_texColor` | Texture | Lip texture |
| `lipsEnabled` | `lips` | `(none)` | `enabled` | Bool | Lip toggle |

Free pack note: `lips` exists in `baseBeauty.deeparproj`. The free pack `LipMat` exposes `s_texColor`; GRWM-106 must verify whether lip color uses an updated material in the larger pack.

## Looks (preset full-face)

Looks effects are self-contained. They do not expose runtime parameters in version 1. Switching to a Look effect replaces all per-category effects.

## Versioning

- Version 1: Initial map.
- When the artist publishes a new effect file with new nodes or parameters, increment the manifest version in `GRWMStudio/Resources/Effects/manifest.json`, add new constants to `EffectParameterMap.swift`, and update this sheet.
