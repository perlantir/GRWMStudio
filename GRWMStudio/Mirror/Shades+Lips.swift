import SwiftUI

extension Shade {
    static let lipShades: [Shade] = [
        Shade(
            id: "lip.classic-red",
            name: "Classic Red",
            swatchColor: Color(hex: 0xCE1F3A),
            effectID: "lips",
            parameters: [
                EffectParam(ref: "lipsColor", value: .color(RGBA(0.81, 0.12, 0.23, 1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_matte")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: false
        ),
        Shade(
            id: "lip.petal-pink",
            name: "Petal Pink",
            swatchColor: Color(hex: 0xFF8BB8),
            effectID: "lips",
            parameters: [
                EffectParam(ref: "lipsColor", value: .color(RGBA(1.0, 0.55, 0.72, 0.95))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_gloss")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: false
        ),
        Shade(
            id: "lip.nude",
            name: "Nude",
            swatchColor: Color(hex: 0xC79A82),
            effectID: "lips",
            parameters: [
                EffectParam(ref: "lipsColor", value: .color(RGBA(0.78, 0.60, 0.51, 0.85))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_satin")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: false
        ),
        Shade(
            id: "lip.berry",
            name: "Berry",
            swatchColor: Color(hex: 0x8C2A4C),
            effectID: "lips",
            parameters: [
                EffectParam(ref: "lipsColor", value: .color(RGBA(0.55, 0.16, 0.30, 1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_matte")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: false
        ),
        Shade(
            id: "lip.coral",
            name: "Coral",
            swatchColor: Color(hex: 0xFF6F5A),
            effectID: "lips",
            parameters: [
                EffectParam(ref: "lipsColor", value: .color(RGBA(1.0, 0.43, 0.35, 0.95))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_satin")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: false
        ),
        Shade(
            id: "lip.plum",
            name: "Plum",
            swatchColor: Color(hex: 0x4B1640),
            effectID: "lips",
            parameters: [
                EffectParam(ref: "lipsColor", value: .color(RGBA(0.29, 0.09, 0.25, 1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_matte")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: true
        ),
        Shade(
            id: "lip.neon-pink",
            name: "Neon Pink",
            swatchColor: Color(hex: 0xFF1E8E),
            effectID: "lips",
            parameters: [
                EffectParam(ref: "lipsColor", value: .color(RGBA(1.0, 0.12, 0.55, 1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_gloss")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: true
        ),
        Shade(
            id: "lip.disco-brat",
            name: "Disco Brat",
            swatchColor: Color(hex: 0xC09BFF),
            effectID: "lips",
            parameters: [
                EffectParam(ref: "lipsColor", value: .color(RGBA(0.75, 0.61, 1.0, 1.0))),
                EffectParam(ref: "lipsTexture", value: .texture("lips_glitter")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: true
        )
    ]
}
