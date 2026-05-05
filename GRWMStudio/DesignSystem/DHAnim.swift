import SwiftUI

enum DHAnim {
    case bouncy
    case softSpring
    case quickPop
    case slowFade
    case stickerWobble
    case heroEmerge
    case countdown
    case progress
    case quickFade
    case snapFade
    case track
    case celebrate
    case pulse

    var animation: Animation {
        switch self {
        case .bouncy:
            .spring(response: 0.4, dampingFraction: 0.65)
        case .softSpring:
            .spring(response: 0.55, dampingFraction: 0.85)
        case .quickPop:
            .spring(response: 0.25, dampingFraction: 0.55)
        case .slowFade:
            .easeInOut(duration: 0.45)
        case .stickerWobble:
            .easeInOut(duration: 1.6).repeatForever(autoreverses: true)
        case .heroEmerge:
            .interpolatingSpring(stiffness: 180, damping: 15)
        case .countdown:
            .spring(response: 0.4, dampingFraction: 0.7)
        case .progress:
            .linear(duration: 1.5)
        case .quickFade:
            .easeOut(duration: 0.18)
        case .snapFade:
            .easeOut(duration: 0.08)
        case .track:
            .easeOut(duration: 0.12)
        case .celebrate:
            .easeOut(duration: 1.2)
        case .pulse:
            .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
        }
    }

    static func respecting(_ kind: DHAnim, reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.01) : kind.animation
    }

    @MainActor
    static func run(_ kind: DHAnim, reduceMotion: Bool, _ updates: @escaping () -> Void) {
        withAnimation(respecting(kind, reduceMotion: reduceMotion), updates)
    }
}

extension View {
    func dhAnimation<V: Equatable>(_ kind: DHAnim, value: V) -> some View {
        modifier(DHAnimationModifier(kind: kind, value: value))
    }
}

struct DHAnimationModifier<V: Equatable>: ViewModifier {
    let kind: DHAnim
    let value: V

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.animation(DHAnim.respecting(kind, reduceMotion: reduceMotion), value: value)
    }
}
