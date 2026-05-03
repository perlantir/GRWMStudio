import SwiftUI

extension Shade {
    static let skinShades: [Shade] = [
        Shade(
            id: "skin.fair",
            name: "Fair",
            swatchColor: Color(hex: 0xFAD9C8),
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "foundationColor", value: .color(RGBA(0.98, 0.85, 0.78, 1)))],
            isPro: false
        ),
        Shade(
            id: "skin.light",
            name: "Light",
            swatchColor: Color(hex: 0xEFC0A4),
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "foundationColor", value: .color(RGBA(0.93, 0.75, 0.64, 1)))],
            isPro: false
        ),
        Shade(
            id: "skin.medium",
            name: "Medium",
            swatchColor: Color(hex: 0xCB956E),
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "foundationColor", value: .color(RGBA(0.79, 0.58, 0.43, 1)))],
            isPro: false
        ),
        Shade(
            id: "skin.tan",
            name: "Tan",
            swatchColor: Color(hex: 0xA4724B),
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "foundationColor", value: .color(RGBA(0.64, 0.45, 0.29, 1)))],
            isPro: false
        ),
        Shade(
            id: "skin.deep",
            name: "Deep",
            swatchColor: Color(hex: 0x6F4326),
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "foundationColor", value: .color(RGBA(0.43, 0.26, 0.15, 1)))],
            isPro: false
        ),
        Shade(
            id: "skin.rich",
            name: "Rich",
            swatchColor: Color(hex: 0x42221A),
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "foundationColor", value: .color(RGBA(0.26, 0.13, 0.10, 1)))],
            isPro: false
        )
    ]
}
