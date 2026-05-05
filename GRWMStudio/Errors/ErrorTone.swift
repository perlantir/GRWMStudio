import SwiftUI

enum ErrorTone: Hashable {
    case pink
    case lav
    case butter
    case mint

    var hero: Color {
        switch self {
        case .pink:
            DH.pink
        case .lav:
            DH.lavender
        case .butter:
            DH.butter
        case .mint:
            DH.mint
        }
    }

    var deep: Color {
        switch self {
        case .pink:
            DH.pinkDeep
        case .lav:
            Color(hex: 0x5A1099)
        case .butter:
            DH.butterDeep
        case .mint:
            DH.mintDeep
        }
    }

    var background: Color {
        switch self {
        case .pink:
            DH.pinkPaper
        case .lav:
            Color(hex: 0xF1E8FF)
        case .butter:
            Color(hex: 0xFFF6E0)
        case .mint:
            Color(hex: 0xE5FFF4)
        }
    }
}
