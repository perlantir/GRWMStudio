import SwiftUI

private struct AppShellSelectorKey: EnvironmentKey {
    static let defaultValue: @MainActor (DHTab) -> Void = { _ in }
}

extension EnvironmentValues {
    var appShellSelector: @MainActor (DHTab) -> Void {
        get { self[AppShellSelectorKey.self] }
        set { self[AppShellSelectorKey.self] = newValue }
    }
}
