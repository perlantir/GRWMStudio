import SwiftUI

extension Shade {
    static let cheekShades: [Shade] = [
        cheek(id: "cheek.pink", name: "Pink", swatchColor: Color(hex: 0xFFB3C7), rgba: RGBA(1.0, 0.7, 0.78, 0.6)),
        cheek(id: "cheek.peach", name: "Peach", swatchColor: Color(hex: 0xFFC799), rgba: RGBA(1.0, 0.78, 0.6, 0.6)),
        cheek(id: "cheek.coral", name: "Coral", swatchColor: Color(hex: 0xFF998C), rgba: RGBA(1.0, 0.6, 0.55, 0.65)),
        cheek(id: "cheek.mauve", name: "Mauve", swatchColor: Color(hex: 0xD98CB3), rgba: RGBA(0.85, 0.55, 0.7, 0.6)),
        cheek(id: "cheek.berry", name: "Berry", swatchColor: Color(hex: 0xB34D73), rgba: RGBA(0.7, 0.3, 0.45, 0.65))
    ]

    private static func cheek(id: String, name: String, swatchColor: Color, rgba: RGBA) -> Shade {
        Shade(
            id: id,
            name: name,
            swatchColor: swatchColor,
            effectID: "blush",
            parameters: [
                EffectParam(ref: "blushColor", value: .color(rgba)),
                EffectParam(ref: "blushMask", value: .texture("blush_mask")),
                EffectParam(ref: "blushEnabled", value: .enabled(true))
            ],
            isPro: false
        )
    }
}
