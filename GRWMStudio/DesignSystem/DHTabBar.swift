import SwiftUI

enum DHTab: String, CaseIterable, Hashable, Identifiable {
    case mirror
    case looks
    case fab
    case feed
    case locker

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .mirror:
            "Mirror"
        case .looks:
            "Looks"
        case .fab:
            ""
        case .feed:
            "Feed"
        case .locker:
            "Locker"
        }
    }

    var iconSystemName: String {
        switch self {
        case .mirror:
            "rectangle.portrait"
        case .looks:
            "circle.circle"
        case .fab:
            "plus"
        case .feed:
            "heart"
        case .locker:
            "person.crop.circle"
        }
    }
}

struct DHTabBar: View {
    @Binding var selected: DHTab
    let onFABTap: () -> Void
    private let showsDefaultFAB: Bool
    private let centerContent: (() -> AnyView)?

    init(selected: Binding<DHTab>, onFABTap: @escaping () -> Void, showsDefaultFAB: Bool = true) {
        self._selected = selected
        self.onFABTap = onFABTap
        self.showsDefaultFAB = showsDefaultFAB
        self.centerContent = nil
    }

    init<CenterContent: View>(
        selected: Binding<DHTab>,
        onFABTap: @escaping () -> Void,
        @ViewBuilder centerContent: @escaping () -> CenterContent
    ) {
        self._selected = selected
        self.onFABTap = onFABTap
        self.showsDefaultFAB = true
        self.centerContent = { AnyView(centerContent()) }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            tabButton(.mirror)
            tabButton(.looks)
            centerSlot
            tabButton(.feed)
            tabButton(.locker)
        }
        .padding(.horizontal, 18)
        .frame(height: 74)
        .background {
            Capsule()
                .fill(.white)
                .chunkyShadow(.lg(deep: DH.pinkDeep), shape: Capsule())
        }
    }

    private func tabButton(_ tab: DHTab) -> some View {
        Button {
            DHHaptics.tap()
            selected = tab
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.iconSystemName)
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 24, height: 24)

                Text(tab.title)
                    .font(DH.font(.microLabel))
                    .tracking(0.04 * DH.TypeStyle.microLabel.size)

                Circle()
                    .fill(selected == tab ? DH.pink : .clear)
                    .frame(width: 6, height: 6)
            }
            .foregroundStyle(selected == tab ? DH.pinkDeep : DH.pinkDeep.opacity(0.55))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(selected == tab ? .isSelected : [])
    }

    @ViewBuilder
    private var centerSlot: some View {
        if let centerContent {
            centerContent()
                .offset(y: -34)
                .frame(maxWidth: .infinity)
        } else if showsDefaultFAB {
            fabButton
        } else {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .accessibilityHidden(true)
        }
    }

    private var fabButton: some View {
        Button {
            DHHaptics.tapMedium()
            onFABTap()
        } label: {
            Image(systemName: DHTab.fab.iconSystemName)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 70, height: 70)
                .background {
                    Circle()
                        .fill(DH.pink)
                        .overlay {
                            Circle()
                                .stroke(.white, lineWidth: 5)
                        }
                        .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 5)
                        .shadow(color: DH.pinkDeep.opacity(0.5), radius: 22, x: 0, y: 10)
                }
        }
        .buttonStyle(.plain)
        .offset(y: -22)
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Create")
    }
}

#Preview("DHTabBar") {
    @Previewable @State var selected: DHTab = .mirror

    ZStack(alignment: .bottom) {
        DHWallpaperGradient()
        DHTabBar(selected: $selected) {}
            .padding(.horizontal, 14)
            .padding(.bottom, 18)
    }
}
