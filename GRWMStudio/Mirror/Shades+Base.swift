import SwiftUI

extension Shade {
    static let baseShades: [Shade] = [
        Shade(
            id: "base.none",
            name: "None",
            swatchColor: DH.cream,
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "foundationAmount", value: .blendshape(0))],
            isPro: false
        ),
        base(id: "base.soft", name: "Soft", swatchColor: DH.pinkLight, rgba: RGBA(1.0, 0.86, 0.78, 1), amount: 0.42),
        base(id: "base.glow", name: "Glow", swatchColor: DH.butter, rgba: RGBA(1.0, 0.78, 0.58, 1), amount: 0.56),
        base(id: "base.glam", name: "Glam", swatchColor: DH.lavender, rgba: RGBA(0.96, 0.70, 0.92, 1), amount: 0.68)
    ]

    private static func base(id: String, name: String, swatchColor: Color, rgba: RGBA, amount: Float) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "foundationColor", value: .color(rgba)),
                EffectParam(ref: "foundationAmount", value: .blendshape(amount))
            ],
            isPro: false
        )
    }
}
