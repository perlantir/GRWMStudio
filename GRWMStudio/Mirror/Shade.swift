import SwiftUI

struct Shade: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let swatchColor: Color
    let effectID: EffectFile.ID
    let parameters: [EffectParam]
    let isPro: Bool

    var localizedName: String {
        L10n.string("mirror.shade.\(id.replacingOccurrences(of: ".", with: "_"))", fallback: name)
    }
}

struct EffectParam: Hashable, Sendable {
    let ref: String
    let value: ParamValue
}

enum ParamValue: Hashable, Sendable {
    case color(RGBA)
    case texture(String)
    case tintedTexture(String, RGBA)
    case blendshape(Float)
    case enabled(Bool)
}

struct RGBA: Hashable, Sendable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
