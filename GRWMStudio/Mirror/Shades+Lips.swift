import SwiftUI

private struct LipColorOption {
    let id: String
    let name: String
    let swatchColor: Color
    let rgba: RGBA
}

extension Shade {
    private static let lipColorOptions: [LipColorOption] = [
        LipColorOption(id: "pink", name: "Pink", swatchColor: Color(hex: 0xFF8CCB), rgba: RGBA(1.00, 0.34, 0.67, 0.90)),
        LipColorOption(id: "purple", name: "Purple", swatchColor: Color(hex: 0xA77DFF), rgba: RGBA(0.64, 0.42, 1.00, 0.88)),
        LipColorOption(id: "gold", name: "Gold", swatchColor: Color(hex: 0xFFD66B), rgba: RGBA(1.00, 0.74, 0.18, 0.82)),
        LipColorOption(id: "teal", name: "Teal", swatchColor: Color(hex: 0x62D6CA), rgba: RGBA(0.18, 0.78, 0.76, 0.82)),
        LipColorOption(id: "brown", name: "Brown", swatchColor: Color(hex: 0x8A5A3C), rgba: RGBA(0.48, 0.28, 0.16, 0.86)),
        LipColorOption(id: "blue", name: "Blue", swatchColor: Color(hex: 0x74B6FF), rgba: RGBA(0.24, 0.48, 1.00, 0.84))
    ]

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
        )
    ] + lipColorOptions.map { option in
        lipTint(
            id: "lip.\(option.id)",
            name: option.name,
            swatchColor: option.swatchColor,
            rgba: option.rgba
        )
    } + [
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

    private static func lipTint(id: String, name: String, swatchColor: Color, rgba: RGBA) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "lips",
            parameters: [
                EffectParam(ref: "lipsTexture", value: .tintedTexture("lips_matte", rgba)),
                EffectParam(ref: "lipsEnabled", value: .enabled(true))
            ],
            isPro: false
        )
    }
}
