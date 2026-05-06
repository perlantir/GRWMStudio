import SwiftUI

private struct EyeColorOption {
    let id: String
    let name: String
    let swatchColor: Color
    let rgba: RGBA
}

extension Shade {
    static let eyeshadowShades: [Shade] = [
        Shade(
            id: "eyeshadow.none",
            name: "None",
            swatchColor: DH.cream,
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "eyeshadowEnabled", value: .enabled(false))],
            isPro: false
        ),
        eyeshadow(id: "eyeshadow.pink", name: "Pink", swatchColor: Color(hex: 0xFF8CCB), rgba: RGBA(1.00, 0.34, 0.67, 0.72)),
        eyeshadow(id: "eyeshadow.purple", name: "Purple", swatchColor: Color(hex: 0xA77DFF), rgba: RGBA(0.64, 0.42, 1.00, 0.70)),
        eyeshadow(id: "eyeshadow.gold", name: "Gold", swatchColor: Color(hex: 0xFFD66B), rgba: RGBA(1.00, 0.74, 0.18, 0.62)),
        eyeshadow(id: "eyeshadow.teal", name: "Teal", swatchColor: Color(hex: 0x62D6CA), rgba: RGBA(0.18, 0.78, 0.76, 0.58)),
        eyeshadow(id: "eyeshadow.brown", name: "Brown", swatchColor: Color(hex: 0x8A5A3C), rgba: RGBA(0.48, 0.28, 0.16, 0.52)),
        eyeshadow(id: "eyeshadow.blue", name: "Blue", swatchColor: Color(hex: 0x74B6FF), rgba: RGBA(0.24, 0.48, 1.00, 0.58))
    ]

    private static let eyeColorOptions: [EyeColorOption] = [
        EyeColorOption(id: "pink", name: "Pink", swatchColor: Color(hex: 0xFF8CCB), rgba: RGBA(1.00, 0.34, 0.67, 0.72)),
        EyeColorOption(id: "purple", name: "Purple", swatchColor: Color(hex: 0xA77DFF), rgba: RGBA(0.64, 0.42, 1.00, 0.70)),
        EyeColorOption(id: "gold", name: "Gold", swatchColor: Color(hex: 0xFFD66B), rgba: RGBA(1.00, 0.74, 0.18, 0.62)),
        EyeColorOption(id: "teal", name: "Teal", swatchColor: Color(hex: 0x62D6CA), rgba: RGBA(0.18, 0.78, 0.76, 0.58)),
        EyeColorOption(id: "brown", name: "Brown", swatchColor: Color(hex: 0x8A5A3C), rgba: RGBA(0.48, 0.28, 0.16, 0.52)),
        EyeColorOption(id: "blue", name: "Blue", swatchColor: Color(hex: 0x74B6FF), rgba: RGBA(0.24, 0.48, 1.00, 0.58))
    ]

    static let eyelinerShades: [Shade] = [
        Shade(
            id: "eyeliner.none",
            name: "None",
            swatchColor: DH.cream,
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "eyelinerEnabled", value: .enabled(false))],
            isPro: false
        )
    ] + eyeColorOptions.map { option in
        eyelinerColor(
            id: "eyeliner.\(option.id)",
            name: option.name,
            swatchColor: option.swatchColor,
            rgba: option.rgba
        )
    } + [
        eyeliner(id: "eyeliner.classic", name: "Classic", texture: "eyeliner_classic", swatchColor: DH.ink, isPro: false),
        eyeliner(id: "eyeliner.winged", name: "Winged", texture: "eyeliner_winged", swatchColor: DH.lavenderDeep, isPro: true),
        eyeliner(id: "eyeliner.double-flick", name: "Double-Flick", texture: "eyeliner_double_flick", swatchColor: DH.pinkDeep, isPro: true)
    ]

    static let eyelashShades: [Shade] = [
        Shade(
            id: "eyelashes.none",
            name: "None",
            swatchColor: DH.cream,
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "eyelashesEnabled", value: .enabled(false))],
            isPro: false
        )
    ] + eyeColorOptions.map { option in
        eyelashesColor(
            id: "eyelashes.\(option.id)",
            name: option.name,
            swatchColor: option.swatchColor,
            rgba: option.rgba
        )
    } + [
        eyelashes(id: "eyelashes.natural", name: "Natural", texture: "eyelashes_natural", swatchColor: Color(hex: 0x4D291A), isPro: false),
        eyelashes(id: "eyelashes.doll", name: "Doll", texture: "eyelashes_doll", swatchColor: DH.lavender, isPro: true),
        eyelashes(id: "eyelashes.drama", name: "Drama", texture: "eyelashes_drama", swatchColor: DH.recRedDeep, isPro: true)
    ]

    private static func eyeshadow(id: String, name: String, swatchColor: Color, rgba: RGBA) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "eyeshadowEnabled", value: .enabled(true)),
                EffectParam(ref: "eyeshadowColor", value: .color(rgba)),
                EffectParam(ref: "eyeshadowMask", value: .texture("eyeshadow_basic"))
            ],
            isPro: false
        )
    }

    private static func eyeliner(id: String, name: String, texture: String, swatchColor: Color, isPro: Bool) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "eyelinerEnabled", value: .enabled(true)),
                EffectParam(ref: "eyelinerTexture", value: .texture(texture)),
                EffectParam(ref: "eyelinerColor", value: .color(RGBA(1, 1, 1, 1)))
            ],
            isPro: isPro
        )
    }

    private static func eyelinerColor(id: String, name: String, swatchColor: Color, rgba: RGBA) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "eyelinerEnabled", value: .enabled(true)),
                EffectParam(ref: "eyelinerTexture", value: .texture("eyeliner_classic")),
                EffectParam(ref: "eyelinerColor", value: .color(rgba))
            ],
            isPro: false
        )
    }

    private static func eyelashes(id: String, name: String, texture: String, swatchColor: Color, isPro: Bool) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "eyelashesEnabled", value: .enabled(true)),
                EffectParam(ref: "eyelashesTexture", value: .texture(texture)),
                EffectParam(ref: "eyelashesColor", value: .color(RGBA(1, 1, 1, 1)))
            ],
            isPro: isPro
        )
    }

    private static func eyelashesColor(id: String, name: String, swatchColor: Color, rgba: RGBA) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "eyelashesEnabled", value: .enabled(true)),
                EffectParam(ref: "eyelashesTexture", value: .texture("eyelashes_natural")),
                EffectParam(ref: "eyelashesColor", value: .color(rgba))
            ],
            isPro: false
        )
    }
}
