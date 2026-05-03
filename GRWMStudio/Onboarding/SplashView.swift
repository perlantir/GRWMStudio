import SwiftUI

struct SplashView: View {
    @Environment(\.rootCoordinator) private var coordinator
    @State private var progress: CGFloat = 0
    @State private var hasAdvanced = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DHWallpaperStripes(stripeWidth: 30, secondaryStripeWidth: 2)
                topSheen(width: geometry.size.width)

                decorativeSparkles(in: geometry.size)
                heroContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 40)
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.light)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("GRWM Studio. Loading.")
        .onAppear(perform: startSplash)
    }

    private var heroContent: some View {
        VStack(spacing: 0) {
            StickerBow(size: 68, fill: DH.pinkLight, strokeWidth: 3)
                .rotationEffect(.degrees(-3))
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 4)
                .stickerBob(amplitude: 3, period: 2.2)
                .padding(.bottom, 14)

            GRWMLogo(layout: .stack, size: .xl)

            Text("Your studio mirror.\nGet ready, but make it sparkle ✨")
                .font(DH.font(.buttonLarge))
                .foregroundStyle(DH.ink.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .frame(maxWidth: 280)
                .padding(.top, 28)

            progressBar
                .padding(.top, 36)

            Text("POLISHING THE MIRROR…")
                .font(DH.font(.caption))
                .tracking(0.24 * 11)
                .foregroundStyle(DH.pinkDeep.opacity(0.6))
                .padding(.top, 8)
        }
    }

    private var progressBar: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.white)
                .frame(width: 120, height: 8)
                .overlay {
                    Capsule()
                        .stroke(DH.pinkDeep.opacity(0.12), lineWidth: 1)
                }
                .shadow(color: DH.pinkLight, radius: 0, x: 0, y: 2)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [DH.pinkLight, DH.pink],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 120 * progress, height: 8)
                .shadow(color: DH.pinkDeep.opacity(0.6), radius: 0, x: 0, y: -2)
        }
        .frame(width: 120, height: 8)
        .clipShape(Capsule())
    }

    @ViewBuilder
    private func decorativeSparkles(in size: CGSize) -> some View {
        StickerSparkle(size: 28, fill: DH.pink)
            .rotationEffect(.degrees(-15))
            .stickerBob()
            .position(x: 44, y: 134)

        StickerSparkle(size: 20, fill: DH.butter)
            .stickerBob(amplitude: 4, period: 1.8)
            .position(x: size.width - 44, y: 190)

        StickerSparkle(size: 22, fill: DH.lavender)
            .rotationEffect(.degrees(20))
            .stickerBob(amplitude: 5, period: 2.4)
            .position(x: 71, y: size.height - 251)

        StickerSparkle(size: 32, fill: DH.pinkLight)
            .stickerBob(amplitude: 4, period: 2.1)
            .position(x: size.width - 56, y: size.height - 176)
    }

    private func topSheen(width: CGFloat) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [.white.opacity(0.6), .clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 340
                )
            )
            .frame(width: width * 1.4, height: 340)
            .position(x: width / 2, y: 0)
    }

    private func startSplash() {
        guard !hasAdvanced else {
            return
        }

        progress = 0
        withAnimation(.linear(duration: 1.5)) {
            progress = 1
        }

        Task {
            try? await Task.sleep(for: .milliseconds(1_800))
            await MainActor.run {
                guard !hasAdvanced else {
                    return
                }

                hasAdvanced = true
                coordinator.advanceFromSplash()
            }
        }
    }
}

#Preview("Splash") {
    SplashView()
        .environment(\.rootCoordinator, RootCoordinator())
}
