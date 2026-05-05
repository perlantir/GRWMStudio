import SwiftUI

struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(DH.ink.opacity(0.58))
                .padding(.horizontal, 6)

            DHCard(bg: .white, deep: DH.pinkLight, cornerRadius: 20, padding: 0) {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }
}
