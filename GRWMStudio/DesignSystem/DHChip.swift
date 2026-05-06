import SwiftUI

struct DHChip: View {
    @ScaledMetric(relativeTo: .body) private var chipHeight = 34
    @ScaledMetric(relativeTo: .body) private var horizontalPadding = 14
    let title: String
    var selected = false
    var leadingIcon: AnyView?
    var accessibilityCategory: String?
    var accessibilityHintText: String?
    let action: () -> Void

    init(
        title: String,
        selected: Bool = false,
        leadingIcon: AnyView? = nil,
        accessibilityCategory: String? = nil,
        accessibilityHintText: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.selected = selected
        self.leadingIcon = leadingIcon
        self.accessibilityCategory = accessibilityCategory
        self.accessibilityHintText = accessibilityHintText
        self.action = action
    }

    var body: some View {
        Button {
            DHAudio.shared.play(.tapHard)
            DHHaptics.shared.fire(.pop)
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
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .padding(.horizontal, horizontalPadding)
            .frame(height: chipHeight)
            .background(background)
            .offset(y: selected ? -1 : 0)
            .dhAnimation(.quickPop, value: selected)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(selected ? "Selected" : "Not selected")
        .accessibilityHint(accessibilityHintText ?? "Double-tap to choose this option.")
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : [.isButton])
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

    private var accessibilityLabel: String {
        guard let accessibilityCategory, !accessibilityCategory.isEmpty else {
            return title
        }

        return "\(title), \(accessibilityCategory)"
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
