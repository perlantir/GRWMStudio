import SwiftUI

enum DH {
    static let pink = Color(hex: 0xFF3DA5)
    static let pinkDeep = Color(hex: 0xD4127B)
    static let pinkLight = Color(hex: 0xFFB8DC)
    static let pinkPaper = Color(hex: 0xFFE5F2)
    static let cream = Color(hex: 0xFFF6FA)
    static let butter = Color(hex: 0xFFD66B)
    static let butterDeep = Color(hex: 0xC99B1F)
    static let lavender = Color(hex: 0xC9A8FF)
    static let lavenderDeep = Color(hex: 0x7A53C9)
    static let mint = Color(hex: 0xA8E8C8)
    static let mintDeep = Color(hex: 0x5DBD8E)
    static let ink = Color(hex: 0x3A0E25)
    static let recRed = Color(hex: 0xFF2D5A)
    static let recRedDeep = Color(hex: 0xB41540)

    enum Radius {
        static let chip: CGFloat = 17
        static let card: CGFloat = 24
        static let bigCard: CGFloat = 32
        static let viewport: CGFloat = 36
        static let viewportInner: CGFloat = 28
        static let swatch: CGFloat = 24
        static let tile: CGFloat = 22
    }

    enum Spacing {
        static let hPad: CGFloat = 18
        static let sectionGap: CGFloat = 18
        static let itemGap: CGFloat = 12
        static let tightGap: CGFloat = 8
    }
}
