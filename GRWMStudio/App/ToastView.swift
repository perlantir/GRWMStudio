import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(DH.font(.bodyEmphasis))
            .tracking(DH.tracking(.bodyEmphasis))
            .foregroundStyle(DH.ink)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                Capsule(style: .continuous)
                    .fill(DH.butter)
                    .chunkyShadow(.sm(deep: DH.butterDeep), shape: Capsule())
            )
            .padding(.horizontal, 18)
    }
}
