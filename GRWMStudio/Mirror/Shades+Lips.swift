import SwiftUI

extension Shade {
    static let lipShades: [Shade] = [
        Shade(
            id: "lip.classic-red",
            name: "Classic Red",
            swatchColor: Color(hex: 0xCE1F3A),
            effectID: "lips",
            parameters: [
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
                EffectParam(ref: "lipsTexture", value: .texture("lips_matte")),
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
                EffectParam(ref: "lipsTexture", value: .texture("lips_satin")),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: true
        )
    ]
}
