import SwiftUI

extension AvatarSwatch {
    var fill: Color {
        switch self {
        case .pink:
            DH.pink
        case .lavender:
            DH.lavender
        case .butter:
            DH.butter
        case .mint:
            DH.mint
        case .peach:
            Color(hex: 0xFFC9AD)
        }
    }

    var accent: Color {
        switch self {
        case .pink:
            DH.pinkDeep
        case .lavender:
            DH.lavenderDeep
        case .butter:
            DH.butterDeep
        case .mint:
            DH.mintDeep
        case .peach:
            Color(hex: 0xD97455)
        }
    }

    var label: String {
        switch self {
        case .pink:
            L10n.string("profile.avatar_swatch.pink")
        case .lavender:
            L10n.string("profile.avatar_swatch.lavender")
        case .butter:
            L10n.string("profile.avatar_swatch.butter")
        case .mint:
            L10n.string("profile.avatar_swatch.mint")
        case .peach:
            L10n.string("profile.avatar_swatch.peach")
        }
    }
}
