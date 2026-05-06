import SwiftUI

struct DHPaywallView: View {
    @Environment(\.rootCoordinator) private var coordinator
    let source: RootCoordinator.PaywallSource
    let onDismiss: () -> Void

    @State private var viewModel = PaywallViewModel()
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            backgroundLayer
            sparkleLayer
            VStack(spacing: 0) {
                topBar
                heroBlock
                    .padding(.horizontal, 24)
                    .padding(.top, 26)
                featureList
                    .padding(.horizontal, 18)
                    .padding(.top, 22)
                priceBanner
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                Spacer(minLength: 0)
                ctaBlock
                    .padding(.horizontal, 18)
                    .padding(.bottom, 34)
            }
            if case .error(let message) = viewModel.phase {
                PaywallErrorToast(message: message)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 168)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            if showConfetti {
                ConfettiOverlay()
                    .transition(.opacity)
            }
            if viewModel.phase == .success {
                SuccessSplash()
                    .transition(.opacity)
            }
        }
        .task {
            DHAudio.shared.play(.paywallReveal)
            _ = ProEntitlementsHolder.shared
            await viewModel.loadProducts()
        }
        .onChange(of: viewModel.phase) { _, newValue in
            guard newValue == .success else { return }
            showConfetti = true
            Sounds.fanfare.play()
            DHHaptics.shared.fire(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onDismiss()
            }
        }
    }

    private var backgroundLayer: some View {
        LinearGradient(
            stops: [
                .init(color: DH.pinkDeep, location: 0),
                .init(color: DH.lavenderDeep, location: 0.56),
                .init(color: DH.lavenderDeep, location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var sparkleLayer: some View {
        let positions = [
            SparklePosition(top: 112, leading: 28, size: 16),
            SparklePosition(top: 158, leading: 334, size: 12),
            SparklePosition(top: 220, leading: 64, size: 20),
            SparklePosition(top: 316, leading: 330, size: 15),
            SparklePosition(top: 454, leading: 42, size: 13),
            SparklePosition(top: 548, leading: 334, size: 18),
            SparklePosition(top: 640, leading: 88, size: 14)
        ]

        return ZStack {
            ForEach(Array(positions.enumerated()), id: \.offset) { index, position in
                StickerSparkle(size: position.size, fill: .white)
                    .opacity(index.isMultiple(of: 2) ? 0.52 : 0.34)
                    .rotationEffect(.degrees(Double(index) * 24))
                    .position(x: position.leading, y: position.top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    private var topBar: some View {
        HStack {
            Button {
                DHHaptics.shared.fire(.tap)
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.2), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.string("paywall.close"))
            .accessibilityHint(L10n.string("paywall.close.hint"))

            Spacer()

            Button {
                Task { await viewModel.restore() }
            } label: {
                Text("paywall.restore")
                    .font(DH.font(.microLabel))
                    .tracking(DH.tracking(.microLabel))
                    .foregroundStyle(.white.opacity(0.82))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.phase == .purchasing || viewModel.phase == .restoring)
            .accessibilityLabel(L10n.string("paywall.restore.accessibility_label"))
            .accessibilityHint(L10n.string("paywall.restore.accessibility_hint"))
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
    }

    private var heroBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("paywall.title_prefix")
                .font(DH.font(.display2))
                .tracking(DH.tracking(.display2))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.22), radius: 0, x: 0, y: 4)

            GRWMLogo(layout: .stack, size: .lg)

            Text("paywall.subtitle")
                .font(DH.font(.body))
                .tracking(DH.tracking(.body))
                .foregroundStyle(.white.opacity(0.88))
                .frame(maxWidth: 304, alignment: .leading)

            Text(paywallSubtitle)
                .font(DH.font(.caption))
                .tracking(DH.tracking(.caption))
                .foregroundStyle(.white.opacity(0.74))
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var featureList: some View {
        VStack(spacing: 10) {
            ForEach(features, id: \.title) { feature in
                HStack(spacing: 12) {
                    Text(feature.emoji)
                        .font(.system(size: 20))
                        .frame(width: 38, height: 38)
                        .background(.white.opacity(0.96), in: Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(DH.font(.headline))
                            .tracking(DH.tracking(.headline))
                            .foregroundStyle(.white)

                        Text(feature.subtitle)
                            .font(DH.font(.caption))
                            .tracking(DH.tracking(.caption))
                            .foregroundStyle(.white.opacity(0.76))
                    }

                    Spacer()
                }
            }
        }
        .padding(18)
        .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 2)
        }
    }

    private var priceBanner: some View {
        HStack {
            Spacer(minLength: 0)

            Text("paywall.launch_price")
                .font(DH.font(.caption))
                .tracking(DH.tracking(.caption))
                .foregroundStyle(DH.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(DH.butter, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .chunkyShadow(.sm(deep: DH.butterDeep), shape: RoundedRectangle(cornerRadius: 14))

            Spacer(minLength: 0)
        }
    }

    private var ctaBlock: some View {
        VStack(spacing: 10) {
            Button {
                Task { await viewModel.purchase() }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.phase == .purchasing {
                        DHSpinner(size: 18, lineWidth: 3)
                    }

                    Text(
                        verbatim: viewModel.phase == .purchasing
                            ? L10n.string("paywall.cta.loading")
                            : L10n.format("paywall.cta.price", viewModel.displayPrice)
                    )
                        .font(DH.font(.buttonLarge))
                        .tracking(DH.tracking(.buttonLarge))
                }
                .foregroundStyle(DH.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    LinearGradient(colors: [DH.butter, DH.butterDeep], startPoint: .top, endPoint: .bottom),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
                .chunkyShadow(.lg(deep: DH.butterDeep), shape: RoundedRectangle(cornerRadius: 22))
            }
            .buttonStyle(.plain)
            .disabled(!isCTAEnabled)
            .opacity(isCTAEnabled ? 1 : 0.5)

            Text("paywall.footer")
                .font(DH.font(.caption))
                .tracking(DH.tracking(.caption))
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)

            HStack(spacing: 18) {
                legalLink(
                    title: L10n.string("settings.about.privacy_policy"),
                    url: "https://grwmstudio.app/privacy"
                )
                legalLink(
                    title: L10n.string("settings.about.terms"),
                    url: "https://grwmstudio.app/terms"
                )
            }
            .padding(.top, 4)
        }
    }

    private func legalLink(title: String, url: String) -> some View {
        Button(title) {
            guard let destination = URL(string: url) else {
                return
            }
            coordinator.startParentGate(intent: .privacyDeepLink(destination))
        }
        .buttonStyle(.plain)
        .font(DH.font(.caption))
        .tracking(DH.tracking(.caption))
        .foregroundStyle(.white.opacity(0.86))
        .underline()
    }
}

private extension DHPaywallView {
    var paywallSubtitle: String {
        switch source {
        case .proShade:
            L10n.string("paywall.source.pro_shade")
        case .lockerLimit:
            L10n.string("paywall.source.locker_limit")
        case .longRecording:
            L10n.string("paywall.source.long_recording")
        case .settings:
            L10n.string("paywall.source.settings")
        }
    }

    var isCTAEnabled: Bool {
        switch viewModel.phase {
        case .ready, .error:
            true
        default:
            false
        }
    }

    var features: [FeatureRow] {
        [
            FeatureRow(
                emoji: "💄",
                title: L10n.string("paywall.feature.shades.title"),
                subtitle: L10n.string("paywall.feature.shades.subtitle")
            ),
            FeatureRow(
                emoji: "✨",
                title: L10n.string("paywall.feature.looks.title"),
                subtitle: L10n.string("paywall.feature.looks.subtitle")
            ),
            FeatureRow(
                emoji: "💼",
                title: L10n.string("paywall.feature.locker.title"),
                subtitle: L10n.string("paywall.feature.locker.subtitle")
            ),
            FeatureRow(
                emoji: "🎬",
                title: L10n.string("paywall.feature.video.title"),
                subtitle: L10n.string("paywall.feature.video.subtitle")
            ),
            FeatureRow(
                emoji: "🚫",
                title: L10n.string("paywall.feature.ads.title"),
                subtitle: L10n.string("paywall.feature.ads.subtitle")
            )
        ]
    }
}

private struct SparklePosition {
    let top: CGFloat
    let leading: CGFloat
    let size: CGFloat
}

private struct FeatureRow {
    let emoji: String
    let title: String
    let subtitle: String
}

private struct PaywallErrorToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(DH.font(.caption))
            .tracking(DH.tracking(.caption))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(DH.recRedDeep, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: DH.recRedDeep.opacity(0.4), radius: 18, x: 0, y: 8)
    }
}

private struct ConfettiOverlay: View {
    var body: some View {
        ZStack {
            ForEach(0 ..< 12, id: \.self) { index in
                Text(index.isMultiple(of: 2) ? "✨" : "🎉")
                    .font(.system(size: index.isMultiple(of: 3) ? 26 : 20))
                    .rotationEffect(.degrees(Double(index * 13)))
                    .position(x: CGFloat(28 + (index * 28)), y: CGFloat(90 + (index % 4) * 72))
                    .opacity(0.85)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}

private struct SuccessSplash: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Text("✨🎉✨")
                    .font(.system(size: 60))

                Text("paywall.success.title")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 28)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.24), lineWidth: 2)
            }
        }
    }
}
