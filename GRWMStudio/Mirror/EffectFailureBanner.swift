import SwiftUI

struct EffectFailureBanner: View {
    let onRetry: () -> Void
    let onDismiss: () -> Void

    @State private var dismissTask: Task<Void, Never>?

    var body: some View {
        DHCard(bg: DH.mint, deep: DH.mintDeep, cornerRadius: DH.Radius.card, padding: 12) {
            HStack(spacing: 10) {
                StickerSparkle(size: 22, fill: DH.mintDeep, stroke: .white, strokeWidth: 2)

                VStack(alignment: .leading, spacing: 2) {
                    Text("mirror.effect_failure.title")
                        .font(DH.font(.bodyEmphasis))
                        .foregroundStyle(DH.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text("mirror.effect_failure.subtitle")
                        .font(DH.font(.body))
                        .foregroundStyle(DH.ink.opacity(0.72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                DHButton(title: L10n.string("mirror.effect_failure.cta"), kind: .ghost, size: .sm, action: retry)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(2)
            }
        }
        .padding(.horizontal, DH.Spacing.hPad)
        .contentShape(RoundedRectangle(cornerRadius: DH.Radius.card))
        .onTapGesture(perform: retry)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.string("mirror.effect_failure.announcement"))
        .onAppear {
            dismissTask?.cancel()
            dismissTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(4))
                guard !Task.isCancelled else {
                    return
                }
                onDismiss()
            }
        }
        .onDisappear {
            dismissTask?.cancel()
            dismissTask = nil
        }
    }

    private func retry() {
        dismissTask?.cancel()
        onRetry()
    }
}

#Preview("Effect Failure Banner") {
    ZStack {
        DHWallpaperGradient()
        VStack {
            EffectFailureBanner {} onDismiss: {}
            Spacer()
        }
        .padding(.top, 80)
    }
}
