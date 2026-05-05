import SwiftUI

struct DHErrorView: View {
    let variant: ErrorVariant
    let onCTA: () -> Void
    let onAlt: () -> Void
    let onClose: () -> Void

    private var tone: ErrorTone {
        variant.tone
    }

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                stops: [
                    .init(color: tone.background, location: 0),
                    .init(color: DH.cream, location: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 18)
                    .padding(.top, 8)

                ZStack(alignment: .topLeading) {
                    heroStack
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)

                    errorChip
                        .padding(.leading, 18)
                        .padding(.top, 130)
                }

                Spacer(minLength: 32)

                ctaStack
                .padding(.horizontal, 18)
                .padding(.bottom, 46)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            DHHaptics.shared.fire(.errorSoft)
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()

            Button {
                DHHaptics.shared.fire(.tap)
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(tone.deep)
                    .frame(width: 44, height: 44)
                    .background(.white, in: Circle())
                    .shadow(color: tone.hero.opacity(0.9), radius: 0, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.string("common.close"))
            .accessibilityHint(L10n.string("errors.close_hint"))
            .accessibilityIdentifier("error-close")
        }
    }

    private var heroStack: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                stops: [
                                    .init(color: .white, location: 0),
                                    .init(color: tone.hero, location: 1)
                                ],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 4,
                                endRadius: 110
                            )
                        )
                        .frame(width: 160, height: 160)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 6)
                        )
                        .shadow(color: tone.deep.opacity(0.9), radius: 0, x: 0, y: 7)
                        .shadow(color: tone.deep.opacity(0.22), radius: 14, x: 0, y: 14)

                    Text(variant.emoji)
                        .font(.system(size: 80))
                }

                variant.sticker
                    .rotationEffect(.degrees(15))
                    .offset(x: 6, y: -6)
            }
            .padding(.top, 6)

            VStack(spacing: 12) {
                Text(variant.title)
                    .font(.custom("Fredoka-Bold", size: 24))
                    .tracking(-0.24)
                    .foregroundStyle(DH.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(variant.sub)
                    .font(.custom("Quicksand-Medium", size: 14))
                    .foregroundStyle(DH.ink.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 28)
        }
    }

    @ViewBuilder
    private var ctaStack: some View {
        let showsAlt = !variant.hidesAltCTAInRelease || isDebugBuild

        VStack(spacing: 10) {
            ErrorActionButton(
                title: variant.ctaLabel,
                style: .primary(hero: tone.hero, deep: tone.deep),
                action: onCTA
            )

            if showsAlt {
                ErrorActionButton(
                    title: variant.altLabel,
                    style: .ghost(deep: tone.deep),
                    action: onAlt
                )
            }
        }
        .frame(maxWidth: showsAlt ? .infinity : 420)
    }

    private var errorChip: some View {
        Text(variant.chipTitle)
            .font(.custom("Fredoka-Bold", size: 9.5))
            .tracking(1.14)
            .foregroundStyle(DH.ink.opacity(0.55))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(DH.ink.opacity(0.08), in: Capsule())
    }

    private var isDebugBuild: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}

private struct ErrorActionButton: View {
    enum Style: Hashable {
        case primary(hero: Color, deep: Color)
        case ghost(deep: Color)
    }

    let title: String
    let style: Style
    let action: () -> Void

    @State private var pressed = false

    private var background: Color {
        switch style {
        case .primary(let hero, _):
            hero
        case .ghost:
            .white.opacity(0.72)
        }
    }

    private var foreground: Color {
        switch style {
        case .primary:
            .white
        case .ghost(let deep):
            deep
        }
    }

    private var deep: Color {
        switch style {
        case .primary(_, let deep):
            deep
        case .ghost(let deep):
            deep.opacity(0.22)
        }
    }

    var body: some View {
        Button {
            DHHaptics.shared.fire(.pop)
            action()
        } label: {
            Text(title)
                .font(DH.font(.buttonLarge))
                .tracking(DH.tracking(.buttonLarge))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background {
                    ZStack {
                        Capsule()
                            .fill(deep)
                            .offset(y: 5)
                        Capsule()
                            .fill(background)
                    }
                    .shadow(color: deep.opacity(0.45), radius: 14, x: 0, y: 7)
                }
                .scaleEffect(pressed ? 0.98 : 1)
                .offset(y: pressed ? 2 : 0)
                .dhAnimation(.quickPop, value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}
