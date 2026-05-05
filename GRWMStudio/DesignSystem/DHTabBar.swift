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
            L10n.string("tab.mirror")
        case .looks:
            L10n.string("tab.looks")
        case .fab:
            ""
        case .feed:
            L10n.string("tab.feed")
        case .locker:
            L10n.string("tab.locker")
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .caption) private var barHeight = 74
    @ScaledMetric(relativeTo: .caption) private var tabHeight = 58
    @ScaledMetric(relativeTo: .caption) private var fabSize = 70
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
        .frame(height: effectiveBarHeight)
        .background {
            Capsule()
                .fill(.white)
                .chunkyShadow(.lg(deep: DH.pinkDeep), shape: Capsule())
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isTabBar)
    }

    private func tabButton(_ tab: DHTab) -> some View {
        Button {
            DHHaptics.shared.fire(.tap)
            selected = tab
        } label: {
            VStack(spacing: isAccessibilityLayout ? 4 : 2) {
                Image(systemName: tab.iconSystemName)
                    .font(.system(size: isAccessibilityLayout ? 20 : 22, weight: .bold))
                    .frame(width: 24, height: 24)

                Text(tab.title)
                    .font(DH.font(.microLabel))
                    .tracking(isAccessibilityLayout ? 0 : 0.04 * DH.TypeStyle.microLabel.size)
                    .lineLimit(isAccessibilityLayout ? 1 : 2)
                    .minimumScaleFactor(isAccessibilityLayout ? 0.55 : 0.85)
                    .multilineTextAlignment(.center)

                Circle()
                    .fill(selected == tab ? DH.pink : .clear)
                    .frame(width: 6, height: 6)
            }
            .foregroundStyle(selected == tab ? DH.pinkDeep : DH.pinkDeep.opacity(0.55))
            .frame(maxWidth: .infinity)
            .frame(height: effectiveTabHeight)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(tab.title)
        .accessibilityValue(selected == tab ? L10n.string("common.selected") : L10n.string("common.not_selected"))
        .accessibilityHint(L10n.format("tab.accessibility_hint", tab.title))
        .accessibilityIdentifier("tab-\(tab.rawValue)")
        .accessibilityAddTraits(selected == tab ? .isSelected : [])
    }

    @ViewBuilder
    private var centerSlot: some View {
        if let centerContent {
            centerContent()
                .offset(y: centerContentLift)
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
            DHHaptics.shared.fire(.pop)
            onFABTap()
        } label: {
            Image(systemName: DHTab.fab.iconSystemName)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: effectiveFABSize, height: effectiveFABSize)
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
        .offset(y: fabLift)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(L10n.string("tab.create"))
        .accessibilityHint(L10n.string("tab.create.hint"))
    }

    private var isAccessibilityLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var effectiveBarHeight: CGFloat {
        min(barHeight, isAccessibilityLayout ? 82 : 74)
    }

    private var effectiveTabHeight: CGFloat {
        min(tabHeight, isAccessibilityLayout ? 62 : 58)
    }

    private var effectiveFABSize: CGFloat {
        min(fabSize, isAccessibilityLayout ? 64 : 70)
    }

    private var centerContentLift: CGFloat {
        isAccessibilityLayout ? -22 : -34
    }

    private var fabLift: CGFloat {
        isAccessibilityLayout ? -16 : -22
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
