import SwiftUI

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconBackground: Color
    let title: String
    let subtitle: String?
    let trailing: Trailing
    let onTap: (() -> Void)?

    init(
        icon: String,
        iconBackground: Color,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
        onTap: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconBackground = iconBackground
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
        self.onTap = onTap
    }

    var body: some View {
        Group {
            if let onTap {
                Button {
                    DHHaptics.shared.fire(.tap)
                    onTap()
                } label: {
                    rowContent
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityLabel)
                .accessibilityHint(accessibilityHint)
            } else {
                rowContent
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            iconBubble

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(DH.font(.buttonLarge))
                    .tracking(DH.tracking(.buttonLarge))
                    .foregroundStyle(DH.ink)

                if let subtitle {
                    Text(subtitle)
                        .font(DH.font(.body))
                        .tracking(DH.tracking(.body))
                        .foregroundStyle(DH.ink.opacity(0.6))
                }
            }

            Spacer(minLength: 0)
            trailing
        }
        .contentShape(Rectangle())
    }

    private var accessibilityLabel: String {
        if let subtitle, !subtitle.isEmpty {
            return "\(title). \(subtitle)"
        }

        return title
    }

    private var accessibilityHint: String {
        guard onTap != nil else {
            return ""
        }

        return L10n.format("settings.row.accessibility_hint", title.lowercased())
    }

    private var iconBubble: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(iconBackground)
            .frame(width: 38, height: 38)
            .overlay {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(iconForeground)
            }
            .chunkyShadow(.sm(deep: iconShadowColor), shape: RoundedRectangle(cornerRadius: 12))
            .accessibilityHidden(true)
    }

    private var iconForeground: Color {
        iconBackground == DH.butter || iconBackground == DH.mint ? DH.ink : .white
    }

    private var iconShadowColor: Color {
        if iconBackground == DH.butter {
            return DH.butterDeep
        }
        if iconBackground == DH.lavender {
            return DH.lavenderDeep
        }
        if iconBackground == DH.mint {
            return DH.mintDeep
        }
        return DH.pinkDeep
    }
}
