import SwiftUI

extension View {
    func settingsCommercePresentation(
        parentGate: Binding<ParentGateIntent?>,
        coordinator: RootCoordinator
    ) -> some View {
        modifier(
            SettingsCommercePresentation(
                parentGate: parentGate,
                coordinator: coordinator
            )
        )
    }
}

private struct SettingsCommercePresentation: ViewModifier {
    @Binding var parentGate: ParentGateIntent?
    @Bindable var coordinator: RootCoordinator
    @State private var paywallSource: RootCoordinator.PaywallSource?

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $parentGate) { intent in
                ParentGateRootView(
                    coordinator: ParentGateCoordinator(
                        intent: intent,
                        onPass: handleParentGatePass,
                        onCancel: { parentGate = nil }
                    )
                )
            }
            .fullScreenCover(item: $paywallSource) { source in
                DHPaywallView(source: source) {
                    paywallSource = nil
                }
            }
    }

    private func handleParentGatePass(_ intent: ParentGateIntent) {
        guard case .paywall(let source) = intent else {
            coordinator.parentGatePassed(intent)
            return
        }

        parentGate = nil
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            paywallSource = source
        }
    }
}
