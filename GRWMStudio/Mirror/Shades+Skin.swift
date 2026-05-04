import SwiftUI

extension Shade {
    static let skinShades: [Shade] = [
        skin(id: "skin.fair", name: "Fair", swatchColor: Color(hex: 0xFAD9C8), rgba: RGBA(0.98, 0.85, 0.78, 1)),
        skin(id: "skin.light", name: "Light", swatchColor: Color(hex: 0xEFC0A4), rgba: RGBA(0.93, 0.75, 0.64, 1)),
        skin(id: "skin.medium", name: "Medium", swatchColor: Color(hex: 0xCB956E), rgba: RGBA(0.79, 0.58, 0.43, 1)),
        skin(id: "skin.tan", name: "Tan", swatchColor: Color(hex: 0xA4724B), rgba: RGBA(0.64, 0.45, 0.29, 1)),
        skin(id: "skin.deep", name: "Deep", swatchColor: Color(hex: 0x6F4326), rgba: RGBA(0.43, 0.26, 0.15, 1)),
        skin(id: "skin.rich", name: "Rich", swatchColor: Color(hex: 0x42221A), rgba: RGBA(0.26, 0.13, 0.10, 1))
    ]

    private static func skin(id: String, name: String, swatchColor: Color, rgba: RGBA) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "foundationColor", value: .color(rgba)),
                EffectParam(ref: "foundationAmount", value: .blendshape(1.0))
            ],
            isPro: false
        )
    }
}
