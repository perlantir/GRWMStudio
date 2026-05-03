import SwiftUI

extension Shade {
    static let browShades: [Shade] = [
        brow(id: "brow.blonde", name: "Blonde", swatchColor: Color(hex: 0xD7B46A), rgba: RGBA(0.72, 0.52, 0.24, 0.85)),
        brow(id: "brow.brown", name: "Brown", swatchColor: Color(hex: 0x7B4A2D), rgba: RGBA(0.38, 0.22, 0.12, 0.88)),
        brow(id: "brow.darkBrown", name: "Dark Brown", swatchColor: Color(hex: 0x4C2B1D), rgba: RGBA(0.22, 0.12, 0.08, 0.9)),
        brow(id: "brow.black", name: "Black", swatchColor: Color(hex: 0x21171A), rgba: RGBA(0.08, 0.06, 0.06, 0.9)),
        brow(id: "brow.softPink", name: "Soft Pink", swatchColor: Color(hex: 0xF4A6C8), rgba: RGBA(0.9, 0.45, 0.62, 0.65))
    ]

    private static func brow(id: String, name: String, swatchColor: Color, rgba: RGBA) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "brows",
            parameters: [
                EffectParam(ref: "browColor", value: .color(rgba)),
                EffectParam(ref: "browTexture", value: .texture("brows_natural")),
                EffectParam(ref: "browEnabled", value: .enabled(true))
            ],
            isPro: false
        )
    }
}
