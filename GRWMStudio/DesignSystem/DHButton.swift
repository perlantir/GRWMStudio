import SwiftUI

struct DHButton: View {
    let title: String
    var kind: Kind = .primary
    var size: Size = .md
    var leadingIcon: AnyView?
    var trailingIcon: AnyView?
    var isFullWidth = false
    let action: () -> Void

    @State private var pressed = false

    init(
        title: String,
        kind: Kind = .primary,
        size: Size = .md,
        leadingIcon: AnyView? = nil,
        trailingIcon: AnyView? = nil,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.kind = kind
        self.size = size
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.isFullWidth = isFullWidth
        self.action = action
    }

    enum Size: CaseIterable {
        case sm
        case md
        case lg
        case xl

        var height: CGFloat {
            switch self {
            case .sm:
                36
            case .md:
                46
            case .lg:
                56
            case .xl:
                64
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .sm:
                14
            case .md:
                18
            case .lg:
                22
            case .xl:
                28
            }
        }

        var fontStyle: DH.TypeStyle {
            switch self {
            case .sm, .md:
                .buttonSmall
            case .lg, .xl:
                .buttonLarge
            }
        }

        var radius: CGFloat {
            height / 2
        }
    }

    enum Kind: CaseIterable {
        case primary
        case white
        case butter
        case lavender
        case ghost

        var background: Color {
            switch self {
            case .primary:
                DH.pink
            case .white:
                .white
            case .butter:
                DH.butter
            case .lavender:
                DH.lavender
            case .ghost:
                .white.opacity(0.55)
            }
        }

        var foreground: Color {
            switch self {
            case .primary, .lavender:
                .white
            case .white, .ghost:
                DH.pinkDeep
            case .butter:
                DH.ink
            }
        }

        var deep: Color {
            switch self {
            case .primary:
                DH.pinkDeep
            case .white:
                DH.pink
            case .butter:
                DH.butterDeep
            case .lavender:
                DH.lavenderDeep
            case .ghost:
                DH.pinkDeep.opacity(0.25)
            }
        }
    }

    var body: some View {
        Button {
            DHHaptics.tapMedium()
            action()
        } label: {
            HStack(spacing: 8) {
                if let leadingIcon {
                    leadingIcon
                }

                Text(title)
                    .font(DH.font(size.fontStyle))
                    .tracking(DH.tracking(size.fontStyle))
                    .foregroundStyle(kind.foreground)

                if let trailingIcon {
                    trailingIcon
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background {
                ZStack {
                    Capsule()
                        .fill(kind.deep)
                        .offset(y: 4)
                    Capsule()
                        .fill(kind.background)
                }
                .shadow(color: kind.deep.opacity(0.35), radius: 14, x: 0, y: 7)
            }
            .scaleEffect(pressed ? 0.97 : 1)
            .offset(y: pressed ? 2 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressed)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}

#Preview("DHButton Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(DHButton.Size.allCases, id: \.self) { size in
                HStack(spacing: 12) {
                    ForEach(DHButton.Kind.allCases, id: \.self) { kind in
                        DHButton(title: previewTitle(for: kind), kind: kind, size: size) {}
                    }
                }
            }

            DHButton(
                title: "FULL WIDTH",
                kind: .primary,
                size: .lg,
                leadingIcon: AnyView(Image(systemName: "sparkles")),
                trailingIcon: AnyView(Image(systemName: "arrow.right")),
                isFullWidth: true
            ) {}
        }
        .padding(24)
    }
    .background(DH.pinkPaper)
}

private func previewTitle(for kind: DHButton.Kind) -> String {
    switch kind {
    case .primary:
        "PINK"
    case .white:
        "WHITE"
    case .butter:
        "BUTTER"
    case .lavender:
        "LAV"
    case .ghost:
        "GHOST"
    }
}
