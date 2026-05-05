import SwiftUI

struct WelcomeView: View {
    @Environment(\.rootCoordinator) private var coordinator

    var body: some View {
        ZStack {
            DHWallpaperStripes(opacity: 0.6)

            VStack(spacing: 0) {
                skipButton
                    .padding(.horizontal, 18)
                    .padding(.top, 4)

                heroCard
                    .padding(.horizontal, DH.Spacing.hPad)
                    .padding(.top, 12)

                headlineBlock
                    .padding(.horizontal, 24)
                    .padding(.top, 18)

                Spacer(minLength: 18)

                pageDots
                    .padding(.bottom, 22)

                ctaBlock
                    .padding(.horizontal, DH.Spacing.hPad)
                    .padding(.bottom, 22)
            }
        }
        .preferredColorScheme(.light)
        .accessibilityElement(children: .contain)
    }

    private var skipButton: some View {
        HStack {
            Spacer()

            Button {
                coordinator.showParentInfo()
            } label: {
                Text("onboarding.welcome.skip")
                    .font(DH.font(.buttonSmall))
                    .tracking(0.08 * DH.TypeStyle.buttonSmall.size)
                    .foregroundStyle(DH.pinkDeep)
                    .padding(.horizontal, 14)
                    .frame(height: 32)
                    .background(Capsule().fill(.white.opacity(0.55)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.string("onboarding.welcome.skip_accessibility"))
        }
    }

    private var heroCard: some View {
        DHCard(bg: DH.pinkLight, deep: DH.pink, cornerRadius: DH.Radius.bigCard, padding: 0) {
            ZStack {
                ScallopTrim()
                    .fill(DH.pinkLight)
                    .frame(height: 14)
                    .offset(y: -7)
                    .frame(maxHeight: .infinity, alignment: .top)

                FaceMock()
                    .frame(width: 246, height: 292)
                    .offset(y: 58)

                StickerSparkle(size: 22, fill: .white)
                    .position(x: 30, y: 30)

                StickerSparkle(size: 16, fill: DH.butter)
                    .position(x: 306, y: 60)

                StickerSparkle(size: 14, fill: .white)
                    .position(x: 24, y: 260)

                heartBubble
                    .position(x: 292, y: 62)
            }
            .frame(height: 340)
            .clipped()
        }
    }

    private var heartBubble: some View {
        ZStack {
            StickerHeart(size: 84, fill: .white, stroke: DH.pinkDeep, strokeWidth: 1.8)
            Text("onboarding.welcome.hero_badge")
                .font(DH.font(.buttonSmall))
                .tracking(0)
                .foregroundStyle(DH.pinkDeep)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
        }
        .rotationEffect(.degrees(6))
        .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 4)
        .accessibilityHidden(true)
    }

    private var headlineBlock: some View {
        VStack(spacing: 10) {
            Text("onboarding.welcome.title")
                .font(DH.font(.display3))
                .tracking(DH.tracking(.display3))
                .foregroundStyle(DH.pinkDeep)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)

            Text("onboarding.welcome.subtitle")
                .font(DH.font(.body))
                .foregroundStyle(DH.ink.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity)
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(DH.pinkDeep)
                .frame(width: 24, height: 8)
                .shadow(color: DH.ink, radius: 0, x: 0, y: 2)

            ForEach(0..<2, id: \.self) { _ in
                Circle()
                    .fill(DH.pinkDeep.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityHidden(true)
    }

    private var ctaBlock: some View {
        VStack(spacing: 10) {
            DHButton(
                title: L10n.string("onboarding.welcome.cta"),
                kind: .primary,
                size: .xl,
                trailingIcon: AnyView(Image(systemName: "arrow.right")),
                isFullWidth: true
            ) {
                coordinator.showParentInfo()
            }
            .accessibilityLabel(L10n.string("onboarding.welcome.cta"))

            Button {
                coordinator.showParentInfo()
            } label: {
                Text("onboarding.welcome.account_link")
                    .font(DH.font(.buttonSmall))
                    .tracking(0.06 * DH.TypeStyle.buttonSmall.size)
                    .foregroundStyle(DH.pinkDeep)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.string("onboarding.welcome.account_link_accessibility"))
        }
    }
}

private struct ScallopTrim: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        var currentX = rect.minX
        while currentX < rect.maxX {
            path.addQuadCurve(
                to: CGPoint(x: min(currentX + 24, rect.maxX), y: rect.maxY),
                control: CGPoint(x: currentX + 12, y: rect.minY)
            )
            currentX += 24
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct FaceMock: View {
    var body: some View {
        ZStack {
            hair

            Ellipse()
                .fill(Color(hex: 0xFFD4B8))
                .frame(width: 188, height: 218)
                .overlay {
                    faceDetails
                }
                .offset(y: 18)

            HStack(spacing: 82) {
                Circle().fill(DH.pink.opacity(0.42))
                Circle().fill(DH.pink.opacity(0.42))
            }
            .frame(width: 168, height: 30)
            .offset(y: 56)
        }
        .accessibilityHidden(true)
    }

    private var hair: some View {
        ZStack {
            Ellipse()
                .fill(DH.pinkDeep.opacity(0.88))
                .frame(width: 218, height: 248)
                .offset(y: 12)

            Ellipse()
                .fill(DH.pinkLight)
                .frame(width: 176, height: 88)
                .rotationEffect(.degrees(-8))
                .offset(x: -18, y: -78)
        }
    }

    private var faceDetails: some View {
        ZStack {
            HStack(spacing: 56) {
                eye
                eye
            }
            .offset(y: -16)

            Capsule()
                .fill(DH.pink)
                .frame(width: 52, height: 16)
                .overlay {
                    Capsule()
                        .fill(DH.pinkPaper)
                        .frame(width: 22, height: 5)
                        .offset(x: 8, y: -2)
                }
                .offset(y: 48)
        }
    }

    private var eye: some View {
        ZStack {
            Capsule()
                .fill(DH.lavender.opacity(0.55))
                .frame(width: 46, height: 18)
                .offset(y: -7)

            Capsule()
                .fill(DH.ink)
                .frame(width: 20, height: 8)
        }
    }
}

#Preview("Welcome") {
    WelcomeView()
        .environment(\.rootCoordinator, RootCoordinator())
}
