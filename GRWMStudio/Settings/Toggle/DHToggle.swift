import SwiftUI

struct DHToggle: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var isOn: Bool

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? DH.pink : DH.ink.opacity(0.16))
                .chunkyShadow(
                    isOn ? .sm(deep: DH.pinkDeep) : .sm(deep: DH.pinkLight),
                    shape: Capsule()
                )

            Circle()
                .fill(.white)
                .frame(width: 20, height: 20)
                .padding(2)
        }
        .frame(width: 42, height: 26)
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
                isOn.toggle()
            }
            DHHaptics.shared.fire(.tap)
        }
        .accessibilityElement()
        .accessibilityLabel(L10n.string("settings.toggle"))
        .accessibilityValue(isOn ? L10n.string("common.on") : L10n.string("common.off"))
        .accessibilityHint(L10n.string("settings.toggle.hint"))
        .accessibilityAddTraits(.isButton)
    }
}
