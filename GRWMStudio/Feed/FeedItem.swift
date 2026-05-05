import Foundation
import SwiftUI

struct FeedItem: Codable, Identifiable, Equatable {
    struct Palette: Codable, Equatable {
        let cardHex: String
        let deepHex: String

        var card: Color { Color(hexString: cardHex) ?? DH.pinkPaper }
        var deep: Color { Color(hexString: deepHex) ?? DH.pinkDeep }
    }

    enum CardHeight: String, Codable {
        case small = "s"
        case medium = "m"
        case large = "l"

        var points: CGFloat {
            switch self {
            case .small:
                168
            case .medium:
                208
            case .large:
                252
            }
        }
    }

    let id: String
    let lookID: String
    let displayTitle: String
    let tagline: String
    let cardHeight: CardHeight
    let palette: Palette
    let hot: Bool
    let hearts: Int
    let featured: Bool

    var localizedDisplayTitle: String {
        L10n.string("feed.item.\(id).title", fallback: displayTitle)
    }

    var localizedTagline: String {
        L10n.string("feed.item.\(id).tagline", fallback: tagline)
    }
}

private extension Color {
    init?(hexString: String) {
        let normalized = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard normalized.count == 6, let hex = UInt32(normalized, radix: 16) else {
            return nil
        }
        self.init(hex: hex)
    }
}
