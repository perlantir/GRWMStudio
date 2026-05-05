import SwiftUI

struct ParentGateRootView: View {
    @State private var coordinator: ParentGateCoordinator

    init(coordinator: ParentGateCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        Group {
            switch coordinator.variant {
            case .math:
                DHParentMathView(coordinator: coordinator)
            case .hold:
                DHParentHoldView(coordinator: coordinator)
            }
        }
        .task {
            Sounds.lockTap.play()
        }
    }
}
