import SwiftUI

struct DHChip: View {
    let title: String
    var selected = false
    var leadingIcon: AnyView?
    let action: () -> Void

    init(title: String, selected: Bool = false, leadingIcon: AnyView? = nil, action: @escaping () -> Void) {
        self.title = title
        self.selected = selected
        self.leadingIcon = leadingIcon
        self.action = action
    }

    var body: some View {
        Button {
            DHHaptics.tap()
            action()
        } label: {
            HStack(spacing: 6) {
                if let leadingIcon {
                    leadingIcon
                }

                Text(title)
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.pinkDeep)
            }
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(background)
            .offset(y: selected ? -1 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selected)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var background: some View {
        if selected {
            ZStack {
                Capsule()
                    .fill(DH.pink)
                    .offset(y: 3)
                Capsule()
                    .fill(.white)
            }
            .shadow(color: DH.pink.opacity(0.35), radius: 8, x: 0, y: 4)
        } else {
            Capsule()
                .fill(.white.opacity(0.55))
        }
    }
}

#Preview("DHChip") {
    HStack(spacing: 12) {
        DHChip(title: "Blush", selected: true, leadingIcon: AnyView(Image(systemName: "heart.fill"))) {}
        DHChip(title: "Lips") {}
        DHChip(title: "Eyes") {}
    }
    .padding(24)
    .background(DH.pinkPaper)
}
