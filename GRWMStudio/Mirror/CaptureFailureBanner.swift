import SwiftUI

struct CaptureFailureBanner: View {
    let onDismiss: () -> Void

    var body: some View {
        DHCard(bg: DH.butter, deep: DH.butterDeep, cornerRadius: DH.Radius.card, padding: 14) {
            HStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(DH.ink)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(.white.opacity(0.75)))

                VStack(alignment: .leading, spacing: 3) {
                    Text("mirror.capture_failure.title")
                        .font(DH.font(.bodyEmphasis))
                        .tracking(DH.tracking(.bodyEmphasis))
                        .foregroundStyle(DH.ink)

                    Text("mirror.capture_failure.subtitle")
                        .font(DH.font(.caption))
                        .foregroundStyle(DH.ink.opacity(0.68))
                }

                Spacer(minLength: 8)

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(DH.ink)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.white.opacity(0.75)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.string("mirror.capture_failure.dismiss"))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(L10n.string("mirror.capture_failure.announcement"))
        .accessibilityIdentifier("capture-failure-banner")
    }
}
