import SwiftUI

struct LookSwitchConfirmationView: View {
    let lookName: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        DHCard(bg: .white, deep: DH.pink, cornerRadius: DH.Radius.card, padding: 12) {
            HStack(spacing: 8) {
                Text("Switch out of \(lookName)?")
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                Spacer(minLength: 0)

                chipButton("Yes, mix it", fill: DH.pinkDeep, foreground: .white, action: onConfirm)
                chipButton("Stay in look", fill: DH.cream, foreground: DH.ink, action: onCancel)
            }
        }
        .padding(.horizontal, 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Switch out of \(lookName)?")
    }

    private func chipButton(_ title: String, fill: Color, foreground: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(foreground)
                .frame(height: 28)
                .padding(.horizontal, 10)
                .background(Capsule().fill(fill))
        }
        .buttonStyle(.plain)
    }
}
